"
" This file was automatically generated by riml 0.4.0
" Modify with care!
"
function! s:SID()
  if exists('s:SID_VALUE')
    return s:SID_VALUE
  endif
  let s:SID_VALUE = matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
  return s:SID_VALUE
endfunction

if exists('g:wordpress_vim_plugin_loaded')
  finish
elseif v:version <# 703 || (v:version ==# 703 && !has('patch97'))
  finish
endif
" included: 'autocmd_loader.riml'
function! s:AutocmdLoaderConstructor()
  let autocmdLoaderObj = {}
  let autocmdLoaderObj.cmds = []
  let autocmdLoaderObj.set_group_name = function('<SNR>' . s:SID() . '_s:AutocmdLoader_set_group_name')
  let autocmdLoaderObj.get_group_name = function('<SNR>' . s:SID() . '_s:AutocmdLoader_get_group_name')
  let autocmdLoaderObj.load = function('<SNR>' . s:SID() . '_s:AutocmdLoader_load')
  let autocmdLoaderObj.unload = function('<SNR>' . s:SID() . '_s:AutocmdLoader_unload')
  let autocmdLoaderObj.cmd = function('<SNR>' . s:SID() . '_s:AutocmdLoader_cmd')
  let autocmdLoaderObj.size = function('<SNR>' . s:SID() . '_s:AutocmdLoader_size')
  return autocmdLoaderObj
endfunction

function! <SID>s:AutocmdLoader_set_group_name(group_name) dict
  let self.group_name = a:group_name
endfunction

function! <SID>s:AutocmdLoader_get_group_name() dict
  return self.group_name
endfunction

function! <SID>s:AutocmdLoader_load() dict
  execute ":augroup " . self.get_group_name()
  execute ":autocmd!"
  for cmd in self.cmds
    execute ":autocmd " . cmd
  endfor
  execute ":augroup END"
endfunction

function! <SID>s:AutocmdLoader_unload() dict
  execute ":augroup " . self.group_name
  execute ":autocmd!"
  execute ":augroup END"
endfunction

function! <SID>s:AutocmdLoader_cmd(ex_cmd) dict
  call add(self.cmds, a:ex_cmd)
endfunction

function! <SID>s:AutocmdLoader_size() dict
  return len(self.cmds)
endfunction

" included: 'buffer.riml'
" included: 'buffer_type_detector.riml'
function! s:BufferTypeDetectorConstructor()
  let bufferTypeDetectorObj = {}
  let bufferTypeDetectorObj.get_project_path = function('<SNR>' . s:SID() . '_s:BufferTypeDetector_get_project_path')
  let bufferTypeDetectorObj.get_parent_path = function('<SNR>' . s:SID() . '_s:BufferTypeDetector_get_parent_path')
  let bufferTypeDetectorObj.is_core_path = function('<SNR>' . s:SID() . '_s:BufferTypeDetector_is_core_path')
  return bufferTypeDetectorObj
endfunction

function! <SID>s:BufferTypeDetector_get_project_path(path) dict
  let parent_path = self.get_parent_path(a:path)
  if self.is_core_path(parent_path)
    return parent_path
  else
    return a:path
  endif
endfunction

function! <SID>s:BufferTypeDetector_get_parent_path(path) dict
  let dirname = fnamemodify(a:path, ':t')
  if dirname ==# 'plugins' || dirname ==# 'mu-plugins'
    let parent_upto = ':h:h'
  else
    let parent_upto = ':h:h:h'
  endif
  return fnamemodify(a:path, parent_upto)
endfunction

function! <SID>s:BufferTypeDetector_is_core_path(path) dict
  let wp_load_path = a:path . "/wp-load.php"
  return filereadable(wp_load_path)
endfunction

" included: 'core_detector.riml'
function! s:CoreDetectorConstructor()
  let coreDetectorObj = {}
  let bufferTypeDetectorObj = s:BufferTypeDetectorConstructor()
  call extend(coreDetectorObj, bufferTypeDetectorObj)
  let coreDetectorObj.detect = function('<SNR>' . s:SID() . '_s:CoreDetector_detect')
  let coreDetectorObj.get_type = function('<SNR>' . s:SID() . '_s:CoreDetector_get_type')
  return coreDetectorObj
endfunction

function! <SID>s:CoreDetector_detect(path) dict
  let found = findfile('wp-load.php', a:path . ";")
  let result = {}
  if found !=# ''
    let result.status = 1
    let result.path = fnamemodify(found, ':h')
  else
    let result.status = 0
    let result.path = ''
  endif
  return result
endfunction

function! <SID>s:CoreDetector_get_type() dict
  return 'core'
endfunction

" included: 'wpcli_detector.riml'
function! s:WpCliDetectorConstructor()
  let wpCliDetectorObj = {}
  let bufferTypeDetectorObj = s:BufferTypeDetectorConstructor()
  call extend(wpCliDetectorObj, bufferTypeDetectorObj)
  let wpCliDetectorObj.detect = function('<SNR>' . s:SID() . '_s:WpCliDetector_detect')
  let wpCliDetectorObj.get_wp_cli_configs = function('<SNR>' . s:SID() . '_s:WpCliDetector_get_wp_cli_configs')
  let wpCliDetectorObj.has_wp_cli = function('<SNR>' . s:SID() . '_s:WpCliDetector_has_wp_cli')
  let wpCliDetectorObj.get_type = function('<SNR>' . s:SID() . '_s:WpCliDetector_get_type')
  return wpCliDetectorObj
endfunction

function! <SID>s:WpCliDetector_detect(path) dict
  let configs = self.get_wp_cli_configs()
  let result = {}
  let result.status = 0
  let result.path = ''
  for config in configs
    let found = self.has_wp_cli(config, a:path)
    if found !=# ''
      let result.status = 1
      let result.path = fnamemodify(found, ':h')
      break
    endif
  endfor
  return result
endfunction

function! <SID>s:WpCliDetector_get_wp_cli_configs() dict
  return ['wp-cli.local.yml', 'wp-cli.yml']
endfunction

function! <SID>s:WpCliDetector_has_wp_cli(config, path) dict
  return findfile(a:config, a:path . ";")
endfunction

function! <SID>s:WpCliDetector_get_type() dict
  return 'wpcli'
endfunction

" included: 'plugin_detector.riml'
function! s:PluginDetectorConstructor()
  let pluginDetectorObj = {}
  let bufferTypeDetectorObj = s:BufferTypeDetectorConstructor()
  call extend(pluginDetectorObj, bufferTypeDetectorObj)
  let pluginDetectorObj.detect = function('<SNR>' . s:SID() . '_s:PluginDetector_detect')
  let pluginDetectorObj.is_plugin = function('<SNR>' . s:SID() . '_s:PluginDetector_is_plugin')
  let pluginDetectorObj.has_plugin_file = function('<SNR>' . s:SID() . '_s:PluginDetector_has_plugin_file')
  let pluginDetectorObj.has_plugin_header = function('<SNR>' . s:SID() . '_s:PluginDetector_has_plugin_header')
  let pluginDetectorObj.get_type = function('<SNR>' . s:SID() . '_s:PluginDetector_get_type')
  return pluginDetectorObj
endfunction

function! <SID>s:PluginDetector_detect(path) dict
  let parent = fnamemodify(a:path, ':p')
  let has_parent = 1
  let result = {}
  let result.status = 0
  let result.path = ''
  while has_parent
    if self.is_plugin(parent)
      let result.status = 1
      let result.path = self.get_project_path(parent)
      break
    endif
    let new_parent = fnamemodify(parent, ':h')
    let has_parent = new_parent !=# parent
    let parent = new_parent
  endwhile
  return result
endfunction

function! <SID>s:PluginDetector_is_plugin(path) dict
  let dirname = fnamemodify(a:path, ':t')
  if dirname ==# 'plugins' || dirname ==# 'mu-plugins'
    return 1
  else
    let plugin_file = a:path . "/" . dirname . ".php"
    return self.has_plugin_file(plugin_file) && self.has_plugin_header(plugin_file)
  endif
endfunction

function! <SID>s:PluginDetector_has_plugin_file(file) dict
  return filereadable(a:file)
endfunction

function! <SID>s:PluginDetector_has_plugin_header(file) dict
  let lines = readfile(a:file)
  for line in lines
    if line =~# '^\s*Plugin Name:'
      return 1
    endif
  endfor
  return 0
endfunction

function! <SID>s:PluginDetector_get_type() dict
  return 'plugin'
endfunction

" included: 'theme_detector.riml'
function! s:ThemeDetectorConstructor()
  let themeDetectorObj = {}
  let bufferTypeDetectorObj = s:BufferTypeDetectorConstructor()
  call extend(themeDetectorObj, bufferTypeDetectorObj)
  let themeDetectorObj.detect = function('<SNR>' . s:SID() . '_s:ThemeDetector_detect')
  let themeDetectorObj.get_wp_path = function('<SNR>' . s:SID() . '_s:ThemeDetector_get_wp_path')
  let themeDetectorObj.has_theme_header = function('<SNR>' . s:SID() . '_s:ThemeDetector_has_theme_header')
  let themeDetectorObj.get_type = function('<SNR>' . s:SID() . '_s:ThemeDetector_get_type')
  return themeDetectorObj
endfunction

function! <SID>s:ThemeDetector_detect(path) dict
  let found = findfile('style.css', a:path . ";")
  let result = {}
  if found !=# '' && self.has_theme_header(found)
    let result.status = 1
    let result.path = self.get_wp_path(found)
  else
    let result.status = 0
    let result.path = ''
  endif
  return result
endfunction

function! <SID>s:ThemeDetector_get_wp_path(found) dict
  let parent_path = fnamemodify(a:found, ':h')
  let core_path = fnamemodify(a:found, ':h:h:h:h')
  if self.is_core_path(core_path)
    return core_path
  else
    return parent_path
  endif
endfunction

function! <SID>s:ThemeDetector_has_theme_header(file) dict
  let lines = readfile(a:file)
  for line in lines
    if line =~# '^\s*Theme Name:'
      return 1
    endif
  endfor
  return 0
endfunction

function! <SID>s:ThemeDetector_get_type() dict
  return 'theme'
endfunction

function! s:BufferConstructor(path)
  let bufferObj = {}
  let bufferObj.path = a:path
  let bufferObj.did_scan = 0
  let bufferObj.project_path = ''
  let bufferObj.type = 'unknown'
  let bufferObj.scan = function('<SNR>' . s:SID() . '_s:Buffer_scan')
  let bufferObj.get_detectors = function('<SNR>' . s:SID() . '_s:Buffer_get_detectors')
  let bufferObj.get_type = function('<SNR>' . s:SID() . '_s:Buffer_get_type')
  let bufferObj.get_project_path = function('<SNR>' . s:SID() . '_s:Buffer_get_project_path')
  let bufferObj.get_path = function('<SNR>' . s:SID() . '_s:Buffer_get_path')
  let bufferObj.get_full_path = function('<SNR>' . s:SID() . '_s:Buffer_get_full_path')
  let bufferObj.get_parent_path = function('<SNR>' . s:SID() . '_s:Buffer_get_parent_path')
  let bufferObj.to_full_path = function('<SNR>' . s:SID() . '_s:Buffer_to_full_path')
  let bufferObj.destroy = function('<SNR>' . s:SID() . '_s:Buffer_destroy')
  return bufferObj
endfunction

function! <SID>s:Buffer_scan() dict
  for detector in self.get_detectors()
    let result = detector.detect(self.get_parent_path())
    if result.status ==# 1
      let self.type = detector.get_type()
      let self.project_path = self.to_full_path(result.path)
      return 1
    endif
  endfor
  return 0
endfunction

function! <SID>s:Buffer_get_detectors() dict
  let detectors = []
  call add(detectors, s:CoreDetectorConstructor())
  call add(detectors, s:WpCliDetectorConstructor())
  call add(detectors, s:PluginDetectorConstructor())
  call add(detectors, s:ThemeDetectorConstructor())
  return detectors
endfunction

function! <SID>s:Buffer_get_type() dict
  if !(self.did_scan)
    call self.scan()
  endif
  return self.type
endfunction

function! <SID>s:Buffer_get_project_path() dict
  if !(self.did_scan)
    call self.scan()
  endif
  return self.project_path
endfunction

function! <SID>s:Buffer_get_path() dict
  return self.path
endfunction

function! <SID>s:Buffer_get_full_path() dict
  if !(has_key(self, 'full_path'))
    let self.full_path = self.to_full_path(self.path)
  endif
  return self.full_path
endfunction

function! <SID>s:Buffer_get_parent_path() dict
  if !(has_key(self, 'parent_path'))
    let self.parent_path = self.to_full_path(fnamemodify(self.path, ':h'))
  endif
  return self.parent_path
endfunction

function! <SID>s:Buffer_to_full_path(path) dict
  let full_path = fnamemodify(a:path, ':p')
  if full_path =~# '/$'
    let full_path = strpart(full_path, 0, len(full_path) - 1)
  endif
  return full_path
endfunction

function! <SID>s:Buffer_destroy() dict
  unlet self.path
endfunction

" included: 'wordpress_plugin.riml'
" included: 'msg.riml'
function! s:echo_warn(...)
  call s:echo_with(a:000, 'WarningMsg')
endfunction

function! s:echo_error(...)
  call s:echo_with(a:000, 'ErrorMsg')
endfunction

function! s:echo_msg(...)
  if exists('g:speckle_mode')
    let logger = s:get_logger()
    let res = call(logger['info'], a:000, logger)
  else
    call s:echo_with(a:000, 'None')
  endif
endfunction

function! s:echo_with(args, style)
  if exists('g:speckle_mode')
    return
  endif
  let msg = join(a:args, ' ')
  execute ":echohl " . a:style
  echomsg msg
  echohl None
endfunction

" included: 'version.riml'
let g:wordpress_vim_version = '0.1.15'
function! s:WordPressPluginConstructor()
  let wordPressPluginObj = {}
  let wordPressPluginObj.start = function('<SNR>' . s:SID() . '_s:WordPressPlugin_start')
  let wordPressPluginObj.loaded = function('<SNR>' . s:SID() . '_s:WordPressPlugin_loaded')
  let wordPressPluginObj.get_app = function('<SNR>' . s:SID() . '_s:WordPressPlugin_get_app')
  let wordPressPluginObj.on_buffer_open = function('<SNR>' . s:SID() . '_s:WordPressPlugin_on_buffer_open')
  let wordPressPluginObj.on_buffer_enter = function('<SNR>' . s:SID() . '_s:WordPressPlugin_on_buffer_enter')
  let wordPressPluginObj.on_buffer_leave = function('<SNR>' . s:SID() . '_s:WordPressPlugin_on_buffer_leave')
  let wordPressPluginObj.on_vim_enter = function('<SNR>' . s:SID() . '_s:WordPressPlugin_on_vim_enter')
  let wordPressPluginObj.can_autostart = function('<SNR>' . s:SID() . '_s:WordPressPlugin_can_autostart')
  let wordPressPluginObj.has_args = function('<SNR>' . s:SID() . '_s:WordPressPlugin_has_args')
  let wordPressPluginObj.has_autostart_option = function('<SNR>' . s:SID() . '_s:WordPressPlugin_has_autostart_option')
  let wordPressPluginObj.has_wordpress = function('<SNR>' . s:SID() . '_s:WordPressPlugin_has_wordpress')
  return wordPressPluginObj
endfunction

function! <SID>s:WordPressPlugin_start() dict
  let loader = s:AutocmdLoaderConstructor()
  call loader.set_group_name('wordpress_vim_plugin_group')
  call loader.cmd("BufNewFile,BufRead * call s:plugin.on_buffer_open(expand('<afile>'))")
  call loader.cmd("BufEnter * call s:plugin.on_buffer_enter(expand('<afile>'))")
  call loader.cmd("BufLeave * call s:plugin.on_buffer_leave(expand('<afile>'))")
  call loader.cmd("VimEnter * call s:plugin.on_vim_enter()")
  call loader.load()
endfunction

function! <SID>s:WordPressPlugin_loaded() dict
  return has_key(self, 'app')
endfunction

function! <SID>s:WordPressPlugin_get_app() dict
  if !(self.loaded())
    redraw
    echomsg "WordPress: Loading ..."
    let self.app = wordpress#app()
  endif
  return self.app
endfunction

function! <SID>s:WordPressPlugin_on_buffer_open(path) dict
  let buffer = s:BufferConstructor(a:path)
  if !(buffer.get_type() ==# 'unknown')
    let b:wordpress_buffer = buffer
    call self.get_app().on_buffer_open(buffer)
  endif
endfunction

function! <SID>s:WordPressPlugin_on_buffer_enter(path) dict
  if exists('b:wordpress_buffer')
    call self.get_app().on_buffer_enter(b:wordpress_buffer)
  endif
endfunction

function! <SID>s:WordPressPlugin_on_buffer_leave(path) dict
  if exists('b:wordpress_buffer')
    call self.get_app().on_buffer_leave(b:wordpress_buffer)
  endif
endfunction

function! <SID>s:WordPressPlugin_on_vim_enter() dict
  if self.can_autostart()
    let app = self.get_app()
    call app.on_buffer_open(self.last_buffer)
    call app.on_buffer_enter(self.last_buffer)
  endif
endfunction

function! <SID>s:WordPressPlugin_can_autostart() dict
  if (has_key(self, 'force_autostart'))
    return self.has_wordpress()
  endif
  if (self.loaded())
    return 0
  endif
  if !(self.has_args())
    return 0
  endif
  if !self.has_autostart_option()
    return 0
  endif
  return self.has_wordpress()
endfunction

function! <SID>s:WordPressPlugin_has_args() dict
  return argc() ==# 0
endfunction

function! <SID>s:WordPressPlugin_has_autostart_option() dict
  if exists('g:wordpress_vim_autostart')
    return g:wordpress_vim_autostart
  else
    return 1
  endif
endfunction

function! <SID>s:WordPressPlugin_has_wordpress() dict
  let self.last_buffer = s:BufferConstructor('psuedo_buffer')
  return self.last_buffer.get_type() !=# 'unknown'
endfunction

function! s:main()
  let s:plugin = s:WordPressPluginConstructor()
  call s:plugin.start()
  let g:wordpress_vim_plugin_loaded = 1
endfunction

if !exists('g:speckle_mode')
  call s:main()
endif
