namespace iZiCodeEditor{
    public class PrefDialog : Gtk.Dialog {

        Gtk.FontButton button_font ;
        Gtk.SourceStyleSchemeChooserWidget widget_scheme ;
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
        Gtk.Switch button_source_map ;
        Gtk.Switch button_highlight_matching_brackets ;

        public void on_activate() {

            // Labels
            var label_font = new Gtk.Label ("Editor font") ;
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
            var label_font_header = new Gtk.Label ("<b>Font</b>") ;
            var label_color_header = new Gtk.Label ("<b>Color Scheme</b>") ;
            var label_tabs_header = new Gtk.Label ("<b>Tab Stops</b>") ;
            var label_wrap_header = new Gtk.Label ("<b>Text Wrapping</b>") ;
            var label_highlight_header = new Gtk.Label ("<b>Highlighting</b>") ;
            var label_margin_header = new Gtk.Label ("<b>Margin</b>") ;
            var label_theme_header = new Gtk.Label ("<b>Theme</b>") ;
            var label_source_header = new Gtk.Label ("<b>Source</b>") ;
            var label_indent_header = new Gtk.Label ("<b>Indent</b>") ;
            var label_source_map_header = new Gtk.Label ("<b>Source Map</b>") ;
            var label_source_map = new Gtk.Label ("Show source map") ;
            var label_highlight_matching_brackets = new Gtk.Label ("Highlight matching brackets") ;

            label_font.set_halign (Gtk.Align.START) ;
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
            label_font_header.set_halign (Gtk.Align.START) ;
            label_color_header.set_halign (Gtk.Align.START) ;
            label_tabs_header.set_halign (Gtk.Align.START) ;
            label_wrap_header.set_halign (Gtk.Align.START) ;
            label_highlight_header.set_halign (Gtk.Align.START) ;
            label_margin_header.set_halign (Gtk.Align.START) ;
            label_theme_header.set_halign (Gtk.Align.START) ;
            label_source_header.set_halign (Gtk.Align.START) ;
            label_indent_header.set_halign (Gtk.Align.START) ;
            label_source_map.set_halign (Gtk.Align.START) ;
            label_source_map_header.set_halign (Gtk.Align.START) ;
            label_highlight_matching_brackets.set_halign (Gtk.Align.START) ;

            label_font.set_hexpand (true) ;
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
            label_font_header.set_hexpand (true) ;
            label_color_header.set_hexpand (true) ;
            label_tabs_header.set_hexpand (true) ;
            label_wrap_header.set_hexpand (true) ;
            label_highlight_header.set_hexpand (true) ;
            label_margin_header.set_hexpand (true) ;
            label_theme_header.set_hexpand (true) ;
            label_source_header.set_hexpand (true) ;
            label_indent_header.set_hexpand (true) ;
            label_source_map.set_hexpand (true) ;
            label_source_map_header.set_hexpand (true) ;
            label_highlight_matching_brackets.set_hexpand (true) ;

            label_font_header.set_use_markup (true) ;
            label_color_header.set_use_markup (true) ;
            label_tabs_header.set_use_markup (true) ;
            label_wrap_header.set_use_markup (true) ;
            label_highlight_header.set_use_markup (true) ;
            label_margin_header.set_use_markup (true) ;
            label_theme_header.set_use_markup (true) ;
            label_source_header.set_use_markup (true) ;
            label_indent_header.set_use_markup (true) ;
            label_source_map_header.set_use_markup (true) ;

            label_font_header.set_line_wrap (true) ;
            label_color_header.set_line_wrap (true) ;
            label_tabs_header.set_line_wrap (true) ;
            label_wrap_header.set_line_wrap (true) ;
            label_highlight_header.set_line_wrap (true) ;
            label_margin_header.set_line_wrap (true) ;
            label_theme_header.set_line_wrap (true) ;
            label_source_header.set_line_wrap (true) ;
            label_indent_header.set_line_wrap (true) ;
            label_source_map_header.set_line_wrap (true) ;

            // Buttons
            button_font = new Gtk.FontButton () ;
            widget_scheme = new Gtk.SourceStyleSchemeChooserWidget () ;
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
            button_source_map = new Gtk.Switch () ;
            button_highlight_matching_brackets = new Gtk.Switch () ;

            button_font.set_halign (Gtk.Align.END) ;
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
            button_source_map.set_halign (Gtk.Align.END) ;
            button_highlight_matching_brackets.set_halign (Gtk.Align.END) ;

            var scroll_scheme = new Gtk.ScrolledWindow (null, null) ;
            scroll_scheme.add (widget_scheme) ;
            scroll_scheme.set_hexpand (true) ;
            scroll_scheme.set_vexpand (true) ;

            button_font.set_font_name (Application.settings.get_string ("font")) ;
            button_font.notify["font"].connect (() => {
                Application.settings.set_string ("font", button_font.get_font ().to_string ()) ;
            }) ;
            Application.settings.bind ("indent-size", button_indent_size, "value", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("tab-size", button_tab_size, "value", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("numbers-show", button_numbers_show, "active", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("highlight-current-line", button_highlight, "active", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("margin-show", button_margin_show, "active", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("margin-pos", button_margin_pos, "value", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("spaces-instead-of-tabs", button_spaces, "active", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("auto-indent", button_auto_indent, "active", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("pattern-show", button_pattern_show, "active", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("dark-mode", button_darktheme, "active", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("text-wrap", button_textwrap, "active", SettingsBindFlags.DEFAULT) ;
            Application.settings.bind ("source-map", button_source_map, "active", SettingsBindFlags.DEFAULT) ;

            widget_scheme.style_scheme = Gtk.SourceStyleSchemeManager.get_default ().get_scheme (Application.settings.get_string ("color-scheme")) ;
            widget_scheme.notify["style-scheme"].connect (() => {
                Application.settings.set_string ("color-scheme", widget_scheme.style_scheme.id) ;
            }) ;

            Application.settings.bind ("highlight-matching-brackets", button_highlight_matching_brackets, "active", SettingsBindFlags.DEFAULT) ;

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

            // View Grid
            var grid_view = new Gtk.Grid () ;
            grid_view.attach (label_source_header, 0, 0, 1, 1) ;
            grid_view.attach (label_numbers_show, 0, 1, 1, 1) ;
            grid_view.attach (button_numbers_show, 1, 1, 1, 1) ;
            grid_view.attach (label_pattern_show, 0, 2, 1, 1) ;
            grid_view.attach (button_pattern_show, 1, 2, 1, 1) ;
            grid_view.attach (label_margin_header, 0, 3, 1, 1) ;
            grid_view.attach (label_margin_show, 0, 4, 1, 1) ;
            grid_view.attach (button_margin_show, 1, 4, 1, 1) ;
            grid_view.attach (label_margin_pos, 0, 5, 1, 1) ;
            grid_view.attach (button_margin_pos, 1, 5, 1, 1) ;
            grid_view.attach (label_wrap_header, 0, 6, 1, 1) ;
            grid_view.attach (label_textwrap, 0, 7, 1, 1) ;
            grid_view.attach (button_textwrap, 1, 7, 1, 1) ;
            grid_view.attach (label_highlight_header, 0, 8, 1, 1) ;
            grid_view.attach (label_highlight, 0, 9, 1, 1) ;
            grid_view.attach (button_highlight, 1, 9, 1, 1) ;
            grid_view.attach (label_highlight_matching_brackets, 0, 10, 1, 1) ;
            grid_view.attach (button_highlight_matching_brackets, 1, 10, 1, 1) ;
            grid_view.attach (label_theme_header, 0, 11, 1, 1) ;
            grid_view.attach (label_darktheme, 0, 12, 1, 1) ;
            grid_view.attach (button_darktheme, 1, 12, 1, 1) ;
            grid_view.attach (label_source_map_header, 0, 13, 1, 1) ;
            grid_view.attach (label_source_map, 0, 14, 1, 1) ;
            grid_view.attach (button_source_map, 1, 14, 1, 1) ;
            grid_view.set_can_focus (false) ;
            grid_view.set_margin_start (10) ;
            grid_view.set_margin_end (10) ;
            grid_view.set_margin_top (10) ;
            grid_view.set_margin_bottom (10) ;
            grid_view.set_row_spacing (10) ;
            grid_view.set_column_spacing (10) ;

            // Editor Grid
            var grid_editor = new Gtk.Grid () ;
            grid_editor.attach (label_tabs_header, 0, 0, 1, 1) ;
            grid_editor.attach (label_tab_size, 0, 1, 1, 1) ;
            grid_editor.attach (button_tab_size, 1, 1, 1, 1) ;
            grid_editor.attach (label_spaces, 0, 2, 1, 1) ;
            grid_editor.attach (button_spaces, 1, 2, 1, 1) ;
            grid_editor.attach (label_indent_header, 0, 3, 1, 1) ;
            grid_editor.attach (label_auto_indent, 0, 4, 1, 1) ;
            grid_editor.attach (button_auto_indent, 1, 4, 1, 1) ;
            grid_editor.attach (label_indent_size, 0, 5, 1, 1) ;
            grid_editor.attach (button_indent_size, 1, 5, 1, 1) ;
            grid_editor.set_can_focus (false) ;
            grid_editor.set_margin_start (10) ;
            grid_editor.set_margin_end (10) ;
            grid_editor.set_margin_top (10) ;
            grid_editor.set_margin_bottom (10) ;
            grid_editor.set_row_spacing (10) ;
            grid_editor.set_column_spacing (10) ;

            // View Grid
            var grid_fontscolors = new Gtk.Grid () ;
            grid_fontscolors.attach (label_font_header, 0, 0, 1, 1) ;
            grid_fontscolors.attach (label_font, 0, 1, 1, 1) ;
            grid_fontscolors.attach (button_font, 1, 1, 1, 1) ;
            grid_fontscolors.attach (label_color_header, 0, 2, 1, 1) ;
            grid_fontscolors.attach (scroll_scheme, 0, 3, 2, 1) ;
            grid_fontscolors.set_can_focus (false) ;
            grid_fontscolors.set_margin_start (10) ;
            grid_fontscolors.set_margin_end (10) ;
            grid_fontscolors.set_margin_top (10) ;
            grid_fontscolors.set_margin_bottom (10) ;
            grid_fontscolors.set_row_spacing (10) ;
            grid_fontscolors.set_column_spacing (10) ;

            var pref_notebook = new Gtk.Notebook () ;
            pref_notebook.append_page (grid_view, new Gtk.Label ("View")) ;
            pref_notebook.append_page (grid_editor, new Gtk.Label ("Editor")) ;
            pref_notebook.append_page (grid_fontscolors, new Gtk.Label ("Fonts & Colors")) ;
            var content = preferences.get_content_area () as Gtk.Container ;
            content.add (pref_notebook) ;
            preferences.show_all () ;

        }

    }
}
