namespace iZiCodeEditor {
    public class Notebook : Gtk.Notebook {
        public unowned ApplicationWindow window { get; construct set; }

        public Document current_doc {
            get {
                return (Document)get_nth_page (get_current_page ());
            }
        }

        public GLib.List<Document> docs;

        public Notebook (iZiCodeEditor.ApplicationWindow window) {
            Object (
                window: window,
                expand: true,
                show_border: false,
                scrollable: true);
        }

        construct {
            docs = new GLib.List<Document> ();

            on_tabs_changed ();
            page_added.connect (on_doc_added);
            page_removed.connect (on_doc_removed);
            switch_page.connect (on_notebook_page_switched);
            page_reordered.connect (on_doc_reordered);
        }

        private void on_doc_removed (Gtk.Widget tab, uint page_num) {
            var doc = (Document)tab;
            docs.remove (doc);
            on_tabs_changed ();
            if (current_doc == null) {
                window.headerbar.set_doc (null);
                window.status_bar.set_doc (null);
            }
        }

        private void on_doc_added (Gtk.Widget tab, uint page_num) {
            var doc = (Document)tab;
            docs.append (doc);
            on_tabs_changed ();
        }

        private void on_doc_reordered (Gtk.Widget tab, uint new_pos) {
            var doc = (Document)tab;
            docs.remove (doc);
            docs.insert (doc, (int)new_pos);
        }

        private void on_notebook_page_switched (Gtk.Widget page, uint page_num = 0) {
            var doc = (Document)page;

            if (doc != null) {
                window.headerbar.set_doc (doc);
                window.status_bar.set_doc (doc);
                doc.sourceview.grab_focus ();
            }
        }

        private void on_tabs_changed () {
            var pages = get_n_pages ();
            set_show_tabs (pages > 1);
            no_show_all = (pages == 0);
            visible = (pages > 0);
        }

        public void new_doc () {
            File file = generate_temporary_file ();
            if (file != null) {
                var doc = new Document (file, this);
                append_page (doc, doc.get_tab_label ());
                set_current_page (page_num (doc));
                set_tab_reorderable (doc, true);
            }
        }

        private File generate_temporary_file () {
            File folder = File.new_for_path (Application.instance.unsaved_files_directory);

            int n = 1;

            File new_file = folder.get_child ("Untitled_%d".printf (n));

            while (new_file.query_exists ()) {
                new_file = folder.get_child ("Untitled_%d".printf (n));
                n++;
            }

            new_file.create_async.begin (0, Priority.DEFAULT, null, (obj, res) => {
                try {
                    new_file.create_async.end (res);
                } catch (Error error) {
                    warning (error.message);
                }
            });

            return new_file;
        }

        public void open_doc_dialog () {
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
                    open_doc (file);
                }
            }
            chooser.destroy ();
        }

        public void open_doc (File file) {
            if (file == null) {
                return;
            }

            for (int n = 0; n < docs.length (); n++) {
                var sel_doc = docs.nth_data (n);
                if (sel_doc == null) {
                    continue;
                }

                if (sel_doc.file.get_uri () == file.get_uri ()) {
                    set_current_page (page_num (sel_doc));
                    warning ("This file is already loaded: %s\n", file.get_parse_name ());
                    return;
                }
            }

            var doc = new Document (file, this);
            append_page (doc, doc.get_tab_label ());
            set_current_page (page_num (doc));
            set_tab_reorderable (doc, true);
        }

        public void close (Gtk.Widget tab) {
            var doc = (Document)tab;

            doc.close ();
            remove_page (page_num (doc));
        }

        public void close_all () {
            docs.foreach ((sel_doc) => {
                close (sel_doc);
            });
        }
    }
}
