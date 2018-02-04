namespace iZiCodeEditor {
  const string NAME = "iZiCodeEditor";
  const string VERSION = "0.1";
  const string DESCRIPTION = "Simple text editor written in vala";
  const string ICON = "accessories-text-editor";
  const string[] AUTHORS = { "danielpinto8zz6 <https://github.com/danielpinto8zz6>", "Daniel Pinto <danielpinto8zz6-at-gmail-dot-com>", null };

  private class Application : Gtk.Application {

    private ApplicationWindow window;

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
      Object (application_id: "com.github.danielpinto8zz6.iZiCodeEditor");
    }

    public override void activate () {
      window = new ApplicationWindow (this);
      window.notebook.new_tab ();
    }

    private static int main (string[] args) {
      Application app = new Application ();
      return app.run (args);
    }
  }
}
