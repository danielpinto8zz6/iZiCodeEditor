namespace iZiCodeEditor {
  public class Search : Gtk.Popover {
    private Gtk.Entry entry;
    private Gtk.SourceSearchContext context = null;
    private iZiCodeEditor.SourceView ? sourceview = null;
    private Gtk.TextBuffer ? buffer = null;
    private Gtk.Button label_occurrences;

    public unowned ApplicationWindow window { get; construct set; }

    public Search (iZiCodeEditor.ApplicationWindow window) {
      Object (window: window);
    }

    construct {
      entry = new Gtk.SearchEntry ();
      entry.set_size_request (200, 30);

      var nextButton = new Gtk.Button.from_icon_name ("go-down-symbolic", Gtk.IconSize.BUTTON);
      var prevButton = new Gtk.Button.from_icon_name ("go-up-symbolic", Gtk.IconSize.BUTTON);

      nextButton.set_can_focus (false);
      prevButton.set_can_focus (false);

      label_occurrences = new Gtk.Button ();
      label_occurrences.set_sensitive (false);

      var searchBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
      searchBox.add (entry);
      searchBox.add (prevButton);
      searchBox.add (nextButton);
      searchBox.add (label_occurrences);
      searchBox.get_style_context ().add_class ("linked");
      searchBox.valign = Gtk.Align.CENTER;
      searchBox.set_border_width (3);
      searchBox.show_all ();

      label_occurrences.hide ();

      add (searchBox);

      entry.changed.connect (forward);
      entry.grab_focus ();
      entry.key_press_event.connect (on_search_entry_key_press);
      nextButton.clicked.connect (forward);
      prevButton.clicked.connect (backward);

      show.connect (() => {
        context.notify["occurrences-count"].connect (() =>
        {
          update_info_label ();
        });
      });

      scroll_event.connect ((evt) => {
        if (evt.direction == Gdk.ScrollDirection.UP)
          window.current_doc.scroll.scroll_event (evt);
        else if (evt.direction == Gdk.ScrollDirection.DOWN)
          window.current_doc.scroll.scroll_event (evt);
        return Gdk.EVENT_PROPAGATE;
      });

      hide.connect (on_popover_hide);
    }

    // Search forward
    private void forward () {
      Gtk.TextIter sel_st;
      Gtk.TextIter sel_end;
      Gtk.TextIter match_st;
      Gtk.TextIter match_end;
      buffer.get_selection_bounds (out sel_st, out sel_end);
      context.settings.set_search_text (entry.get_text ());
      context.set_highlight (true);
      context.settings.set_wrap_around (true);
      bool found = context.forward2 (sel_end, out match_st, out match_end, null);
      if (found) {
        buffer.select_range (match_st, match_end);
        sourceview.scroll_to_iter (match_st, 0.10, false, 0, 0);
        entry.get_style_context ().remove_class (Gtk.STYLE_CLASS_ERROR);
      } else {
        if (entry.text == "") {
          label_occurrences.hide ();
          entry.get_style_context ().remove_class (Gtk.STYLE_CLASS_ERROR);
        } else
          entry.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR);
      }
      update_info_label ();
    }

    // Search backward
    private void backward () {
      Gtk.TextIter sel_st;
      Gtk.TextIter sel_end;
      Gtk.TextIter match_st;
      Gtk.TextIter match_end;
      buffer.get_selection_bounds (out sel_st, out sel_end);
      context.settings.set_search_text (entry.get_text ());
      context.settings.set_wrap_around (true);
      bool found = context.backward2 (sel_st, out match_st, out match_end, null);
      if (found == true) {
        buffer.select_range (match_st, match_end);
        sourceview.scroll_to_iter (match_st, 0.10, false, 0, 0);
        entry.get_style_context ().remove_class (Gtk.STYLE_CLASS_ERROR);
      } else {
        if (entry.text == "")
          entry.get_style_context ().remove_class (Gtk.STYLE_CLASS_ERROR);
        else
          entry.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR);
      }
      update_info_label ();
    }

    // On popover hide
    private void on_popover_hide () {
      sourceview.grab_focus ();
      if (entry.get_text_length () > 0)
        context.set_highlight (false);
    }

    private bool on_search_entry_key_press (Gdk.EventKey event) {
      string key = Gdk.keyval_name (event.keyval);
      if (event.state == Gdk.ModifierType.SHIFT_MASK) {
        key = "<Shift>" + key;
      }

      switch (key) {
      case "<Shift>Return" :
      case "Up" :
        backward ();
        return true;
      case "Return" :
      case "Down" :
        forward ();
        return true;
      }

      return false;
    }

    public void set_sourceview (iZiCodeEditor.SourceView sourceview) {
      if (sourceview == null) {
        return;
      }
      this.sourceview = sourceview;
      buffer = sourceview.get_buffer ();
      context = new Gtk.SourceSearchContext (buffer as Gtk.SourceBuffer, null);
    }

    private void update_info_label () {
      if (context == null ||
          context.settings.get_search_text () == null) {
        label_occurrences.set_label ("");
        return;
      }

      int count = context.occurrences_count;

      if (count == -1) {
        label_occurrences.hide ();
        return;
      }

      if (count == 0) {
        label_occurrences.hide ();
        return;
      }

      Gtk.TextBuffer buffer = context.get_buffer ();
      Gtk.TextIter start;
      Gtk.TextIter end;

      buffer.get_selection_bounds (out start, out end);

      int pos = context.get_occurrence_position (start, end);

      label_occurrences.set_label ("%d of %d".printf (pos, count));
      label_occurrences.show ();
    }
  }
}
