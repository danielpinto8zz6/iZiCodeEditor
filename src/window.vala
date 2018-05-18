namespace EasyCode {
  public class Window : Gtk.ApplicationWindow {
    public weak Application app { get; construct; }

    private Notebook _notebook;
    public Notebook notebook {
      get { return _notebook; }
    }

    private BottomBar _bottom_bar;
    public BottomBar bottom_bar {
      get { return _bottom_bar; }
    }

    private LeftBar _left_bar;
    public LeftBar left_bar {
      get { return _left_bar; }
    }

    private RightBar _right_bar;
    public RightBar right_bar {
      get { return _right_bar; }
    }

    private StatusBar _status_bar;
    public StatusBar status_bar {
      get {return _status_bar;}
    }

    private HeaderBar _header_bar;
    public HeaderBar header_bar {
      get {return _header_bar;}
    }

    private Terminal terminal;
    private Replace replace;
    private Preferences preferences;

    private Explorer explorer;
    private Gtk.Paned leftPaned;
    private Gtk.Paned rightPaned;
    private Gtk.Paned mainPaned;

    private const int64 USEC_PER_SEC = 1000000;
    private const int64 FORCE_SHUTDOWN_USEC = 5 * USEC_PER_SEC;

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
        return _notebook.current;
      }
    }

    public Window (Application app) {
      Object (
        application: app,
        icon_name: Constants.ICON,
        title: Constants.NAME
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
      _header_bar = new HeaderBar (this);
      this.set_titlebar (header_bar);

      Gtk.Settings.get_default ().set_property ("gtk-application-prefer-dark-theme", Application.settings_view.get_boolean ("dark-mode"));

      Application.settings_view.changed["dark-mode"].connect (() => {
        Gtk.Settings.get_default ().set_property ("gtk-application-prefer-dark-theme", Application.settings_view.get_boolean ("dark-mode"));
      });

      _notebook = new Notebook (this);

      _left_bar = new LeftBar (this);

      _bottom_bar = new BottomBar (this);

      _right_bar = new RightBar (this);

      _status_bar = new StatusBar ();

      var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
      content.width_request = 200;
      content.pack_start (_notebook, true, true, 0);

      leftPaned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
      leftPaned.position = 180;
      leftPaned.pack1 (_left_bar, false, false);
      leftPaned.pack2 (content, true, false);

      rightPaned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
      rightPaned.pack1 (leftPaned, true, false);
      rightPaned.pack2 (_right_bar, false, false);

      mainPaned = new Gtk.Paned (Gtk.Orientation.VERTICAL);
      mainPaned.pack1 (rightPaned, true, false);
      mainPaned.pack2 (_bottom_bar, false, false);

      explorer = new EasyCode.Explorer ();
      explorer.file_clicked.connect ((path) => {
        open_doc (File.new_for_path (path));
      });

      _left_bar.append_page (explorer, new Gtk.Label ("Explorer"));

      terminal = new EasyCode.Terminal ();

      var label_terminal = new Gtk.Label ("Terminal");
      var scrolled_terminal = (Gtk.Scrollbar)terminal.get_child_at (1, 0);

      if (Application.settings_terminal.get_boolean ("terminal")) {
        _bottom_bar.append_page (terminal, label_terminal);
      } else {
        _bottom_bar.remove_page (_notebook.page_num (scrolled_terminal));
      }
      Application.settings_terminal.changed["terminal"].connect (() => {
        if (Application.settings_terminal.get_boolean ("terminal")) {
          _bottom_bar.append_page (terminal, label_terminal);
        } else {
          _bottom_bar.remove_page (_notebook.page_num (scrolled_terminal));
        }
      });

      var mainBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

      mainBox.pack_start (mainPaned, false, true, 0);

      mainBox.pack_end (_status_bar, false, false, 0);

      mainBox.show_all ();

      add (mainBox);

      support_drag_and_drop ();

      create_unsaved_documents_directory ();

      restore_saved_state ();

      if (_notebook.get_n_pages () == 0) {
        _status_bar.hide_buttons ();
      }

      delete_event.connect (() => {
        action_quit ();
        return true;
      });

      show ();
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
          open_doc (file);

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

    private void next_page () {
      if ((_notebook.get_current_page () + 1) == _notebook.get_n_pages ()) {
        _notebook.set_current_page (0);
      } else {
        _notebook.next_page ();
      }
    }

    private void action_undo () {
      if (_notebook.get_n_pages () > 0) {
        current_doc.sourceview.undo ();
      }
    }

    private void action_redo () {
      if (_notebook.get_n_pages () > 0) {
        current_doc.sourceview.redo ();
      }
    }

    private void action_open () {
      var chooser = new Gtk.FileChooserDialog (
        "Select a file to edit", this, Gtk.FileChooserAction.OPEN,
        "_Cancel",
        Gtk.ResponseType.CANCEL,
        "_Open",
        Gtk.ResponseType.ACCEPT);
      var filter = new Gtk.FileFilter ();
      filter.add_mime_type ("text/plain");

      chooser.set_select_multiple (true);
      chooser.set_modal (true);
      chooser.set_filter (filter);
      chooser.show ();
      if (chooser.run () == Gtk.ResponseType.ACCEPT) {
        foreach (string uri in chooser.get_uris ()) {
          var file = File.new_for_uri (uri);
          open_doc (file);
        }
      }
      chooser.destroy ();
    }

    private void action_open_folder () {
      var chooser = new Gtk.FileChooserDialog (
        "Select a folder.", this, Gtk.FileChooserAction.SELECT_FOLDER,
        "Cancel", Gtk.ResponseType.CANCEL,
        "Open", Gtk.ResponseType.ACCEPT);
      chooser.select_multiple = true;

      if (chooser.run () == Gtk.ResponseType.ACCEPT) {
        chooser.get_files ().foreach ((file) => {
          explorer.open_folder (file.get_path ());
        });
      }

      chooser.destroy ();
    }

    private void action_save () {
      if (current_doc != null) {
        if (current_doc.is_file_temporary == true) {
          action_save_as ();
        } else {
          current_doc.save.begin ();
        }
      }
    }

    private void action_search () {
      if (_notebook.get_n_pages () > 0) {
        _header_bar.search.show ();
      }
    }

    private void action_gotoline () {
      if (_notebook.get_n_pages () > 0) {
        _header_bar.gotoline.show ();
      }
    }

    private void action_new () {
      File file = generate_temporary_file ();
      if (file != null) {
        var doc = new Document (file, _notebook);
        _notebook.add_tab (doc);
      }
    }

    private void action_save_as () {
      if (current_doc != null) {
        current_doc.save_as.begin ();
      }
    }

    private void action_save_all () {
      if (_notebook.get_n_pages () > 0) {
        foreach (var doc in _notebook.tabs) {
          if (doc != null) {
            if (doc.is_file_temporary == true) {
              action_save_as ();
            } else {
              doc.save.begin ();
            }
          }
        }
      }
    }

    private void action_replace () {
      if (_notebook.get_n_pages () > 0) {
        replace = new EasyCode.Replace (this);
        replace.show_all ();
      }
    }

    private void action_close () {
      if (_notebook.get_n_pages () > 0)
        _notebook.remove_tab (current_doc);
    }

    private void action_close_all () {
      if (_notebook.get_n_pages () > 0) {
        _notebook.remove_all_tabs ();
      }
    }

    private void action_preferences () {
      preferences = new EasyCode.Preferences (this);
      preferences.show_all ();
    }

    private void action_about () {
      Gtk.show_about_dialog (this,
                             program_name: Constants.NAME,
                             version: Constants.APP_VERSION,
                             comments: Constants.DESCRIPTION,
                             logo_icon_name: Constants.ICON,
                             icon_name: Constants.ICON,
                             authors: Constants.AUTHORS,
                             copyright: "Copyright \xc2\xa9 2018",
                             website: Constants.WEBSITE,
                             license_type: Gtk.License.GPL_3_0);
    }

    private void action_quit () {
      hide ();

      handle_quit ();

      int64 start_usec = get_monotonic_time ();

      while (Gtk.events_pending ()) {
        Gtk.main_iteration ();

        int64 delta_usec = get_monotonic_time () - start_usec;
        if (delta_usec >= FORCE_SHUTDOWN_USEC) {
          debug ("Forcing shutdown, %ss passed...", (delta_usec / USEC_PER_SEC).to_string ());
          destroy ();
        }
      }

      destroy ();
    }

    private void handle_quit () {
      set_saved_state ();

      set_opened_folders ();

      set_opened_docs ();

      save_opened_docs ();
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

      if (_notebook.tabs.length () > 0) {
        Application.saved_state.set_uint ("active-tab", _notebook.get_current_page ());
      } else {
        Application.saved_state.reset ("active-tab");
      }
    }

    private void save_opened_docs () {
      if (_notebook.tabs.length () > 0) {
        foreach (var doc in _notebook.tabs) {
          doc.save.begin ();
        }
      }
    }

    private void set_opened_docs () {
      string[] opened_docs = { };

      foreach (var doc in _notebook.tabs) {
        if (doc.file != null && doc.exists ()) {
          opened_docs += doc.file.get_uri ();
        }
      }
      Application.saved_state.set_strv ("recent-files", opened_docs);
    }

    private void create_unsaved_documents_directory () {
      File dir = File.new_for_path (Application.instance.unsaved_files_directory);
      if (!dir.query_exists ()) {
        try {
          dir.make_directory_with_parents ();
        } catch (Error e) {
          critical ("Unable to create the 'unsaved' directory: '%s': %s", dir.get_path (), e.message);
        }
      }
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

    public void restore_opened_docs () {
      string[] recent_files = Application.saved_state.get_strv ("recent-files");
      if (recent_files.length > 0) {
        foreach (string uri in recent_files) {
          if (uri != "") {
            File file;
            if (Uri.parse_scheme (uri) != null) {
              file = File.new_for_uri (uri);
            } else {
              file = File.new_for_commandline_arg (uri);
            }
            open_doc (file);
          }
        }
        _notebook.set_current_page ((int)Application.saved_state.get_uint ("active-tab"));
      }
    }

    private void set_opened_folders () {
      string[] folders = { };
      for (int i = 0; i < explorer.opened_folders.length (); i++) {
        var folder = explorer.opened_folders.nth_data (i);
        if (folder == null) {
          continue;
        }
        folders += folder.path;
      }
      Application.saved_state.set_strv ("recent-folders", folders);
    }

    public void restore_opened_folders () {
      string[] folders = Application.saved_state.get_strv ("recent-folders");
      if (folders.length > 0) {
        foreach (string path in folders) {
          if (path != "") {
            if (File.new_for_path (path).query_exists ()) {
              explorer.open_folder (path);
            }
          }
        }
      }
    }

    private File generate_temporary_file () {
      File folder = File.new_for_path (Application.instance.unsaved_files_directory);

      int n = 1;

      File new_file = folder.get_child ("Untitled_%d".printf (n));

      while (new_file.query_exists ()) {
        new_file = folder.get_child ("Untitled_%d".printf (n));
        n++;
      }

      new_file.create_async.begin (0, Priority.DEFAULT, null, (obj, res) => {
        try {
          new_file.create_async.end (res);
        } catch (Error error) {
          warning (error.message);
        }
      });

      return new_file;
    }

    public void open_doc (File file) {
      if (file == null) {
        return;
      }

      for (int n = 0; n < _notebook.tabs.length (); n++) {
        var sel_doc = _notebook.tabs.nth_data (n);
        if (sel_doc == null) {
          continue;
        }

        if (sel_doc.file.get_uri () == file.get_uri ()) {
          _notebook.set_current_page (_notebook.page_num (sel_doc));
          warning ("This file is already loaded: %s\n", file.get_parse_name ());
          return;
        }
      }

      var doc = new Document (file, _notebook);
      _notebook.append_page (doc, doc.get_tab_label ());
      _notebook.set_current_page (_notebook.page_num (doc));
      _notebook.set_tab_reorderable (doc, true);
    }
  }
}
