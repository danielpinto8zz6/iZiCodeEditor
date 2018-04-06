namespace iZiCodeEditor {
    public class Explorer : Gtk.ScrolledWindow {
        public List<Folder>opened_folders;

        private Gtk.Box folder_view;

        public signal void file_clicked (string filepath);

        public Explorer() {
            GLib.Object (hscrollbar_policy: Gtk.PolicyType.AUTOMATIC,
                         vscrollbar_policy: Gtk.PolicyType.AUTOMATIC,
                         expand: true);
        }

        construct {
            opened_folders = new List<Folder>();
            folder_view = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            add (folder_view);
            show_all ();
        }

        public void open_folder (string path) {
            if (is_open (path)) {
                warning ("'%s' is already open.", path);
                return;
            } else if (!is_valid_directory (path)) {
                warning ("Cannot open invalid directory.");
                return;
            }

            Folder folder = new Folder (path);
            opened_folders.append (folder);
            folder_view.add (folder);
            folder.closed.connect (close_folder);
            folder.file_clicked.connect ((path) => {
                file_clicked (path);
            });
        }

        private bool is_open (string path) {
            for (int i = 0; i < opened_folders.length (); i++) {
                var folder = opened_folders.nth_data (i);
                if (folder == null) {
                    continue;
                }
                if (folder.path == path) {
                    return true;
                }
            }
            return false;
        }

        private bool is_valid_directory (string path) {
            try {
                File file = File.new_for_path (path);
                FileInfo info = file.query_info ("standard::*", 0);

                if (info.get_is_hidden () || info.get_is_backup ()) {
                    return false;
                }
                if (info.get_file_type () == FileType.DIRECTORY) {
                    return true;
                }
            } catch (Error error) {
                warning (error.message);
            }
            return false;
        }

        private void close_folder (Folder folder) {
            folder.clear ();
            folder.destroy ();
            opened_folders.remove (folder);
        }
    }
}