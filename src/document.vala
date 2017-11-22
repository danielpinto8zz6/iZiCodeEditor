namespace iZiCodeEditor{
    public class Document : Gtk.Grid {
        public iZiCodeEditor.SourceView sourceview ;

        private Gtk.SourceMap source_map ;

        private Gtk.SourceFile sourcefile ;

        public File file {
            get {
                return sourcefile.location ;
            }
            set {
                sourcefile.set_location (value) ;
            }
        }

        public Gtk.Label label ;

        public Gtk.Box _tab_label ;

        public Gtk.Box tab_label {
            get {
                return (Gtk.Box)_tab_label ;
            }
        }

        public string ? _file_name = null ;

        public string ? file_name {
            get {
                return _file_name ;
            }
            set {
                _file_name = value ;
            }
        }

        public string ? _file_parse_name = null ;

        public string ? file_parse_name {
            get {
                return _file_parse_name ;
            }
            set {
                _file_parse_name = value ;
            }
        }

        private string ? _mime_type = null ;
        public string ? mime_type {
            get {
                if( _mime_type == null ){
                    try {
                        var info = file.query_info ("standard::*", FileQueryInfoFlags.NONE, null) ;
                        var content_type = info.get_attribute_as_string (FileAttribute.STANDARD_CONTENT_TYPE) ;
                        _mime_type = ContentType.get_mime_type (content_type) ;
                        return _mime_type ;
                    } catch ( Error e ){
                        debug (e.message) ;
                    }
                }

                if( _mime_type == null ){
                    _mime_type = "undefined" ;
                }

                return _mime_type ;
            }
        }

        public signal void close_tab(Document doc) ;
        public signal void cursor_position(Document doc) ;

        public Document (File ? file = null) {
            this.file = file ;
            if( file != null ){
                _file_name = file.get_basename () ;
                _file_parse_name = file.get_parse_name () ;
            } else {
                _file_name = "New Document" ;
                _file_parse_name = null ;
            }
        }

        construct {
            label = new Gtk.Label ("") ;
            label.set_size_request (100, -1) ;

            var eventbox = new Gtk.EventBox () ;
            eventbox.add (label) ;
            eventbox.button_press_event.connect ((event) => {
                if( event.button == 2 ){
                    close_tab (this) ;
                }
                return false ;
            }) ;
            var tab_button = new Gtk.Button.from_icon_name ("window-close-symbolic",
                                                            Gtk.IconSize.MENU) ;
            tab_button.set_relief (Gtk.ReliefStyle.NONE) ;
            tab_button.set_hexpand (false) ;
            tab_button.get_style_context ().add_class ("close-tab-button") ;
            tab_button.clicked.connect (() => {
                close_tab (this) ;
            }) ;
            _tab_label = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) ;
            _tab_label.pack_start (eventbox) ;
            _tab_label.pack_end (tab_button) ;
            _tab_label.show_all () ;

            sourceview = new iZiCodeEditor.SourceView () ;
            source_map = new Gtk.SourceMap () ;
            sourcefile = new Gtk.SourceFile () ;

            var scroll = new Gtk.ScrolledWindow (null, null) ;
            scroll.add (sourceview) ;
            scroll.set_hexpand (true) ;
            scroll.set_vexpand (true) ;

            source_map.set_view (sourceview) ;

            Gtk.TargetEntry uris = { "text/uri-list", 0, 0 } ;
            Gtk.TargetEntry text = { "text/plain", 0, 0 } ;
            Gtk.drag_dest_set (sourceview, Gtk.DestDefaults.ALL, { uris, text }, Gdk.DragAction.COPY) ;

            if( Application.settings_view.get_boolean ("source-map")){
                source_map.show () ;
                scroll.vscrollbar_policy = Gtk.PolicyType.EXTERNAL ;
            } else {
                source_map.hide () ;
                source_map.no_show_all = true ;
                scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC ;
            }
            Application.settings_view.changed["source-map"].connect (() => {
                if( Application.settings_view.get_boolean ("source-map")){
                    source_map.show () ;
                    scroll.vscrollbar_policy = Gtk.PolicyType.EXTERNAL ;
                } else {
                    source_map.hide () ;
                    source_map.no_show_all = true ;
                    scroll.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC ;
                }
            }) ;

            sourceview.buffer.notify["cursor-position"].connect (() => {
                cursor_position (this) ;
            }) ;

            attach (scroll, 0, 0, 1, 1) ;
            attach_next_to (source_map, scroll, Gtk.PositionType.RIGHT, 1, 1) ;

            show_all () ;
        }

        public void new_doc() {

            sourceview.buffer.modified_changed.connect (() => {
                set_status () ;
            }) ;

            label.label = file_name ;
            label.tooltip_text = file_parse_name ;

            Gtk.TextIter iter_st ;
            sourceview.buffer.get_start_iter (out iter_st) ;
            sourceview.buffer.place_cursor (iter_st) ;
            sourceview.scroll_to_iter (iter_st, 0.10, false, 0, 0) ;

            sourceview.grab_focus () ;
        }

        public async bool open() {
            sourceview.sensitive = false ;

            while( Gtk.events_pending ()){
                Gtk.main_iteration () ;
            }

            try {
                var source_file_loader = new Gtk.SourceFileLoader ((Gtk.SourceBuffer)sourceview.buffer, sourcefile) ;

                yield source_file_loader.load_async(GLib.Priority.DEFAULT, null, null) ;

            } catch ( Error e ){
                stderr.printf ("error: %s\n", e.message) ;
                return false ;
            }

            sourceview.set_language_from_file (file) ;

            Application.instance.get_last_window ().status_bar.update_statusbar_language (this) ;

            sourceview.buffer.set_modified (false) ;

            sourceview.buffer.modified_changed.connect (() => {
                set_status () ;
            }) ;

            label.label = file_name ;
            label.tooltip_text = file_parse_name ;

            sourceview.sensitive = true ;

            Gtk.TextIter iter_st ;
            sourceview.buffer.get_start_iter (out iter_st) ;
            sourceview.buffer.place_cursor (iter_st) ;
            sourceview.scroll_to_iter (iter_st, 0.10, false, 0, 0) ;

            sourceview.grab_focus () ;

            return true ;
        }

        public async bool save() {
            if( file == null ){
                save_as.begin () ;
            }
            try {
                var source_file_saver = new Gtk.SourceFileSaver ((Gtk.SourceBuffer)sourceview.buffer, sourcefile) ;

                yield source_file_saver.save_async(GLib.Priority.DEFAULT, null, null) ;

            } catch ( Error e ){
                save_fallback () ;
                stderr.printf ("error: %s\n", e.message) ;
                return false ;
            }
            sourceview.buffer.set_modified (false) ;

            return true ;
        }

        public void save_fallback() {
            var parent_window = sourceview.get_toplevel () as Gtk.Window ;

            var dialog = new Gtk.MessageDialog (parent_window,
                                                Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.NONE,
                                                "Error saving file %s.\nThe file on disk may now be truncated!", file.get_parse_name ()) ;
            dialog.add_button ("Don't save", Gtk.ResponseType.NO) ;
            dialog.add_button ("Select New Location", Gtk.ResponseType.YES) ;
            dialog.set_resizable (false) ;
            dialog.set_default_response (Gtk.ResponseType.YES) ;
            int response = dialog.run () ;
            switch( response ){
            case Gtk.ResponseType.NO:
                break ;
            case Gtk.ResponseType.YES:
                save_as.begin () ;
                break ;
            }
            dialog.destroy () ;
        }

        public async bool save_as() {
            var parent_window = sourceview.get_toplevel () as Gtk.Window ;

            var dialog = new Gtk.FileChooserDialog ("Save As...", parent_window,
                                                    Gtk.FileChooserAction.SAVE,
                                                    "Cancel", Gtk.ResponseType.CANCEL,
                                                    "Save", Gtk.ResponseType.ACCEPT) ;
            dialog.set_do_overwrite_confirmation (true) ;
            dialog.set_modal (true) ;
            dialog.show () ;
            if( dialog.run () == Gtk.ResponseType.ACCEPT ){
                file = File.new_for_uri (dialog.get_file ().get_uri ()) ;

                sourceview.buffer.set_modified (true) ;
                var is_saved = yield save() ;

                if( is_saved ){
                    sourceview.set_language_from_file (file) ;

                    Application.instance.get_last_window ().status_bar.update_statusbar_language (this) ;

                    _file_name = file.get_basename () ;
                    _file_parse_name = file.get_parse_name () ;

                    Application.instance.get_last_window ().headerbar.set_title (file_name) ;
                    Application.instance.get_last_window ().headerbar.set_subtitle (file_parse_name) ;

                    label.label = file_name ;
                    label.tooltip_text = file_parse_name ;
                }

                dialog.destroy () ;
            }
            return true ;
        }

        public void set_status() {
            string unsaved_identifier = "* " ;

            if( sourceview.buffer.get_modified () == true ){

                if( !(unsaved_identifier in name)){
                    label.label = unsaved_identifier + label.label ;
                }
            } else {
                label.label = label.label.replace (unsaved_identifier, "") ;
            }
        }

    }
}
