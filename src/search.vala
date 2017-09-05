namespace iZiCodeEditor{
    public class Search : Gtk.Dialog {
        private Gtk.Entry entry ;
        private Gtk.SourceSearchContext context ;
        private Gtk.Popover popover ;

        public void show_dialog() {
            if( notebook.get_n_pages () == 0 )
                return ;

            entry = new Gtk.SearchEntry () ;
            entry.set_size_request (200, 30) ;

            var nextButton = new Gtk.Button.from_icon_name ("go-down-symbolic", Gtk.IconSize.BUTTON) ;
            var prevButton = new Gtk.Button.from_icon_name ("go-up-symbolic", Gtk.IconSize.BUTTON) ;
            var closeButton = new Gtk.Button.from_icon_name ("close-symbolic", Gtk.IconSize.BUTTON) ;

            nextButton.set_can_focus (false) ;
            prevButton.set_can_focus (false) ;
            closeButton.set_can_focus (false) ;

            var searchBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) ;
            searchBox.pack_start (entry, false, true, 0) ;
            searchBox.pack_start (prevButton, false, false, 0) ;
            searchBox.pack_start (nextButton, false, false, 0) ;
            searchBox.pack_start (closeButton, false, false, 0) ;
            searchBox.get_style_context ().add_class ("linked") ;
            searchBox.valign = Gtk.Align.CENTER ;
            searchBox.set_border_width (3) ;
            searchBox.show_all () ;

            popover = new Gtk.Popover (searchButton) ;
            popover.add (searchBox) ;
            popover.set_modal (false) ;
            popover.set_visible (true) ;

            // signals
            entry.changed.connect (forward_on_changed) ;
            entry.activate.connect (forward) ;
            entry.grab_focus () ;
            entry.key_press_event.connect (on_search_entry_key_press) ;
            nextButton.clicked.connect (forward) ;
            prevButton.clicked.connect (backward) ;
            closeButton.clicked.connect (() => {
                popover.hide () ;
            }) ;

            popover.hide.connect (on_popover_hide) ;
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

        // On popover hide
        private void on_popover_hide() {
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_current_sourceview () ;
            view.grab_focus () ;

            if( entry.get_text_length () > 0 )
                context.set_highlight (false) ;
        }

        public bool on_search_entry_key_press(Gdk.EventKey event) {

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
                popover.hide () ;
                return true ;
            }

            return false ;
        }

    }
}
