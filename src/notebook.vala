namespace EasyCode {
  public class Notebook : Gtk.Notebook {
    public unowned Window window;

    private List<Document> _tabs;
    public List<Document> tabs {
      get { return _tabs; }
    }

    public Document current {
      get {
        return (Document)get_nth_page (get_current_page ());
      }
    }

    public Notebook (Window window) {
      Object (expand: true,
        show_border: false,
        scrollable: true);

      this.window = window;

      _tabs = new List<Document>();

      on_tabs_changed ();
      page_added.connect (on_tab_added);
      page_removed.connect (on_tab_removed);
      switch_page.connect (on_tab_switched);
      page_reordered.connect (on_tab_reordered);
    }

    private void on_tab_removed (Gtk.Widget widget, uint page_num) {
      var tab = (Document)widget;

      if (tab == null)
        return;

      _tabs.remove (tab);
      on_tabs_changed ();
      if (current == null) {
        window.header_bar.set_doc (null);
        window.status_bar.set_doc (null);
      }
    }

    private void on_tab_added (Gtk.Widget widget, uint page_num) {
      var tab = (Document)widget;

      if (tab == null)
        return;

      _tabs.append (tab);
      on_tabs_changed ();
    }

    private void on_tab_reordered (Gtk.Widget widget, uint new_pos) {
      var tab = (Document)widget;

      if (tab == null)
        return;

      _tabs.remove (tab);
      _tabs.insert (tab, (int)new_pos);
    }

    private void on_tab_switched (Gtk.Widget widget, uint page_num = 0) {
      var tab = (Document)widget;

      if (tab == null)
        return;

          window.header_bar.set_doc (tab);
          window.status_bar.set_doc (tab);
          tab.sourceview.grab_focus ();
    }

    private void on_tabs_changed () {
      var pages = get_n_pages ();
      set_show_tabs (pages > 1);
      no_show_all = (pages == 0);
      visible = (pages > 0);
    }

    public void add_tab (Document tab) {
      if (tab == null)
        return;

      this.append_page (tab, tab.tab_label);
      //  tab.closed.connect (remove_tab);
      this.set_current_page (page_num (tab));
      this.set_tab_reorderable (tab, true);
    }

    public void remove_tab (Document tab) {
      if (tab == null)
        return;

      var pos = page_num (tab);

      if (pos != -1){
        tab.close ();
        this.remove_page (pos);
      }
    }

    public void remove_all_tabs () {
      _tabs.foreach ((tab) => {
        this.remove_tab (tab);
      });
    }

    public void set_taTab (Document tab) {
      if (tab == null)
        return;

      var pos = page_num (tab);

      if (pos != -1)
        this.set_current_page (page_num (tab));
    }
  }
}
