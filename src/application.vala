namespace iZiCodeEditor {
  const string NAME = "iZiCodeEditor";
  const string APPLICATION_ID = "com.github.danielpinto8zz6.iZiCodeEditor";
  const string VERSION = "0.1";
  const string DESCRIPTION = "Simple text editor written in vala";
  const string ICON = "accessories-text-editor";
  const string[] AUTHORS = { "danielpinto8zz6 <https://github.com/danielpinto8zz6>", "Daniel Pinto <danielpinto8zz6-at-gmail-dot-com>", null };

  public class Application : Gtk.Application {
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

    construct {
      flags |= ApplicationFlags.HANDLES_OPEN;
      flags |= ApplicationFlags.HANDLES_COMMAND_LINE;

      application_id = APPLICATION_ID;
    }

    public static Application _instance = null;

    public static Application instance {
      get {
        if (_instance == null) {
          _instance = new Application ();
        }
        return _instance;
      }
    }

    private int _command_line (ApplicationCommandLine command_line) {
      bool version = false;

      OptionEntry[] options = new OptionEntry[1];
      options[0] = { "version", 'v', 0, OptionArg.NONE, ref version, "Display version number", null };

      string[] args = command_line.get_arguments ();
      int unclaimed_args;
      string *[] _args = new string[args.length];
      for (int i = 0; i < args.length; i++) {
        _args[i] = args[i];
      }

      try {
        var opt_context = new OptionContext ("- OptionContext example");
        opt_context.set_help_enabled (true);
        opt_context.add_main_entries (options, null);
        unowned string[] tmp = _args;
        opt_context.parse (ref tmp);
        unclaimed_args = args.length - 1;
      } catch (OptionError e) {
        command_line.print ("error: %s\n", e.message);
        command_line.print ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
        return 0;
      }

      if (version) {
        command_line.print ("%s %s\n", NAME, VERSION);
        return 1;
      }

      activate ();

      // Open all files given as arguments
      if (unclaimed_args > 0) {
        File[] files = new File[unclaimed_args];
        files.length = 0;

        foreach (string arg in args[1:unclaimed_args + 1]) {
          // We set a message, that later is informed to the user
          // in a dialog if something noteworthy happens.
          string msg = "";
          try {
            var file = File.new_for_commandline_arg (arg);

            if (!file.query_exists ()) {
              try {
                FileUtils.set_contents (file.get_path (), "");
              } catch (Error e) {
                string reason = "";
                // We list some common errors for quick feedback
                if (e is FileError.ACCES) {
                  reason = "Maybe you do not have the necessary permissions.";
                } else if (e is FileError.NOENT) {
                  reason = "Maybe the file path provided is not valid.";
                } else if (e is FileError.ROFS) {
                  reason = "The location is read-only.";
                } else if (e is FileError.NOTDIR) {
                  reason = "The parent directory doesn't exist.";
                } else {
                  // Otherwise we simple use the error notification from glib
                  msg = e.message;
                }

                if (reason.length > 0) {
                  msg = "File %s cannot be created.\n%s".printf (file.get_path (), reason);
                }

                // Escape to the outer catch clause, and overwrite
                // the weird glib's standard errors.
                throw new Error (e.domain, e.code, msg);
              }
            }

            var info = file.query_info ("standard::*", FileQueryInfoFlags.NONE, null);
            string err_msg = "File %s cannot be opened.\n%s";
            string reason = "";

            switch (info.get_file_type ()) {
            case FileType.REGULAR:
            case FileType.SYMBOLIC_LINK:
              files += file;
              break;
            case FileType.MOUNTABLE:
              reason = "It is a mountable location.";
              break;
            case FileType.DIRECTORY:
              reason = "It is a directory.";
              break;
            case FileType.SPECIAL:
              reason = "It is a special file such as a socket,\n fifo, block device, or character device.";
              break;
            default:
              reason = "It is an unknown file type.";
              break;
            }

            if (reason.length > 0) {
              msg = err_msg.printf (file.get_path (), reason);
            }
          } catch (Error e) {
            warning (e.message);
          }

          // Notify the user that something happened.
          if (msg.length > 0) {
            var parent_window = get_last_window () as Gtk.Window;

            var dialog = new Gtk.MessageDialog.with_markup (parent_window,
                                                            Gtk.DialogFlags.MODAL,
                                                            Gtk.MessageType.ERROR,
                                                            Gtk.ButtonsType.CLOSE,
                                                            msg);
            dialog.run ();
            dialog.destroy ();
            dialog.close ();
          }
        }

        if (files.length > 0) {
          open (files, "");
        }
      }

      return 0;
    }

    public override int command_line (ApplicationCommandLine command_line) {
      int res = _command_line (command_line);
      return res;
    }

    public override void open (File[] files, string hint) {
      var window = get_last_window ();

      foreach (File file in files)
        window.notebook.open (file);
    }

    public ApplicationWindow ? get_last_window () {
      unowned List<weak Gtk.Window> windows = get_windows ();
      return windows.length () > 0 ? windows.last ().data as ApplicationWindow : null;
    }

    public override void activate () {
      // If there is no windows open, restore recent files, otherwise, open blank tab
      if (get_last_window () == null) {
        var window = this.new_window ();
        window.show ();
        if (settings_editor.get_boolean ("restore-recent-files")) {
          window.restore_recent_files ();
        }
      } else {
        var window = this.new_window ();
        window.show ();
      }
    }

    public ApplicationWindow new_window () {
      return new ApplicationWindow (this);
    }

    private static int main (string[] args) {
      Application app = Application.instance;
      return app.run (args);
    }
  }
}
