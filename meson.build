project('easycode', ['c', 'vala'],        version: '0.1.0',
  meson_version: '>= 0.40.0',
)

locale_dir = join_paths(get_option('prefix'), get_option('localedir'))
vapi_dir = join_paths(meson.source_root(), 'vapi')

# Add our custom VAPI dir
add_project_arguments(['--vapidir', vapi_dir],
  language: 'vala'
)

i18n = import('i18n')

glib_min_version = '2.50'

# Configuration
conf = configuration_data()

conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('LOCALE_DIR', locale_dir)
conf.set_quoted('VERSION', meson.project_version())

configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

subdir('data')
subdir('src')
subdir('po')

meson.add_install_script('build-aux/meson/postinstall.py')
