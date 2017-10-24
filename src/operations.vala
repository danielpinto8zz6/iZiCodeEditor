namespace iZiCodeEditor{
    public class Operations : GLib.Object {
        public void add_recent_files() {
            string[] recent_files = Application.saved_state.get_strv ("recent-files") ;
            if( recent_files.length > 0 ){
                for( int i = 0 ; i < recent_files.length ; i++ ){
                    var one = GLib.File.new_for_path (recent_files[i]) ;
                    if( one.query_exists () == true ){
                        var nbook = new iZiCodeEditor.NBook () ;
                        var operations = new iZiCodeEditor.Operations () ;
                        nbook.create_tab (recent_files[i]) ;
                        operations.open_file (recent_files[i]) ;
                    }
                }
                notebook.set_current_page ((int) Application.saved_state.get_uint ("active-tab")) ;
            }
        }

        public void open_file(string path) {

            var fileopen = File.new_for_path (path) ;
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;

            set_language (path, buffer) ;

            var file = new Gtk.SourceFile () ;
            file.location = fileopen ;

            var source_file_loader = new Gtk.SourceFileLoader (buffer, file) ;

            var load_cancellable = new GLib.Cancellable () ;

            source_file_loader.load_async.begin (GLib.Priority.DEFAULT, load_cancellable, null) ;

            buffer.set_modified (false) ;

            view.grab_focus () ;
        }

        public void set_language(string path, Gtk.SourceBuffer buffer) {
            var manager = new Gtk.SourceLanguageManager () ;
            var lang = manager.guess_language (path, null) ;

            if( lang != null ){
                buffer.set_language (lang) ;
                buffer.set_highlight_syntax (true) ;
            } else {
                buffer.set_highlight_syntax (false) ;
            }
        }

        // method for saving files
        public void save_from_buffer(string filename, Gtk.SourceBuffer bf) {
            var filesave = File.new_for_path (filename) ;
            var file = new Gtk.SourceFile () ;
            file.location = filesave ;

            var save_cancellable = new GLib.Cancellable () ;
            var source_file_saver = new Gtk.SourceFileSaver (bf, file) ;

            source_file_saver.save_async.begin (GLib.Priority.DEFAULT, save_cancellable, null) ;

            save_cancellable.cancelled.connect (() => {
                var dialogs = new iZiCodeEditor.Dialogs () ;
                dialogs.save_fallback (filename) ;
            }) ;

            bf.set_modified (false) ;
        }

        // current file
        public void save_current() {
            if( notebook.get_n_pages () == 0 ){
                return ;
            }
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            string cf = tabs.get_current_path () ;
            if( cf == "Untitled" ){
                var dialogs = new iZiCodeEditor.Dialogs () ;
                dialogs.show_save () ;
            } else {
                save_from_buffer (cf, buffer) ;
            }
            view.grab_focus () ;
        }

        // save file with new name
        public void save_file_as(string path) {
            var tabs = new iZiCodeEditor.Tabs () ;
            string cf = tabs.get_current_path () ;
            var view = tabs.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            // check whether current name is same as path
            if( cf == path ){
                save_current () ;
                return ;
            }
            save_from_buffer (path, buffer) ;
            view.grab_focus () ;
            // remove current tab before creating new
            tabs.check_notebook_for_file_name (path) ;
            tabs.check_notebook_for_file_name (cf) ;
            var nbook = new iZiCodeEditor.NBook () ;
            nbook.create_tab (path) ;
            open_file (path) ;
        }

        // save file with given notebook tab position
        public void save_file_at_pos(int pos) {
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_sourceview_at_tab (pos) ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            string path = tabs.get_path_at_tab (pos) ;
            if( path == "Untitled" ){
                var dialogs = new iZiCodeEditor.Dialogs () ;
                notebook.set_current_page (pos) ;
                dialogs.show_save () ;
            } else {
                save_from_buffer (path, buffer) ;
            }
            view.grab_focus () ;
        }

        // save all files
        public void save_all() {
            int i ;
            for( i = (int) files.length () - 1 ; i >= 0 ; i-- ){
                save_file_at_pos (i) ;
            }
        }

        // wrap text toggle
        public void wrap_text() {
            for( int i = 0 ; i < files.length () ; i++ ){
                var tabs = new iZiCodeEditor.Tabs () ;
                var view = tabs.get_sourceview_at_tab (i) ;
                if( view.get_wrap_mode () == Gtk.WrapMode.WORD ){
                    view.set_wrap_mode (Gtk.WrapMode.NONE) ;
                } else {
                    view.set_wrap_mode (Gtk.WrapMode.WORD) ;
                }
            }
        }

        // close tab
        public void close_tab() {
            if( notebook.get_n_pages () == 0 ){
                return ;
            }
            var tabs = new iZiCodeEditor.Tabs () ;
            var tab_page = (Gtk.Grid)notebook.get_nth_page (
                notebook.get_current_page ()) ;
            string path = tabs.get_current_path () ;
            var nbook = new iZiCodeEditor.NBook () ;
            nbook.destroy_tab (tab_page, path) ;
        }

        // close all tab
        public void close_all_tabs() {
            for( uint i = files.length () ; i > 0 ; i-- ){
                var tabs = new iZiCodeEditor.Tabs () ;
                var tab_page = (Gtk.Grid)notebook.get_nth_page (
                    notebook.get_current_page ()) ;
                string path = tabs.get_current_path () ;
                var nbook = new iZiCodeEditor.NBook () ;
                nbook.destroy_tab (tab_page, path) ;
            }
        }

        // undo last
        public void undo_last() {
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_current_sourceview () ;
            view.undo () ;
        }

        // redo last
        public void redo_last() {
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_current_sourceview () ;
            view.redo () ;
        }

    }
}
