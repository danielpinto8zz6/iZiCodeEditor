namespace iZiCodeEditor {
    public class ApplicationWindow : Gtk.ApplicationWindow {
        public weak Application app { get; construct; }

        public iZiCodeEditor.Notebook notebook;
        public Gtk.Notebook bottomBar;
        public Gtk.Notebook leftBar;
        private iZiCodeEditor.Terminal terminal;
        public iZiCodeEditor.HeaderBar headerbar;
        public iZiCodeEditor.StatusBar status_bar;
        public iZiCodeEditor.Replace replace;
        public iZiCodeEditor.Preferences preferences;
        private iZiCodeEditor.Explorer explorer;
        public GLib.List<string> files;
        private Gtk.Paned leftPaned;
        private Gtk.Paned rightPaned;
        private Gtk.Paned mainPaned;

        public const string ACTION_PREFIX = "win.";
        public const string ACTION_NEXT_PAGE = "next-page";
        public const string ACTION_UNDO = "undo";
        public const string ACTION_REDO = "redo";
        public const string ACTION_OPEN = "open";
        public const string ACTION_OPEN_FOLDER = "open-folder";
        public const string ACTION_SAVE = "save";
        public const string ACTION_SEARCH = "search";
        public const string ACTION_GOTOLINE = "go-to";
        public const string ACTION_NEW = "new";
        public const string ACTION_SAVE_AS = "save-as";
        public const string ACTION_SAVE_ALL = "save-all";
        public const string ACTION_REPLACE = "replace";
        public const string ACTION_CLOSE = "close";
        public const string ACTION_CLOSE_ALL = "close-all";
        public const string ACTION_PREFERENCES = "preferences";
        public const string ACTION_ABOUT = "about";
        public const string ACTION_QUIT = "quit";
        public const string ACTION_ZOOM_DEFAULT = "zoom-default";
        public const string ACTION_ZOOM_IN = "zoom-in";
        public const string ACTION_ZOOM_OUT = "zoom-out";
        public const string ACTION_COMMENT = "comment";

        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

        public const GLib.ActionEntry[] action_entries = {
            { ACTION_NEXT_PAGE, next_page },
            { ACTION_UNDO, action_undo },
            { ACTION_REDO, action_redo },
            { ACTION_OPEN, action_open },
            { ACTION_OPEN_FOLDER, action_open_folder },
            { ACTION_SAVE, action_save },
            { ACTION_SEARCH, action_search },
            { ACTION_GOTOLINE, action_gotoline },
            { ACTION_NEW, action_new },
            { ACTION_SAVE_AS, action_save_as },
            { ACTION_SAVE_ALL, action_save_all },
            { ACTION_REPLACE, action_replace },
            { ACTION_CLOSE, action_close },
            { ACTION_CLOSE_ALL, action_close_all },
            { ACTION_PREFERENCES, action_preferences },
            { ACTION_ABOUT, action_about },
            { ACTION_QUIT, action_quit },
            { ACTION_ZOOM_DEFAULT, action_set_default_zoom },
            { ACTION_ZOOM_IN, action_zoom_in },
            { ACTION_ZOOM_OUT, action_zoom_out },
            { ACTION_COMMENT, action_comment }
        };

        public Document current_doc {
            get {
                return notebook.current_doc;
            }
        }

        public ApplicationWindow (Application app) {
            Object (
                application: app,
                icon_name: ICON,
                title: NAME
                );

            action_accelerators.set (ACTION_NEXT_PAGE,    "<Control>Tab");
            action_accelerators.set (ACTION_UNDO,         "<Control>Z");
            action_accelerators.set (ACTION_REDO,         "<Control>Y");
            action_accelerators.set (ACTION_OPEN,         "<Control>O");
            action_accelerators.set (ACTION_OPEN_FOLDER,  "<Control><Shift>O");
            action_accelerators.set (ACTION_SAVE,         "<Control>S");
            action_accelerators.set (ACTION_NEW,          "<Control>N");
            action_accelerators.set (ACTION_SAVE_ALL,     "<Control><Shift>S");
            action_accelerators.set (ACTION_SEARCH,       "<Control>F");
            action_accelerators.set (ACTION_GOTOLINE,     "<Control>L");
            action_accelerators.set (ACTION_REPLACE,      "<Control>H");
            action_accelerators.set (ACTION_PREFERENCES,  "<Control>P");
            action_accelerators.set (ACTION_CLOSE,        "<Control>W");
            action_accelerators.set (ACTION_CLOSE_ALL,    "<Control><Shift>W");
            action_accelerators.set (ACTION_QUIT,         "<Control>Q");
            action_accelerators.set (ACTION_ZOOM_DEFAULT, "<Control>0");
            action_accelerators.set (ACTION_ZOOM_DEFAULT, "<Control>KP_0");
            action_accelerators.set (ACTION_ZOOM_IN,      "<Control>plus");
            action_accelerators.set (ACTION_ZOOM_IN,      "<Control>KP_Add");
            action_accelerators.set (ACTION_ZOOM_OUT,     "<Control>minus");
            action_accelerators.set (ACTION_ZOOM_OUT,     "<Control>KP_Subtract");
            action_accelerators.set (ACTION_COMMENT,      "<Control>M");

            var actions = new SimpleActionGroup ();
            actions.add_action_entries (action_entries, this);
            insert_action_group ("win", actions);

            foreach (var action in action_accelerators.get_keys ()) {
                application.set_accels_for_action (ACTION_PREFIX + action, action_accelerators[action].to_array ());
            }
        }

        construct {
            files = new GLib.List<string>();

            // window
            window_position = Gtk.WindowPosition.CENTER;

            Gtk.Settings.get_default ().set_property ("gtk-application-prefer-dark-theme", Application.settings_view.get_boolean ("dark-mode"));

            Application.settings_view.changed["dark-mode"].connect (() => {
                Gtk.Settings.get_default ().set_property ("gtk-application-prefer-dark-theme", Application.settings_view.get_boolean ("dark-mode"));
            });

            headerbar = new iZiCodeEditor.HeaderBar (this);
            set_titlebar (headerbar);
            headerbar.show_all ();

            notebook = new iZiCodeEditor.Notebook (this);

            var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            content.width_request = 200;
            content.pack_start (notebook, true, true, 0);

            //  // Left Bar
            leftBar = new Gtk.Notebook ();
            leftBar.no_show_all = true;
            leftBar.page_added.connect (() => { on_bars_changed (leftBar); });
            leftBar.page_removed.connect (() => { on_bars_changed (leftBar); });

            // Bottom Bar
            bottomBar = new Gtk.Notebook ();
            bottomBar.no_show_all = true;
            bottomBar.page_added.connect (() => { on_bars_changed (bottomBar); });
            bottomBar.page_removed.connect (() => { on_bars_changed (bottomBar); });

            leftPaned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            leftPaned.position = 180;
            leftPaned.pack1 (leftBar, false, false);
            leftPaned.pack2 (content, true, false);

            rightPaned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            rightPaned.pack1 (leftPaned, true, false);
            // rightPaned.pack2 (rightBar, false, false) ;

            mainPaned = new Gtk.Paned (Gtk.Orientation.VERTICAL);
            mainPaned.pack1 (rightPaned, true, false);
            mainPaned.pack2 (bottomBar, false, false);

            explorer = new iZiCodeEditor.Explorer ();
            explorer.restore_recent_folders ();
            explorer.file_clicked.connect ((path) => {
                notebook.open (File.new_for_path (path));
            });

            leftBar.append_page (explorer, new Gtk.Label ("Explorer"));

            terminal = new iZiCodeEditor.Terminal ();

            var label_terminal = new Gtk.Label ("Terminal");
            var scrolled_terminal = (Gtk.Scrollbar)terminal.get_child_at (1, 0);

            if (Application.settings_terminal.get_boolean ("terminal")) {
                bottomBar.append_page (terminal, label_terminal);
            } else {
                bottomBar.remove_page (notebook.page_num (scrolled_terminal));
            }
            Application.settings_terminal.changed["terminal"].connect (() => {
                if (Application.settings_terminal.get_boolean ("terminal")) {
                    bottomBar.append_page (terminal, label_terminal);
                } else {
                    bottomBar.remove_page (notebook.page_num (scrolled_terminal));
                }
            });

            status_bar = new iZiCodeEditor.StatusBar (this);

            var mainBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            mainBox.pack_start (mainPaned, false, true, 0);

            mainBox.pack_end (status_bar, false, false, 0);

            mainBox.show_all ();

            add (mainBox);

            if (Application.settings_view.get_boolean ("status-bar")) {
                status_bar.show ();
            } else {
                status_bar.hide ();
            }
            Application.settings_view.changed["status-bar"].connect (() => {
                if (Application.settings_view.get_boolean ("status-bar")) {
                    status_bar.show ();
                } else {
                    status_bar.hide ();
                }
            });

            support_drag_and_drop ();

            this.delete_event.connect (() => {
                action_quit ();
                return true;
            });

            restore_saved_state ();

            if (notebook.get_n_pages () == 0)
                action_new ();

            show ();
        }

        private void restore_saved_state () {
            if (Application.saved_state.get_boolean ("maximized")) {
                maximize ();
            }

            set_default_size (Application.saved_state.get_int ("width"), Application.saved_state.get_int ("height"));

            rightPaned.position = Application.saved_state.get_int ("left-paned-size");
            leftPaned.position = Application.saved_state.get_int ("right-paned-size");
            mainPaned.position = Application.saved_state.get_int ("main-paned-size");
        }

        public void restore_recent_files () {
            string[] recent_files = Application.saved_state.get_strv ("recent-files");
            if (recent_files.length > 0) {
                foreach (string uri in recent_files) {
                    if (uri != "") {
                        var file = File.new_for_uri (uri);
                        if (file.query_exists ())
                            notebook.open (file);
                    }
                }
                notebook.set_current_page ((int)Application.saved_state.get_uint ("active-tab"));
            }
        }

        private void support_drag_and_drop () {
            Gtk.drag_dest_set (this, Gtk.DestDefaults.ALL, { }, Gdk.DragAction.COPY);
            Gtk.drag_dest_add_uri_targets (this);
            drag_data_received.connect ((dc, x, y, selection_data, info, time) =>
            {
                File[] files = { };
                foreach (string uri in selection_data.get_uris ()) {
                    if (0 < uri.length)
                        files += File.new_for_uri (uri);
                }

                foreach (File file in files)
                    notebook.open (file);

                Gtk.drag_finish (dc, true, true, time);
            });
        }

        private void action_comment () {
            var doc = current_doc;
            if (doc == null) {
                return;
            }

            var buffer = doc.sourceview.buffer;
            if (buffer is Gtk.SourceBuffer) {
                Comment.toggle_comment (buffer as Gtk.SourceBuffer);
            }
        }

        public void action_zoom_in () {
            Zoom.handle_zoom (Gdk.ScrollDirection.UP);
        }

        public void action_zoom_out () {
            Zoom.handle_zoom (Gdk.ScrollDirection.DOWN);
        }

        private void action_set_default_zoom () {
            Zoom.set_default_zoom ();
        }

        private void on_bars_changed (Gtk.Notebook notebook) {
            var pages = notebook.get_n_pages ();
            notebook.set_show_tabs (pages > 1);
            notebook.no_show_all = (pages == 0);
            notebook.visible = (pages > 0);
        }

        private void next_page () {
            if ((notebook.get_current_page () + 1) == notebook.get_n_pages ()) {
                notebook.set_current_page (0);
            } else {
                notebook.next_page ();
            }
        }

        private void action_undo () {
            if (notebook.get_n_pages () > 0) {
                current_doc.sourceview.undo ();
            }
        }

        private void action_redo () {
            if (notebook.get_n_pages () > 0) {
                current_doc.sourceview.redo ();
            }
        }

        private void action_open () {
            notebook.open_dialog ();
        }

        private void action_open_folder () {
            var chooser = new Gtk.FileChooserDialog (
                "Select a folder.", this, Gtk.FileChooserAction.SELECT_FOLDER,
                "Cancel", Gtk.ResponseType.CANCEL,
                "Open", Gtk.ResponseType.ACCEPT);
            chooser.select_multiple = true;

            if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                SList<File> files = chooser.get_files ();
                files.foreach ((file) => {
                    explorer.open_folder (file.get_path ());
                });
            }

            chooser.destroy ();
        }

        private void action_save () {
            if (notebook.get_n_pages () > 0) {
                current_doc.save.begin ();
            }
        }

        private void action_search () {
            if (notebook.get_n_pages () > 0) {
                headerbar.search.show ();
            }
        }

        private void action_gotoline () {
            if (notebook.get_n_pages () > 0) {
                headerbar.gotoline.show ();
            }
        }

        private void action_new () {
            notebook.new_tab ();
        }

        private void action_save_as () {
            if (notebook.get_n_pages () > 0) {
                current_doc.save_as.begin ();
            }
        }

        private void action_save_all () {
            if (notebook.get_n_pages () > 0) {
                notebook.save_all ();
            }
        }

        private void action_replace () {
            if (notebook.get_n_pages () > 0) {
                replace = new iZiCodeEditor.Replace (this);
                replace.show_all ();
            }
        }

        private void action_close () {
            if (notebook.get_n_pages () > 0)
                notebook.close (notebook.get_nth_page (notebook.get_current_page ()));
        }

        private void action_close_all () {
            if (notebook.get_n_pages () > 0) {
                notebook.close_all ();
            }
        }

        private void action_preferences () {
            preferences = new iZiCodeEditor.Preferences (this);
            preferences.show_all ();
        }


        private void action_about () {
            show_about ();
        }

        private void action_quit () {
            set_saved_state ();
            notebook.close_all ();
            destroy ();
        }

        private void set_saved_state () {
            int width, height;
            get_size (out width, out height);
            Application.saved_state.set_boolean ("maximized", is_maximized);
            Application.saved_state.set_int ("width",            width);
            Application.saved_state.set_int ("height",           height);
            Application.saved_state.set_int ("left-paned-size",  leftPaned.position);
            Application.saved_state.set_int ("right-paned-size", rightPaned.position);
            Application.saved_state.set_int ("main-paned-size",  mainPaned.position);

            set_recent_files ();
            explorer.set_recent_folders ();

            Application.saved_state.set_uint ("active-tab", notebook.get_current_page ());
        }

        private void set_recent_files () {
            string[] recent_files = { };
            for (int i = 0; i < notebook.docs.length (); i++) {
                var sel_doc = notebook.docs.nth_data (i);
                if (sel_doc == null || sel_doc.is_file_temporary) {
                    continue;
                }
                recent_files += sel_doc.file.get_uri ();
            }
            Application.saved_state.set_strv ("recent-files", recent_files);
        }

        private void show_about () {
            var about = new Gtk.AboutDialog ();
            about.set_program_name (NAME);
            about.set_version (VERSION);
            about.set_comments (DESCRIPTION);
            about.set_logo_icon_name (ICON);
            about.set_icon_name (ICON);
            about.set_authors (AUTHORS);
            about.set_copyright ("Copyright \xc2\xa9 2017");
            about.set_website ("https://github.com/danielpinto8zz6");
            about.set_property ("skip-taskbar-hint", true);
            about.set_transient_for (this);
            about.license_type = Gtk.License.GPL_3_0;
            about.run ();
            about.hide ();
        }
    }
}
