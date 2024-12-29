--[[
  URL: https://github.com/kenloen/plotly.lua
  David Wang made all variables used in functions 'local' in addition to some minor changes.
  12/12/2024 Thursday
--]]
require 'browser-setting'; -- dwang

local json = require("dkjson")

local plotly = {}

-- https://cdn.plot.ly/plotly-latest.min.js
plotly.cdn_main = "<script src='" .. plotly_engine .. "' charset='utf-8'></script>" -- dwang
plotly.header = ""
plotly.body = ""
plotly.id_count = 1
plotly.sleep_time = 5 -- dwang, for slow devices like Surface Pro 7, originally, 1
plotly.gridq = false -- dwang, organize traces/figures according to specified grids, e.g., 2x2
plotly.layout = {} -- dwang

local writehtml_failedq = false -- dwang

---Converts a set of figures to an HTML string
---@param figues table
---@return string
function plotly.tohtml(figues)
  -- Create header tags
  local header = "<head>\n"..plotly.cdn_main.."\n"..plotly.header.."\n".."\n</head>\n"

  -- Create body tags
  local plots = ""
  for i, fig in pairs(figues) do
    plots = plots..fig:toplotstring()
  end

  return header.."<body>\n"..plots.."</body>"
end

---Saves a set of figures to filename
---@param filename string
---@param figures table
function plotly.tofile(filename, figures)
  writehtml_failedq = false
  local html_str = plotly.tohtml(figures)
  local file = io.open(filename, "w")
  if file ~= nil then -- dwang
    file:write(html_str)
    file:close()
  else
    writehtml_failedq = true
    print(string.format("Failed to create %s. The current folder might not be writable.", filename))
  end
end

---Shows a set of figures in the browser
---@param figures table
function plotly.show(figures)
  local filename = temp_plot_html_file -- dwang
  plotly.tofile(filename, figures)
  if not writehtml_failedq then
    open_url(filename)
    --[[ dwang, keep the file
    if filename == temp_plot_html_file then
      sleep(plotly.sleep_time)
      os.remove(filename)
    end
    --]]
  end
end

function sleep (a)
  local sec = tonumber(os.clock() + a)
  while (os.clock() < sec) do
  end
end

-- From: https://stackoverflow.com/questions/11163748/open-web-browser-using-lua-in-a-vlc-extension#18864453
-- Attempts to open a given URL in the system default browser, regardless of Operating System.
local open_cmd -- this needs to stay outside the function, or it'll re-sniff every time...
function open_url(url)
  if not open_cmd then
    if package.config:sub(1,1) == '\\' then -- windows
      open_cmd = function(url)
        -- Should work on anything since (and including) win'95
        --- os.execute(string.format('start "%s"', url)) -- dwang
        os.execute(string.format('"%s" %s', win_browser, url)) -- dwang
      end
    -- the only systems left should understand uname...
    elseif (io.popen("uname -s"):read'*a') == "Darwin" then -- OSX/Darwin ? (I can not test.)
      open_cmd = function(url)
        -- I cannot test, but this should work on modern Macs.
        -- os.execute(string.format('open "%s"', url)) -- dwang
        os.execute(string.format('%s "%s"', mac_browser, url)) --dwang
      end
    else -- that ought to only leave Linux
      open_cmd = function(url)
        -- should work on X-based distros.
        -- os.execute(string.format('xdg-open "%s"', url)) --dwang
        os.execute(string.format('%s "%s"', linux_browser, url)) --dwang
      end
    end
  end

  open_cmd(url)
end

-- Figure metatable
local figure = {}

---Adding a trace for the figure. All options can be found here: https://plotly.com/javascript/reference/index/
---Easy to call like: figure:add_trace{x=x, y=y, ...}
---@param self table
---@param trace table
function figure.add_trace(self, trace)
  self["data"][#self["data"]+1] = trace
end

local dash_style = {["-"] = "solid", [":"] = "dot", ["--"] = "dash"}
local mode_shorthand = {["m"] = "markers", ["l"]="lines", ["m+l"]="lines+markers", ["l+m"]="lines+markers"}


--[[Adding a trace for the figure with shorthand for common options (similar to matlab or matplotlib).
All js options can be found here: https://plotly.com/javascript/reference/index/
Easy to call like: figure:plot{x, y, ...}
Shorthand options:
| key | explanation |
| :----: | :---------: |
| *1* | x-values  |
| *2* | y-values   |
| *ls* | line-style (options: "-", ".", "--")  |
| *lw* | line-width (numeric value - default 2) |
| *ms* | marker-size (numeric value - default 2) |
| *c* or *color* | sets color of line and marker |
| *mode* | shorter mode forms (options: "m"="markers", "l"="lines", "m+l" or "l+m"="markers+lines") |
| *title* | sets/updates the title of the figure |
| *xlabel* | sets/updates the xlabel of the figure |
| *ylabel* | sets/updates the ylabel of the figure |
]]
---@param self plotly.figure
---@param trace table
---@return plotly.figure
function figure.plot(self, trace)
  if not trace["line"] then
    trace["line"] = {}
  end
  if not trace["marker"] then
    trace["marker"] = {}
  end
  for name, val in pairs(trace) do
    if name == 'layout' then -- dwang
      if plotly.gridq then
        print("Only the first option that defines 'layout' matters.")
      else
        if val['grid'] ~= nil then
          if val['grid']['rows'] ~= nil and val['grid']['columns'] ~= nil then
            plotly.gridq = true
            plotly.layout = val
            plotly.layout['grid']['pattern'] = 'independent'
          else
            print('Invalid grid: both rows and columns must be specified.')
          end
        end
      end
      trace[name] = nil
    elseif name == "ls" or name == 'style' then -- dwang, name == 'style'
      trace["line"]["dash"] = dash_style[val]
      trace[name] = nil
    elseif name == "lw" or name == 'width' then -- dwang, name == 'width'
      trace["line"]["width"] = val
      trace[name] = nil
    elseif name == "title" then
      if plotly.gridq == false or plotly.layout["title"] == nil then
        plotly.layout["title"] = val
      end
      trace[name] = nil
    elseif name == 1 then
      trace["x"] = val
      trace[name] = nil
    elseif name == 2 then
      trace["y"] = val
      trace[name] = nil
    elseif name == "ms" or name == 'size' then -- dwang, name == 'size'
      trace["marker"]["size"] = val
      trace[name] = nil
    elseif name == 'symbol' then -- dwang
      trace["marker"]["symbol"] = val
      trace[name] = nil
    elseif name == "c" or name == "color" then
      trace["marker"]["color"] = val
      trace["line"]["color"] = val
      trace[name] = nil
    elseif name == "mode" and mode_shorthand[val] then
      trace["mode"] = mode_shorthand[val]
    elseif name == "xlabel" then
      if plotly.gridq == false or plotly.layout["xaxis"] == nil then
        plotly.layout["xaxis"] = {title={text=val}}
      end
      trace[name] = nil
    elseif name == "ylabel" then
      if plotly.gridq == false or plotly.layout["yaxis"] == nil then
        plotly.layout["yaxis"] = {title={text=val}}
      end
      trace[name] = nil
    end
  end

  self:add_trace(trace)
  self:update_layout(plotly.layout)
  return self
end

---Updates the plotly figure layout (options can be seen here: https://plotly.com/javascript/reference/layout/)
---@param self table
---@param layout table
function figure.update_layout(self, layout)
  for name, val in pairs(layout) do
    self["layout"][name] = val
  end
end

---Updates the plotly figure config (options can be seen here: https://plotly.com/javascript/configuration-options/)
---@param self table
---@param config table
function figure.update_config(self, config)
  for name, val in pairs(config) do
    self["config"][name] = val
  end
end

function figure.toplotstring(self)
  if plotly.gridq then -- dwang
    if type(self['layout']['grid']['rows']) == 'string' then
      self['layout']['grid']['rows'] = tonumber(self['layout']['grid']['rows'])
    end
    if type(self['layout']['grid']['cloumns']) == 'string' then
      self['layout']['grid']['cloumns'] = tonumber(self['layout']['grid']['cloumns'])
    end

    if self['layout']['grid']['rows'] * self['layout']['grid']['columns'] < #self['data'] then
      return '<html><body>Invalid grid: rows * columns &lt; the number of traces.</body></html>'
    end

    self['layout']['xaxis'] = nil
    self['layout']['yaxis'] = nil

    -- plotly-2.9.0.min.js, hopefully all versions, determines if grid options are used
    -- by checking whether the texts of xaxis and yaxis are different for traces
    for i = 1,#self['data'] do
      local s = tostring(i)
      self['data'][i]['xaxis'] = 'x' .. s -- they are different :-)
      self['data'][i]['yaxis'] = 'y' .. s
    end
  end

  -- Converting input
  local data_str = json.encode (self["data"])
  local layout_str = json.encode (self["layout"])
  local config_str = json.encode (self["config"])
  local div_id -- dwang
  if not self.div_id then div_id = "plot"..plotly.id_count end
  plotly.id_count = plotly.id_count+1
  -- Creating string
  local plot = [[<div id='%s'>
<script type="text/javascript" charset='utf-8'>
  var data = %s
  var layout = %s
  ]]
  if plotly.gridq == false then
    plot = plot .. [[
  var config = %s
  Plotly.newPlot(%s, data, layout, config);
  ]]
    plot = string.format(plot, div_id, data_str, layout_str, config_str, div_id)
  else
    plot = plot .. [[
  Plotly.newPlot(%s, data, layout);
    ]]
    plot = string.format(plot, div_id, data_str, layout_str, div_id)
  end
  plot = plot .. [[</script>
</div>
  ]]
  return plot
end

function figure.tohtmlstring(self)
  -- Create header tags
  local header = "<head>\n"..plotly.cdn_main.."\n"..plotly.header.."\n</head>\n"

  -- Create body tags
  local plot = self:toplotstring()

  return header.."<body>\n"..plot.."</body>"
end

---Saves the figure to an HTML file with *filename*
---@param self table
---@param filename string
function figure.tofile(self, filename)
  writehtml_failedq = false
  local html_str = self:tohtmlstring()
  local file = io.open(filename, "w")
  if file ~= nil then -- dwang
    file:write(html_str)
    file:close()
  else
    writehtml_failedq = true
    print(string.format("Failed to create %s. The very device might not be writable.", filename))
  end
  return self
end

---Opens/shows the plot in the browser
---@param self plotly.figure
function figure.show(self)
  local filename = temp_plot_html_file
  self:tofile(filename)
  if not writehtml_failedq then
    open_url(filename)
    --[[ dwang, keep the file
    if filename == temp_plot_html_file then
      sleep(plotly.sleep_time)
      os.remove(filename)
    end
    --]]
  end
end


-- Assigning functions
function plotly.figure()
  local fig = {data={}, layout={}, config={}}
  setmetatable(fig, {__index=figure})
  return fig
end

--[[Adding a trace for the figure with shorthand for common options (similar to matlab or matplotlib).
All js options can be found here: https://plotly.com/javascript/reference/index/
Easy to call like: plotly.plot{x, y, ...}
Shorthand options:
| key | explanation |
| :----: | :---------: |
| *1* | x-values  |
| *2* | y-values   |
| *ls* | line-style (options: "-", ".", "--")  |
| *lw* | line-width (numeric value - default 2) |
| *ms* | marker-size (numeric value - default 2) |
| *c* or *color* | sets color of line and marker |
| *mode* | shorter mode forms (options: "m"="markers", "l"="lines", "m+l" or "l+m"="markers+lines") |
| *title* | sets/updates the title of the figure |
| *xlabel* | sets/updates the xlabel of the figure |
| *ylabel* | sets/updates the ylabel of the figure |
]]
---@param trace table
---@return plotly.figure
function plotly.plot(trace)
  local fig = plotly.figure()
  fig:plot(trace)
  return fig
end

--[[ plots multiple functions/traces on a single figure -- dwang
--]]
function plotly.plots(traces)
  local fig = plotly.figure()
  for i = 1, #traces do
    fig:plot(traces[i])
  end
  return fig
end

return plotly
