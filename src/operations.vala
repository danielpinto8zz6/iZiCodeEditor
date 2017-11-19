namespace iZiCodeEditor{
    public class Operations : GLib.Object {
        public unowned ApplicationWindow window { get ; construct set ; }

        private int FONT_SIZE_MAX = 72 ;
        private int FONT_SIZE_MIN = 7 ;

        public Operations (iZiCodeEditor.ApplicationWindow window) {
            Object (
                window: window) ;
        }

        public void open(string path) {
            for( int i = 0 ; i < window.files.length () ; i++ ){
                if( window.files.nth_data (i) == path ){
                    window.notebook.set_current_page (i) ;
                    stderr.printf ("This file is already loaded: %s\n", path) ;
                    return ;
                }
            }
            window.notebook.create_tab (path) ;
            open_file.begin (path) ;
        }

        public void add_recent_files() {
            string[] recent_files = Application.saved_state.get_strv ("recent-files") ;
            if( recent_files.length > 0 ){
                for( int i = 0 ; i < recent_files.length ; i++ ){
                    var one = GLib.File.new_for_path (recent_files[i]) ;
                    if( one.query_exists () == true ){
                        open (recent_files[i]) ;
                    }
                }
                window.notebook.set_current_page ((int) Application.saved_state.get_uint ("active-tab")) ;
            }
        }

        private string mime_type(File file) {
            string mime_type = "" ;
            try {
                var info = file.query_info ("standard::*", FileQueryInfoFlags.NONE, null) ;
                var content_type = info.get_content_type () ;
                mime_type = ContentType.get_mime_type (content_type) ;
            } catch ( Error e ){
                debug (e.message) ;
            }
            return mime_type ;
        }

        public async bool open_file(string path) {
            var fileopen = File.new_for_path (path) ;
            var manager = new Gtk.SourceLanguageManager () ;

            var lang = manager.guess_language (fileopen.get_path (), mime_type (fileopen)) ;
            var view = window.notebook.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            if( lang != null ){
                buffer.set_language (lang) ;
                buffer.set_highlight_syntax (true) ;
            } else {
                buffer.set_highlight_syntax (false) ;
            }
            var file = new Gtk.SourceFile () ;
            file.location = fileopen ;

            try {
                var source_file_loader = new Gtk.SourceFileLoader (buffer, file) ;

                yield source_file_loader.load_async(GLib.Priority.DEFAULT, null, null) ;

            } catch ( Error e ){
                stderr.printf ("error: %s\n", e.message) ;
                return false ;
            }
            buffer.set_modified (false) ;

            // place cursor on start
            Gtk.TextIter iter_st ;
            buffer.get_start_iter (out iter_st) ;
            buffer.place_cursor (iter_st) ;
            view.scroll_to_iter (iter_st, 0.10, false, 0, 0) ;

            view.grab_focus () ;

            return true ;
        }

        public async bool save(string filename, Gtk.SourceBuffer buffer) {
            var filesave = File.new_for_path (filename) ;
            var file = new Gtk.SourceFile () ;
            file.location = filesave ;

            try {
                var source_file_saver = new Gtk.SourceFileSaver (buffer, file) ;

                yield source_file_saver.save_async(GLib.Priority.DEFAULT, null, null) ;

            } catch ( Error e ){
                window.dialogs.save_fallback (filename) ;
                stderr.printf ("error: %s\n", e.message) ;
                return false ;
            }
            buffer.set_modified (false) ;

            return true ;
        }

        // current file
        public void save_current() {
            if( window.notebook.get_n_pages () == 0 ){
                return ;
            }
            var view = window.notebook.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            string path = window.files.nth_data (window.notebook.get_current_page ()) ;
            if( path == "Untitled" ){
                window.dialogs.show_save () ;
            } else {
                save.begin (path, buffer) ;
            }
            view.grab_focus () ;
        }

        // save file with new name
        public async bool save_as(string newpath) {
            string oldpath = window.files.nth_data (window.notebook.get_current_page ()) ;
            var view = window.notebook.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            // check whether current name is same as path
            if( oldpath == newpath ){
                save_current () ;
                return false ;
            }
            var is_saved = yield save(newpath, buffer) ;

            if( is_saved )
                update_tab (oldpath, newpath) ;

            return is_saved ;
        }

        public void update_tab(string oldpath, string newpath) {
            unowned List<string> del_item = window.files.find_custom (oldpath, strcmp) ;
            window.files.remove_link (del_item) ;
            window.notebook.remove_page (window.notebook.get_current_page ()) ;

            open (newpath) ;
        }

        // save file with given notebook tab position
        public void save_file_at_pos(int pos) {
            var view = window.notebook.get_sourceview_at_tab (pos) ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            string path = window.files.nth_data (pos) ;
            if( path == "Untitled" ){
                window.notebook.set_current_page (pos) ;
                window.dialogs.show_save () ;
            } else {
                save.begin (path, buffer) ;
            }
            view.grab_focus () ;
        }

        // save all files
        public void save_all() {
            int i ;
            for( i = (int) window.files.length () - 1 ; i >= 0 ; i-- ){
                save_file_at_pos (i) ;
            }
        }

        // wrap text toggle
        public void wrap_text() {
            for( int i = 0 ; i < window.files.length () ; i++ ){
                var view = window.notebook.get_sourceview_at_tab (i) ;
                if( view.get_wrap_mode () == Gtk.WrapMode.WORD ){
                    view.set_wrap_mode (Gtk.WrapMode.NONE) ;
                } else {
                    view.set_wrap_mode (Gtk.WrapMode.WORD) ;
                }
            }
        }

        public void zooming(Gdk.ScrollDirection direction) {
            string font = get_current_font () ;
            int font_size = (int) get_current_font_size () ;

            if( direction == Gdk.ScrollDirection.DOWN ){
                font_size-- ;
                if( font_size < FONT_SIZE_MIN ){
                    return ;
                }
            } else if( direction == Gdk.ScrollDirection.UP ){
                font_size++ ;
                if( font_size > FONT_SIZE_MAX ){
                    return ;
                }
            }

            string new_font = font + " " + font_size.to_string () ;
            Application.settings_fonts_colors.set_string ("font", new_font) ;
        }

        private string get_current_font() {
            string font = Application.settings_fonts_colors.get_string ("font") ;
            string font_family = font.substring (0, font.last_index_of (" ")) ;
            return font_family ;
        }

        private double get_current_font_size() {
            string font = Application.settings_fonts_colors.get_string ("font") ;
            string font_size = font.substring (font.last_index_of (" ") + 1) ;
            return double.parse (font_size) ;
        }

        public string get_default_font() {
            string font = Application.settings_fonts_colors.get_string ("font") ;
            string font_family = font.substring (0, font.last_index_of (" ")) ;
            return font_family ;
        }

    }
}
