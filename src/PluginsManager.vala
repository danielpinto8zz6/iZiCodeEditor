namespace iZiCodeEditor{

    public class Plugins : Object {

        public Gtk.Notebook bottomBar { get ; set ; }
        public Gtk.Notebook leftBar { get ; set ; }
        public Gtk.Notebook rightBar { get ; set ; }

        private Peas.ExtensionSet extensions { get ; set ; }

        public Plugins () {

            // Bars

            bottomBar = new Gtk.Notebook () ;
            bottomBar.no_show_all = true ;
            bottomBar.page_added.connect (() => { on_bars_changed (bottomBar) ; }) ;
            bottomBar.page_removed.connect (() => { on_bars_changed (bottomBar) ; }) ;

            leftBar = new Gtk.Notebook () ;
            leftBar.no_show_all = true ;
            leftBar.width_request = 200 ;
            leftBar.page_added.connect (() => { on_bars_changed (leftBar) ; }) ;
            leftBar.page_removed.connect (() => { on_bars_changed (leftBar) ; }) ;


            rightBar = new Gtk.Notebook () ;
            rightBar.no_show_all = true ;
            rightBar.width_request = 200 ;
            rightBar.page_added.connect (() => { on_bars_changed (rightBar) ; }) ;
            rightBar.page_removed.connect (() => { on_bars_changed (rightBar) ; }) ;

            /* Get the default engine */
            var engine = Peas.Engine.get_default () ;

            /* Enable the python3 loader */
            // engine.enable_loader("python3");

            /* Add the current directory to the search path */
            string dir = Environment.get_current_dir () ;
            engine.add_search_path (dir, dir) ;

            /* Create the ExtensionSet */
            extensions = new Peas.ExtensionSet (engine, typeof
                                                (iZiCodeEditor.Extension), "plugins", this) ;
            extensions.extension_added.connect ((info, extension) => {
                (extension as iZiCodeEditor.Extension).activate () ;
            }) ;
            extensions.extension_removed.connect ((info, extension) => {
                (extension as iZiCodeEditor.Extension).deactivate () ;
            }) ;

            /* Load all the plugins */
            foreach( var plugin in engine.get_plugin_list () )
                engine.try_load_plugin (plugin) ;

        }

        private void on_bars_changed(Gtk.Notebook notebook) {
            var pages = notebook.get_n_pages () ;
            notebook.set_show_tabs (pages > 1) ;
            notebook.no_show_all = (pages == 0) ;
            notebook.visible = (pages > 0) ;
        }

    }

    public interface Extension : Object {

        /* This will be set to the window */
        public abstract Plugins plugins { get ; construct set ; }

        /* The "constructor" */
        public abstract void activate() ;

        /* The "destructor" */
        public abstract void deactivate() ;

    }
}
