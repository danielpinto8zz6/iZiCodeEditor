namespace iZiCodeEditor{
    public class Replace : Gtk.Dialog {
        private Gtk.Entry entry_sch ;
        private Gtk.Entry entry_rep ;
        private Gtk.CheckButton check_case ;
        private Gtk.CheckButton check_back ;
        private Gtk.CheckButton check_regex ;
        private Gtk.CheckButton check_wordboundaries ;
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
            header.set_title ("Search & Replace") ;
            dialog.set_titlebar (header) ;

            var label_sch = new Gtk.Label.with_mnemonic ("Search for:") ;
            entry_sch = new Gtk.Entry () ;
            var label_rep = new Gtk.Label.with_mnemonic ("Repace with:") ;
            entry_rep = new Gtk.Entry () ;
            check_case = new Gtk.CheckButton.with_mnemonic ("Case sensitive") ;
            check_case.set_active (true) ;
            check_back = new Gtk.CheckButton.with_mnemonic ("Search backwards") ;
            check_back.set_active (false) ;
            check_regex = new Gtk.CheckButton.with_mnemonic ("Regular expressions") ;
            check_regex.set_active (false) ;
            check_wordboundaries = new Gtk.CheckButton.with_mnemonic ("Word boundaries") ;
            check_wordboundaries.set_active (false) ;
            var replaceButton = new Gtk.Button.with_label ("Replace") ;
            var replaceAllButton = new Gtk.Button.with_label ("Replace All") ;
            var findButton = new Gtk.Button.with_label ("Find") ;

            var buttonBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) ;
            buttonBox.pack_start (replaceButton, false, true, 0) ;
            buttonBox.pack_start (replaceAllButton, false, true, 0) ;
            buttonBox.pack_start (findButton, false, true, 0) ;
            buttonBox.set_homogeneous (true) ;
            buttonBox.get_style_context ().add_class ("linked") ;

            replaceButton.clicked.connect (replace) ;
            replaceAllButton.clicked.connect (() => {
                replace_all () ;
                context.set_highlight (false) ;
            }) ;
            findButton.clicked.connect (find) ;
            var grid = new Gtk.Grid () ;
            grid.set_column_spacing (30) ;
            grid.set_row_spacing (10) ;
            grid.set_border_width (10) ;
            // grid.set_row_homogeneous (true) ;
            grid.attach (label_sch, 0, 0, 1, 1) ;
            grid.attach (entry_sch, 1, 0, 5, 1) ;
            grid.attach (label_rep, 0, 1, 1, 1) ;
            grid.attach (entry_rep, 1, 1, 5, 1) ;
            grid.attach (check_case, 0, 2, 3, 1) ;
            grid.attach (check_back, 3, 2, 3, 1) ;
            grid.attach (check_regex, 0, 3, 3, 1) ;
            grid.attach (check_wordboundaries, 3, 3, 3, 1) ;
            grid.attach (buttonBox, 0, 4, 6, 1) ;
            grid.show_all () ;

            var content = dialog.get_content_area () as Gtk.Container ;
            content.add (grid) ;

            dialog.delete_event.connect (() => {
                context.set_highlight (false) ;
                dialog.destroy () ;
                return true ;
            }) ;
            dialog.show_all () ;

            entry_start_text () ;

            entry_sch.grab_focus_without_selecting () ;

        }

        // Set entry text from selectin
        public void entry_start_text() {
            Gtk.TextIter sel_st ;
            Gtk.TextIter sel_end ;
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            buffer.get_selection_bounds (out sel_st, out sel_end) ;
            string sel_text = buffer.get_text (sel_st, sel_end, true) ;
            entry_sch.grab_focus () ;
            entry_sch.set_text (sel_text) ;
            entry_sch.select_region (0, 0) ;
            entry_sch.set_position (-1) ;
        }

        // Replace
        private void replace() {
            // declaring vars
            bool forward = true ;
            bool found ;
            Gtk.TextIter sel_st ;
            Gtk.TextIter sel_end ;
            Gtk.TextIter match_st ;
            Gtk.TextIter match_end ;
            string search = entry_sch.get_text () ;
            string replace = entry_rep.get_text () ;
            // current source view
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            var settings = new Gtk.SourceSearchSettings () ;
            settings.set_wrap_around (true) ;
            context = new Gtk.SourceSearchContext (buffer, settings) ;
            if( check_case.get_active () ){
                settings.set_case_sensitive (true) ;
            }
            if( check_back.get_active () ){
                forward = false ;
            }
            if( check_regex.get_active () ){
                settings.set_regex_enabled (true) ;
            }
            if( check_wordboundaries.get_active () ){
                settings.set_at_word_boundaries (true) ;
            }
            buffer.get_selection_bounds (out sel_st, out sel_end) ;
            settings.set_search_text (search) ;
            // replace forward/backward
            if( forward ){
                found = context.forward (sel_st, out match_st, out match_end) ;
            } else {
                found = context.backward (sel_end, out match_st, out match_end) ;
            }
            if( found ){
                try {
                    buffer.select_range (match_st, match_end) ;
                    view.scroll_to_iter (match_st, 0.10, false, 0, 0) ;
                    context.replace (match_st, match_end, replace, replace.length) ;
                } catch ( Error e ){
                    stderr.printf ("error: %s\n", e.message) ;
                }
            }
        }

        // Replace all
        private void replace_all() {
            // declaring vars
            Gtk.TextIter sel_st ;
            Gtk.TextIter sel_end ;
            Gtk.TextIter match_st ;
            Gtk.TextIter match_end ;
            string search = entry_sch.get_text () ;
            string replace = entry_rep.get_text () ;
            // current source view
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            var settings = new Gtk.SourceSearchSettings () ;
            settings.set_wrap_around (true) ;
            context = new Gtk.SourceSearchContext (buffer, settings) ;
            if( check_case.get_active () ){
                settings.set_case_sensitive (true) ;
            }
            if( check_regex.get_active () ){
                settings.set_regex_enabled (true) ;
            }
            if( check_wordboundaries.get_active () ){
                settings.set_at_word_boundaries (true) ;
            }
            buffer.get_selection_bounds (out sel_st, out sel_end) ;
            settings.set_search_text (search) ;
            // replace all
            bool found = context.forward (sel_st, out match_st, out match_end) ;
            if( found ){
                try {
                    context.replace_all (replace, replace.length) ;
                    context.set_highlight (false) ;
                } catch ( Error e ){
                    stderr.printf ("error: %s\n", e.message) ;
                }
            }
        }

        // Find
        private void find() {
            // declaring vars
            bool forward = true ;
            bool found ;
            Gtk.TextIter sel_st ;
            Gtk.TextIter sel_end ;
            Gtk.TextIter match_st ;
            Gtk.TextIter match_end ;
            string search = entry_sch.get_text () ;
            // current source view
            var tabs = new iZiCodeEditor.Tabs () ;
            var view = tabs.get_current_sourceview () ;
            var buffer = (Gtk.SourceBuffer)view.get_buffer () ;
            var settings = new Gtk.SourceSearchSettings () ;
            settings.set_wrap_around (true) ;
            context = new Gtk.SourceSearchContext (buffer, settings) ;
            if( check_case.get_active ()  ){
                settings.set_case_sensitive (true) ;
            }
            if( check_back.get_active () ){
                forward = false ;
            }
            if( check_regex.get_active () ){
                settings.set_regex_enabled (true) ;
            }
            if( check_wordboundaries.get_active () ){
                settings.set_at_word_boundaries (true) ;
            }
            buffer.get_selection_bounds (out sel_st, out sel_end) ;
            settings.set_search_text (search) ;
            // find forward/backward
            if( forward ){
                found = context.forward (sel_end, out match_st, out match_end) ;
            } else {
                found = context.backward (sel_st, out match_st, out match_end) ;
            }
            if( found ){
                buffer.select_range (match_st, match_end) ;
                view.scroll_to_iter (match_st, 0.10, false, 0, 0) ;
                entry_sch.get_style_context ().remove_class (Gtk.STYLE_CLASS_ERROR) ;
            } else {
                if( entry_sch.text == "" )
                    entry_sch.get_style_context ().remove_class (Gtk.STYLE_CLASS_ERROR) ;
                else
                    entry_sch.get_style_context ().add_class (Gtk.STYLE_CLASS_ERROR) ;
            }
        }

    }
}
