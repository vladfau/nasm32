nasm32-bundle
===============

Utility written in Python to run nasm (32bit) in Docker. Initially, it was created for my SSU assembly courses, but can be applied under wider circumstances. 

By default students are to use bundles NASM+MinGW for Windows. It has numerous disadvantages:

* Windows VM required to run it on Mac or Linux
* Huge size: WinXP Virtualbox image is 8 GB against **170 MB** (more, if use `boot2docker`)
* Waste of time and energy: containers are more energy efficient
* Require a lot of work to configure: nasm32-bundle is zero-configuration tool (but agile!)

Why no dockerize? Go for it!

This bundle contains:

* Dockerfile for building nasm32
* Script to run your assembly code
* Makefile example (used by default)
* Assembly sources examples

Before start
=============

Pull image:

`docker pull vladfau/nasm32`

Clone repository:

`git clone https://github.com/ka2m/nasm32-bundle`


Usage
=====

`./run-nasm youfile.asm`

All assembly files must have `.asm` extension.

### Script optional parameters

| Parameter | Description |
|:---------|:-------------|
| -h, --help| shows help |
| -s, --sudo | if passed, Docker is being executed with sudo| 
| -v, --verbose |  produces debug output |
| -p ARGS, --pargs ARGS | all passed parameters are going to be passed to assembled program | 
| -S, --save | if passed, resulting executable will be copied to source directory |
| -l, --ld | if passed, insted of linking with help of gcc and using C libraries, ld will be used |
| -m PATH, --makefile PATH | path to custom Makefile |
| -M "cmd", --make "cmd" | custom make command, must be surronded with " and incompatbile with -l |
### Note on sudo

sudo is not usually required using boot2docker. On Linux please add your user to `docker` group. More info on [Docker website](https://docs.docker.com/installation/ubuntulinux/).

### Makefile and compiling

You can find Makefile in this repository, it's really simple. Makefile has conditional, basing on two main compiling commands I've used througout the course. Main one is: 

```sh        
    nasm -f elf -l $(src).lst $(src).asm
    gcc -m32 -o $(src) $(src).o
```
As you can see, here we link our assembly file with C libraries, it's usually used to invoke `printf` or `scanf` in assembly sources.

On the other hand, when you want to try system calls or something, which doesn't require `glibc`, you are to execute the commands:

```sh
    nasm -f elf $(src).asm
    ld -m elf_i386 -o $(src) $(src).o
```

Hence, if you execute `run-nasm` with `-l` option, the second variant is used, otherwise it falls to the first one with C libraries linking.

**As $(src) the last passed source is being taken, if passed more than one source**

Examples 
=========

In this repository you have three example files: `apb.asm`, `httpd.asm` and `helloworld.asm`.

`helloworld.asm` just prints "Hello world". Example:

`./run-nasm -s examples/helloworld.asm`

`apb.asm` is simple a + b program, which takes two arguments from stdin and prints to stdout their sum. Example:

`./run-nasm -s examples/apb.asm`

`server.asm` is a simple echo server on Linux sockets (compile without C libraries). Example:

`./run-nasm -s -l examples/server.asm`


How do things work
===================

`run-nasm` script is pretty obvious and if you read line by line you most probably understand all the performed actions. However, let's go through both it and Dockerfile

### Dockerfile

Built from Debian image. It installs `nasm`, `make` and required `glibc` libraries. That's all!

### Script

Script parses paremeters, I'll tell you about it in the section below. Then, it copies source files according to temporary directory. Next, Makefile is being copied. Finally, Docker is being called, where all the assembly is taking place. After all things are done, temporary directory is being cleaned up. 



Requirements
============

* `docker` >= 1.7 is recommended
* Linux (x64, kernel >= 3.10) or [boot2docker](https://github.com/boot2docker/boot2docker) for OS X/Windows

LICENSE
=======

MIT

Credits
=======

Vlad Slepukhin, 2015
