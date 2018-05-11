namespace iZiCodeEditor {
  public class Replace : Gtk.Dialog {
    public unowned ApplicationWindow window { get; construct set; }

    private Gtk.Entry entry_sch;
    private Gtk.Entry entry_rep;
    private Gtk.CheckButton check_case;
    private Gtk.CheckButton check_back;
    private Gtk.CheckButton check_regex;
    private Gtk.CheckButton check_wordboundaries;
    private Gtk.SourceSearchContext context = null;
    private Gtk.SourceView ? view = null;

    public Replace (iZiCodeEditor.ApplicationWindow window) {
      Object (
        window: window,
        transient_for: window,
        resizable: false,
        border_width: 5
        );

      set_property ("skip-taskbar-hint", true);

      var header = new Gtk.HeaderBar ();
      header.set_show_close_button (true);
      header.set_title ("Search & Replace");
      set_titlebar (header);
    }

    construct {
      view = window.notebook.current_doc.sourceview;
      context = new Gtk.SourceSearchContext (view.buffer as Gtk.SourceBuffer, null);
      context.settings.set_wrap_around (true);

      var label_sch = new Gtk.Label.with_mnemonic ("Search for:");
      entry_sch = new Gtk.Entry ();
      var label_rep = new Gtk.Label.with_mnemonic ("Repace with:");
      entry_rep = new Gtk.Entry ();
      check_case = new Gtk.CheckButton.with_mnemonic ("Case sensitive");
      check_case.set_active (true);
      check_back = new Gtk.CheckButton.with_mnemonic ("Search backwards");
      check_back.set_active (false);
      check_regex = new Gtk.CheckButton.with_mnemonic ("Regular expressions");
      check_regex.set_active (false);
      check_wordboundaries = new Gtk.CheckButton.with_mnemonic ("Word boundaries");
      check_wordboundaries.set_active (false);
      var replaceButton = new Gtk.Button.with_label ("Replace");
      var replaceAllButton = new Gtk.Button.with_label ("Replace All");
      var findButton = new Gtk.Button.with_label ("Find");

      var buttonBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
      buttonBox.pack_start (replaceButton,    false, true, 0);
      buttonBox.pack_start (replaceAllButton, false, true, 0);
      buttonBox.pack_start (findButton,       false, true, 0);
      buttonBox.set_homogeneous (true);
      buttonBox.get_style_context ().add_class ("linked");

      replaceButton.clicked.connect (replace);
      replaceAllButton.clicked.connect (() => {
        replace_all ();
        context.set_highlight (false);
      });
      findButton.clicked.connect (find);
      var grid = new Gtk.Grid ();
      grid.set_column_spacing (30);
      grid.set_row_spacing (10);
      grid.set_border_width (10);
      // grid.set_row_homogeneous (true) ;
      grid.attach (label_sch,            0, 0, 1, 1);
      grid.attach (entry_sch,            1, 0, 5, 1);
      grid.attach (label_rep,            0, 1, 1, 1);
      grid.attach (entry_rep,            1, 1, 5, 1);
      grid.attach (check_case,           0, 2, 3, 1);
      grid.attach (check_back,           3, 2, 3, 1);
      grid.attach (check_regex,          0, 3, 3, 1);
      grid.attach (check_wordboundaries, 3, 3, 3, 1);
      grid.attach (buttonBox,            0, 4, 6, 1);
      grid.show_all ();

      var content = get_content_area () as Gtk.Container;
      content.add (grid);

      delete_event.connect (() => {
        context.set_highlight (false);
        destroy ();
      });

      entry_sch.grab_focus_without_selecting ();
    }

    // Replace
    private void replace () {
      // declaring vars
      bool forward = true;
      bool found;
      Gtk.TextIter sel_st;
      Gtk.TextIter sel_end;
      Gtk.TextIter match_st;
      Gtk.TextIter match_end;
      string search = entry_sch.get_text ();
      string replace = entry_rep.get_text ();

      if (check_case.get_active ()) {
        context.settings.set_case_sensitive (true);
      }
      if (check_back.get_active ()) {
        forward = false;
      }
      if (check_regex.get_active ()) {
        context.settings.set_regex_enabled (true);
      }
      if (check_wordboundaries.get_active ()) {
        context.settings.set_at_word_boundaries (true);
      }
      view.buffer.get_selection_bounds (out sel_st, out sel_end);
      context.settings.set_search_text (search);
      // replace forward/backward
      if (forward) {
        found = context.forward2 (sel_st, out match_st, out match_end, null);
      } else {
        found = context.backward2 (sel_end, out match_st, out match_end, null);
      }
      if (found) {
        try {
          view.buffer.select_range (match_st, match_end);
          view.scroll_to_iter (match_st, 0.10, false, 0, 0);
          context.replace2 (match_st, match_end, replace, replace.length);
        } catch (Error e) {
          stderr.printf ("error: %s\n", e.message);
        }
      }
    }

    // Replace all
    private void replace_all () {
      // declaring vars
      Gtk.TextIter sel_st;
      Gtk.TextIter sel_end;
      Gtk.TextIter match_st;
      Gtk.TextIter match_end;
      string search = entry_sch.get_text ();
      string replace = entry_rep.get_text ();

      if (check_case.get_active ()) {
        context.settings.set_case_sensitive (true);
      }
      if (check_regex.get_active ()) {
        context.settings.set_regex_enabled (true);
      }
      if (check_wordboundaries.get_active ()) {
        context.settings.set_at_word_boundaries (true);
      }
      view.buffer.get_selection_bounds (out sel_st, out sel_end);
      context.settings.set_search_text (search);
      // replace all
      bool found = context.forward2 (sel_st, out match_st, out match_end, null);
      if (found) {
        try {
          context.replace_all (replace, replace.length);
          context.set_highlight (false);
        } catch (Error e) {
          stderr.printf ("error: %s\n", e.message);
        }
      }
    }

    // Find
    private void find () {
      // declaring vars
      bool forward = true;
      bool found;
      Gtk.TextIter sel_st;
      Gtk.TextIter sel_end;
      Gtk.TextIter match_st;
      Gtk.TextIter match_end;
      string search = entry_sch.get_text ();

      if (check_case.get_active ()) {
        context.settings.set_case_sensitive (true);
      }
      if (check_back.get_active ()) {
        forward = false;
      }
      if (check_regex.get_active ()) {
        context.settings.set_regex_enabled (true);
      }
      if (check_wordboundaries.get_active ()) {
        context.settings.set_at_word_boundaries (true);
      }
      view.buffer.get_selection_bounds (out sel_st, out sel_end);
      context.settings.set_search_text (search);
      // find forward/backward
      if (forward) {
        found = context.forward2 (sel_end, out match_st, out match_end, null);
      } else {
        found = context.backward2 (sel_st, out match_st, out match_end, null);
      }
      if (found) {
        view.buffer.select_range (match_st, match_end);
        view.scroll_to_iter (match_st, 0.10, false, 0, 0);
        entry_sch.get_style_context ().remove_class (Gtk.STYLE_CLASS_ERROR);
      } else {
        if (entry_sch.text == "")
          entry_sch.get_style_context ().remove_class (Gtk.STYLE_CLASS_ERROR);
        else
          entry_sch.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR);
      }
    }
  }
}
