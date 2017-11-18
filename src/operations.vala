namespace iZiCodeEditor{
    public class Operations : GLib.Object {
        public unowned ApplicationWindow window { get ; construct set ; }

        private int FONT_SIZE_MAX = 72 ;
        private int FONT_SIZE_MIN = 7 ;

        public Operations (iZiCodeEditor.ApplicationWindow window) {
            Object (
                window: window) ;
        }

        public void add_recent_files() {
            string[] recent_files = Application.saved_state.get_strv ("recent-files") ;
            if( recent_files.length > 0 ){
                for( int i = 0 ; i < recent_files.length ; i++ ){
                    var one = GLib.File.new_for_path (recent_files[i]) ;
                    if( one.query_exists () == true ){
                        window.notebook.create_tab (recent_files[i]) ;
                        open_file.begin (recent_files[i]) ;
                    }
                }
                window.notebook.set_current_page ((int) Application.saved_state.get_uint ("active-tab")) ;
            }
        }

        public async bool open_file(string path) {

            var fileopen = File.new_for_path (path) ;
            var manager = new Gtk.SourceLanguageManager () ;
            var lang = manager.guess_language (fileopen.get_path (), null) ;
            var view = window.tabs.get_current_sourceview () ;
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
                if( Application.settings_view.get_boolean ("status-bar"))
                    window.status_bar.status_messages ("error: " + e.message) ;
                return false ;
            }
            buffer.set_modified (false) ;

            view.grab_focus () ;

            return true ;
        }

        // method for saving files
        public void save_from_buffer(string filename, Gtk.SourceBuffer bf) {
            var file = File.new_for_path (filename) ;
            try {
                file.replace_contents (bf.text.data, null, false, 0, null, null) ;
                bf.set_modified (false) ;
                if( Application.settings_view.get_boolean ("status-bar"))
                    window.status_bar.status_messages ("saving " + filename + " ...") ;
            } catch ( Error e ){
                window.dialogs.save_fallback (filename) ;
                stderr.printf ("error: %s\n", e.message) ;
                if( Application.settings_view.get_boolean ("status-bar"))
                    window.status_bar.status_messages ("error: " + e.message) ;
            }
        }

        // current file
        public void save_current() {
            var view = window.tabs.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            string cf = window.files.nth_data (window.notebook.get_current_page ()) ;
            if( cf == "Untitled" ){
                window.dialogs.show_save () ;
            } else {
                save_from_buffer (cf, buffer) ;
            }
            view.grab_focus () ;
        }

        // save file with new name
        public void save_file_as(string path) {
            string cf = window.files.nth_data (window.notebook.get_current_page ()) ;
            var view = window.tabs.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            // check whether current name is same as path
            if( cf == path ){
                save_current () ;
                return ;
            }
            save_from_buffer (path, buffer) ;
            view.grab_focus () ;
            // remove current tab before creating new
            window.tabs.check_notebook_for_file_name (path) ;
            window.tabs.check_notebook_for_file_name (cf) ;
            window.notebook.create_tab (path) ;
            open_file.begin (path) ;
        }

        // save file with given notebook tab position
        public void save_file_at_pos(int pos) {
            var view = window.tabs.get_sourceview_at_tab (pos) ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            string path = window.files.nth_data (pos) ;
            if( path == "Untitled" ){
                window.notebook.set_current_page (pos) ;
                window.dialogs.show_save () ;
            } else {
                save_from_buffer (path, buffer) ;
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
                var view = window.tabs.get_sourceview_at_tab (i) ;
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
