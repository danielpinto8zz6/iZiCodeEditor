namespace iZiCodeEditor {
  public class GoToLine : Gtk.Popover {
    private Gtk.Entry entry;
    private iZiCodeEditor.SourceView ? sourceview = null;
    private Gtk.TextBuffer ? buffer = null;

    construct {
      entry = new Gtk.Entry ();
      entry.set_size_request (200, 30);

      var gotoBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
      gotoBox.pack_start (entry, false, true, 0);
      gotoBox.valign = Gtk.Align.CENTER;
      gotoBox.set_border_width (3);
      gotoBox.show_all ();

      add (gotoBox);

      scroll_event.connect ((evt) => {
        var window = Application.instance.get_last_window ();
        var tab_page = (Gtk.Grid)window.notebook.get_nth_page (window.notebook.get_current_page ());
        var scrolled = (Gtk.ScrolledWindow)tab_page.get_child_at (0, 0);
        scrolled.scroll_event (evt);
        return Gdk.EVENT_PROPAGATE;
      });

      entry.activate.connect_after (() => {
        int line, offset;
        entry.text.scanf ("%i.%i", out line, out offset);
        if (line < buffer.get_line_count ()) {
          sourceview.go_to (line, offset);
          sourceview.grab_focus ();
        } else {
          entry.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR);
        }
      });

      entry.grab_focus ();

      hide.connect (on_popover_hide);
    }

    private void on_popover_hide () {
      sourceview.grab_focus ();
    }

    public void set_sourceview (iZiCodeEditor.SourceView sourceview) {
      if (sourceview == null) {
        return;
      }
      this.sourceview = sourceview;
      buffer = sourceview.get_buffer ();
    }
  }
}
