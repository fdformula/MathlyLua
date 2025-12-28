## [CudaText](https://cudatext.github.io/) is a very good "IDE" for Lua + Mathly

If you download CudaText (Windows) or related configuration files (Linux or MacOS) here, quite a few CudaText plugins are included. Some plugins are customized and even have new features added. While in CudaText, press
```
  F1               to open help on current Lua/Mathly function
  F2               to start Lua + Mathly in the folder of the current file

  Ctrl-,           to run the selected code or the current line in the editor (or Shift-Enter)
  Ctrl-.           to run all code in the editor (or Ctrl-Enter. HTML file? open it in a browser)

  Ctrl-Alt-Space   to trigger auto (Lua/Mathly) lexical completion
  Shift-Alt-Space  to trigger auto text completion (Ctrl-P D, load an English dictionary as part of the text)

  Ctrl-P L         to turn on/off Lua lexer switch (when editing Lua script, say, in a HTML file)
  Ctrl-P P         to insert a plot template
```
`F2`, `Ctrl-,`, and `Ctrl-.` work with Bash, Julia, Octave, Python, R, Ruby, and some other languages with interactive REPL terminals.
CudaText detects and selects the very language according to the extension of the present filename (defaults to Lua). See: The first few
lines of the file, `cudatext/py/cuda_ex_terminal/__init__.py`.

Other hotkeys? See `cudatext/cudatext-hotkeys-for-lua-mathly.txt`.

Only one interpreter is allowed at a time. To change an interpreter, you may enter the interpreter terminal, and press ctrl-c or execute commands like `os.exit()`, `exit`, `quit`, `exit()`, etc., to exit the present interpreter. Then, go to the very file in the editor and press F2 to start the associated interpreter.

&rArr; Microsoft Windows users may download on this very page the file, `cudatext-for-mathly-win-*.7z`. It includes the text editor, CudaText, with Lua 5.4.8 and
Mathly included and integrated. Run [7zip](https://7-zip.org/) to extract it to C:\ (the root directory of the C drive). <em>Do not change the name of the folder,
`C:\cygwin`</em>.

&rArr; Linux users may download the file, [cudatext-for-mathly-linux.tar.gz](https://github.com/fdformula/MathlyLua/blob/main/cudatext-for-mathly-linux.tar.gz).
Run `tar xfz cudatext-for-mathly-linux.tar.gz` and refer to the included file, `cudatext-for-mathly-linux/note.txt`, for further steps.

&rArr; MacOS users? Download the file, [cudatext-for-mathly-macosx.tar.gz](https://github.com/fdformula/MathlyLua/blob/main/cudatext-for-mathly-macos.tar.gz). Expand the downloaded file
and refer to the included file, `note.txt`, for other steps.

`Note`: [Lite XL](https://github.com/fdformula/MathlyLua/tree/main/IDE%20-%20Lite%20XL) is another very good "IDE" for Lua + Mathly.
