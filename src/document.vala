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
        label.label = get_file_name ();
        label.tooltip_text = get_file_path ();
      }
    }

    public Gtk.Box tab_label;

    private Gtk.Label label;

    public Gtk.ScrolledWindow scroll;

    private bool ask_if_externally_modified = false;
    private bool ask_if_deleted = false;

    public bool is_file_temporary {
      get {
        return file.get_path ().has_prefix (Application.instance.unsaved_files_directory);
      }
    }
    public bool saved = true;
    private bool loaded = false;

    private Cancellable save_cancellable;
    private Cancellable load_cancellable;

    public signal void doc_closed ();

    public unowned Notebook notebook { get; construct set; }

    public Document (File file, Notebook notebook) {
      Object (notebook: notebook,
              file: file);

      Idle.add_full (GLib.Priority.LOW, () => {
        open.begin ((obj, res) => {
          open.end (res);
        });

        return false;
      });

      sourceview.update_syntax_highlighting ();
    }

    construct {
      label = new Gtk.Label ("");
      label.set_size_request (100, -1);
      label.ellipsize = Pango.EllipsizeMode.END;

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

      scroll = new Gtk.ScrolledWindow (null, null);
      scroll.add (sourceview);
      scroll.set_hexpand (true);
      scroll.set_vexpand (true);

      source_map.set_view (sourceview);

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

      attach (scroll, 0, 1, 1, 1);
      attach_next_to (source_map, scroll, Gtk.PositionType.RIGHT, 1, 1);

      show_all ();
    }

    private bool check_file () {
      if (!loaded) {
        return false;
      }
      sourcefile.check_file_on_disk ();

      if (!ask_if_deleted && sourcefile.is_deleted ()) {
        ask_if_deleted = true;

        Gtk.InfoBar infobar = new Gtk.InfoBar ();

        infobar.add_button ("Save",   Gtk.ResponseType.OK);
        infobar.add_button ("Ignore", Gtk.ResponseType.REJECT);

        string msg = "The file %s was deleted. Do you want to save it?"
                     .printf (file.get_parse_name ());

        Gtk.Container content = infobar.get_content_area ();
        var info = new Gtk.Label (msg);
        content.add (info);

        infobar.set_message_type (Gtk.MessageType.WARNING);

        attach (infobar, 0, 0, 2, 1);

        infobar.show_all ();

        infobar.response.connect ((response_id) =>
        {
          if (response_id == Gtk.ResponseType.OK) {
            save_as.begin ();
            ask_if_deleted = false;
          }
          sourceview.grab_focus ();
          infobar.destroy ();
        });
      } else if (!ask_if_externally_modified && sourcefile.is_local ()
                 && sourcefile.is_externally_modified ()) {
        ask_if_externally_modified = true;

        Gtk.InfoBar infobar = new Gtk.InfoBar ();

        infobar.add_button ("Reload", Gtk.ResponseType.OK);
        infobar.add_button ("Ignore", Gtk.ResponseType.REJECT);

        string msg = "The file %s changed on disk. Reload it?"
                     .printf (file.get_parse_name ());

        Gtk.Container content = infobar.get_content_area ();
        var info = new Gtk.Label (msg);
        content.add (info);

        infobar.set_message_type (Gtk.MessageType.WARNING);

        attach (infobar, 0, 0, 2, 1);

        infobar.show_all ();

        infobar.response.connect ((response_id) =>
        {
          if (response_id == Gtk.ResponseType.OK) {
            open.begin ();
            ask_if_externally_modified = false;
          }
          infobar.destroy ();
          sourceview.grab_focus ();
        });
      }
      return false;
    }

    private async void open () {
      if (load_cancellable != null) {
        load_cancellable.cancel ();
      }

      load_cancellable = new Cancellable ();

      if (!exists (load_cancellable)) {
        try {
          FileUtils.set_contents (file.get_path (), "");
        } catch (FileError error) {
          warning ("Cannot create file \"%s\": %s", get_file_name (), error.message);
          return;
        }
      }

      sourceview.sensitive = false;
      loaded = false;

      while (Gtk.events_pending ()) {
        Gtk.main_iteration ();
      }

      var buffer = new Gtk.SourceBuffer (null);

      try {
        var source_file_loader = new Gtk.SourceFileLoader (buffer, sourcefile);
        yield source_file_loader.load_async (GLib.Priority.LOW, load_cancellable, null);
        sourceview.buffer.text = buffer.text;
        loaded = true;
      } catch (Error e) {
        sourceview.buffer.text = "";
        critical (e.message);
        return;
      } finally {
        load_cancellable = null;
      }

      sourceview.focus_in_event.connect (check_file);

      sourceview.buffer.set_modified (false);

      sourceview.buffer.modified_changed.connect (() => {
        if (sourceview.buffer.get_modified ()) {
          set_saved_status (false);
        }
      });

      Gtk.TextIter iter_st;
      sourceview.buffer.get_start_iter (out iter_st);
      sourceview.buffer.place_cursor (iter_st);
      sourceview.scroll_to_iter (iter_st, 0.10, false, 0, 0);

      sourceview.sensitive = true;

      sourceview.grab_focus ();
    }

    public async bool save () {
      if (!sourceview.buffer.get_modified () || loaded == false) {
        return false;
      }

      save_cancellable.cancel ();
      save_cancellable = new GLib.Cancellable ();

      var source_file_saver = new Gtk.SourceFileSaver ((Gtk.SourceBuffer)sourceview.buffer, sourcefile);

      try {
        yield source_file_saver.save_async (GLib.Priority.DEFAULT, save_cancellable, null);
      } catch (Error e) {
        warning ("Cannot save \"%s\": %s", get_file_name (), e.message);
        return false;
      }

      sourceview.buffer.set_modified (false);

      set_saved_status (true);

      return true;
    }

    public async bool save_as () {
      if (!loaded) {
        return false;
      }

      bool success = false;
      bool is_current_file_temporary = is_file_temporary;
      string current_file = file.get_path ();

      var dialog = new Gtk.FileChooserDialog ("Save As...", window,
                                              Gtk.FileChooserAction.SAVE,
                                              "Cancel", Gtk.ResponseType.CANCEL,
                                              "Save", Gtk.ResponseType.ACCEPT);
      dialog.set_do_overwrite_confirmation (true);
      dialog.set_modal (true);
      dialog.show ();
      if (dialog.run () == Gtk.ResponseType.ACCEPT) {
        file = File.new_for_uri (dialog.get_file ().get_uri ());

        success = true;
      }

      if (success) {
        sourceview.buffer.set_modified (true);
        var is_saved = yield save ();

        if (is_saved && is_current_file_temporary) {
          try {
            File.new_for_path (current_file).delete ();
          } catch (Error err) {
            message ("Temporary file cannot be deleted: %s", current_file);
          }
        }

        sourceview.update_syntax_highlighting ();
      }

      dialog.destroy ();

      return success;
    }

    public void set_saved_status (bool val) {
      saved = val;

      string unsaved_identifier = "* ";

      if (!val) {
        if (!(unsaved_identifier in label.label)) {
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
      return file.get_basename ();
    }

    public string get_file_path () {
      return !is_file_temporary ? file.get_parse_name () : null;
    }

    private bool delete_temporary_file (bool force = false) {
      if (!is_file_temporary || (sourceview.buffer.text.length > 0 && !force)) {
        return false;
      }

      try {
        file.delete ();
        return true;
      } catch (Error e) {
        warning ("Cannot delete temporary file \"%s\": %s", file.get_path (), e.message);
      }

      return false;
    }

    public bool close () {
      if (!loaded) {
        load_cancellable.cancel ();
        return true;
      }

      bool ret = true;

      if (!saved || (is_file_temporary && !delete_temporary_file ())) {
        var dialog = new Gtk.MessageDialog (window, Gtk.DialogFlags.MODAL,
                                            Gtk.MessageType.WARNING, Gtk.ButtonsType.NONE, "");
        dialog.type_hint = Gdk.WindowTypeHint.DIALOG;
        dialog.deletable = false;

        dialog.use_markup = true;

        dialog.text = ("<b>Save changes to document %s before closing?</b>").printf (get_file_name ());

        dialog.add_button ("Close without saving", Gtk.ResponseType.NO);
        dialog.add_button ("Cancel",               Gtk.ResponseType.CANCEL);
        dialog.add_button ("Save",                 Gtk.ResponseType.YES);
        dialog.set_default_response (Gtk.ResponseType.ACCEPT);

        int response = dialog.run ();
        switch (response) {
        case Gtk.ResponseType.CANCEL :
        case Gtk.ResponseType.DELETE_EVENT :
          ret = false;
          break;
        case Gtk.ResponseType.YES :
          if (is_file_temporary)
            save_as.begin ();
          else
            save.begin ();
          break;
        case Gtk.ResponseType.NO :
          if (is_file_temporary)
            delete_temporary_file (true);
          break;
        }
        dialog.destroy ();
      }

      if (ret) {
        doc_closed ();
      }

      return ret;
    }

    public bool exists (Cancellable ? cancellable = null) {
      return file.query_exists (cancellable);
    }
  }
}
