namespace iZiCodeEditor{

    public class StatusBar : Gtk.ActionBar {
        construct {

            terminal_switch () ;
            tab_popover () ;
            zoom_popover () ;
            line_popover () ;
        }

        private void terminal_switch() {
            var terminal_switch = new Gtk.Button.from_icon_name ("terminal", Gtk.IconSize.SMALL_TOOLBAR) ;
            terminal_switch.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT) ;
            pack_start (terminal_switch) ;

            terminal_switch.clicked.connect (() => {
                Application.settings_terminal.set_boolean ("terminal", !Application.settings_terminal.get_boolean ("terminal")) ;
            }) ;
        }

        private void tab_popover() {
            uint width = Application.settings_editor.get_uint ("tab-size") ;

            string tab_width_string = string.join ("", "Tab width : ", width.to_string ()) ;

            var tab_width_button = new Gtk.Button.with_label (tab_width_string) ;
            tab_width_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT) ;

            var space_tab_label = new Gtk.Label ("Spaces instead of tabs") ;
            space_tab_label.set_halign (Gtk.Align.START) ;

            var width_label = new Gtk.Label ("Tab width") ;
            width_label.set_halign (Gtk.Align.START) ;

            var autoindent_label = new Gtk.Label ("Automatic indentation") ;
            autoindent_label.set_halign (Gtk.Align.START) ;

            var label_tab_size = new Gtk.Label ("Tab width") ;
            label_tab_size.set_halign (Gtk.Align.START) ;

            var autoindent_check = new Gtk.CheckButton () ;
            Application.settings_editor.bind ("auto-indent", autoindent_check, "active", SettingsBindFlags.DEFAULT) ;
            autoindent_check.set_halign (Gtk.Align.END) ;

            var space_tab_check = new Gtk.CheckButton () ;
            Application.settings_editor.bind ("spaces-instead-of-tabs", space_tab_check, "active", SettingsBindFlags.DEFAULT) ;
            space_tab_check.set_halign (Gtk.Align.END) ;

            var button_tab_size = new Gtk.SpinButton.with_range (1, 8, 1) ;
            Application.settings_editor.bind ("tab-size", button_tab_size, "value", SettingsBindFlags.DEFAULT) ;
            button_tab_size.set_halign (Gtk.Align.END) ;

            Application.settings_editor.changed["tab-size"].connect (() => {
                width = Application.settings_editor.get_uint ("tab-size") ;
                tab_width_string = string.join ("", "Tab width : ", width.to_string ()) ;
                tab_width_button.set_label (tab_width_string) ;
            }) ;

            var tab_grid = new Gtk.Grid () ;

            tab_grid.set_margin_start (12) ;
            tab_grid.set_margin_end (12) ;
            tab_grid.set_margin_top (12) ;
            tab_grid.set_margin_bottom (12) ;
            tab_grid.set_column_spacing (12) ;
            tab_grid.set_row_spacing (12) ;
            tab_grid.attach (autoindent_label, 0, 0, 1, 1) ;
            tab_grid.attach (autoindent_check, 1, 0, 1, 1) ;
            tab_grid.attach (space_tab_label, 0, 1, 1, 1) ;
            tab_grid.attach (space_tab_check, 1, 1, 1, 1) ;
            tab_grid.attach (label_tab_size, 0, 2, 1, 1) ;
            tab_grid.attach (button_tab_size, 1, 2, 1, 1) ;

            tab_grid.show_all () ;

            var tab_width_popover = new Gtk.Popover (tab_width_button) ;

            tab_width_popover.add (tab_grid) ;

            tab_width_button.clicked.connect (tab_width_popover.show_all) ;

            pack_end (tab_width_button) ;

        }

        private void line_popover() {

            var line_button = new Gtk.Button.with_label ("Linhas : 1") ;
            line_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT) ;

            var show_line_numbers_label = new Gtk.Label ("Show line numbers") ;
            show_line_numbers_label.set_halign (Gtk.Align.START) ;

            var show_right_margin_label = new Gtk.Label ("Show right margin") ;
            show_right_margin_label.set_halign (Gtk.Align.START) ;

            var highlight_current_line_label = new Gtk.Label ("Highlight current line") ;
            highlight_current_line_label.set_halign (Gtk.Align.START) ;

            var text_wrap_label = new Gtk.Label ("Text wrap") ;
            text_wrap_label.set_halign (Gtk.Align.START) ;

            var show_line_numbers_button = new Gtk.CheckButton () ;
            Application.settings_view.bind ("numbers-show", show_line_numbers_button, "active", SettingsBindFlags.DEFAULT) ;
            show_line_numbers_button.set_halign (Gtk.Align.END) ;

            var show_right_margin_button = new Gtk.CheckButton () ;
            Application.settings_view.bind ("margin-show", show_right_margin_button, "active", SettingsBindFlags.DEFAULT) ;
            show_right_margin_button.set_halign (Gtk.Align.END) ;

            var highlight_current_line_button = new Gtk.CheckButton () ;
            Application.settings_editor.bind ("highlight-current-line", highlight_current_line_button, "active", SettingsBindFlags.DEFAULT) ;
            highlight_current_line_button.set_halign (Gtk.Align.END) ;

            var text_wrap_button = new Gtk.CheckButton () ;
            Application.settings_view.bind ("text-wrap", text_wrap_button, "active", SettingsBindFlags.DEFAULT) ;
            text_wrap_button.set_halign (Gtk.Align.END) ;

            var line_grid = new Gtk.Grid () ;

            line_grid.set_margin_start (12) ;
            line_grid.set_margin_end (12) ;
            line_grid.set_margin_top (12) ;
            line_grid.set_margin_bottom (12) ;
            line_grid.set_column_spacing (12) ;
            line_grid.set_row_spacing (12) ;
            line_grid.attach (show_line_numbers_label, 0, 0, 1, 1) ;
            line_grid.attach (show_line_numbers_button, 1, 0, 1, 1) ;
            line_grid.attach (show_right_margin_label, 0, 1, 1, 1) ;
            line_grid.attach (show_right_margin_button, 1, 1, 1, 1) ;
            line_grid.attach (highlight_current_line_label, 0, 2, 1, 1) ;
            line_grid.attach (highlight_current_line_button, 1, 2, 1, 1) ;
            line_grid.attach (text_wrap_label, 0, 3, 1, 1) ;
            line_grid.attach (text_wrap_button, 1, 3, 1, 1) ;

            line_grid.show_all () ;

            var line_popover = new Gtk.Popover (line_button) ;

            line_popover.add (line_grid) ;

            line_button.clicked.connect (line_popover.show_all) ;

            pack_end (line_button) ;

        }

        private void zoom_popover() {
            var sourceview = new iZiCodeEditor.SourceView () ;
            Gtk.Button zoomButton = new Gtk.Button.from_icon_name ("zoom", Gtk.IconSize.SMALL_TOOLBAR) ;
            zoomButton.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT) ;

            var minusButton = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.BUTTON) ;
            minusButton.set_can_focus (false) ;
            minusButton.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT) ;
            minusButton.clicked.connect (sourceview.zoom_out) ;

            var plusButton = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.BUTTON) ;
            plusButton.set_can_focus (false) ;
            plusButton.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT) ;
            plusButton.clicked.connect (sourceview.zoom_in) ;

            var resetButton = new Gtk.Button.with_label ("Reset") ;
            resetButton.set_can_focus (false) ;
            resetButton.clicked.connect (sourceview.set_default_zoom) ;

            Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) ;
            box.pack_start (minusButton, false, false, 0) ;
            box.pack_start (plusButton, false, false, 0) ;
            box.pack_start (resetButton, false, false, 0) ;
            box.valign = Gtk.Align.CENTER ;
            box.set_border_width (3) ;

            var zoomPopover = new Gtk.Popover (zoomButton) ;

            zoomPopover.add (box) ;

            zoomButton.clicked.connect (zoomPopover.show_all) ;

            pack_end (zoomButton) ;

        }

    }
}
