namespace iZiCodeEditor {
    public class Folder : Gtk.TreeView {
        public new string path { get; set construct; }

        private Gtk.TreeStore store;

        private FileMonitor monitor;

        public signal void removed ();

        public signal void file_clicked (string filepath);

        private Gtk.Menu menu;

        private Gtk.CellRendererPixbuf pixbuf_cell;
        private Gtk.CellRendererText text_cell;

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
            override_background_color (Gtk.StateFlags.NORMAL, {0.0,0.0,0.0,0.0});

            store = new Gtk.TreeStore (5, typeof (Icon),typeof (string), typeof (FileInfo), typeof (string), typeof (bool));

            store.set_sort_func (0, (model, a, b) => {
                string aname;
                string bname;
                bool aisdir;
                bool bisdir;

                model.get (a, 1, out aname, 4, out aisdir);
                model.get (b, 1, out bname, 4, out bisdir);

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

            var column = new Gtk.TreeViewColumn ();

            pixbuf_cell = new Gtk.CellRendererPixbuf ();
            column.set_title ("");
            column.pack_start (pixbuf_cell, false);
            column.add_attribute (pixbuf_cell,"gicon",0);

            text_cell = new Gtk.CellRendererText ();
            text_cell.edited.connect (text_cell_edited);

            column.pack_start (text_cell, false);
            column.add_attribute (text_cell,"text",1);

            column.set_title (Path.get_basename (path));


            append_column (column);

            base.set_model (store);

            add (File.new_for_path (path));

            row_activated.connect (on_row_activated);

            button_press_event.connect (on_button_pressed);

            menu = get_context_menu ();

            show_all ();
        }

        private new void add (File folder) {
            if (folder.query_exists ()) {
                try {
                    add_file (folder, null, new Cancellable ());
                    monitor_directory (folder);
                } catch ( Error error ) {
                    warning (error.message);
                }
            } else {
                warning ("File %s doesn't exists", folder.get_path ());
            }
        }

        private void add_file (File file, Gtk.TreeIter ? parent = null, Cancellable ?  cancellable = null) throws Error {
            Gtk.TreeIter iter;
            store.append (out iter, parent);
            var info = file.query_info ("standard::*", 0);
            store.set (iter, 0, info.get_icon (), 1, info.get_display_name (), 2, info, 3, file.get_parse_name (), 4, is_directory (info));
            if (is_directory (info)) {
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

        private void monitor_directory (File folder) {
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
                    removed ();
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
            FileInfo info;

            Gtk.TreeIter iter;

            store.get_iter (out iter, path);
            store.get (iter, 2, out info, -1);

            if ( info.get_file_type () == FileType.DIRECTORY ) {
                if (is_row_expanded (path)) {
                    collapse_row (path);
                } else {
                    expand_row (path, false);
                }
            } else {
                string file_path = get_full_path (iter);
                print ("row %s", file_path);
                file_clicked (file_path);
            }
        }

        private string get_full_path (Gtk.TreeIter iter) {
            string path;

            store.get (iter, 3, out path);

            return path;
        }

        private File get_file (Gtk.TreeIter iter) {
            File file;

            file = File.new_for_path (get_full_path (iter));

            return file;
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

        private bool on_button_pressed (Gdk.EventButton event) {
            if (event.button == 3) {
                menu.popup_at_pointer (event);
            }
            return false;
        }

        public Gtk.Menu ? get_context_menu () {
            var rename_item = new Gtk.MenuItem.with_label ("Rename");
            rename_item.activate.connect (() => {
                Gtk.TreePath ? path;

                get_cursor (out path, null);

                text_cell.editable = true;

                set_cursor_on_cell (path, get_column (0), text_cell, true);
            });

            var trash_item = new Gtk.MenuItem.with_label ("Move to Trash");
            trash_item.activate.connect (() => {
                Gtk.TreeIter iter = get_iter_at_cursor ();
                trash (get_file (iter));
            });

            var open_containing_folder = new Gtk.MenuItem.with_label ("Open Containing Folder");
            open_containing_folder.activate.connect (() => {
                Gtk.TreeIter iter = get_iter_at_cursor ();
                open_in_file_manager (Path.get_dirname (get_full_path (iter)));
            });

            var menu = new Gtk.Menu ();
            menu.add (rename_item);
            menu.add (trash_item);
            menu.add (open_containing_folder);
            menu.show_all ();

            return menu;
        }

        private void open_in_file_manager (string path) {
            try {
                GLib.AppInfo.launch_default_for_uri (Path.build_path (Path.DIR_SEPARATOR_S, "file://", path),null);
            } catch (Error error) {
                warning (error.message);
            }
        }

        private void text_cell_edited (string name, string new_name) {
            Gtk.TreeIter iter = get_iter_at_cursor ();
            rename (get_file (iter), new_name);
        }

        private void trash (File file) {
            try {
                file.trash ();
            } catch (GLib.Error error) {
                warning (error.message);
            }
        }

        private void rename (File file, string name) {
            try {
                file.set_display_name (name);
            } catch (GLib.Error error) {
                warning (error.message);
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
    }
}