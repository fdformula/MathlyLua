-- no firefox? you are strongly encouraged to install it. (www.mozilla.org)
-- ms edge doesn't work well
win_browser = 'C:/Program Files/Mozilla Firefox/firefox.exe'
linux_browser = 'firefox'
mac_browser = 'firefox'

-- plotly_engine = 'plotly-2.35.2.min.js'
plotly_engine = 'file:///C:/cygwin/bin/plotly-2.9.0.min.js'
--plotly_engine = 'file:////usr/local/share/lua/5.4/plotly-2.9.0.min.js'





-- ↓ ↓ ↓ ↓ Do nothing below unless you know what you do!!! ↓ ↓ ↓ ↓ --
--
-- temporary plotting output, a HTML file of JavaScript code and data
-- using plotly graphing library (https://plotly.com/javascript/)
--
-- the file will stay until you delete it manually or so.
local home = os.getenv('HOME') or os.getenv('HOMEPATH')
if home == nil then
  print('Please define your HOME directory and come back.\n')
  os.exit()
else
  home = string.gsub(home, '\\', '/')
  tmp_plot_html_file = home .. '/_tmp-mathly_plot-6_4.html'
end
