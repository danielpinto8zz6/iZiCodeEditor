namespace iZiCodeEditor{
    public class Search : Gtk.SearchBar {
        public Gtk.SearchEntry entry ;
        private Gtk.SourceSearchContext context ;

        construct {

            set_show_close_button (true) ;

            var nextButton = new Gtk.Button.from_icon_name ("go-down-symbolic", Gtk.IconSize.BUTTON) ;
            var prevButton = new Gtk.Button.from_icon_name ("go-up-symbolic", Gtk.IconSize.BUTTON) ;

            entry = new Gtk.SearchEntry () ;
            connect_entry (entry) ;

            var searchBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) ;
            searchBox.pack_start (entry, false, true, 0) ;
            searchBox.pack_start (prevButton, false, false, 0) ;
            searchBox.pack_start (nextButton, false, false, 0) ;
            searchBox.get_style_context ().add_class ("linked") ;
            add (searchBox) ;

            nextButton.clicked.connect (forward) ;
            prevButton.clicked.connect (backward) ;

            entry.changed.connect (forward_on_changed) ;
            entry.activate.connect (forward) ;
            entry.key_press_event.connect (on_search_entry_key_press) ;

        }

        // Search forward on entry changed
        public void forward_on_changed() {
            Gtk.TextIter sel_st ;
            Gtk.TextIter sel_end ;
            Gtk.TextIter match_st ;
            Gtk.TextIter match_end ;
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            buffer.get_selection_bounds (out sel_st, out sel_end) ;
            var settings = new Gtk.SourceSearchSettings () ;
            context = new Gtk.SourceSearchContext (buffer, settings) ;
            settings.set_search_text (entry.get_text ()) ;
            context.set_highlight (true) ;
            settings.set_wrap_around (true) ;
            bool found = context.forward (sel_st, out match_st, out match_end) ;
            if( found ){
                buffer.select_range (match_st, match_end) ;
                view.scroll_to_iter (match_st, 0.10, false, 0, 0) ;
                entry.get_style_context ().remove_class (Gtk.STYLE_CLASS_ERROR) ;
            } else {
                if( entry.text == "" )
                    entry.get_style_context ().remove_class (Gtk.STYLE_CLASS_ERROR) ;
                else
                    entry.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR) ;
            }
        }

        // Search forward
        public void forward() {
            Gtk.TextIter sel_st ;
            Gtk.TextIter sel_end ;
            Gtk.TextIter match_st ;
            Gtk.TextIter match_end ;
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            buffer.get_selection_bounds (out sel_st, out sel_end) ;
            var settings = new Gtk.SourceSearchSettings () ;
            context = new Gtk.SourceSearchContext (buffer, settings) ;
            settings.set_search_text (entry.get_text ()) ;
            settings.set_wrap_around (true) ;
            bool found = context.forward (sel_end, out match_st, out match_end) ;
            if( found ){
                buffer.select_range (match_st, match_end) ;
                view.scroll_to_iter (match_st, 0.10, false, 0, 0) ;
                entry.get_style_context ().remove_class (Gtk.STYLE_CLASS_ERROR) ;
            } else {
                if( entry.text == "" )
                    entry.get_style_context ().remove_class (Gtk.STYLE_CLASS_ERROR) ;
                else if( entry.text == "" )
                    entry.get_style_context ().remove_class (Gtk.STYLE_CLASS_ERROR) ;
                else
                    entry.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR) ;
            }
        }

        // Search backward
        public void backward() {
            Gtk.TextIter sel_st ;
            Gtk.TextIter sel_end ;
            Gtk.TextIter match_st ;
            Gtk.TextIter match_end ;
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            buffer.get_selection_bounds (out sel_st, out sel_end) ;
            var settings = new Gtk.SourceSearchSettings () ;
            context = new Gtk.SourceSearchContext (buffer, settings) ;
            settings.set_search_text (entry.get_text ()) ;
            settings.set_wrap_around (true) ;
            bool found = context.backward (sel_st, out match_st, out match_end) ;
            if( found == true ){
                buffer.select_range (match_st, match_end) ;
                view.scroll_to_iter (match_st, 0.10, false, 0, 0) ;
                entry.get_style_context ().remove_class (Gtk.STYLE_CLASS_ERROR) ;
            } else {
                if( entry.text == "" )
                    entry.get_style_context ().remove_class (Gtk.STYLE_CLASS_ERROR) ;
                else
                    entry.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR) ;
            }
        }

        public bool on_search_entry_key_press(Gdk.EventKey event) {
            if( entry.text == "" ){
                return false ;
            }

            string key = Gdk.keyval_name (event.keyval) ;
            if( event.state == Gdk.ModifierType.SHIFT_MASK ){
                key = "<Shift>" + key ;
            }

            switch( key ){
            case "<Shift>Return":
            case "Up":
                backward () ;
                return true ;
            case "Return":
            case "Down":
                forward () ;
                return true ;
            case "Escape":
                set_search_mode (false) ;
                return true ;
            }

            return false ;
        }

    }
}
