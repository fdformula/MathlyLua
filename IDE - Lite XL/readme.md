## [Lite XL](https://github.com/lite-xl/lite-xl) is a very good "IDE" for Lua + Mathly

It is even smaller and faster than [CudaText](https://github.com/fdformula/MathlyLua/tree/main/IDE%20-%20CudaText). You can download here the customized
versions for Windows, Linux, and MacOS. While in Lite XL, press
```
  F1               to open help on current Lua/Mathly function
  F2               to start Lua + Mathly or an associated interpreter in the folder of the current file

  Ctrl-,           to run the selected code or the current line in the editor (or Shift-Enter)
  Ctrl-.           to run all code in the editor (or Ctrl-Enter. HTML file? open it in a browser)

  Ctrl-t           to insert template for plot
```
`F2`, `Ctrl-,`, and `Ctrl-.` work with Bash, Julia, Octave, Python, R, Ruby, and some other languages with interactive REPL terminals.
Lite XL detects and selects the very language according to the extension of the present filename (defaults to Lua). See: The first few
lines of the file, `lite-xl/data/plugins/language_lua_mathly.lua`.

Other hotkeys? See `lite-xl/lite_xl-hotkeys-for-lua-mathly.txt`.

Only one interpreter is allowed at a time. To change an interpreter, you may enter the interpreter terminal, and press ctrl-c or execute
commands like `os.exit()`, `exit`, `quit`, `exit()`, etc., to exit the present interpreter. Then, go to the very file in the editor and
press F2 to start the associated interpreter.

&rArr; Microsoft Windows users may download on this very page the file, `lite-xl-*-for-mathly-windows.7z`. It includes the text editor, Lite XL, with Lua 5.4.8 and
Mathly included and integrated. Run [7zip](https://7-zip.org/) to extract it to C:\ (the root directory of the C drive). <em>Do not change the name of the folder,
`C:\cygwin`</em>.

&rArr; Linux users may download the file, `lite-xl-2.1.8-for-mathly-linux.tar.gz`. Run `tar xfz lite-xl-2.1.8-for-mathly-linux.tar.gz` and refer to the included file,
`lite-xl-2.1.8-for-mathly-linux/note.txt`, for further steps.

&rArr; MacOS users may download the file, `lite-xl-for-mathly-macos_intel.tar.gz`, if your Mac is Intel-based. Run
```bash
tar xfz lite-xl-for-mathly-macos_intel.tar.gz
```
and refer to the included file, `lite-xl-for-mathly-macos_intel/note.txt`, for further steps. If your Mac is newer and uses M-series chips, you still need the file.
You will first download [Lite XL](https://github.com/lite-xl/lite-xl) and install it. You will also need to install Lite XL Plugin Manager (`lpm`) and `lite-xl-terminal`
as follows:

```bash
wget --no-check-certificate https://github.com/lite-xl/lite-xl-plugin-manager/releases/download/latest/lpm.`uname -m | sed 's/arm64/aarch64/'`-`uname | tr '[:upper:]' '[:lower:]'` -O lpm && chmod +x lpm
./lpm install terminal
```
Then, run
```bash
rm -fr lite-xl-for-mathly-macos_intel/Applications/Lite\ XL.app/Contents/MacOS/
cp -R lite-xl-for-mathly-macos_intel/usr/* /usr/
cp -R lite-xl-for-mathly-macos_intel/Applications/* /Applications/
rm /Applications/Lite\ XL.app/Contents/Resources/terminal/*
cp -R ~/.config/lite-xl/plugins/terminal/* /Applications/Lite\ XL.app/Contents/Resources/terminal/
cp lite-xl-for-mathly-macos_intel/Applications/Lite\ XL.app/Contents/Resources/terminal/init.lua /Applications/Lite\ XL.app/Contents/Resources/terminal/
rm -fr ~/.config/lite-xl/
```
`Note`: [CudaText](https://github.com/fdformula/MathlyLua/tree/main/IDE%20-%20CudaText) is another very good "IDE" for Lua + Mathly.
