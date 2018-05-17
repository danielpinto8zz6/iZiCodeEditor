easycode_sources = [
    'application.vala',
    'goto.vala',
    'headerbar.vala',
    'notebook.vala',
    'preferences.vala',
    'replace.vala',
    'search.vala',
    'sourceview.vala',
    'statusbar.vala',
    'terminal.vala',
    'window.vala',
    'document.vala',
    'comment.vala',
    'zoom.vala',
    'leftbar.vala',
    'bottombar.vala',
    'rightbar.vala',
    'constants.vala',
    'Explorer/explorer.vala',
    'Explorer/folder.vala'
]

easycode_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('gtksourceview-3.0', version: '>=3.22'),
  dependency ('gee-0.8', version: '>=0.8'),
  dependency ('vte-2.91', version: '>=0.52')
]

easycode_vala_flags = [
  '--target-glib', glib_min_version,
  '--vapidir=' + meson.current_source_dir(),
  '--pkg', 'config'
]

easycode_c_flags = [
  '-include', 'config.h',
]

gnome = import('gnome')

executable('easycode', easycode_sources,
  vala_args: easycode_vala_flags,  dependencies: easycode_deps,
  c_args: easycode_c_flags,
  install: true,
)