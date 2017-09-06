namespace iZiCodeEditor{
    public class PrefDialog : Gtk.Dialog {

        Gtk.FontButton button_font ;
        Gtk.ComboBoxText button_scheme ;
        Gtk.SpinButton button_margin_pos ;
        Gtk.SpinButton button_indent_size ;
        Gtk.SpinButton button_tab_size ;

        Gtk.Switch button_numbers_show ;
        Gtk.Switch button_highlight ;
        Gtk.Switch button_margin_show ;
        Gtk.Switch button_spaces ;
        Gtk.Switch button_auto_indent ;
        Gtk.Switch button_pattern_show ;
        Gtk.Switch button_darktheme ;
        Gtk.Switch button_textwrap ;

        public void on_activate() {

            // Labels
            var label_font = new Gtk.Label ("Editor font") ;
            var label_scheme = new Gtk.Label ("Color scheme") ;
            var label_margin_pos = new Gtk.Label ("Margin width") ;
            var label_indent_size = new Gtk.Label ("Indent width") ;
            var label_tab_size = new Gtk.Label ("Tab width") ;
            var label_numbers_show = new Gtk.Label ("Show line numbers") ;
            var label_highlight = new Gtk.Label ("Highlight current line") ;
            var label_margin_show = new Gtk.Label ("Show margin on right") ;
            var label_spaces = new Gtk.Label ("Insert spaces instead of tabs") ;
            var label_auto_indent = new Gtk.Label ("Text auto indentation") ;
            var label_pattern_show = new Gtk.Label ("Show grid pattern") ;
            var label_darktheme = new Gtk.Label ("Use dark variant") ;
            var label_textwrap = new Gtk.Label ("Text wrap") ;

            label_font.set_halign (Gtk.Align.START) ;
            label_scheme.set_halign (Gtk.Align.START) ;
            label_margin_pos.set_halign (Gtk.Align.START) ;
            label_indent_size.set_halign (Gtk.Align.START) ;
            label_tab_size.set_halign (Gtk.Align.START) ;
            label_numbers_show.set_halign (Gtk.Align.START) ;
            label_highlight.set_halign (Gtk.Align.START) ;
            label_margin_show.set_halign (Gtk.Align.START) ;
            label_spaces.set_halign (Gtk.Align.START) ;
            label_auto_indent.set_halign (Gtk.Align.START) ;
            label_pattern_show.set_halign (Gtk.Align.START) ;
            label_darktheme.set_halign (Gtk.Align.START) ;
            label_textwrap.set_halign (Gtk.Align.START) ;

            label_font.set_hexpand (true) ;
            label_scheme.set_hexpand (true) ;
            label_margin_pos.set_hexpand (true) ;
            label_indent_size.set_hexpand (true) ;
            label_tab_size.set_hexpand (true) ;
            label_numbers_show.set_hexpand (true) ;
            label_highlight.set_hexpand (true) ;
            label_margin_show.set_hexpand (true) ;
            label_spaces.set_hexpand (true) ;
            label_auto_indent.set_hexpand (true) ;
            label_pattern_show.set_hexpand (true) ;
            label_darktheme.set_hexpand (true) ;
            label_textwrap.set_hexpand (true) ;

            // Buttons
            button_font = new Gtk.FontButton () ;
            button_scheme = new Gtk.ComboBoxText () ;
            button_margin_pos = new Gtk.SpinButton.with_range (70, 110, 1) ;
            button_indent_size = new Gtk.SpinButton.with_range (1, 8, 1) ;
            button_tab_size = new Gtk.SpinButton.with_range (1, 8, 1) ;
            button_numbers_show = new Gtk.Switch () ;
            button_highlight = new Gtk.Switch () ;
            button_margin_show = new Gtk.Switch () ;
            button_spaces = new Gtk.Switch () ;
            button_auto_indent = new Gtk.Switch () ;
            button_pattern_show = new Gtk.Switch () ;
            button_darktheme = new Gtk.Switch () ;
            button_textwrap = new Gtk.Switch () ;

            button_font.set_halign (Gtk.Align.END) ;
            button_scheme.set_halign (Gtk.Align.END) ;
            button_margin_pos.set_halign (Gtk.Align.END) ;
            button_indent_size.set_halign (Gtk.Align.END) ;
            button_tab_size.set_halign (Gtk.Align.END) ;
            button_numbers_show.set_halign (Gtk.Align.END) ;
            button_highlight.set_halign (Gtk.Align.END) ;
            button_margin_show.set_halign (Gtk.Align.END) ;
            button_spaces.set_halign (Gtk.Align.END) ;
            button_auto_indent.set_halign (Gtk.Align.END) ;
            button_pattern_show.set_halign (Gtk.Align.END) ;
            button_darktheme.set_halign (Gtk.Align.END) ;
            button_textwrap.set_halign (Gtk.Align.END) ;
            // Default values
            button_font.set_font_name (font) ;
            get_styles_list (button_scheme) ;
            button_margin_pos.set_value (margin_pos) ;
            button_indent_size.set_value (indent_size) ;
            button_tab_size.set_value (tab_size) ;
            button_numbers_show.set_active (numbers_show) ;
            button_highlight.set_active (highlight) ;
            button_margin_show.set_active (margin_show) ;
            button_spaces.set_active (spaces) ;
            button_auto_indent.set_active (auto_indent) ;
            button_pattern_show.set_active (pattern_show) ;
            button_darktheme.set_active (darktheme) ;
            button_textwrap.set_active (textwrap) ;
            // Connect signals
            button_font.font_set.connect (on_button_font_changed) ;
            button_scheme.changed.connect (on_button_scheme_changed) ;
            button_margin_pos.value_changed.connect (on_button_margin_pos_changed) ;
            button_indent_size.value_changed.connect (on_button_indent_size_changed) ;
            button_tab_size.value_changed.connect (on_button_tab_size_changed) ;
            button_numbers_show.notify["active"].connect (on_button_numbers_show_changed) ;
            button_highlight.notify["active"].connect (on_button_highlight_changed) ;
            button_margin_show.notify["active"].connect (on_button_margin_show_changed) ;
            button_spaces.notify["active"].connect (on_button_spaces_changed) ;
            button_auto_indent.notify["active"].connect (on_button_auto_indent_changed) ;
            button_pattern_show.notify["active"].connect (on_button_pattern_show_changed) ;
            button_darktheme.notify["active"].connect (on_button_darktheme_changed) ;
            button_textwrap.notify["active"].connect (on_button_textwrap_changed) ;
            // Dialog
            var preferences = new Gtk.Dialog () ;
            preferences.set_title ("Preferences") ;
            preferences.set_transient_for (window) ;
            preferences.set_property ("skip-taskbar-hint", true) ;
            preferences.set_resizable (false) ;

            var header = new Gtk.HeaderBar () ;
            header.set_show_close_button (true) ;
            header.set_title ("Preferences") ;
            preferences.set_titlebar (header) ;

            // Editor Grid
            var grid_editor = new Gtk.Grid () ;
            grid_editor.attach (label_font, 0, 0, 1, 1) ;
            grid_editor.attach (button_font, 1, 0, 1, 1) ;
            grid_editor.attach (label_scheme, 0, 1, 1, 1) ;
            grid_editor.attach (button_scheme, 1, 1, 1, 1) ;
            grid_editor.attach (label_margin_pos, 0, 2, 1, 1) ;
            grid_editor.attach (button_margin_pos, 1, 2, 1, 1) ;
            grid_editor.attach (label_indent_size, 0, 3, 1, 1) ;
            grid_editor.attach (button_indent_size, 1, 3, 1, 1) ;
            grid_editor.attach (label_tab_size, 0, 4, 1, 1) ;
            grid_editor.attach (button_tab_size, 1, 4, 1, 1) ;
            grid_editor.attach (label_textwrap, 0, 5, 1, 1) ;
            grid_editor.attach (button_textwrap, 1, 5, 1, 1) ;
            grid_editor.set_can_focus (false) ;
            grid_editor.set_margin_start (10) ;
            grid_editor.set_margin_end (10) ;
            grid_editor.set_margin_top (10) ;
            grid_editor.set_margin_bottom (10) ;
            grid_editor.set_row_spacing (10) ;
            grid_editor.set_column_spacing (10) ;

            // View Grid
            var grid_view = new Gtk.Grid () ;
            grid_view.attach (label_numbers_show, 0, 0, 1, 1) ;
            grid_view.attach (button_numbers_show, 1, 0, 1, 1) ;
            grid_view.attach (label_highlight, 0, 1, 1, 1) ;
            grid_view.attach (button_highlight, 1, 1, 1, 1) ;
            grid_view.attach (label_margin_show, 0, 2, 1, 1) ;
            grid_view.attach (button_margin_show, 1, 2, 1, 1) ;
            grid_view.attach (label_spaces, 0, 3, 1, 1) ;
            grid_view.attach (button_spaces, 1, 3, 1, 1) ;
            grid_view.attach (label_auto_indent, 0, 4, 1, 1) ;
            grid_view.attach (button_auto_indent, 1, 4, 1, 1) ;
            grid_view.attach (label_pattern_show, 0, 5, 1, 1) ;
            grid_view.attach (button_pattern_show, 1, 5, 1, 1) ;
            grid_view.attach (label_darktheme, 0, 6, 1, 1) ;
            grid_view.attach (button_darktheme, 1, 6, 1, 1) ;
            grid_view.set_can_focus (false) ;
            grid_view.set_margin_start (10) ;
            grid_view.set_margin_end (10) ;
            grid_view.set_margin_top (10) ;
            grid_view.set_margin_bottom (10) ;
            grid_view.set_row_spacing (10) ;
            grid_view.set_column_spacing (10) ;

            var pref_notebook = new Gtk.Notebook () ;
            pref_notebook.append_page (grid_view, new Gtk.Label ("Editor")) ;
            pref_notebook.append_page (grid_editor, new Gtk.Label ("View")) ;
            var content = preferences.get_content_area () as Gtk.Container ;
            content.add (pref_notebook) ;
            preferences.show_all () ;

        }

        private void get_styles_list(Gtk.ComboBoxText combo) {
            var manager = new Gtk.SourceStyleSchemeManager () ;
            string[] scheme_ids ;
            scheme_ids = manager.get_scheme_ids () ;
            foreach( string i in scheme_ids ){
                var scheme = manager.get_scheme (i) ;
                combo.append (scheme.id, scheme.name) ;
            }
            combo.set_active_id (scheme) ;
        }

        // 1. Editor
        private void on_button_font_changed() {
            font = button_font.get_font ().to_string () ;
            var settings = new iZiCodeEditor.Settings () ;
            var apply = new iZiCodeEditor.Apply () ;
            settings.set_font () ;
            apply.set_font () ;
        }

        private void on_button_scheme_changed() {
            scheme = button_scheme.get_active_id () ;
            var settings = new iZiCodeEditor.Settings () ;
            var apply = new iZiCodeEditor.Apply () ;
            settings.set_scheme () ;
            apply.set_scheme () ;
        }

        private void on_button_margin_pos_changed() {
            margin_pos = button_margin_pos.get_value_as_int () ;
            var settings = new iZiCodeEditor.Settings () ;
            var apply = new iZiCodeEditor.Apply () ;
            settings.set_margin_pos () ;
            apply.set_margin_pos () ;
        }

        private void on_button_indent_size_changed() {
            indent_size = button_indent_size.get_value_as_int () ;
            var settings = new iZiCodeEditor.Settings () ;
            var apply = new iZiCodeEditor.Apply () ;
            settings.set_indent_size () ;
            apply.set_indent_size () ;
        }

        private void on_button_tab_size_changed() {
            tab_size = button_tab_size.get_value_as_int () ;
            var settings = new iZiCodeEditor.Settings () ;
            var apply = new iZiCodeEditor.Apply () ;
            settings.set_tab_size () ;
            apply.set_tab_size () ;
        }

        // 2. View
        private void on_button_numbers_show_changed() {
            if( button_numbers_show.active ){
                numbers_show = true ;
            } else {
                numbers_show = false ;
            }
            var settings = new iZiCodeEditor.Settings () ;
            var apply = new iZiCodeEditor.Apply () ;
            settings.set_numbers_show () ;
            apply.set_numbers_show () ;
        }

        private void on_button_highlight_changed() {
            if( button_highlight.active ){
                highlight = true ;
            } else {
                highlight = false ;
            }
            var settings = new iZiCodeEditor.Settings () ;
            var apply = new iZiCodeEditor.Apply () ;
            settings.set_highlight () ;
            apply.set_highlight () ;
        }

        private void on_button_margin_show_changed() {
            if( button_margin_show.active ){
                margin_show = true ;
            } else {
                margin_show = false ;
            }
            var settings = new iZiCodeEditor.Settings () ;
            var apply = new iZiCodeEditor.Apply () ;
            settings.set_margin_show () ;
            apply.set_margin_show () ;
        }

        private void on_button_spaces_changed() {
            if( button_spaces.active ){
                spaces = true ;
            } else {
                spaces = false ;
            }
            var settings = new iZiCodeEditor.Settings () ;
            var apply = new iZiCodeEditor.Apply () ;
            settings.set_spaces () ;
            apply.set_spaces () ;
        }

        private void on_button_auto_indent_changed() {
            if( button_auto_indent.active ){
                auto_indent = true ;
            } else {
                auto_indent = false ;
            }
            var settings = new iZiCodeEditor.Settings () ;
            var apply = new iZiCodeEditor.Apply () ;
            settings.set_auto_indent () ;
            apply.set_auto_indent () ;
        }

        private void on_button_pattern_show_changed() {
            if( button_pattern_show.active ){
                pattern_show = true ;
            } else {
                pattern_show = false ;
            }
            var settings = new iZiCodeEditor.Settings () ;
            var apply = new iZiCodeEditor.Apply () ;
            settings.set_pattern_show () ;
            apply.set_pattern_show () ;
        }

        private void on_button_darktheme_changed() {
            if( button_darktheme.active ){
                darktheme = true ;
            } else {
                darktheme = false ;
            }
            var settings = new iZiCodeEditor.Settings () ;
            var apply = new iZiCodeEditor.Apply () ;
            settings.set_darktheme () ;
            apply.set_darktheme () ;
        }

        private void on_button_textwrap_changed() {
            if( button_textwrap.active ){
                textwrap = true ;
            } else {
                textwrap = false ;
            }
            var settings = new iZiCodeEditor.Settings () ;
            var apply = new iZiCodeEditor.Apply () ;
            settings.set_textwrap () ;
            apply.set_textwrap () ;
        }

    }
}
