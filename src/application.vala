namespace iZiCodeEditor {
  const string NAME = "iZiCodeEditor";
  const string VERSION = "0.1";
  const string DESCRIPTION = "Simple text editor written in vala";
  const string ICON = "accessories-text-editor";
  const string[] AUTHORS = { "danielpinto8zz6 <https://github.com/danielpinto8zz6>", "Daniel Pinto <danielpinto8zz6-at-gmail-dot-com>", null };

  private class Application : Gtk.Application {

    private ApplicationWindow window;

    public static Application _instance = null;

    public static Application instance {
      get {
        if (_instance == null) {
          _instance = new Application ();
        }
        return _instance;
      }
    }

    private static GLib.Settings _settings_editor = new GLib.Settings ("com.github.danielpinto8zz6.iZiCodeEditor.settings.editor");
    public static GLib.Settings settings_editor {
      get {
        return _settings_editor;
      }
    }
    private static GLib.Settings _settings_fonts_colors = new GLib.Settings ("com.github.danielpinto8zz6.iZiCodeEditor.settings.fonts-colors");
    public static GLib.Settings settings_fonts_colors {
      get {
        return _settings_fonts_colors;
      }
    }
    private static GLib.Settings _settings_terminal = new GLib.Settings ("com.github.danielpinto8zz6.iZiCodeEditor.settings.terminal");
    public static GLib.Settings settings_terminal {
      get {
        return _settings_terminal;
      }
    }
    private static GLib.Settings _settings_view = new GLib.Settings ("com.github.danielpinto8zz6.iZiCodeEditor.settings.view");
    public static GLib.Settings settings_view {
      get {
        return _settings_view;
      }
    }
    private static GLib.Settings _saved_state = new GLib.Settings ("com.github.danielpinto8zz6.iZiCodeEditor.saved-state");
    public static GLib.Settings saved_state {
      get {
        return _saved_state;
      }
    }
    public Application () {
      Object (application_id: "com.github.danielpinto8zz6.iZiCodeEditor",
              flags : GLib.ApplicationFlags.HANDLES_OPEN);
    }

    public override void startup () {
      base.startup ();
      window = new ApplicationWindow (this);
      window.present ();
      // window.notebook.add_recent_files () ;

      try {
        var provider = new Gtk.CssProvider ();
        var css_stuff = """ .close-tab-button { padding :0; } """;
        provider.load_from_data (css_stuff, css_stuff.length);
      } catch (Error e) {
        stderr.printf ("Error: %s\n", e.message);
      }
    }

    public override void activate () {
      if (window.notebook.get_n_pages () == 0) {
        window.notebook.new_tab ();
      }
      get_last_window ().present ();
    }

    public override void open (File[] files, string hint) {
      foreach (File file in files) {
        try {

          var info = file.query_info ("standard::*", FileQueryInfoFlags.NONE, null);
          string reason = "";

          switch (info.get_file_type ()) {
          case FileType.REGULAR:
            break;
          case FileType.MOUNTABLE:
            reason = "It is a mountable location.";
            break;
          case FileType.DIRECTORY:
            reason = "It is a directory.";
            break;
          case FileType.SPECIAL:
            reason = "It is a \"special\" file such as a socket,\n fifo, block device, or character device.";
            break;
          default:
            reason = "It is an \"unknown\" file type.";
            break;
          }

          if (reason.length > 0) {
            stderr.printf ("File %s cannot be opened.\n%s\n\n", file.get_parse_name (), reason);
          } else {
            window.notebook.open (file);
          }
        } catch (Error e) {
          debug (e.message);
        }
      }

      get_active_window ().present ();
    }

    public ApplicationWindow ? get_last_window () {
      unowned List<weak Gtk.Window> window = get_windows ();
      return window.length () > 0 ? window.last ().data as ApplicationWindow : null;
    }

    private static int main (string[] args) {
      Application app = Application.instance;
      return app.run (args);
    }
  }
}
