namespace iZiCodeEditor{
    public class Find : Gtk.Dialog {
        private Gtk.Entry entry ;
        private Gtk.SourceSearchContext context ;

        public void show_dialog() {
            if( notebook.get_n_pages () == 0 ){
                return ;
            }

            var dialog = new Gtk.Dialog () ;
            dialog.set_transient_for (window) ;
            dialog.set_border_width (5) ;
            dialog.set_property ("skip-taskbar-hint", true) ;
            dialog.set_resizable (false) ;

            var header = new Gtk.HeaderBar () ;
            header.set_show_close_button (true) ;
            header.set_title ("Find") ;
            dialog.set_titlebar (header) ;

            var label_sch = new Gtk.Label.with_mnemonic ("Search for:") ;
            entry = new Gtk.Entry () ;
            var grid = new Gtk.Grid () ;
            grid.set_column_spacing (30) ;
            grid.set_row_spacing (10) ;
            grid.set_border_width (10) ;
            grid.set_row_homogeneous (true) ;
            grid.attach (label_sch, 0, 0, 1, 1) ;
            grid.attach (entry, 1, 0, 7, 1) ;
            grid.show_all () ;
            var content = dialog.get_content_area () as Gtk.Container ;
            content.add (grid) ;
            dialog.add_button ("Close", 1) ;
            dialog.add_button ("Previous", 2) ;
            dialog.add_button ("Next", 3) ;
            dialog.delete_event.connect (() => {
                context.set_highlight (false) ;
                dialog.destroy () ;
                return true ;
            }) ;
            dialog.response.connect (on_response) ;
            dialog.show_all () ;
            // signals
            entry.changed.connect (forward_on_changed) ;
            entry.activate.connect (forward) ;
            entry_start_text () ;
        }

        private void on_response(Gtk.Dialog dialog, int response) {
            switch( response ){
            case 1:
                context.set_highlight (false) ;
                dialog.destroy () ;
                break ;
            case 2:
                backward () ;
                break ;
            case 3:
                forward () ;
                break ;
            }
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
            rgba.parse ("#000000") ;
            entry.override_color (Gtk.StateFlags.NORMAL, rgba) ;
        }

        private void on_not_found_entry_color() {
            var rgba = Gdk.RGBA () ;
            rgba.parse ("#FF6666") ;
            entry.override_color (Gtk.StateFlags.NORMAL, rgba) ;
        }

    }
}
