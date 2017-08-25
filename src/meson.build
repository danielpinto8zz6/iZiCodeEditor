vala_sources = [
    'application.vala',
    'search.vala',
    'operations.vala',
    'settings.vala',
    'apply.vala', 
    'preferences.vala',
    'tabs.vala',
    'dialogs.vala',
    'notebook.vala',
    'window.vala'
]

vala_args = [
    '--pkg=gtk+-3.0',
    '--pkg=gtksourceview-3.0',
]

iZiCodeEditor = executable('iZiCodeEditor',
                     vala_sources,
                     vala_args: vala_args,
                     install: true,
                     dependencies : [gtk, sourceview])
