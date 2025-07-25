-- no firefox? you are strongly encouraged to install it. (www.mozilla.org)
-- ms edge doesn't work well
win_browser = 'C:/Program Files/Mozilla Firefox/firefox.exe'
linux_browser = 'firefox'
mac_browser = '/Applications/Firefox.app/Contents/MacOS/firefox'

plotly_engine = 'plotly-2.9.0.min.js'
do
  local dir
  if package.config:sub(1,1) == '\\' then -- windows
    dir = 'C:/cygwin/bin/' -- must end with '/'  ← ← ← ← ← windows users
  else
    dir = '/usr/local/share/lua/5.4/' -- ← ← ← users of other os systems
  end
  plotly_engine = 'file:///' .. dir .. plotly_engine
end


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
  if package.config:sub(1,1) == '\\' then -- windows
    local dir = ':/cygwin/home' -- in case https://cygwin.com/ is installed
    if string.find(home, dir, 2, true) ~= nil then
      home = 'c' .. dir
    elseif string.match(home, '^/Users/') then  -- /Users/account
      home = 'c:' .. home
    end
  end
  tmp_plot_html_file = home .. '/_tmp-mathly_plot-6_4.html'
end
