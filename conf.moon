conf =
  debug: true
  moudle:
    reload: false
    keyboard: false
    key: false
    layout: false
    mouse: false
    hotkey: true
    expose: false
  externalDevice:
    productID: {}
    productName: { 'GH60' }
  hyper1: {'alt', 'shift', 'cmd'}
  hyper2: {'ctrl', 'alt', 'shift', 'cmd'} -- LCAG
  notification:
    x: 80
    y: 80
  oneTapTimeout: 0.15
  appActiveTimeout: 0.1
  appHideTimeout: 0.2
  sysEventTimeout: 0.15
  totalVimBindingApp: {
    'com.github.atom',
    'com.googlecode.iterm2',
    'com.apple.com.Terminal',
    'org.gnu.Emacs',
  }
  partialVimBindingApp: {
    'com.apple.dt.Xcode',
    -- Jetbrains
    'com.google.android.studio',
    'com.jetbrains.intellij',
    'com.jetbrains.pycharm',
    'com.jetbrains.CLion',
    'com.jetbrains.AppCode'
    'org.rstudio.RStudio',
    }
  notEmacsBindingApp: {
    'org.telegram.desktop',
    'com.microsoft.Word'
  }
conf
