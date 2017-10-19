namespace iZiCodeEditor{

    public class StatusBar : Gtk.ActionBar {
        construct {
            var terminal_switch = new Gtk.Button.from_icon_name ("terminal", Gtk.IconSize.SMALL_TOOLBAR) ;
            terminal_switch.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT) ;
            pack_start (terminal_switch) ;

            terminal_switch.clicked.connect (() => {
                Application.settings_terminal.set_boolean ("terminal", !Application.settings_terminal.get_boolean ("terminal")) ;
            }) ;

            tab_popover () ;
            zoom_popover () ;
        }

        private void tab_popover() {
            uint width = Application.settings_editor.get_uint ("tab-size") ;

            string tab_width_string = string.join ("", "Tab width : ", width.to_string ()) ;

            var tab_width_button = new Gtk.Button.with_label (tab_width_string) ;
            tab_width_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT) ;

            var space_tab_label = new Gtk.Label ("Insert spaces instead of tabs:") ;
            space_tab_label.set_halign (Gtk.Align.START) ;

            var width_label = new Gtk.Label ("Tab width:") ;
            width_label.set_halign (Gtk.Align.START) ;

            var autoindent_label = new Gtk.Label ("Automatic indentation:") ;
            autoindent_label.set_halign (Gtk.Align.START) ;

            var autoindent_switch = new Gtk.Switch () ;
            autoindent_switch.set_halign (Gtk.Align.END) ;
            Application.settings_editor.bind ("auto-indent", autoindent_switch, "active", SettingsBindFlags.DEFAULT) ;

            var tab_width = new Gtk.SpinButton.with_range (1, 24, 1) ;
            tab_width.set_halign (Gtk.Align.END) ;
            Application.settings_editor.bind ("tab-size", tab_width, "value", SettingsBindFlags.DEFAULT) ;

            var space_tab_switch = new Gtk.Switch () ;
            space_tab_switch.set_halign (Gtk.Align.END) ;
            Application.settings_editor.bind ("spaces-instead-of-tabs", space_tab_switch, "active", SettingsBindFlags.DEFAULT) ;

            Application.settings_editor.changed["tab-size"].connect (() => {
                width = Application.settings_editor.get_uint ("tab-size") ;
                tab_width_string = string.join ("", "Tab width : ", width.to_string ()) ;
                tab_width_button.set_label (tab_width_string) ;
            }) ;
            var tab_grid = new Gtk.Grid () ;

            tab_grid.set_margin_start (3) ;
            tab_grid.set_margin_end (3) ;
            tab_grid.set_margin_top (3) ;
            tab_grid.set_margin_bottom (3) ;
            tab_grid.set_column_spacing (3) ;
            tab_grid.set_row_spacing (3) ;
            tab_grid.attach (autoindent_label, 0, 0, 1, 1) ;
            tab_grid.attach (autoindent_switch, 1, 0, 1, 1) ;
            tab_grid.attach (space_tab_label, 0, 1, 1, 1) ;
            tab_grid.attach (space_tab_switch, 1, 1, 1, 1) ;
            tab_grid.attach (width_label, 0, 2, 1, 1) ;
            tab_grid.attach (tab_width, 1, 2, 1, 1) ;
            tab_grid.show_all () ;

            var tab_width_popover = new Gtk.Popover (tab_width_button) ;

            tab_width_popover.add (tab_grid) ;

            tab_width_button.clicked.connect (tab_width_popover.show_all) ;

            pack_end (tab_width_button) ;

        }

        private void zoom_popover() {
            var sourceview = new iZiCodeEditor.SourceView () ;
            Gtk.Button zoomButton = new Gtk.Button.from_icon_name ("zoom", Gtk.IconSize.SMALL_TOOLBAR) ;
            zoomButton.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT) ;
            pack_start (zoomButton) ;

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
