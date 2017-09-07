namespace iZiCodeEditor{
    const string NAME = "iZiCodeEditor" ;
    const string VERSION = "0.1" ;
    const string DESCRIPTION = "Simple text editor written in vala" ;
    const string ICON = "accessories-text-editor" ;
    const string[] AUTHORS = { "danielpinto8zz6 <https://github.com/danielpinto8zz6>", "Daniel Pinto <danielpinto8zz6-at-gmail-dot-com>", null } ;

    private class Application : Gtk.Application {
        public Application () {
            Object (application_id: "org.vala-apps.iZiCodeEditor",
                    flags : GLib.ApplicationFlags.HANDLES_OPEN) ;
        }

        public override void startup() {
            base.startup () ;
            var mainwin = new iZiCodeEditor.MainWin () ;
            mainwin.add_main_window (this) ;
            var operations = new iZiCodeEditor.Operations () ;
            operations.add_recent_files () ;
        }

        public override void activate() {

            var mainwin = new iZiCodeEditor.MainWin () ;
            mainwin.action_new () ;
            get_active_window ().present () ;
        }

        public override void open(File[] files, string hint) {
            string fileopen = null ;
            foreach( File f in files ){
                fileopen = f.get_path () ;
                var nbook = new iZiCodeEditor.NBook () ;
                nbook.create_tab (fileopen) ;
                var operations = new iZiCodeEditor.Operations () ;
                operations.open_file (fileopen) ;
            }
            get_active_window ().present () ;
        }

        private static int main(string[] args) {
            iZiCodeEditor.Application app = new iZiCodeEditor.Application () ;
            return app.run (args) ;
        }

    }
}
