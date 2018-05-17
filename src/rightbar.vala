namespace EasyCode {
  public class RightBar : Gtk.Notebook {
    private unowned Window window;

    public RightBar (Window window) {
      Object (no_show_all: true);

      this.window = window;

      this.page_added.connect (() => { on_bars_changed (); });
      this.page_removed.connect (() => { on_bars_changed (); });
    }

    private void on_bars_changed () {
      var pages = this.get_n_pages ();
      this.set_show_tabs (pages > 1);
      this.no_show_all = (pages == 0);
      this.visible = (pages > 0);
    }
  }
}
