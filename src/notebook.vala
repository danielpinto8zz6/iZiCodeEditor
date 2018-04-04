namespace iZiCodeEditor {
    public class Notebook : Gtk.Notebook {
        public unowned ApplicationWindow window { get; construct set; }

        public Document current_doc {
            get {
                return (Document)get_nth_page (window.notebook.get_current_page ());
            }
        }

        public GLib.List<Document> docs;

        public Notebook (iZiCodeEditor.ApplicationWindow window) {
            Object (
                window: window,
                expand: true,
                show_border: false);
        }

        construct {
            docs = new GLib.List<Document> ();

            scrollable = true;

            on_tabs_changed ();
            page_added.connect (on_doc_added);
            page_removed.connect (on_doc_removed);
            switch_page.connect (on_notebook_page_switched);
            page_reordered.connect (on_doc_reordered);
        }

        private void on_doc_removed (Gtk.Widget tab, uint page_num) {
            var doc = (Document)tab;
            docs.remove (doc);
            doc.sourceview.focus_in_event.disconnect (on_focus_in_event);
            on_tabs_changed ();
        }

        private void on_doc_added (Gtk.Widget tab, uint page_num) {
            var doc = (Document)tab;
            docs.append (doc);
            doc.sourceview.focus_in_event.connect_after (on_focus_in_event);
            on_tabs_changed ();
        }

        private void on_doc_reordered (Gtk.Widget tab, uint new_pos) {
            var doc = (Document)tab;

            docs.remove (doc);
            docs.insert (doc, (int)new_pos);
        }

        private void on_notebook_page_switched (Gtk.Widget page, uint page_num = 0) {
            var doc = (Document)page;

            window.headerbar.set_doc (doc);
            window.status_bar.set_doc (doc);
            doc.sourceview.grab_focus ();
        }

        private bool on_focus_in_event () {
            var doc = current_doc;
            if (doc != null) {
                on_notebook_page_switched (doc);
            }

            return false;
        }

        private void on_tabs_changed () {
            var pages = get_n_pages ();
            set_show_tabs (pages > 1);
            no_show_all = (pages == 0);
            visible = (pages > 0);
        }

        public void new_tab () {
            var doc = new Document.new_doc (this);
            add_doc (doc);
            set_current_page (page_num (doc));
            set_tab_reorderable (doc, true);
            doc.sourceview.grab_focus ();
        }

        public void open_dialog () {
            var chooser = new Gtk.FileChooserDialog (
                "Select a file to edit", window, Gtk.FileChooserAction.OPEN,
                "_Cancel",
                Gtk.ResponseType.CANCEL,
                "_Open",
                Gtk.ResponseType.ACCEPT);
            var filter = new Gtk.FileFilter ();
            filter.add_mime_type ("text/plain");

            chooser.set_select_multiple (true);
            chooser.set_modal (true);
            chooser.set_filter (filter);
            chooser.show ();
            if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                foreach (string uri in chooser.get_uris ()) {
                    var file = File.new_for_uri (uri);
                    open (file);
                }
            }
            chooser.destroy ();
        }

        public void open (File file) {
            for (int n = 0; n <= docs.length (); n++) {
                var sel_doc = docs.nth_data (n);
                if (sel_doc == null) {
                    continue;
                }

                if (!sel_doc.is_file_temporary && sel_doc.file.get_uri () == file.get_uri ()) {
                    set_current_page (page_num (sel_doc));
                    stderr.printf ("This file is already loaded: %s\n", file.get_parse_name ());
                    return;
                }
            }
            var current = current_doc;
            var doc = new Document (file, this);
            add_doc (doc);
            set_current_page (page_num (doc));
            set_tab_reorderable (doc, true);

            if (current != null && current.is_file_temporary && !current.sourceview.buffer.get_modified ()) {
                close (current);
            }
        }

        public void close (Gtk.Widget tab) {
            var doc = (Document)tab;

            doc.close ();
            remove_page (page_num (doc));
        }

        public void close_all () {
            for (uint i = docs.length (); i > 0; i--) {
                close (current_doc);
            }
        }

        private void add_doc (Document doc) {
            append_page (doc, doc.get_tab_label ());
        }
    }
}
