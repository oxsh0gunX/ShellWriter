ShellWriter v2

A simple script to quickly generate reverse shell payloads for CTFs.

It saves you from manually editing IPs and ports. This version has new features like finding your tun0 IP and starting a listener for you.

**Installation**

_Make it executable:
_
 1) chmod +x shellwriter_v2.sh


_Move it to your PATH (This lets you run shellwriter from any terminal) :_

 2) sudo mv shellwriter_v2.sh /usr/local/bin/shellwriter

**ALL DONE :)
******

How to Use

Run the tool with flags.

Options

-i <IP>: Your listening IP

-p <PORT>: Your listening port

-t: (Easy Mode) Automatically use your tun0 IP

-l: (Easy Mode) Automatically start a netcat listener

-h: Show help

Examples

1. CTF Mode (Fastest Way)
Uses your tun0 IP and starts a listener on port 9001.

shellwriter -t -p 9001 -l


2. Manual Mode
Specify your IP and port.

shellwriter -i {ip} -p 4444


3. Interactive Mode
If you run shellwriter with no flags, it will ask you for the IP and port.

Disclaimer: This tool is for educational use and authorized testing (like CTFs) only.
enjoy
