ShellWriter v2

A simple and fast reverse shell generator that automates the process of selecting and modifying reverse shell payloads. Instead of manually copying from PentesterMonkey and editing IP and port details, ShellWriter does it for you in seconds.

This version includes command-line flags, an automatic tun0 IP finder, and a built-in netcat listener.

Installation

Clone/Download:
Get the shellwriter_v2.sh file onto your system.

Make it Executable:

chmod +x shellwriter_v2.sh


Move to your PATH (Recommended):
This lets you run the tool from anywhere. We'll rename it to just shellwriter for convenience.

sudo mv shellwriter_v2.sh /usr/local/bin/shellwriter


All Done!
You can now use the tool from anywhere by typing shellwriter.

Usage

ShellWriter v2 can be run with flags or interactively.

shellwriter [OPTIONS]


Options

-i <IP>: Specify the LHOST (Listening IP).

-p <PORT>: Specify the LPORT (Listening Port).

-t: Automatically use the IP address from your tun0 interface (for CTFs/VPNs).

-l: Automatically start a netcat listener on the specified IP and port after generating the payload.

-h: Show the help message.

Examples

1. Standard Use (Manual IP & Port)
This will validate the IP/Port and then show the payload menu.

shellwriter -i 10.10.14.5 -p 4444


2. CTF Mode (Auto tun0 IP & Start Listener)
This is the fastest way. It automatically finds your tun0 IP, asks for a port, generates the payload, and then starts the listener.

shellwriter -t -p 9001 -l


3. Interactive Mode
Just run the command with no arguments. It will prompt you to enter the LHOST and LPORT.

shellwriter


Available Payloads

Bash

Python 2

Python 3

Netcat (Traditional)

Perl

PHP (Exec)

Ruby

Java

PowerShell

Simple PHP File Uploader

Disclaimer: This tool is intended for educational purposes and authorized security testing (like CTFs) only. Using it on systems without explicit permission is illegal and unethical.
