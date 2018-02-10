namespace iZiCodeEditor {
  public class Document : Gtk.Grid {
    public iZiCodeEditor.SourceView sourceview;

    private Gtk.SourceMap source_map;

    private Gtk.SourceFile sourcefile = null;

    public unowned ApplicationWindow window {
      get {
        return notebook.window;
      }
    }

    public File file {
      get {
        return sourcefile.location;
      }
      set {
        sourcefile.set_location (value);
      }
    }

    public Gtk.Box tab_label;

    private Gtk.Label label;

    public unowned Notebook notebook { get; construct set; }

    public Document (File file, Notebook notebook) {
      Object (notebook: notebook,
              file: file);

      open.begin ();

      sourceview.change_syntax_highlight_from_file (file);

      label.label = get_file_name ();
      label.tooltip_text = get_file_path ();

      sourceview.buffer.set_modified (false);

      Gtk.TextIter iter_st;
      sourceview.buffer.get_start_iter (out iter_st);
      sourceview.buffer.place_cursor (iter_st);
      sourceview.scroll_to_iter (iter_st, 0.10, false, 0, 0);
    }

    public Document.new_doc (Notebook notebook) {
      Object (notebook: notebook);

      label.label = get_file_name ();
      label.tooltip_text = get_file_path ();

      Gtk.TextIter iter_st;
      sourceview.buffer.get_start_iter (out iter_st);
      sourceview.buffer.place_cursor (iter_st);
      sourceview.scroll_to_iter (iter_st, 0.10, false, 0, 0);
    }

    construct {

      label = new Gtk.Label ("");
      label.set_size_request (100, -1);

      var eventbox = new Gtk.EventBox ();
      eventbox.add (label);
      eventbox.button_press_event.connect ((event) => {
        if (event.button == 2) {
          notebook.close (this);
        }
        return false;
      });
      var tab_button = new Gtk.Button.from_icon_name ("window-close-symbolic",
                                                      Gtk.IconSize.MENU);
      tab_button.set_relief (Gtk.ReliefStyle.NONE);
      tab_button.set_hexpand (false);

      try {
        var provider = new Gtk.CssProvider ();
        var css_stuff = """ .close-tab-button { padding :0; } """;
        provider.load_from_data (css_stuff, css_stuff.length);
      } catch (Error e) {
        stderr.printf ("Error: %s\n", e.message);
      }

      tab_button.get_style_context ().add_class ("close-tab-button");
      tab_button.clicked.connect (() => {
        notebook.close (this);
      });
      tab_label = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
      tab_label.pack_start (eventbox);
      tab_label.pack_end (tab_button);
      tab_label.show_all ();

      sourceview = new iZiCodeEditor.SourceView (this);
      source_map = new Gtk.SourceMap ();
      sourcefile = new Gtk.SourceFile ();

      var scroll = new Gtk.ScrolledWindow (null, null);
      scroll.add (sourceview);
      scroll.set_hexpand (true);
      scroll.set_vexpand (true);

      source_map.set_view (sourceview);

      Gtk.TargetEntry uris = { "text/uri-list", 0, 0 };
      Gtk.TargetEntry text = { "text/plain", 0, 0 };
      Gtk.drag_dest_set (sourceview, Gtk.DestDefaults.ALL, { uris, text }, Gdk.DragAction.COPY);

      if (Application.settings_view.get_boolean ("source-map")) {
        source_map.show ();
        scroll.vscrollbar_policy = Gtk.PolicyType.EXTERNAL;
      } else {
        source_map.hide ();
        source_map.no_show_all = true;
        scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
      }
      Application.settings_view.changed["source-map"].connect (() => {
        if (Application.settings_view.get_boolean ("source-map")) {
          source_map.show ();
          scroll.vscrollbar_policy = Gtk.PolicyType.EXTERNAL;
        } else {
          source_map.hide ();
          source_map.no_show_all = true;
          scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
        }
      });

      attach (scroll, 0, 0, 1, 1);
      attach_next_to (source_map, scroll, Gtk.PositionType.RIGHT, 1, 1);

      show_all ();
    }

    public async bool open () {
      sourceview.sensitive = false;

      var buffer = new Gtk.SourceBuffer (null);

      try {
        var source_file_loader = new Gtk.SourceFileLoader (buffer, sourcefile);
        yield source_file_loader.load_async (GLib.Priority.DEFAULT, null, null);

        sourceview.buffer.text = buffer.text;
      } catch (Error e) {
        sourceview.buffer.text = "";
        critical (e.message);
        return false;
      }

      sourceview.buffer.set_modified (false);

      sourceview.sensitive = true;

      return true;
    }

    public async bool save () {
      if (!sourceview.buffer.get_modified ()) {
        return false;
      } else if (file == null) {
        save_as.begin ();
      }

      try {
        var source_file_saver = new Gtk.SourceFileSaver ((Gtk.SourceBuffer)sourceview.buffer, sourcefile);

        yield source_file_saver.save_async (GLib.Priority.DEFAULT, null, null);
      } catch (Error e) {
        save_fallback ();
        stderr.printf ("error: %s\n", e.message);
        return false;
      }
      sourceview.buffer.set_modified (false);

      return true;
    }

    public void save_fallback () {
      var parent_window = sourceview.get_toplevel () as Gtk.Window;

      var dialog = new Gtk.MessageDialog (parent_window,
                                          Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.NONE,
                                          "Error saving file %s.\n", file.get_parse_name ());
      dialog.add_button ("Don't save", Gtk.ResponseType.NO);
      dialog.add_button ("Select New Location", Gtk.ResponseType.YES);
      dialog.set_resizable (false);
      dialog.set_default_response (Gtk.ResponseType.YES);
      int response = dialog.run ();
      switch (response) {
      case Gtk.ResponseType.NO:
        break;
      case Gtk.ResponseType.YES:
        save_as.begin ();
        break;
      }
      dialog.destroy ();
    }

    public async bool save_as () {
      var parent_window = sourceview.get_toplevel () as Gtk.Window;

      var dialog = new Gtk.FileChooserDialog ("Save As...", parent_window,
                                              Gtk.FileChooserAction.SAVE,
                                              "Cancel", Gtk.ResponseType.CANCEL,
                                              "Save", Gtk.ResponseType.ACCEPT);
      dialog.set_do_overwrite_confirmation (true);
      dialog.set_modal (true);
      dialog.show ();
      if (dialog.run () == Gtk.ResponseType.ACCEPT) {
        file = File.new_for_uri (dialog.get_file ().get_uri ());

        sourceview.buffer.set_modified (true);
        var is_saved = yield save ();

        if (is_saved) {
          sourceview.change_syntax_highlight_from_file (file);

          label.label = get_file_name ();
          label.tooltip_text = get_file_path ();
        }

        dialog.destroy ();
      }
      return true;
    }

    public void set_status () {
      string unsaved_identifier = "* ";

      if (sourceview.buffer.get_modified ()) {
        if (!(unsaved_identifier in name)) {
          label.label = unsaved_identifier + label.label;
        }
      } else {
        label.label = label.label.replace (unsaved_identifier, "");
      }
    }

    public Gtk.Box get_tab_label () {
      return (Gtk.Box)tab_label;
    }

    public string get_file_name () {
      return file != null ? file.get_basename () : "New document";
    }

    public string get_file_path () {
      return file != null ? file.get_parse_name () : null;
    }
  }
}
