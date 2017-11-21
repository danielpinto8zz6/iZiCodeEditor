namespace iZiCodeEditor{
    public class Notebook : Gtk.Notebook {
        public unowned ApplicationWindow window { get ; construct set ; }

        public Document current_doc {
            get {
                return (Document) get_nth_page (window.notebook.get_current_page ()) ;
            }
        }

        public GLib.List<Document> docs ;

        public Notebook (iZiCodeEditor.ApplicationWindow window) {
            Object (
                window: window,
                expand: true,
                show_border: false) ;
        }

        construct {
            docs = new GLib.List<Document> () ;

            Application.settings_view.changed["text-wrap"].connect (() => {
                text_wrap_mode () ;
            }) ;

            on_tabs_changed () ;
            page_added.connect (on_doc_added) ;
            page_removed.connect (on_doc_removed) ;
            switch_page.connect (on_notebook_page_switched) ;
            page_reordered.connect (on_doc_reordered) ;
        }

        private void on_doc_removed(Gtk.Widget tab, uint page_num) {
            var doc = (Document) tab ;
            docs.remove (doc) ;
            doc.sourceview.drag_data_received.disconnect (drag_received) ;
            on_tabs_changed () ;
        }

        private void on_doc_added(Gtk.Widget tab, uint page_num) {
            var doc = (Document) tab ;
            docs.append (doc) ;
            doc.sourceview.drag_data_received.connect (drag_received) ;
            on_tabs_changed () ;
        }

        private void on_doc_reordered(Gtk.Widget tab, uint new_pos) {
            var doc = (Document) tab ;

            docs.remove (doc) ;
            docs.insert (doc, (int) new_pos) ;
        }

        public void on_notebook_page_switched(Gtk.Widget page, uint page_num) {
            var doc = (Document) page ;
            string title = doc.file.get_basename () ;
            string subtitle = doc.file.get_parse_name () ;

            window.headerbar.set_title (title) ;
            window.headerbar.set_subtitle (subtitle) ;

            window.status_bar.update_statusbar (doc) ;
        }

        public void on_tabs_changed() {
            var pages = get_n_pages () ;
            set_show_tabs (pages > 1) ;
            no_show_all = (pages == 0) ;
            visible = (pages > 0) ;
        }

        private void drag_received(Gtk.Widget w, Gdk.DragContext ctx, int x, int y, Gtk.SelectionData sel, uint info, uint time) {
            var uris = sel.get_uris () ;
            foreach( var filename in uris ){
                var file = File.new_for_uri (filename) ;
                open (file) ;
            }

            Gtk.drag_finish (ctx, true, false, time) ;
        }

        public void save_opened(Document doc) {
            var dialog = new Gtk.MessageDialog (window,
                                                Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE,
                                                "The file '%s' is not saved.\nDo you want to save it before closing?", doc.file.get_parse_name ()) ;
            dialog.add_button ("Don't save", Gtk.ResponseType.NO) ;
            dialog.add_button ("Cancel", Gtk.ResponseType.CANCEL) ;
            dialog.add_button ("Save", Gtk.ResponseType.YES) ;
            dialog.set_resizable (false) ;
            dialog.set_default_response (Gtk.ResponseType.YES) ;
            int response = dialog.run () ;
            switch( response ){
            case Gtk.ResponseType.NO:
                remove_page (page_num (doc)) ;
                break ;
            case Gtk.ResponseType.CANCEL:
                break ;
            case Gtk.ResponseType.YES:
                doc.save.begin () ;
                remove_page (page_num (doc)) ;
                break ;
            }
            dialog.destroy () ;
        }

        public void open_dialog() {
            var chooser = new Gtk.FileChooserDialog (
                "Select a file to edit", window, Gtk.FileChooserAction.OPEN,
                "_Cancel",
                Gtk.ResponseType.CANCEL,
                "_Open",
                Gtk.ResponseType.ACCEPT) ;
            var filter = new Gtk.FileFilter () ;
            filter.add_mime_type ("text/plain") ;

            chooser.set_select_multiple (true) ;
            chooser.set_modal (true) ;
            chooser.set_filter (filter) ;
            chooser.show () ;
            if( chooser.run () == Gtk.ResponseType.ACCEPT ){
                foreach( string uri in chooser.get_uris ()){
                    var file = File.new_for_uri (uri) ;
                    open (file) ;
                }
            }
            chooser.destroy () ;
        }

        public void open(File file) {
            for( int n = 0 ; n <= docs.length () ; n++ ){
                var sel_doc = docs.nth_data (n) ;
                if( sel_doc == null ){
                    continue ;
                }

                if( sel_doc.file != null && sel_doc.file.get_uri () == file.get_uri ()){
                    set_current_page (page_num (sel_doc)) ;
                    stderr.printf ("This file is already loaded: %s\n", file.get_parse_name ()) ;
                    return ;
                }
            }
            var doc = new Document (file) ;
            doc.open.begin () ;
            append_page (doc, doc.tab_label) ;
            set_current_page (page_num (doc)) ;
            set_tab_reorderable (doc, true) ;
        }

        public void close(Gtk.Widget tab) {
            var doc = (Document) tab ;

            if( doc.sourceview.buffer.get_modified () == true ){
                save_opened (doc) ;
            } else {
                remove_page (page_num (doc)) ;
            }
            if( get_n_pages () == 0 ){
                window.headerbar.set_title (NAME) ;
                window.headerbar.set_subtitle (null) ;
            }
        }

        public void close_all() {
            for( uint i = docs.length () ; i > 0 ; i-- ){
                close (current_doc) ;
            }
        }

        public void set_recent_files() {
            string[] recent_files = {} ;
            for( int i = 0 ; i < docs.length () ; i++ ){
                var sel_doc = docs.nth_data (i) ;
                if( sel_doc == null ){
                    continue ;
                }
                recent_files += sel_doc.file.get_uri () ;
            }
            Application.saved_state.set_strv ("recent-files", recent_files) ;
        }

        public void add_recent_files() {
            string[] recent_files = Application.saved_state.get_strv ("recent-files") ;
            if( recent_files.length > 0 ){
                for( int i = 0 ; i < recent_files.length ; i++ ){
                    var one = GLib.File.new_for_uri (recent_files[i]) ;
                    if( one.query_exists () == true ){
                        window.notebook.open (one) ;
                    }
                }
                window.notebook.set_current_page ((int) Application.saved_state.get_uint ("active-tab")) ;
            }
        }

        public void save_all() {
            for( int n = 0 ; n <= docs.length () ; n++ ){
                var sel_doc = docs.nth_data (n) ;
                if( sel_doc == null ){
                    continue ;
                }
                sel_doc.save.begin () ;
            }
        }

        public void text_wrap_mode() {
            for( int n = 0 ; n <= docs.length () ; n++ ){
                var sel_doc = docs.nth_data (n) ;
                if( sel_doc == null ){
                    continue ;
                }
                if( sel_doc.sourceview.get_wrap_mode () == Gtk.WrapMode.WORD ){
                    sel_doc.sourceview.set_wrap_mode (Gtk.WrapMode.NONE) ;
                } else {
                    sel_doc.sourceview.set_wrap_mode (Gtk.WrapMode.WORD) ;
                }

            }
        }

    }
}
