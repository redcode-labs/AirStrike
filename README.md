<h1 align="center"> Airstrike </h1>
<p align="center">
  <a>
    <img alt="Sammler" title="Sammler" src="logo.png" width="450">
  </a>
</p>


<p align="center">
  Tool that automates cracking of WPA-2 Wi-Fi credentials using client-server architecture
</p>


# Requirements
Airstrike uses Hashcat Brain Architecture, `aircrack-ng`  suite, `entr` utility and some helper scripts.

You can use `install.sh` script to download all dependencies.

# Usage
Run `aircrack_server.sh` on the machine on which you want to crack passwords.
This script builds `aircrack_client.sh` file, which can be executed on any Linux host that is able to connect with the server started earlier. Upon execution, the client automatically captures handshakes, connects with the server and sends captured data. 

Whenever a password is sucessfully cracked by the server, the `watcher.sh` script prints it out to terminal on the server side.

The only required option flag for `airstrike_client.sh` is the `-w` flag: it specifies the wordlist that should be used by the server. Listening interface can be specified with `-i` flag. By default, a current wireless interface is automatically selected.
Additionally, `airstrike_client.sh` listens for WPA-2 data without any filter, so it will capture and crack all of the passwords of all Wi-Fi networks in range (whenever handshakes are exchanged).


# Navigation
`Ctrl + S` will send capturd assets (Wi-Fi hansdhakes in `.hccapx` form) to the server.
`Ctrl + I` disaplays information about capture progress.

Above shortcuts can be used inside a running instance of `airstrike_client.sh`

> made with :heart: by Red Code Labs <*>
