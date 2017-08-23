datadir = get_option('datadir')

install_data('iZiCodeEditor.desktop',
    install_dir : join_paths(datadir, 'applications'))

install_data('com.github.danielpinto8zz6.iZiCodeEditor.gschema.xml',
             install_dir: join_paths(datadir, 'glib-2.0' ,'schemas'))
meson.add_install_script('meson_post_install.py')

