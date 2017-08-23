namespace iZiCodeEditor{
    public class Find : Gtk.Dialog {
        private Gtk.Entry entry ;
        private Gtk.SourceSearchContext context ;
        private Gtk.Popover popover ;
        private Gtk.Box buttonBox ;

        public void show_dialog() {
            if( notebook.get_n_pages () == 0 ){
                return ;
            }

            popover = new Gtk.Popover (searchButton) ;

            entry = new Gtk.Entry () ;

            var nextButton = new Gtk.Button.from_icon_name ("go-next-symbolic", Gtk.IconSize.BUTTON) ;
            var prevButton = new Gtk.Button.from_icon_name ("go-previous-symbolic", Gtk.IconSize.BUTTON) ;

            buttonBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) ;
            buttonBox.get_style_context ().add_class ("linked") ;
            buttonBox.pack_start (entry, false, false, 0) ;
            buttonBox.pack_start (prevButton, false, false, 0) ;
            buttonBox.pack_start (nextButton, false, false, 0) ;
            buttonBox.border_width = 6 ;
            popover.delete_event.connect (() => {
                context.set_highlight (false) ;
                popover.destroy () ;
                return true ;
            }) ;

            nextButton.clicked.connect (forward) ;
            prevButton.clicked.connect (backward) ;

            entry.changed.connect (forward_on_changed) ;
            entry.activate.connect (forward) ;
            entry_start_text () ;

            popover.add (buttonBox) ;
            popover.show_all () ;

        }

        // Set entry text from selection
        private void entry_start_text() {
            Gtk.TextIter sel_st ;
            Gtk.TextIter sel_end ;
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            buffer.get_selection_bounds (out sel_st, out sel_end) ;
            string sel_text = buffer.get_text (sel_st, sel_end, true) ;
            entry.grab_focus () ;
            entry.set_text (sel_text) ;
            entry.select_region (0, 0) ;
            entry.set_position (-1) ;
        }

        // Search forward on entry changed
        private void forward_on_changed() {
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
            bool found = context.forward (sel_st, out match_st, out match_end) ;
            if( found == true ){
                buffer.select_range (match_st, match_end) ;
                view.scroll_to_iter (match_st, 0.10, false, 0, 0) ;
                on_found_entry_color () ;
            } else {
                on_not_found_entry_color () ;
            }
        }

        // Search forward
        private void forward() {
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
            bool found = context.forward (sel_end, out match_st, out match_end) ;
            if( found == true ){
                buffer.select_range (match_st, match_end) ;
                view.scroll_to_iter (match_st, 0.10, false, 0, 0) ;
                on_found_entry_color () ;
            } else {
                on_not_found_entry_color () ;
            }
        }

        // Search backward
        private void backward() {
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
            bool found = context.backward (sel_st, out match_st, out match_end) ;
            if( found == true ){
                buffer.select_range (match_st, match_end) ;
                view.scroll_to_iter (match_st, 0.10, false, 0, 0) ;
                on_found_entry_color () ;
            } else {
                on_not_found_entry_color () ;
            }
        }

        // Change entry color
        private void on_found_entry_color() {
            var rgba = Gdk.RGBA () ;
            rgba.parse ("black") ;
            entry.override_color (Gtk.StateFlags.NORMAL, rgba) ;
        }

        private void on_not_found_entry_color() {
            var rgba = Gdk.RGBA () ;
            rgba.parse ("red") ;
            entry.override_color (Gtk.StateFlags.NORMAL, rgba) ;
        }

    }
}
