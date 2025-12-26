## CudaText is a very good "IDE" customized for Lua + Mathly

&rArr; Microsoft Windows users may download on this very page the file, `cudatext-for-mathly-win-*.7z`. It includes a text editor, CudaText, with Lua 5.4.8 and
Mathly integrated. Run [7zip](https://7-zip.org/) to extract it to C:\ (the root directory of the C drive). <em>Do not change the name of the folder,
`C:\cygwin`</em>.

[CudaText](https://cudatext.github.io/) is a very good "IDE" for Lua + Mathly.
Quite a few CudaText plugins are included. Some are customized and even have new features added. While in CudaText, press
```
  F1               to open help document on current Lua/Mathly function
  F2               to start Lua interpreter with Mathly loaded in the folder of the current file
  Ctrl-,           to run the command on current line or selected code in the editor
  Ctrl-.           to run all code in the editor (HTML file? open it in a browser)

  Ctrl-Alt-Space   to trigger auto (Lua/Mathly) lexical completion
  Shift-Alt-Space  to trigger auto text completion (Ctrl-P D, load an English dictionary as part of the text)

  Ctrl-P L         to turn on/off Lua lexer switch (when editing Lua script, say, in a HTML file)
  Ctrl-P P         to insert a plot template
```
`F2`, `Ctrl-,`, and `Ctrl-.` work with Bash, Julia, Octave, Python, R, Ruby, and some other languages with interactive REPL terminals.
CudaText detects and selects the very language according to the extension of the present filename (defaults to Lua). See: The first few
lines of the file, `C:\cygwin\cudatext\py\cuda_ex_terminal\__init__.py`.

Other hotkeys? Refer to `C:\cygwin\cudatext\cudatext-hotkeys-for-plugins.txt`.

&rArr; Linux users? For most Linux distributions, download the file, [cudatext-for-mathly-linux.tar.gz](https://github.com/fdformula/MathlyLua/blob/main/cudatext-for-mathly-linux.tar.gz).
For other distributions like Fedora, download the file, [cudatext-for-mathly-linux-RARE.tar.gz](https://github.com/fdformula/MathlyLua/blob/main/cudatext-for-mathly-linux-RARE.tar.gz).
Expand the downloaded file and refer to the included file, `note.txt`, for other steps.

&rArr; MacOS users? Download the file, [cudatext-for-mathly-macosx.tar.gz](https://github.com/fdformula/MathlyLua/blob/main/cudatext-for-mathly-macos.tar.gz). Expand the downloaded file
and refer to the included file, `note.txt`, for other steps.

[Lite XL](https://github.com/lite-xl/lite-xl) is another very good "IDE" for Lua and Mathly. It is much smaller and faster. You can download here the customized versions for Windows, Linux, and
MacOS. While in Lite XL, press
```
  F1               to open help document on current Lua/Mathly function
  F2               to start Lua interpreter with Mathly loaded in the folder of the current file
  Ctrl-,           to run the command on current line or selected code in the editor
  Ctrl-.           to run all code in the editor (HTML file? open it in a browser)
```
