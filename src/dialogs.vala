namespace iZiCodeEditor{
    public class Dialogs : GLib.Object {
        public unowned ApplicationWindow window { get ; construct set ; }

        public Dialogs (iZiCodeEditor.ApplicationWindow window) {
            this.window = window ;
        }

        public void show_open() {
            string selected ;
            var chooser = new Gtk.FileChooserDialog (
                "Select a file to edit", window, Gtk.FileChooserAction.OPEN,
                "_Cancel",
                Gtk.ResponseType.CANCEL,
                "_Open",
                Gtk.ResponseType.ACCEPT) ;
            if( window.notebook.get_n_pages () > 0 ){
                string cf = files.nth_data (window.notebook.get_current_page ()) ;
                chooser.set_current_folder (Path.get_dirname (cf)) ;
            }
            var filter = new Gtk.FileFilter () ;
            filter.add_mime_type ("text/plain") ;

            chooser.set_select_multiple (false) ;
            chooser.set_modal (true) ;
            chooser.set_filter (filter) ;
            chooser.show () ;
            if( chooser.run () == Gtk.ResponseType.ACCEPT ){
                selected = chooser.get_filename () ;
                string path = files.nth_data (window.notebook.get_current_page ()) ;
                var view = window.tabs.get_sourceview_at_tab (window.notebook.get_current_page ()) ;
                var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
                if( buffer.get_modified () == false && path == "Untitled" ){
                    window.operations.close_tab () ;
                }
                window.notebook.create_tab (selected) ;
                window.operations.open_file (selected) ;
            }
            chooser.destroy () ;
        }

        public void changes_one(int num, string path) {
            var dialog = new Gtk.MessageDialog (window,
                                                Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE,
                                                "The file '%s' is not saved.\nDo you want to save it before closing?", path) ;
            dialog.add_button ("Don't save", Gtk.ResponseType.NO) ;
            dialog.add_button ("Cancel", Gtk.ResponseType.CANCEL) ;
            dialog.add_button ("Save", Gtk.ResponseType.YES) ;
            dialog.set_resizable (false) ;
            dialog.set_default_response (Gtk.ResponseType.YES) ;
            int response = dialog.run () ;
            switch( response ){
            case Gtk.ResponseType.NO:
                window.notebook.remove_page (num) ;
                unowned List<string> del_item = files.find_custom (path, strcmp) ;
                files.remove_link (del_item) ;
                break ;
            case Gtk.ResponseType.CANCEL:
                break ;
            case Gtk.ResponseType.YES:
                window.operations.save_file_at_pos (num) ;
                window.notebook.remove_page (num) ;
                unowned List<string> del_item = files.find_custom (path, strcmp) ;
                files.remove_link (del_item) ;
                break ;
            }
            dialog.destroy () ;
        }

        public void changes_all() {
            string[] recent_files = {} ;
            for( int i = 0 ; i < files.length () ; i++ ){
                if( files.nth_data (i) != "Untitled" )
                    recent_files += files.nth_data (i) ;
            }
            Application.saved_state.set_strv ("recent-files", recent_files) ;

            for( int i = (int) files.length () - 1 ; i >= 0 ; i-- ){
                string path = files.nth_data (i) ;
                var view = window.tabs.get_sourceview_at_tab (i) ;
                var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
                if( buffer.get_modified () == false ){
                    window.notebook.remove_page (i) ;
                    unowned List<string> del_item = files.find_custom (path, strcmp) ;
                    files.remove_link (del_item) ;
                } else {
                    changes_one (i, path) ;
                }
            }
        }

        public void show_save() {
            string newname ;
            var dialog = new Gtk.FileChooserDialog ("Save As...", window,
                                                    Gtk.FileChooserAction.SAVE,
                                                    "Cancel", Gtk.ResponseType.CANCEL,
                                                    "Save", Gtk.ResponseType.ACCEPT) ;
            string cf = files.nth_data (window.notebook.get_current_page ()) ;
            dialog.set_current_folder (Path.get_dirname (cf)) ;
            dialog.set_current_name (Path.get_basename (cf)) ;
            dialog.set_do_overwrite_confirmation (true) ;
            dialog.set_modal (true) ;
            dialog.show () ;
            if( dialog.run () == Gtk.ResponseType.ACCEPT ){
                newname = dialog.get_filename () ;
                window.operations.save_file_as (newname) ;
            }
            dialog.destroy () ;
        }

        public void save_fallback(string path) {
            var dialog = new Gtk.MessageDialog (window,
                                                Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.NONE,
                                                "Error saving file %s.\nThe file on disk may now be truncated!", path) ;
            dialog.add_button ("Don't save", Gtk.ResponseType.NO) ;
            dialog.add_button ("Select New Location", Gtk.ResponseType.YES) ;
            dialog.set_resizable (false) ;
            dialog.set_default_response (Gtk.ResponseType.YES) ;
            int response = dialog.run () ;
            switch( response ){
            case Gtk.ResponseType.NO:
                break ;
            case Gtk.ResponseType.YES:
                show_save () ;
                break ;
            }
            dialog.destroy () ;
        }

        public void show_about() {
            var about = new Gtk.AboutDialog () ;
            about.set_program_name (NAME) ;
            about.set_version (VERSION) ;
            about.set_comments (DESCRIPTION) ;
            about.set_logo_icon_name (ICON) ;
            about.set_icon_name (ICON) ;
            about.set_authors (AUTHORS) ;
            about.set_copyright ("Copyright \xc2\xa9 2017") ;
            about.set_website ("https://github.com/danielpinto8zz6") ;
            about.set_property ("skip-taskbar-hint", true) ;
            about.set_transient_for (window) ;
            about.license_type = Gtk.License.GPL_3_0 ;
            about.run () ;
            about.hide () ;
        }

        public void reset_all() {
            var dialog = new Gtk.MessageDialog (window,
                                                Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE,
                                                "Are you sure you want to reset all preferences?") ;
            dialog.add_button ("Yes", Gtk.ResponseType.YES) ;
            dialog.add_button ("Cancel", Gtk.ResponseType.CANCEL) ;
            dialog.set_resizable (false) ;
            dialog.set_default_response (Gtk.ResponseType.YES) ;
            int response = dialog.run () ;
            switch( response ){
            case Gtk.ResponseType.CANCEL:
                break ;
            case Gtk.ResponseType.YES:
                foreach( var key in Application.settings_editor.settings_schema.list_keys ())
                    Application.settings_view.reset (key) ;
                foreach( var key in Application.settings_fonts_colors.settings_schema.list_keys ())
                    Application.settings_view.reset (key) ;
                foreach( var key in Application.settings_terminal.settings_schema.list_keys ())
                    Application.settings_view.reset (key) ;
                foreach( var key in Application.settings_view.settings_schema.list_keys ())
                    Application.settings_view.reset (key) ;
                break ;
            }
            dialog.destroy () ;
        }

    }
}
