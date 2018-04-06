namespace iZiCodeEditor {
    public class StatusBar : Gtk.ActionBar {
        private Gtk.SourceLanguageManager manager;

        private const string lang_fallback = "Plain text";

        private Gtk.ListBox lang_listbox;

        private Gtk.Button lang_button;

        private Gtk.Button line_button;

        private Gtk.Button tab_width_button;

        private Gtk.Label insmode_label;

        private unowned Document ? doc = null;

        construct {
            manager = Gtk.SourceLanguageManager.get_default ();

            insmode_label = new Gtk.Label ("");
            insmode_label.width_request = 60;

            lang_button = new Gtk.Button.with_label (lang_fallback);
            lang_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            lang_button.width_request = 120;

            lang_listbox = new Gtk.ListBox ();

            var label_fallback = new Gtk.Label (lang_fallback);
            label_fallback.set_halign (Gtk.Align.START);
            lang_listbox.add (label_fallback);

            foreach (var lang_id in manager.get_language_ids ()) {
                var label = new Gtk.Label (manager.get_language (lang_id).name);
                label.set_halign (Gtk.Align.START);
                lang_listbox.add (label);
            }

            var lang_scrolled = new Gtk.ScrolledWindow (null, null);
            lang_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
            lang_scrolled.height_request = 350;
            lang_scrolled.expand = true;
            lang_scrolled.margin_top = lang_scrolled.margin_bottom = 6;
            lang_scrolled.add (lang_listbox);

            Gtk.Box lang_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            lang_box.valign = Gtk.Align.CENTER;
            lang_box.set_border_width (6);
            lang_box.width_request = 250;

            var searchentry = new Gtk.SearchEntry ();

            lang_listbox.set_filter_func ((row) => {
                return (((row as Gtk.ListBoxRow).get_child () as Gtk.Label).label.down ().contains (searchentry.text.down ().strip ()));
            });

            searchentry.search_changed.connect (() => {
                lang_listbox.invalidate_filter ();
            });

            lang_box.pack_start (searchentry,   false, false, 0);
            lang_box.pack_start (lang_scrolled, false, false, 0);

            var lang_popover = new Gtk.Popover (lang_button);

            lang_popover.add (lang_box);

            lang_button.clicked.connect (lang_popover.show_all);

            lang_listbox.row_activated.connect (row => {
                string language = ((row as Gtk.ListBoxRow).get_child () as Gtk.Label).label;

                if (language != doc.sourceview.language.name) {
                    doc.sourceview.language = language != null ? get_selected_language (language) : null;
                    lang_button.set_label (language);
                }
                lang_popover.hide ();
            });

            uint width = Application.settings_editor.get_uint ("tab-size");

            string tab_width_string = string.join ("", "Tab width : ", width.to_string ());

            tab_width_button = new Gtk.Button.with_label (tab_width_string);
            tab_width_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            tab_width_button.width_request = 120;

            var space_tab_label = new Gtk.Label ("Spaces instead of tabs");
            space_tab_label.set_halign (Gtk.Align.START);

            var width_label = new Gtk.Label ("Tab width");
            width_label.set_halign (Gtk.Align.START);

            var autoindent_label = new Gtk.Label ("Automatic indentation");
            autoindent_label.set_halign (Gtk.Align.START);

            var label_tab_size = new Gtk.Label ("Tab width");
            label_tab_size.set_halign (Gtk.Align.START);

            var autoindent_check = new Gtk.CheckButton ();
            Application.settings_editor.bind ("auto-indent", autoindent_check, "active", SettingsBindFlags.DEFAULT);
            autoindent_check.set_halign (Gtk.Align.END);

            var space_tab_check = new Gtk.CheckButton ();
            Application.settings_editor.bind ("spaces-instead-of-tabs", space_tab_check, "active", SettingsBindFlags.DEFAULT);
            space_tab_check.set_halign (Gtk.Align.END);

            var button_tab_size = new Gtk.SpinButton.with_range (1, 8, 1);
            Application.settings_editor.bind ("tab-size", button_tab_size, "value", SettingsBindFlags.DEFAULT);
            button_tab_size.set_halign (Gtk.Align.END);

            Application.settings_editor.changed["tab-size"].connect (() => {
                width = Application.settings_editor.get_uint ("tab-size");
                tab_width_string = string.join ("", "Tab width : ", width.to_string ());
                tab_width_button.set_label (tab_width_string);
            });

            var tab_grid = new Gtk.Grid ();

            tab_grid.set_margin_start (12);
            tab_grid.set_margin_end (12);
            tab_grid.set_margin_top (12);
            tab_grid.set_margin_bottom (12);
            tab_grid.set_column_spacing (12);
            tab_grid.set_row_spacing (12);
            tab_grid.attach (autoindent_label, 0, 0, 1, 1);
            tab_grid.attach (autoindent_check, 1, 0, 1, 1);
            tab_grid.attach (space_tab_label,  0, 1, 1, 1);
            tab_grid.attach (space_tab_check,  1, 1, 1, 1);
            tab_grid.attach (label_tab_size,   0, 2, 1, 1);
            tab_grid.attach (button_tab_size,  1, 2, 1, 1);

            var tab_width_popover = new Gtk.Popover (tab_width_button);

            tab_width_popover.add (tab_grid);

            tab_width_button.clicked.connect (tab_width_popover.show_all);

            line_button = new Gtk.Button.with_label ("");
            line_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            line_button.width_request = 120;

            var show_line_numbers_label = new Gtk.Label ("Show line numbers");
            show_line_numbers_label.set_halign (Gtk.Align.START);

            var show_right_margin_label = new Gtk.Label ("Show right margin");
            show_right_margin_label.set_halign (Gtk.Align.START);

            var highlight_current_line_label = new Gtk.Label ("Highlight current line");
            highlight_current_line_label.set_halign (Gtk.Align.START);

            var text_wrap_label = new Gtk.Label ("Text wrap");
            text_wrap_label.set_halign (Gtk.Align.START);

            var show_line_numbers_button = new Gtk.CheckButton ();
            Application.settings_view.bind ("numbers-show", show_line_numbers_button, "active", SettingsBindFlags.DEFAULT);
            show_line_numbers_button.set_halign (Gtk.Align.END);

            var show_right_margin_button = new Gtk.CheckButton ();
            Application.settings_view.bind ("margin-show", show_right_margin_button, "active", SettingsBindFlags.DEFAULT);
            show_right_margin_button.set_halign (Gtk.Align.END);

            var highlight_current_line_button = new Gtk.CheckButton ();
            Application.settings_editor.bind ("highlight-current-line", highlight_current_line_button, "active", SettingsBindFlags.DEFAULT);
            highlight_current_line_button.set_halign (Gtk.Align.END);

            var text_wrap_button = new Gtk.CheckButton ();
            Application.settings_view.bind ("text-wrap", text_wrap_button, "active", SettingsBindFlags.DEFAULT);
            text_wrap_button.set_halign (Gtk.Align.END);

            var line_grid = new Gtk.Grid ();

            line_grid.set_margin_start (12);
            line_grid.set_margin_end (12);
            line_grid.set_margin_top (12);
            line_grid.set_margin_bottom (12);
            line_grid.set_column_spacing (12);
            line_grid.set_row_spacing (12);
            line_grid.attach (show_line_numbers_label,       0, 0, 1, 1);
            line_grid.attach (show_line_numbers_button,      1, 0, 1, 1);
            line_grid.attach (show_right_margin_label,       0, 1, 1, 1);
            line_grid.attach (show_right_margin_button,      1, 1, 1, 1);
            line_grid.attach (highlight_current_line_label,  0, 2, 1, 1);
            line_grid.attach (highlight_current_line_button, 1, 2, 1, 1);
            line_grid.attach (text_wrap_label,               0, 3, 1, 1);
            line_grid.attach (text_wrap_button,              1, 3, 1, 1);

            var line_popover = new Gtk.Popover (line_button);

            line_popover.add (line_grid);

            line_button.clicked.connect (line_popover.show_all);


            var terminal_switch = new Gtk.Button.from_icon_name ("terminal", Gtk.IconSize.SMALL_TOOLBAR);
            terminal_switch.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            terminal_switch.clicked.connect (() => {
                Application.settings_terminal.set_boolean ("terminal", !Application.settings_terminal.get_boolean ("terminal"));
            });

            pack_start (terminal_switch);
            pack_end (insmode_label);
            pack_end (lang_button);
            pack_end (tab_width_button);
            pack_end (line_button);

            if (Application.settings_view.get_boolean ("status-bar")) {
                show ();
            } else {
                hide ();
            }

            Application.settings_view.changed["status-bar"].connect (() => {
                if (Application.settings_view.get_boolean ("status-bar")) {
                    show ();
                } else {
                    hide ();
                }
            });
        }

        private void update_statusbar_insmode () {
            insmode_label.set_label (doc.sourceview.overwrite ? "OVR" : "INS");
        }

        private void update_statusbar_line () {
            var buffer = doc.sourceview.buffer;
            var position = doc.sourceview.buffer.cursor_position;
            Gtk.TextIter iter;
            buffer.get_iter_at_offset (out iter, position);
            line_button.set_label ("Ln %d, Col %d".printf (iter.get_line () + 1, iter.get_line_offset () + 1));
        }

        private void update_statusbar_language () {
            var language = doc.sourceview.language;
            if (language != null) {
                lang_button.set_label (language.name);
                lang_listbox.select_row (listbox_get_row (language.name));
            } else {
                lang_button.set_label (lang_fallback);
                lang_listbox.select_row (listbox_get_row (lang_fallback));
            }
        }

        private Gtk.ListBoxRow listbox_get_row (string lang) {
            var selected_row = new Gtk.ListBoxRow ();
            lang_listbox.foreach (widget => {
                if (lang == ((widget as Gtk.ListBoxRow).get_child () as Gtk.Label).label) {
                    selected_row = (Gtk.ListBoxRow)widget;
                }
            });
            return selected_row;
        }

        private Gtk.SourceLanguage get_selected_language (string language) {
            Gtk.SourceLanguage selected = null;
            foreach (var lang_id in manager.get_language_ids ()) {
                if (manager.get_language (lang_id).name == language) {
                    selected = manager.get_language (lang_id);
                }
            }
            return selected;
        }

        public void set_doc (Document ? doc = null) {
            if (this.doc != null) {
                this.doc.sourceview.buffer.notify["cursor-position"].disconnect (update_statusbar_line);
                this.doc.sourceview.notify["overwrite"].disconnect (update_statusbar_insmode);
            }
            if (doc != null) {
                this.doc = doc;
                update_statusbar_language ();
                update_statusbar_line ();
                update_statusbar_insmode ();
                this.doc.sourceview.buffer.notify["cursor-position"].connect (update_statusbar_line);
                this.doc.sourceview.notify["overwrite"].connect (update_statusbar_insmode);

                lang_listbox.show ();
                lang_button.show ();
                line_button.show ();
                insmode_label.show ();
                tab_width_button.show ();
            } else {
                lang_listbox.hide ();
                lang_button.hide ();
                line_button.hide ();
                insmode_label.hide ();
                tab_width_button.hide ();
            }
        }

        public void hide_buttons () {
            lang_listbox.hide ();
            lang_button.hide ();
            line_button.hide ();
            insmode_label.hide ();
            tab_width_button.hide ();
        }
    }
}
