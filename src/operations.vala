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
            try {
                uint8[] contents ;
                var fileopen = File.new_for_path (path) ;
                var manager = new Gtk.SourceLanguageManager () ;
                // mime type and source language
                FileInfo info = fileopen.query_info ("standard::*", 0, null) ;
                string content = info.get_content_type () ;
                string mime = GLib.ContentType.get_mime_type (content) ;
                Gtk.SourceLanguage lang = manager.guess_language (path, mime) ;
                var tabs = new iZiCodeEditor.Tabs () ;
                var view = tabs.get_current_sourceview () ;
                var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
                buffer.set_language (lang) ;
                // load file content
                fileopen.load_contents (null, out contents, null) ;
                buffer.begin_not_undoable_action () ;
                buffer.set_text ((string) contents, -1) ;
                buffer.end_not_undoable_action () ;
                buffer.set_modified (false) ;
                // place cursor on start
                Gtk.TextIter iter_st ;
                buffer.get_start_iter (out iter_st) ;
                buffer.place_cursor (iter_st) ;
                view.scroll_to_iter (iter_st, 0.10, false, 0, 0) ;
                view.grab_focus () ;
            } catch ( Error e ){
                stderr.printf ("error: %s\n", e.message) ;
            }
        }

        // method for saving files
        public void save_from_buffer(string filename, Gtk.SourceBuffer bf) {
            var file = File.new_for_path (filename) ;
            try {
                file.replace_contents (bf.text.data, null, false, 0, null, null) ;
                bf.set_modified (false) ;
                // print ("debug saved: %s\n", filename) ;
            } catch ( Error e ){
                var dialogs = new iZiCodeEditor.Dialogs () ;
                dialogs.save_fallback (filename) ;
                stderr.printf ("error: %s\n", e.message) ;
            }
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
