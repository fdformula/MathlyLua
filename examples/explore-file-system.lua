mathly = require('mathly')

clear()

-- explore a folder and all subfolders for files specified in 'specs'
-- opts.process(fname, i, n) is a function that defines how to process the i-th
-- one of all n files
--
-- 1. no change is needed for function explore(...)
-- 2. edit function process(...) at the bottom of this file for your task
--
function explore(dir, specs, opts)
  if opts == nil then opts = {} end
  if opts.folder == nil then opts.folder = false end
  if opts.subfolder == nil then opts.subfolder = true end

  if type(specs) == 'string' then
    specs = {specs}
  elseif specs == nil then
    specs = {'*'}
  end
  local fname, cmd = tmp_plot_html_file .. 'XpL'
  if iswindows() then -- dir /s /b /a-d /on *.lua mathly*
    cmd = 'dir /b /on '
    if opts.subfolder then cmd = cmd .. '/s ' end
    cmd = cmd .. qq(opts.folder, '/ad', '/a-d')
    for i = 1, #specs do cmd = cmd .. ' "' .. specs[i] .. '"' end
    cmd = cmd .. ' > ' .. fname

    local batfname = fname .. '.bat'
    local f = io.open(batfname, "w")
    cmd = 'cd /d "' .. dir:gsub('/', '\\') .. '" & ' .. cmd
    f:write(cmd)
    f:close()
    os.execute(batfname)
    rm(batfname)
  else -- find . -type f \( -name "*.lua" -o -name "mathly*" \)
    cmd = 'find "' .. dir .. '" '
    if opts.subfolder == false then cmd = cmd .. '-maxdepth 1 ' end
    cmd = cmd .. '-type ' .. qq(opts.folder, 'd', 'f')
    cmd = cmd .. ' \\( -name'
    for i = 1, #specs do
      if i > 1 then cmd = cmd .. ' -o -name' end
      cmd = cmd .. ' "' .. specs[i] .. '"'
    end
    cmd = cmd .. ' \\) > ' .. fname
  end

  local fnames, v = {}, os.execute(cmd)
  if v then
    local f = io.open(fname, "r")
    for txt in f:lines() do fnames[#fnames + 1] = txt end
    f:close()
    rm(fname)
  --else
  --  print("No entry was found.")
  end

  local i = 1 -- remove repetitive entries from fnames, a SORTED list
  while i <= #fnames do
    local j = i + 1
    while j <= #fnames and fnames[j] == fnames[i] do table.remove(fnames, j) end
    i = j
  end

  local n = #fnames
  for i = 1, n do
    if type(opts.task) == 'function' then opts.task(fnames[i], i, n) end
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
-- define how to process fname, the i-th one of all n files/folders
--
function process(fname, i, n)
  local k, fmt = n, 1
  while k // 10 > 0 do fmt = fmt + 1; k = k // 10 end
  fmt = string.format('No. %%%dd of %%d: %%s\n', fmt)
  printf(fmt, i, n, fname)

  -- process fname here ...
end

-- examples
if iswindows() then
  explore('C:\\cygwin', {'*.lua', 'mathly*'},
          {task = process, folder = false, subfolder = true})  -- process files, including those in subfolders
  explore('C:\\cygwin', {'doc*', 'cuda*'},
          {task = process, folder = true, subfolder = true})   -- process folder and subfolders only
else
  explore('/usr/share/doc', {'mathly*', 's*', '*.html'},
          {task = process, folder = false, subfolder = false}) -- process files only, excluding those in subfolders
  explore('/usr/share/cudatext', 'cuda_*',
          {task = process, folder = true, subfolder = true})   -- process folder and subfolders only
end
