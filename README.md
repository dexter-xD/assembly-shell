# Simple x86 Assembly Shell  

This project is a **simple shell written in x86 assembly**, created primarily as a learning exercise to explore x86 assembly language.  

⚠️ **Disclaimer**: This shell is not intended for production use. Its functionality is limited and primarily aimed at understanding the basics of writing low-level system programs.  

---

## Features  

- Execute programs using either:  
  - Full path (e.g., `/bin/ls`)  
  - Program name (if located in `/bin/`)  
- Pass arguments to programs (e.g., `ls -alsh`)  
- Built-in commands:  
  - `cd` for changing directories  
  - `exit` for terminating the shell  
- Forward `CTRL+C` interrupts to the current process.  
- Copies environment variables from the parent shell (currently, modification of environment variables is not supported).  

---

## Dependencies  

To build and run this shell, ensure the following are installed on your system:  

- **NASM** (Netwide Assembler): [nasm.us](https://nasm.us/)  
- **Linker** (e.g., [mold](https://github.com/rui314/mold), `ld`, etc.)  
- **Linux** (relies on Linux-specific syscalls)  
- A POSIX-compliant shell such as:  
  - [dash](http://gondor.apana.org.au/~herbert/dash/)  
  - [bash](https://www.gnu.org/software/bash/)  
- Coreutils implementation (e.g., [Toybox](http://www.landley.net/toybox), [BusyBox](https://busybox.net/), or [GNU Coreutils](https://www.gnu.org/software/coreutils/))  

---

## Building  

To build the project, simply run the included `build.sh` script:  

```bash
./build.sh
```  

Ensure all dependencies are installed before running the script.  

---

## Limitations  

- Only capable of executing programs located in `/bin/` or with full paths provided.  
- Cannot modify environment variables, though they are inherited from the parent shell.  
- Basic functionality; not feature-complete or suitable for production use.  

---

## Notes  

This project was built for educational purposes, and contributions are not expected. However, feel free to fork or adapt it to enhance your understanding of x86 assembly or Linux system programming.  

For any feedback or suggestions, please open an issue or pull request!  

--- 