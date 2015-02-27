ssu-open-nasm32
===============

SSU Open nasm (32 bit) - a docker bundle and utils for Assembly course in SSU.

By default students are to use bundles NASM+MinGW for Windows, which makes us use
VMs, which has huge size, waste a lot of time and energy. More, working with them is
hard in the meaning of data update.

Why no dockerize? Go for it!

This bundle contains:

* Dockerfile for building nasm32 (406 MB agains WinXP Virtualbox image of 8 GB)
* Script to run your assembly code
* Script to clean up after

Requirements
============

* `docker` >= 1.5.0
* OS X or any Linux
* `gsed` for OS X can be used

Code style
==========

You can write in default SSU NASM style (with underscores: `_printf`, `_main`, etc.)
Script automatically converts it (at least tries) to normal conventions.


Usage
=====

### Before start

First of all, you need to build `nasm32` container with Dockerfile included by running this command in the root of the repository:

`docker build -t nasm32 .`

### run_nasm

`run_nasm <your_assembly_file_without_extension>`

Run command is analogue to `bgcc` from SSU bundle. It creates temporary directory, converts code,
runs docker, detaches from it (not the best solution, though, never repeat again), runs `bash` in container and attaches to it.


### Inside container

`cd /tmp`

`./your-filename`

### cleanup-nasm

Removes temporary directories and Docker containers.


Credits
=======

Vlad Slepukhin, 2015
