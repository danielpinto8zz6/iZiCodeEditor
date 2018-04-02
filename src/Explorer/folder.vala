namespace iZiCodeEditor {
    public class Folder : Gtk.TreeView {
        public new string path { get; set construct; }

        private Gtk.TreeStore store;

        private FileMonitor monitor;

        public signal void closed ();

        public signal void file_clicked (string filepath);

        private Gtk.CellRendererPixbuf pixbuf_cell;
        private Gtk.CellRendererText text_cell;

        private Gtk.Menu menu;

        private Gtk.MenuItem rename_item;
        private Gtk.MenuItem delete_item;
        private Gtk.MenuItem close_folder_item;
        private Gtk.MenuItem new_item;
        private Gtk.MenuItem new_file_item;
        private Gtk.MenuItem new_folder_item;
        private Gtk.MenuItem open_containing_folder_item;

        public Folder (string path) {
            Object (path: path,
                    activate_on_single_click: true,
                    enable_tree_lines: true,
                    enable_search: true,
                    hover_selection: true,
                    headers_clickable: false,
                    headers_visible: false);
        }

        ~Folder () {
            monitor.cancel ();
        }

        construct {
            store = new Gtk.TreeStore (5, typeof (Icon),typeof (string), typeof (string), typeof (bool), typeof (bool));

            store.set_sort_func (0, (model, a, b) => {
                string aname;
                string bname;
                bool aisdir;
                bool bisdir;

                model.get (a, 1, out aname, 3, out aisdir);
                model.get (b, 1, out bname, 3, out bisdir);

                if (aisdir == bisdir) {
                    if (aname.collate_key_for_filename () == bname.collate_key_for_filename ()) {
                        return 0;
                    } else if (aname.collate_key_for_filename () > bname.collate_key_for_filename ()) {
                        return 1;
                    } else {
                        return -1;
                    }
                } else if (aisdir) {
                    return -1;
                } else {
                    return 1;
                }
            });

            store.set_sort_column_id (0, Gtk.SortType.ASCENDING);

            menu = get_menu ();

            var column = new Gtk.TreeViewColumn ();

            pixbuf_cell = new Gtk.CellRendererPixbuf ();
            column.set_title ("");
            column.pack_start (pixbuf_cell, false);
            column.add_attribute (pixbuf_cell,"gicon",0);

            text_cell = new Gtk.CellRendererText ();
            text_cell.edited.connect ((path, new_name)=>{
                Gtk.TreeIter iter;
                store.get_iter_from_string (out iter, path);
                rename (File.new_for_path (get_full_path (iter)), new_name);
            });

            column.pack_start (text_cell, false);
            column.add_attribute (text_cell,"text",1);

            column.set_title (Path.get_basename (path));

            append_column (column);

            base.set_model (store);

            add (File.new_for_path (path));

            row_activated.connect (on_row_activated);

            button_press_event.connect (on_button_pressed);

            show_all ();
        }

        private new void add (File folder) {
            if (folder.query_exists ()) {
                try {
                    add_file (folder, null, new Cancellable (), true);
                    start_monitoring (folder);
                } catch ( Error error ) {
                    warning (error.message);
                }
            } else {
                warning ("File %s doesn't exists", folder.get_path ());
            }
        }

        private void add_file (File file, Gtk.TreeIter ? parent = null, Cancellable ?  cancellable = null, bool is_root_dir = false) throws Error {
            FileInfo info = file.query_info ("standard::*", 0);
            if (!is_valid (info)) {
                return;
            }
            Gtk.TreeIter iter;
            store.append (out iter, parent);
            bool is_dir = is_directory (info);
            store.set (iter, 0, info.get_icon (), 1, info.get_display_name (), 2, file.get_parse_name (), 3, is_dir, 4, is_root_dir);
            if (is_dir) {
                FileEnumerator e = file.enumerate_children ("standard::*", 0, cancellable);
                while (cancellable.is_cancelled () == false && (info = e.next_file (cancellable)) != null) {
                    File subdir = file.resolve_relative_path (info.get_name ());
                    add_file (subdir, iter);
                }
                if ( cancellable.is_cancelled ()) {
                    throw new IOError.CANCELLED ("Operation was cancelled");
                }
            }
        }

        private bool is_valid (FileInfo info) {
            if (info.get_is_backup ()) {
                return false;
            }
            if (is_directory (info)) {
                if (info.get_is_hidden ()) {
                    return false;
                }
                return true;
            }
            if (info.get_file_type () == FileType.REGULAR &&
                ContentType.is_a (info.get_content_type (), "text/*")) {
                return true;
            }
            return false;
        }

        private void start_monitoring (File folder) {
            try {
                monitor = folder.monitor_directory (GLib.FileMonitorFlags.NONE);
                monitor.changed.connect (on_directory_changed);
            } catch (GLib.Error error) {
                warning (error.message);
            }
        }

        private void on_directory_changed (GLib.File source, GLib.File ? dest, GLib.FileMonitorEvent event) {
            string file_path = source.get_path ();
            switch (event) {
            case GLib.FileMonitorEvent.DELETED :
                if (file_path == path) {
                    closed ();
                } else {
                    delete_row (file_path);
                }
                break;
            case GLib.FileMonitorEvent.CREATED :
                add_row (source);
                break;
            }
        }

        public void clear () {
            store.clear ();
        }

        private void on_row_activated (Gtk.TreePath path, Gtk.TreeViewColumn column) {
            bool is_dir;

            Gtk.TreeIter iter;

            store.get_iter (out iter, path);
            store.get (iter, 3, out is_dir, -1);

            if ( is_dir ) {
                if (is_row_expanded (path)) {
                    collapse_row (path);
                } else {
                    expand_row (path, false);
                }
            } else {
                string file_path = get_full_path (iter);
                file_clicked (file_path);
            }
        }

        private Gtk.TreeIter get_iter_at_cursor () {
            Gtk.TreePath ? path;
            Gtk.TreeViewColumn ? column;
            Gtk.TreeIter iter;

            get_cursor (out path, out column);
            store.get_iter (out iter, path);

            return iter;
        }

        private string get_full_path (Gtk.TreeIter iter) {
            string path;

            store.get (iter, 2, out path);

            return path;
        }

        public void delete_row (string name) {
            Gtk.TreeModelForeachFunc delete_path = (model, path, iter) => {
                if (get_full_path (iter) == name) {
                    store.remove (ref iter);
                    return true;
                }
                return false;
            };

            store.foreach (delete_path);
        }

        public void add_row (File file) {
            string dirname = Path.get_dirname (file.get_path ());

            Gtk.TreeModelForeachFunc add_to_row = (model, path, iter) => {
                if (get_full_path (iter) == dirname) {
                    try {
                        add_file (file, iter, new Cancellable ());
                    } catch ( Error error ) {
                        warning (error.message);
                    }
                    return true;
                }
                return false;
            };

            store.foreach (add_to_row);
        }

        private bool is_directory (FileInfo info) {
            return info.get_file_type () == FileType.DIRECTORY ? true : false;
        }

        private Gtk.Menu ? get_menu () {
            Gtk.Menu main_menu = new Gtk.Menu ();

            new_item = new Gtk.MenuItem.with_label ("New");
            main_menu.add (new_item);

            Gtk.Menu new_submenu = new Gtk.Menu ();
            new_item.set_submenu (new_submenu);

            new_file_item = new Gtk.MenuItem.with_label ("File");
            new_file_item.activate.connect (action_new_file);
            new_submenu.add (new_file_item);

            new_folder_item = new Gtk.MenuItem.with_label ("Folder");
            new_folder_item.activate.connect (action_new_folder);
            new_submenu.add (new_folder_item);

            rename_item = new Gtk.MenuItem.with_label ("Rename");
            rename_item.activate.connect (action_rename);
            main_menu.add (rename_item);

            delete_item = new Gtk.MenuItem.with_label ("Delete");
            delete_item.activate.connect (action_delete);
            main_menu.add (delete_item);

            open_containing_folder_item = new Gtk.MenuItem.with_label ("Open Containing Folder");
            open_containing_folder_item.activate.connect (action_open_containing_folder);
            main_menu.add (open_containing_folder_item);

            close_folder_item = new Gtk.MenuItem.with_label ("Close Folder");
            close_folder_item.activate.connect (action_close_folder);
            main_menu.add (close_folder_item);

            main_menu.show_all ();

            return main_menu;
        }

        private void action_new_file () {
            Gtk.TreeIter iter = get_iter_at_cursor ();
            create_file (File.new_for_path (get_full_path (iter)));
        }

        private void action_new_folder () {
            Gtk.TreeIter iter = get_iter_at_cursor ();
            create_folder (File.new_for_path (get_full_path (iter)));
        }

        private void action_rename () {
            Gtk.TreePath ? path;

            get_cursor (out path, null);

            text_cell.editable = true;

            set_cursor_on_cell (path, get_column (0), text_cell, true);

            text_cell.editable = false;
        }

        private void action_delete () {
            Gtk.TreeIter iter = get_iter_at_cursor ();
            trash (File.new_for_path (get_full_path (iter)));
        }

        private void action_close_folder () {
            closed ();
        }

        private void action_open_containing_folder () {
            Gtk.TreeIter iter = get_iter_at_cursor ();
            open_externally (Path.build_path (Path.DIR_SEPARATOR_S, "file://", Path.get_dirname (get_full_path (iter))));
        }

        protected void create_file (File file) {
            if (!is_executable (file)) {
                warning ("Unable to open parent folder");
                return;
            }

            File new_file = file.get_child ("Untitled");

            int n = 1;
            while (new_file.query_exists ()) {
                new_file = file.get_child ("Untitled_%d".printf (n));
                n++;
            }

            new_file.create_async.begin (0, Priority.DEFAULT, null, (obj, res) => {
                try {
                    new_file.create_async.end (res);
                } catch (Error error) {
                    warning (error.message);
                }
            });
        }

        protected void create_folder (File file) {
            if (!is_executable (file)) {
                warning ("Unable to open parent folder");
                return;
            }

            File folder = file.get_child ("Untitled");

            int n = 1;
            while (folder.query_exists ()) {
                folder = file.get_child ("Untitled_%d".printf (n));
                n++;
            }

            folder.make_directory_async.begin (Priority.DEFAULT, null, (obj, res) => {
                try {
                    folder.make_directory_async.end (res);
                } catch (Error error) {
                    warning (error.message);
                }
            });
        }

        private bool is_executable (File file) {
            try {
                FileInfo info = file.query_info (FileAttribute.ACCESS_CAN_EXECUTE, 0);

                return info.get_attribute_boolean (FileAttribute.ACCESS_CAN_EXECUTE);
            } catch (Error errir) {
                return false;
            }
        }

        private void open_externally (string uri) {
            AppInfo.launch_default_for_uri_async.begin (uri, null, null, (obj, res) => {
                try {
                    AppInfo.launch_default_for_uri_async.end (res);
                } catch (Error error) {
                    warning (error.message);
                }
            });
        }

        private void rename (File file, string new_name) {
            file.set_display_name_async.begin (new_name, Priority.DEFAULT, null, (obj, res) => {
                try {
                    file.set_display_name_async.end (res);
                } catch (Error error) {
                    warning (error.message);
                }
            });
        }

        private void trash (File file) {
            file.trash_async.begin (Priority.DEFAULT, null, (obj, res) => {
                try {
                    file.trash_async.end (res);
                } catch (Error error) {
                    warning (error.message);
                }
            });
        }

        private bool on_button_pressed (Gdk.EventButton event) {
            if (event.button == 3) {
                on_context_menu (event);
            }
            return false;
        }

        private void on_context_menu (Gdk.EventButton event) {
            Gtk.TreePath path;
            get_cursor (out path, null);

            if (path == null) {
                return;
            }

            Gtk.TreeIter iter;
            if (!store.get_iter (out iter, path)) {
                return;
            }

            bool is_dir, is_root_dir;
            string file_path;

            store.get (iter, 2, out file_path, 3, out is_dir, 4, out is_root_dir, -1);

            if (is_dir) {
                rename_item.show ();
                delete_item.show ();
                close_folder_item.hide ();
                new_item.show ();
                new_file_item.show ();
                new_folder_item.show ();
                open_containing_folder_item.show ();
                if (is_root_dir) {
                    rename_item.hide ();
                    delete_item.hide ();
                    close_folder_item.show ();
                }
            } else {
                rename_item.show ();
                delete_item.show ();
                close_folder_item.hide ();
                new_item.hide ();
                new_file_item.hide ();
                new_folder_item.hide ();
                open_containing_folder_item.show ();
            }

            menu.popup_at_pointer (event);
        }
    }
}