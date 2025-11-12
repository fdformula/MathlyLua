mathly = require('mathly')

clear()

-- explore a folder and all subfolders for files specified in 'specs'
-- e.g., explore('/usr/share/', '*.lua'), explore('/', {'*.lua', 'fd*.jl'})
-- process(fname, i, n) is a function that defines how to process the i-th
-- one of all n files
--
-- 1. no change is needed for function explore(...)
-- 2. edit function process(...) at the bottom of this file for your task
--
function explore(dir, specs, process, opt)
  if type(specs) == 'string' then
    specs = {specs}
  elseif specs == nil then
    specs = {'*'}
  end
  local fname, cmd = tmp_plot_html_file .. 'XpL'
  if iswindows() then -- dir /s /b /a-d /on *.lua mathly*
    cmd = 'dir /s /b /on '
    cmd = cmd .. qq(opt == 'directory' or opt == 'folder', '/ad', '/a-d')
    for i = 1, #specs do cmd = cmd .. ' ' .. specs[i] end
    cmd = cmd .. ' > ' .. fname

    local batfname = fname .. '.bat'
    local f = io.open(batfname, "w")
    cmd = 'cd /d "' .. dir:gsub('/', '\\') .. '" & ' .. cmd
    f:write(cmd)
    f:close()
    os.execute(batfname)
    rm(batfname)
  else -- find . -type f \( -name "*.lua" -o -name "mathly*" \)
    cmd = 'find "' .. dir .. '" -type '
    cmd = cmd .. qq(opt == 'directory' or opt == 'folder', 'd', 'f')
    cmd = cmd .. ' \\( -name'
    for i = 1, #specs do
      if i > 1 then cmd = cmd .. ' -o -name' end
      cmd = cmd .. ' ' .. specs[i]
    end
    cmd = cmd .. ' \\) > ' .. fname
  end

  local v, fnames = os.execute(cmd), {}
  if v == true then
    local f = io.open(fname, "r")
    for txt in f:lines() do fnames[#fnames + 1] = txt end
    f:close()
    rm(fname)
  else
    print("Failed to explore the folder.")
    return -1
  end

  local i = 1 -- remove repetitive entries from fnames, a SORTED list
  while i <= #fnames do
    local j = i + 1
    while j <= #fnames and fnames[j] == fnames[i] do table.remove(fnames, j) end
    i = i + 1
  end

  local n = #fnames
  for i = 1, n do
    if type(process) == 'function' then process(fnames[i], i, n) end
  end
  fnames = nil
  printf("\n%d items processed\n", n)
  return n
end -- explore

-- return the (path, filename, basename, extension) of a filename
-- path, fname, basename, ext = parse_filename("/user/local/share/lua/5.4/mathly.lua")
-- -- /user/local/share/lua/5.4, mathly.lua, mathly, lua
function parse_filename(fname)
  local path, ext, pos = '', '', string.find(fname, "[/\\][^/\\]*$", 1)
  if pos then
    path = string.sub(fname, 1, pos - 1)
    fname = string.sub(fname, pos)
  end
  local c = string.sub(fname, 1, 1)
  if c == "/" or c == "\\" then fname = string.sub(fname, 2) end

  local basename = fname
  pos = string.find(fname, "%.[^%.]*$", 1)
  if pos then
    basename = string.sub(fname, 1, pos - 1)
    ext = string.sub(fname, pos + 1)
  end
  return path, fname, basename, ext
end

--
-- define how to process the i-th one of all n files/folders
--
function process(fname, i, n)
  local k, fmt = n, 1
  while k // 10 > 0 do fmt = fmt + 1; k = k // 10 end
  fmt = string.format('No. %%%dd of %%d: %%s\n', fmt)
  printf(fmt, i, n, fname)

  -- your task
end

-- examples
if iswindows() then
  explore('C:\\cygwin', {'*.lua', 'mathly*'}, process)           -- list & process files only
  explore('C:\\cygwin', {'doc*', 'cuda*'}, process, 'folder')    -- list and process folders only
else
  explore('/usr/local/', {'mathly*', '*.txt'}, process)          -- list & process files only
  explore('/usr/share/cudatext', 'cuda_*', process, 'directory') -- list & process folders only
end
