namespace iZiCodeEditor {
  public class Preferences : Gtk.Dialog {
    private Gtk.FontButton button_font;
    private Gtk.SourceStyleSchemeChooserWidget widget_scheme;
    private Gtk.SpinButton button_margin_pos;
    private Gtk.SpinButton button_indent_size;
    private Gtk.SpinButton button_tab_size;
    private Gtk.FontButton button_terminal_font;

    private Gtk.Switch button_numbers_show;
    private Gtk.Switch button_highlight;
    private Gtk.Switch button_margin_show;
    private Gtk.Switch button_spaces;
    private Gtk.Switch button_auto_indent;
    private Gtk.Switch button_pattern_show;
    private Gtk.Switch button_darktheme;
    private Gtk.Switch button_textwrap;
    private Gtk.Switch button_source_map;
    private Gtk.Switch button_highlight_matching_brackets;
    private Gtk.Switch button_status_bar;
    private Gtk.Switch button_terminal;
    private Gtk.Switch button_brackets_completion;

    private Gtk.ColorButton button_terminal_fg;
    private Gtk.ColorButton button_terminal_bg;

    private Gtk.HeaderBar header;

    public Preferences (ApplicationWindow window) {
      Object (
        transient_for: window,
        resizable: true
        );
      header = new Gtk.HeaderBar ();
      header.set_show_close_button (true);
      header.set_title ("Preferences");
      set_titlebar (header);
      set_property ("skip-taskbar-hint", true);

      var menuButton = new Gtk.Button.with_label ("Reset");
      header.pack_end (menuButton);

      menuButton.clicked.connect (reset_all);
    }

    construct {

      // Labels
      var label_font = new Gtk.Label ("Editor font");
      var label_margin_pos = new Gtk.Label ("Margin width");
      var label_indent_size = new Gtk.Label ("Indent width");
      var label_tab_size = new Gtk.Label ("Tab width");
      var label_numbers_show = new Gtk.Label ("Show line numbers");
      var label_highlight = new Gtk.Label ("Highlight current line");
      var label_margin_show = new Gtk.Label ("Show margin on right");
      var label_spaces = new Gtk.Label ("Insert spaces instead of tabs");
      var label_auto_indent = new Gtk.Label ("Text auto indentation");
      var label_pattern_show = new Gtk.Label ("Show grid pattern");
      var label_darktheme = new Gtk.Label ("Use dark variant");
      var label_textwrap = new Gtk.Label ("Text wrap");
      var label_font_header = new Gtk.Label ("<b>Font</b>");
      var label_color_header = new Gtk.Label ("<b>Color Scheme</b>");
      var label_tabs_header = new Gtk.Label ("<b>Tab Stops</b>");
      var label_wrap_header = new Gtk.Label ("<b>Text Wrapping</b>");
      var label_highlight_header = new Gtk.Label ("<b>Highlighting</b>");
      var label_margin_header = new Gtk.Label ("<b>Margin</b>");
      var label_theme_header = new Gtk.Label ("<b>Theme</b>");
      var label_source_header = new Gtk.Label ("<b>Source</b>");
      var label_indent_header = new Gtk.Label ("<b>Indent</b>");
      var label_source_map_header = new Gtk.Label ("<b>Source Map</b>");
      var label_source_map = new Gtk.Label ("Show source map");
      var label_highlight_matching_brackets = new Gtk.Label ("Highlight matching brackets");
      var label_status_bar_header = new Gtk.Label ("<b>Status Bar</b>");
      var label_status_bar = new Gtk.Label ("Show status bar");
      var label_terminal_header = new Gtk.Label ("<b>Terminal</b>");
      var label_terminal = new Gtk.Label ("Show terminal");
      var label_brackets_completion_header = new Gtk.Label ("<b>Completion</b>");
      var label_brackets_completion = new Gtk.Label ("Brackets Completion");
      var label_terminal_font_header = new Gtk.Label ("<b>Font</b>");
      var label_terminal_font = new Gtk.Label ("Terminal font");
      var label_terminal_color_header = new Gtk.Label ("<b>Color</b>");
      var label_terminal_color_bg = new Gtk.Label ("Background Color");
      var label_terminal_color_fg = new Gtk.Label ("Foreground Color");

      label_font.set_halign (Gtk.Align.START);
      label_margin_pos.set_halign (Gtk.Align.START);
      label_indent_size.set_halign (Gtk.Align.START);
      label_tab_size.set_halign (Gtk.Align.START);
      label_numbers_show.set_halign (Gtk.Align.START);
      label_highlight.set_halign (Gtk.Align.START);
      label_margin_show.set_halign (Gtk.Align.START);
      label_spaces.set_halign (Gtk.Align.START);
      label_auto_indent.set_halign (Gtk.Align.START);
      label_pattern_show.set_halign (Gtk.Align.START);
      label_darktheme.set_halign (Gtk.Align.START);
      label_textwrap.set_halign (Gtk.Align.START);
      label_font_header.set_halign (Gtk.Align.START);
      label_color_header.set_halign (Gtk.Align.START);
      label_tabs_header.set_halign (Gtk.Align.START);
      label_wrap_header.set_halign (Gtk.Align.START);
      label_highlight_header.set_halign (Gtk.Align.START);
      label_margin_header.set_halign (Gtk.Align.START);
      label_theme_header.set_halign (Gtk.Align.START);
      label_source_header.set_halign (Gtk.Align.START);
      label_indent_header.set_halign (Gtk.Align.START);
      label_source_map.set_halign (Gtk.Align.START);
      label_source_map_header.set_halign (Gtk.Align.START);
      label_highlight_matching_brackets.set_halign (Gtk.Align.START);
      label_status_bar_header.set_halign (Gtk.Align.START);
      label_status_bar.set_halign (Gtk.Align.START);
      label_terminal_header.set_halign (Gtk.Align.START);
      label_terminal.set_halign (Gtk.Align.START);
      label_brackets_completion.set_halign (Gtk.Align.START);
      label_brackets_completion_header.set_halign (Gtk.Align.START);
      label_terminal_font_header.set_halign (Gtk.Align.START);
      label_terminal_font.set_halign (Gtk.Align.START);
      label_terminal_color_header.set_halign (Gtk.Align.START);
      label_terminal_color_bg.set_halign (Gtk.Align.START);
      label_terminal_color_fg.set_halign (Gtk.Align.START);

      label_font.set_hexpand (true);
      label_margin_pos.set_hexpand (true);
      label_indent_size.set_hexpand (true);
      label_tab_size.set_hexpand (true);
      label_numbers_show.set_hexpand (true);
      label_highlight.set_hexpand (true);
      label_margin_show.set_hexpand (true);
      label_spaces.set_hexpand (true);
      label_auto_indent.set_hexpand (true);
      label_pattern_show.set_hexpand (true);
      label_darktheme.set_hexpand (true);
      label_textwrap.set_hexpand (true);
      label_font_header.set_hexpand (true);
      label_color_header.set_hexpand (true);
      label_tabs_header.set_hexpand (true);
      label_wrap_header.set_hexpand (true);
      label_highlight_header.set_hexpand (true);
      label_margin_header.set_hexpand (true);
      label_theme_header.set_hexpand (true);
      label_source_header.set_hexpand (true);
      label_indent_header.set_hexpand (true);
      label_source_map.set_hexpand (true);
      label_source_map_header.set_hexpand (true);
      label_highlight_matching_brackets.set_hexpand (true);
      label_status_bar_header.set_hexpand (true);
      label_status_bar.set_hexpand (true);
      label_terminal_header.set_hexpand (true);
      label_terminal.set_hexpand (true);
      label_brackets_completion.set_hexpand (true);
      label_brackets_completion_header.set_hexpand (true);
      label_terminal_font_header.set_hexpand (true);
      label_terminal_font.set_hexpand (true);
      label_terminal_color_header.set_hexpand (true);
      label_terminal_color_bg.set_hexpand (true);
      label_terminal_color_fg.set_hexpand (true);

      label_font_header.set_use_markup (true);
      label_color_header.set_use_markup (true);
      label_tabs_header.set_use_markup (true);
      label_wrap_header.set_use_markup (true);
      label_highlight_header.set_use_markup (true);
      label_margin_header.set_use_markup (true);
      label_theme_header.set_use_markup (true);
      label_source_header.set_use_markup (true);
      label_indent_header.set_use_markup (true);
      label_source_map_header.set_use_markup (true);
      label_status_bar_header.set_use_markup (true);
      label_terminal_header.set_use_markup (true);
      label_brackets_completion_header.set_use_markup (true);
      label_terminal_font_header.set_use_markup (true);
      label_terminal_color_header.set_use_markup (true);

      label_font_header.set_line_wrap (true);
      label_color_header.set_line_wrap (true);
      label_tabs_header.set_line_wrap (true);
      label_wrap_header.set_line_wrap (true);
      label_highlight_header.set_line_wrap (true);
      label_margin_header.set_line_wrap (true);
      label_theme_header.set_line_wrap (true);
      label_source_header.set_line_wrap (true);
      label_indent_header.set_line_wrap (true);
      label_source_map_header.set_line_wrap (true);
      label_status_bar_header.set_line_wrap (true);
      label_terminal_header.set_line_wrap (true);
      label_brackets_completion.set_line_wrap (true);
      label_terminal_font_header.set_line_wrap (true);
      label_terminal_color_header.set_line_wrap (true);

      // Buttons
      button_font = new Gtk.FontButton ();
      widget_scheme = new Gtk.SourceStyleSchemeChooserWidget ();
      button_margin_pos = new Gtk.SpinButton.with_range (70, 110, 1);
      button_indent_size = new Gtk.SpinButton.with_range (1, 8, 1);
      button_tab_size = new Gtk.SpinButton.with_range (1, 8, 1);
      button_numbers_show = new Gtk.Switch ();
      button_highlight = new Gtk.Switch ();
      button_margin_show = new Gtk.Switch ();
      button_spaces = new Gtk.Switch ();
      button_auto_indent = new Gtk.Switch ();
      button_pattern_show = new Gtk.Switch ();
      button_darktheme = new Gtk.Switch ();
      button_textwrap = new Gtk.Switch ();
      button_source_map = new Gtk.Switch ();
      button_highlight_matching_brackets = new Gtk.Switch ();
      button_status_bar = new Gtk.Switch ();
      button_terminal = new Gtk.Switch ();
      button_brackets_completion = new Gtk.Switch ();
      button_terminal_font = new Gtk.FontButton ();
      button_terminal_bg = new Gtk.ColorButton ();
      button_terminal_fg = new Gtk.ColorButton ();

      button_font.set_halign (Gtk.Align.END);
      button_margin_pos.set_halign (Gtk.Align.END);
      button_indent_size.set_halign (Gtk.Align.END);
      button_tab_size.set_halign (Gtk.Align.END);
      button_numbers_show.set_halign (Gtk.Align.END);
      button_highlight.set_halign (Gtk.Align.END);
      button_margin_show.set_halign (Gtk.Align.END);
      button_spaces.set_halign (Gtk.Align.END);
      button_auto_indent.set_halign (Gtk.Align.END);
      button_pattern_show.set_halign (Gtk.Align.END);
      button_darktheme.set_halign (Gtk.Align.END);
      button_textwrap.set_halign (Gtk.Align.END);
      button_source_map.set_halign (Gtk.Align.END);
      button_highlight_matching_brackets.set_halign (Gtk.Align.END);
      button_status_bar.set_halign (Gtk.Align.END);
      button_terminal.set_halign (Gtk.Align.END);
      button_brackets_completion.set_halign (Gtk.Align.END);
      button_terminal_font.set_halign (Gtk.Align.END);
      button_terminal_bg.set_halign (Gtk.Align.END);
      button_terminal_fg.set_halign (Gtk.Align.END);

      var scroll_scheme = new Gtk.ScrolledWindow (null, null);
      scroll_scheme.add (widget_scheme);
      scroll_scheme.set_hexpand (true);
      scroll_scheme.set_vexpand (true);

      button_font.set_font_name (Application.settings_fonts_colors.get_string ("font"));
      button_font.notify["font"].connect (() => {
        Application.settings_fonts_colors.set_string ("font", button_font.get_font ().to_string ());
      });
      Application.settings_editor.bind ("indent-size", button_indent_size, "value", SettingsBindFlags.DEFAULT);
      Application.settings_editor.bind ("tab-size", button_tab_size, "value", SettingsBindFlags.DEFAULT);
      Application.settings_view.bind ("numbers-show", button_numbers_show, "active", SettingsBindFlags.DEFAULT);
      Application.settings_editor.bind ("highlight-current-line", button_highlight, "active", SettingsBindFlags.DEFAULT);
      Application.settings_view.bind ("margin-show", button_margin_show, "active", SettingsBindFlags.DEFAULT);
      Application.settings_view.bind ("margin-pos", button_margin_pos, "value", SettingsBindFlags.DEFAULT);
      Application.settings_editor.bind ("spaces-instead-of-tabs", button_spaces, "active", SettingsBindFlags.DEFAULT);
      Application.settings_editor.bind ("auto-indent", button_auto_indent, "active", SettingsBindFlags.DEFAULT);
      Application.settings_view.bind ("pattern-show", button_pattern_show, "active", SettingsBindFlags.DEFAULT);
      Application.settings_view.bind ("dark-mode", button_darktheme, "active", SettingsBindFlags.DEFAULT);
      Application.settings_view.bind ("text-wrap", button_textwrap, "active", SettingsBindFlags.DEFAULT);
      Application.settings_view.bind ("source-map", button_source_map, "active", SettingsBindFlags.DEFAULT);
      Application.settings_view.bind ("status-bar", button_status_bar, "active", SettingsBindFlags.DEFAULT);
      widget_scheme.style_scheme = Gtk.SourceStyleSchemeManager.get_default ().get_scheme (Application.settings_fonts_colors.get_string ("color-scheme"));
      widget_scheme.notify["style-scheme"].connect (() => {
        Application.settings_fonts_colors.set_string ("color-scheme", widget_scheme.style_scheme.id);
      });
      Application.settings_editor.bind ("highlight-matching-brackets", button_highlight_matching_brackets, "active", SettingsBindFlags.DEFAULT);
      Application.settings_terminal.bind ("terminal", button_terminal, "active", SettingsBindFlags.DEFAULT);
      Application.settings_editor.bind ("brackets-completion", button_brackets_completion, "active", SettingsBindFlags.DEFAULT);
      button_terminal_font.set_font_name (Application.settings_terminal.get_string ("font"));
      button_terminal_font.notify["font"].connect (() => {
        Application.settings_terminal.set_string ("font", button_terminal_font.get_font ().to_string ());
      });
      string background_setting = Application.settings_terminal.get_string ("bgcolor");
      Gdk.RGBA background_color = Gdk.RGBA ();
      background_color.parse (background_setting);
      button_terminal_bg.set_rgba (background_color);
      button_terminal_bg.notify["color"].connect (() => {
        Application.settings_terminal.set_string ("bgcolor", button_terminal_bg.get_rgba ().to_string ());
      });
      string foreground_setting = Application.settings_terminal.get_string ("fgcolor");
      Gdk.RGBA foreground_color = Gdk.RGBA ();
      foreground_color.parse (foreground_setting);
      button_terminal_fg.set_rgba (foreground_color);
      button_terminal_fg.notify["color"].connect (() => {
        Application.settings_terminal.set_string ("fgcolor", button_terminal_fg.get_rgba ().to_string ());
        print ("DEBUG : %s", button_terminal_fg.get_rgba ().to_string ());
      });

      // View Grid
      var grid_view = new Gtk.Grid ();
      grid_view.attach (label_source_header, 0, 0, 1, 1);
      grid_view.attach (label_numbers_show, 0, 1, 1, 1);
      grid_view.attach (button_numbers_show, 1, 1, 1, 1);
      grid_view.attach (label_pattern_show, 0, 2, 1, 1);
      grid_view.attach (button_pattern_show, 1, 2, 1, 1);
      grid_view.attach (label_margin_header, 0, 3, 1, 1);
      grid_view.attach (label_margin_show, 0, 4, 1, 1);
      grid_view.attach (button_margin_show, 1, 4, 1, 1);
      grid_view.attach (label_margin_pos, 0, 5, 1, 1);
      grid_view.attach (button_margin_pos, 1, 5, 1, 1);
      grid_view.attach (label_wrap_header, 0, 6, 1, 1);
      grid_view.attach (label_textwrap, 0, 7, 1, 1);
      grid_view.attach (button_textwrap, 1, 7, 1, 1);
      grid_view.attach (label_theme_header, 0, 8, 1, 1);
      grid_view.attach (label_darktheme, 0, 9, 1, 1);
      grid_view.attach (button_darktheme, 1, 9, 1, 1);
      grid_view.attach (label_source_map_header, 0, 10, 1, 1);
      grid_view.attach (label_source_map, 0, 11, 1, 1);
      grid_view.attach (button_source_map, 1, 11, 1, 1);
      grid_view.attach (label_status_bar_header, 0, 12, 1, 1);
      grid_view.attach (label_status_bar, 0, 13, 1, 1);
      grid_view.attach (button_status_bar, 1, 13, 1, 1);
      grid_view.set_can_focus (false);
      grid_view.set_margin_start (10);
      grid_view.set_margin_end (10);
      grid_view.set_margin_top (10);
      grid_view.set_margin_bottom (10);
      grid_view.set_row_spacing (10);
      grid_view.set_column_spacing (10);

      // Editor Grid
      var grid_editor = new Gtk.Grid ();
      grid_editor.attach (label_tabs_header, 0, 0, 1, 1);
      grid_editor.attach (label_tab_size, 0, 1, 1, 1);
      grid_editor.attach (button_tab_size, 1, 1, 1, 1);
      grid_editor.attach (label_spaces, 0, 2, 1, 1);
      grid_editor.attach (button_spaces, 1, 2, 1, 1);
      grid_editor.attach (label_indent_header, 0, 3, 1, 1);
      grid_editor.attach (label_auto_indent, 0, 4, 1, 1);
      grid_editor.attach (button_auto_indent, 1, 4, 1, 1);
      grid_editor.attach (label_indent_size, 0, 5, 1, 1);
      grid_editor.attach (button_indent_size, 1, 5, 1, 1);
      grid_editor.attach (label_highlight_header, 0, 6, 1, 1);
      grid_editor.attach (label_highlight, 0, 7, 1, 1);
      grid_editor.attach (button_highlight, 1, 7, 1, 1);
      grid_editor.attach (label_highlight_matching_brackets, 0, 8, 1, 1);
      grid_editor.attach (button_highlight_matching_brackets, 1, 8, 1, 1);
      grid_editor.attach (label_brackets_completion_header, 0, 9, 1, 1);
      grid_editor.attach (label_brackets_completion, 0, 10, 1, 1);
      grid_editor.attach (button_brackets_completion, 1, 10, 1, 1);
      grid_editor.set_can_focus (false);
      grid_editor.set_margin_start (10);
      grid_editor.set_margin_end (10);
      grid_editor.set_margin_top (10);
      grid_editor.set_margin_bottom (10);
      grid_editor.set_row_spacing (10);
      grid_editor.set_column_spacing (10);

      // View Grid
      var grid_fontscolors = new Gtk.Grid ();
      grid_fontscolors.attach (label_font_header, 0, 0, 1, 1);
      grid_fontscolors.attach (label_font, 0, 1, 1, 1);
      grid_fontscolors.attach (button_font, 1, 1, 1, 1);
      grid_fontscolors.attach (label_color_header, 0, 2, 1, 1);
      grid_fontscolors.attach (scroll_scheme, 0, 3, 2, 1);
      grid_fontscolors.set_can_focus (false);
      grid_fontscolors.set_margin_start (10);
      grid_fontscolors.set_margin_end (10);
      grid_fontscolors.set_margin_top (10);
      grid_fontscolors.set_margin_bottom (10);
      grid_fontscolors.set_row_spacing (10);
      grid_fontscolors.set_column_spacing (10);

      // Terminal Grid
      var grid_terminal = new Gtk.Grid ();
      grid_terminal.attach (label_terminal_header, 0, 0, 1, 1);
      grid_terminal.attach (label_terminal, 0, 1, 1, 1);
      grid_terminal.attach (button_terminal, 1, 1, 1, 1);
      grid_terminal.attach (label_terminal_font_header, 0, 2, 1, 1);
      grid_terminal.attach (label_terminal_font, 0, 3, 1, 1);
      grid_terminal.attach (button_terminal_font, 1, 3, 1, 1);
      grid_terminal.attach (label_terminal_color_header, 0, 4, 1, 1);
      grid_terminal.attach (label_terminal_color_bg, 0, 5, 1, 1);
      grid_terminal.attach (button_terminal_bg, 1, 5, 1, 1);
      grid_terminal.attach (label_terminal_color_fg, 0, 6, 1, 1);
      grid_terminal.attach (button_terminal_fg, 1, 6, 1, 1);
      grid_terminal.set_can_focus (false);
      grid_terminal.set_margin_start (10);
      grid_terminal.set_margin_end (10);
      grid_terminal.set_margin_top (10);
      grid_terminal.set_margin_bottom (10);
      grid_terminal.set_row_spacing (10);
      grid_terminal.set_column_spacing (10);

      var pref_notebook = new Gtk.Notebook ();
      pref_notebook.append_page (grid_view, new Gtk.Label ("View"));
      pref_notebook.append_page (grid_editor, new Gtk.Label ("Editor"));
      pref_notebook.append_page (grid_fontscolors, new Gtk.Label ("Fonts & Colors"));
      pref_notebook.append_page (grid_terminal, new Gtk.Label ("Terminal"));
      var content = get_content_area () as Gtk.Container;
      content.add (pref_notebook);
    }

    public void reset_all () {
      var dialog = new Gtk.MessageDialog (get_toplevel () as Gtk.Window,
                                          Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE,
                                          "Are you sure you want to reset all preferences?");
      dialog.add_button ("Yes", Gtk.ResponseType.YES);
      dialog.add_button ("Cancel", Gtk.ResponseType.CANCEL);
      dialog.set_resizable (false);
      dialog.set_default_response (Gtk.ResponseType.YES);
      int response = dialog.run ();
      switch (response) {
      case Gtk.ResponseType.CANCEL:
        break;
      case Gtk.ResponseType.YES:
        foreach (var key in Application.settings_editor.settings_schema.list_keys ())
          Application.settings_view.reset (key);
        foreach (var key in Application.settings_fonts_colors.settings_schema.list_keys ())
          Application.settings_view.reset (key);
        foreach (var key in Application.settings_terminal.settings_schema.list_keys ())
          Application.settings_view.reset (key);
        foreach (var key in Application.settings_view.settings_schema.list_keys ())
          Application.settings_view.reset (key);
        break;
      }
      dialog.destroy ();
    }
  }
}
