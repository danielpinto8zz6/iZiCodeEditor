namespace iZiCodeEditor {
    public class Document : Gtk.Grid {
        public iZiCodeEditor.SourceView sourceview;

        private Gtk.SourceMap source_map;

        private Gtk.SourceFile sourcefile = null;

        public unowned ApplicationWindow window {
            get {
                return notebook.window;
            }
        }

        public File file {
            get {
                return sourcefile.location;
            }
            set {
                sourcefile.set_location (value);
                label.label = get_file_name ();
                label.tooltip_text = get_file_path ();
            }
        }

        public Gtk.Box tab_label;

        private Gtk.Label label;

        public Gtk.ScrolledWindow scroll;

        private bool ask_if_externally_modified = false;
        private bool ask_if_deleted = false;

        public bool is_file_temporary = false;

        public unowned Notebook notebook { get; construct set; }

        public Document (File file, Notebook notebook) {
            Object (notebook: notebook,
                    file: file);

            Idle.add_full (GLib.Priority.LOW, () => {
                open.begin ((obj, res) => {
                    open.end (res);
                });

                return false;
            });

            sourceview.update_syntax_highlighting ();
        }

        public Document.new_doc (Notebook notebook) {
            Object (notebook: notebook);
            is_file_temporary = true;

            label.label = get_file_name ();
        }

        static construct {
            try {
                var provider = new Gtk.CssProvider ();
                var css_stuff = """ .close-tab-button { padding :0; } """;
                provider.load_from_data (css_stuff, css_stuff.length);
            } catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
        }

        construct {
            label = new Gtk.Label ("");
            label.set_size_request (100, -1);
            label.ellipsize = Pango.EllipsizeMode.END;

            var eventbox = new Gtk.EventBox ();
            eventbox.add (label);
            eventbox.button_press_event.connect ((event) => {
                if (event.button == 2) {
                    notebook.close (this);
                }
                return false;
            });
            var tab_button = new Gtk.Button.from_icon_name ("window-close-symbolic",
                                                            Gtk.IconSize.MENU);
            tab_button.set_relief (Gtk.ReliefStyle.NONE);
            tab_button.set_hexpand (false);

            tab_button.get_style_context ().add_class ("close-tab-button");
            tab_button.clicked.connect (() => {
                notebook.close (this);
            });
            tab_label = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            tab_label.pack_start (eventbox);
            tab_label.pack_end (tab_button);
            tab_label.show_all ();

            sourceview = new iZiCodeEditor.SourceView (this);
            source_map = new Gtk.SourceMap ();
            sourcefile = new Gtk.SourceFile ();

            scroll = new Gtk.ScrolledWindow (null, null);
            scroll.add (sourceview);
            scroll.set_hexpand (true);
            scroll.set_vexpand (true);

            source_map.set_view (sourceview);

            if (Application.settings_view.get_boolean ("source-map")) {
                source_map.show ();
                scroll.vscrollbar_policy = Gtk.PolicyType.EXTERNAL;
            } else {
                source_map.hide ();
                source_map.no_show_all = true;
                scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
            }
            Application.settings_view.changed["source-map"].connect (() => {
                if (Application.settings_view.get_boolean ("source-map")) {
                    source_map.show ();
                    scroll.vscrollbar_policy = Gtk.PolicyType.EXTERNAL;
                } else {
                    source_map.hide ();
                    source_map.no_show_all = true;
                    scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
                }
            });

            sourceview.focus_in_event.connect (view_focused_in);

            sourceview.buffer.modified_changed.connect (() => {
                set_status ();
            });

            attach (scroll, 0, 1, 1, 1);
            attach_next_to (source_map, scroll, Gtk.PositionType.RIGHT, 1, 1);

            show_all ();
        }

        private bool view_focused_in () {
            sourcefile.check_file_on_disk ();

            if (!ask_if_deleted && sourcefile.is_deleted ()) {
                ask_if_deleted = true;

                Gtk.InfoBar infobar = new Gtk.InfoBar ();

                infobar.add_button ("Save",   Gtk.ResponseType.OK);
                infobar.add_button ("Ignore", Gtk.ResponseType.REJECT);

                string msg = "The file %s was deleted. Do you want to save it?"
                             .printf (file.get_parse_name ());

                Gtk.Container content = infobar.get_content_area ();
                var info = new Gtk.Label (msg);
                content.add (info);

                infobar.set_message_type (Gtk.MessageType.WARNING);

                attach (infobar, 0, 0, 2, 1);

                infobar.show_all ();

                infobar.response.connect ((response_id) =>
                {
                    if (response_id == Gtk.ResponseType.OK) {
                        save_as.begin ();
                        ask_if_deleted = false;
                    }
                    sourceview.grab_focus ();
                    infobar.destroy ();
                });
            } else if (!ask_if_externally_modified && sourcefile.is_local ()
                       && sourcefile.is_externally_modified ()) {
                ask_if_externally_modified = true;

                Gtk.InfoBar infobar = new Gtk.InfoBar ();

                infobar.add_button ("Reload", Gtk.ResponseType.OK);
                infobar.add_button ("Ignore", Gtk.ResponseType.REJECT);

                string msg = "The file %s changed on disk. Reload it?"
                             .printf (file.get_parse_name ());

                Gtk.Container content = infobar.get_content_area ();
                var info = new Gtk.Label (msg);
                content.add (info);

                infobar.set_message_type (Gtk.MessageType.WARNING);

                attach (infobar, 0, 0, 2, 1);

                infobar.show_all ();

                infobar.response.connect ((response_id) =>
                {
                    if (response_id == Gtk.ResponseType.OK) {
                        open.begin ();
                        ask_if_externally_modified = false;
                    }
                    infobar.destroy ();
                    sourceview.grab_focus ();
                });
            }
            return false;
        }

        private async bool open () {
            sourceview.sensitive = false;

            var buffer = new Gtk.SourceBuffer (null);

            try {
                var source_file_loader = new Gtk.SourceFileLoader (buffer, sourcefile);
                yield source_file_loader.load_async (GLib.Priority.DEFAULT, null, null);

                sourceview.buffer.text = buffer.text;
            } catch (Error e) {
                sourceview.buffer.text = "";
                critical (e.message);
                return false;
            }

            sourceview.buffer.set_modified (false);

            Gtk.TextIter iter_st;
            sourceview.buffer.get_start_iter (out iter_st);
            sourceview.buffer.place_cursor (iter_st);
            sourceview.scroll_to_iter (iter_st, 0.10, false, 0, 0);

            sourceview.sensitive = true;

            sourceview.grab_focus ();

            return true;
        }

        public async bool save () {
            if (!sourceview.buffer.get_modified ()) {
                return false;
            } else if (is_file_temporary) {
                save_as.begin ();
            }

            try {
                var source_file_saver = new Gtk.SourceFileSaver ((Gtk.SourceBuffer)sourceview.buffer, sourcefile);

                yield source_file_saver.save_async (GLib.Priority.DEFAULT, null, null);
            } catch (Error e) {
                save_fallback ();
                stderr.printf ("error: %s\n", e.message);
                return false;
            }
            sourceview.buffer.set_modified (false);

            return true;
        }

        private void save_fallback () {
            var dialog = new Gtk.MessageDialog (window,
                                                Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.NONE,
                                                "Error saving file %s.\n", file.get_parse_name ());
            dialog.add_button ("Don't save",          Gtk.ResponseType.NO);
            dialog.add_button ("Select New Location", Gtk.ResponseType.YES);
            dialog.set_resizable (false);
            dialog.set_default_response (Gtk.ResponseType.YES);
            int response = dialog.run ();
            switch (response) {
            case Gtk.ResponseType.NO :
                break;
            case Gtk.ResponseType.YES :
                save_as.begin ();
                break;
            }
            dialog.destroy ();
        }

        public async bool save_as () {
            var dialog = new Gtk.FileChooserDialog ("Save As...", window,
                                                    Gtk.FileChooserAction.SAVE,
                                                    "Cancel", Gtk.ResponseType.CANCEL,
                                                    "Save", Gtk.ResponseType.ACCEPT);
            dialog.set_do_overwrite_confirmation (true);
            dialog.set_modal (true);
            dialog.show ();
            if (dialog.run () == Gtk.ResponseType.ACCEPT) {
                file = File.new_for_uri (dialog.get_file ().get_uri ());

                sourceview.buffer.set_modified (true);

                is_file_temporary = false;

                var is_saved = yield save ();

                if (is_saved) {
                    sourceview.update_syntax_highlighting ();
                }

                dialog.destroy ();
            }
            return true;
        }

        public void set_status () {
            string unsaved_identifier = "* ";

            if (sourceview.buffer.get_modified ()) {
                if (!(unsaved_identifier in name)) {
                    label.label = unsaved_identifier + label.label;
                }
            } else {
                label.label = label.label.replace (unsaved_identifier, "");
            }
        }

        public Gtk.Box get_tab_label () {
            return (Gtk.Box)tab_label;
        }

        public string get_file_name () {
            return !is_file_temporary ? file.get_basename () : "New document";
        }

        public string get_file_path () {
            return !is_file_temporary ? file.get_parse_name () : null;
        }
    }
}
