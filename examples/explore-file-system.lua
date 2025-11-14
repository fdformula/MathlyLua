mathly = require('mathly')

clear()

-- explore a folder and its subfolders for files/folders specified in opts.patterns
--
-- 1. no change is needed for function explore(...)
-- 2. edit function process(...) at the bottom of this file for your task
--
-- opts.objects    = 'files'         process matched files only (default)
-- opts.objects    = 'folders'       process matched (sub)folders only
-- opts.objects    = 'files+folders' process matched files and (sub)folders
--
-- opts.subfolders = 'included'      find items in subfolders (default)
-- opts.subfolders = 'excluded'      find items in 'dir' only
--
-- opts.task = function(fname, i, n) define how to process 'fname', the i-th
--                                   one of all n matched files/folders
--
function explore(dir, opts)
  if opts == nil then opts = {} end
  if opts.objects == nil then opts.objects = 'files' end
  if opts.subfolders == nil then opts.subfolders = 'included' end

  if type(opts.patterns) == 'string' then
    opts.patterns = {opts.patterns}
  elseif opts.patterns == nil then
    opts.patterns = {'*'}
  end
  local fname, cmd = tmp_plot_html_file .. 'XpL'
  if iswindows() then -- dir /s /b /a-d /on *.lua mathly*
    cmd = 'dir /b /on '
    if opts.subfolders == 'included' then cmd = cmd .. '/s ' end
    cmd = cmd .. qq(opts.objects == 'folders', '/ad', qq(opts.objects == 'files', '/a-d', ''))
    for i = 1, #opts.patterns do cmd = cmd .. ' "' .. opts.patterns[i] .. '"' end
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
    if opts.subfolders == 'excluded' then cmd = cmd .. '-maxdepth 1 ' end
    cmd = cmd .. qq(opts.objects == 'files+folders', '', '-type ' .. qq(opts.objects == 'folders', 'd', 'f'))
    cmd = cmd .. ' \\( -name'
    for i = 1, #opts.patterns do
      if i > 1 then cmd = cmd .. ' -o -name' end
      cmd = cmd .. ' "' .. opts.patterns[i] .. '"'
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
  if type(opts.task) == 'function' then
    print()
    for i = 1, n do
      opts.task(fnames[i], i, n)
    end
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
-- need temporary files? you may use tmp_plot_html_file, a filename
-- provided by Mathly with full path, or use it to create filenames like:
--
--   tmpfname1 = tmp_plot_html_file .. 'fPrcss.1'
--
function process(fname, i, n)
  local k, fmt = n, 1
  while k // 10 > 0 do fmt = fmt + 1; k = k // 10 end
  fmt = string.format('%%%dd/%%d: %%s\n', fmt)
  printf(fmt, i, n, fname)

  -- process fname below ...

end

-- examples
if iswindows() then
  explore('C:\\cygwin',
          { patterns = {'doc*', 'cuda*'},
            task = process,
            objects = 'files',
            subfolders = 'included'})
  explore('C:\\cygwin',
          { patterns = {'doc*', 'cuda*'},
            task = process,
            objects = 'folders',
            subfolders = 'included'})
  explore('C:\\cygwin',
          { patterns = {'doc*', 'cuda*'},
            task = process,
            objects = 'files+folders',
            subfolders = 'included'})
else
  explore('/usr/share/cudatext',
          { patterns = {'mathly*', 'c*', '*.txt'},
            task = process,
            objects = 'files',
            subfolders = 'excluded'})
  explore('/usr/share/cudatext',
          { patterns = 'cuda*',
            task = process,
            objects = 'files+folders',
            subfolders = 'included'})
end
