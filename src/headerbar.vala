namespace iZiCodeEditor {

  public class HeaderBar : Gtk.HeaderBar {
    public Gtk.Button searchButton;
    public iZiCodeEditor.Search search;
    public iZiCodeEditor.GoToLine gotoline;

    public unowned Document ? doc = null;

    public HeaderBar () {
      Object (
        show_close_button: true);
    }

    construct {
      var zoom_out_button = new Gtk.Button.from_icon_name ("zoom-out-symbolic", Gtk.IconSize.MENU);
      zoom_out_button.action_name = "win.zoom-out";

      var zoom_default_button = new Gtk.Button.with_label ("100%");
      zoom_default_button.action_name = "win.zoom-default";

      var zoom_in_button = new Gtk.Button.from_icon_name ("zoom-in-symbolic", Gtk.IconSize.MENU);
      zoom_in_button.action_name = "win.zoom-in";

      var zoom_grid = new Gtk.Grid ();
      zoom_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
      zoom_grid.margin_bottom = 6;
      zoom_grid.add (zoom_out_button);
      zoom_grid.add (zoom_default_button);
      zoom_grid.add (zoom_in_button);

      var save_as_button = new Gtk.ModelButton ();
      save_as_button.text = "Save as...";
      save_as_button.action_name = "win.save-as";

      var save_all_button = new Gtk.ModelButton ();
      save_all_button.text = "Save All";
      save_all_button.action_name = "win.save-all";

      var search_button = new Gtk.ModelButton ();
      search_button.text = "Search...";
      search_button.action_name = "win.search";

      var replace_button = new Gtk.ModelButton ();
      replace_button.text = "Replace...";
      replace_button.action_name = "win.replace";

      var go_to_button = new Gtk.ModelButton ();
      go_to_button.text = "Go to...";
      go_to_button.action_name = "win.go-to";

      var close_button = new Gtk.ModelButton ();
      close_button.text = "Close";
      close_button.action_name = "win.close";

      var close_all_button = new Gtk.ModelButton ();
      close_all_button.text = "Close All";
      close_all_button.action_name = "win.close-all";

      var preferences_button = new Gtk.ModelButton ();
      preferences_button.text = "Preferences";
      preferences_button.action_name = "win.preferences";

      var about_button = new Gtk.ModelButton ();
      about_button.text = "About";
      about_button.action_name = "win.about";

      var quit_button = new Gtk.ModelButton ();
      quit_button.text = "Quit";
      quit_button.action_name = "win.quit";

      var menu_grid = new Gtk.Grid ();
      menu_grid.margin = 6;
      menu_grid.orientation = Gtk.Orientation.VERTICAL;
      menu_grid.add (zoom_grid);
      menu_grid.add (save_as_button);
      menu_grid.add (save_all_button);
      menu_grid.add (search_button);
      menu_grid.add (replace_button);
      menu_grid.add (go_to_button);
      menu_grid.add (close_button);
      menu_grid.add (close_all_button);
      menu_grid.add (preferences_button);
      menu_grid.add (about_button);
      menu_grid.add (quit_button);
      menu_grid.show_all ();

      var menu = new Gtk.Popover (null);
      menu.add (menu_grid);

      // var menu = new GLib.Menu ();
      // var section = new GLib.Menu ();
      // section.append ("Save As...", "win.save-as");
      // section.append ("Save All", "win.save-all");
      // menu.append_section (null, section);
      // section = new GLib.Menu ();
      // section.append ("Search...", "win.search");
      // section.append ("Replace...", "win.replace");
      // menu.append_section (null, section);
      // section = new GLib.Menu ();
      // section.append ("Go to line...", "win.gotoline");
      // menu.append_section (null, section);
      // section = new GLib.Menu ();
      // section.append ("Close", "win.close");
      // section.append ("Close All", "win.close-all");
      // menu.append_section (null, section);
      // section = new GLib.Menu ();
      // section.append ("Preferences", "win.pref");
      // menu.append_section (null, section);
      // section = new GLib.Menu ();
      // section.append ("About", "win.about");
      // section.append ("Quit", "win.quit");
      // menu.append_section (null, section);
      // menu.add (zoom_grid);

      var leftIcons = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
      var rightIcons = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

      var openButton = new Gtk.Button.from_icon_name ("document-open-symbolic", Gtk.IconSize.BUTTON);
      openButton.action_name = ApplicationWindow.ACTION_PREFIX + ApplicationWindow.ACTION_OPEN;

      var newButton = new Gtk.Button.from_icon_name ("tab-new-symbolic", Gtk.IconSize.BUTTON);
      newButton.action_name = ApplicationWindow.ACTION_PREFIX + ApplicationWindow.ACTION_NEW;

      var saveButton = new Gtk.Button.from_icon_name ("document-save-symbolic", Gtk.IconSize.BUTTON);
      saveButton.action_name = ApplicationWindow.ACTION_PREFIX + ApplicationWindow.ACTION_SAVE;

      searchButton = new Gtk.Button.from_icon_name ("edit-find-symbolic", Gtk.IconSize.BUTTON);
      searchButton.action_name = ApplicationWindow.ACTION_PREFIX + ApplicationWindow.ACTION_SEARCH;

      search = new iZiCodeEditor.Search ();
      search.set_relative_to (searchButton);

      var menuButton = new Gtk.MenuButton ();
      menuButton.image = new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.BUTTON);
      menuButton.set_popover (menu);

      leftIcons.pack_start (openButton, false, false, 0);
      leftIcons.pack_start (newButton, false, false, 0);
      leftIcons.get_style_context ().add_class ("linked");

      rightIcons.pack_start (searchButton, false, false, 0);
      rightIcons.pack_start (saveButton, false, false, 0);
      rightIcons.pack_start (menuButton, false, false, 0);
      rightIcons.get_style_context ().add_class ("linked");

      pack_start (leftIcons);
      pack_end (rightIcons);

      gotoline = new iZiCodeEditor.GoToLine ();
      gotoline.set_relative_to (searchButton);

      Application.settings_fonts_colors.changed.connect (() => {
        // Default font size = 14, so, (14-4) * 10 = 100% zoom
        zoom_default_button.label = "%.0f%%".printf ((Application.instance.get_last_window ().get_current_font_size () - 4) * 10);
      });
    }

    public void set_doc (Document doc) {
      this.doc = doc;
      set_title (doc.file_name);
      set_subtitle (doc.file_parse_name);
      search.set_sourceview (doc.sourceview);
      gotoline.set_sourceview (doc.sourceview);
    }
  }
}
