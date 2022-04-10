+++
title = "Trezor for more than crypto"
tags = ["trezor", "doom", "emacs", "gpg"]
draft = false
+++

I've been using a [Trezor](https://trezor.io/) for many years now. I've gone through both a first and second generation version. Though my original use case was for crypto currencies I never ended up getting on the crypto train.

What I do use my Trezor for every day is as a hardware key for encryption and
authentication. Coupling it with the brilliant [trezor-agent open source project](https://github.com/romanz/trezor-agent)
I can:

-   Easily SSH to servers using the same key from multiple computers
-   Sign my email using [gpgtools](https://gpgtools.org/)
-   Sign git commits
-   Use as two factor authentication

In short, its an amazing little device.

For use as a wallet or 2FA it works swell to just plug it in and use the
official trezor app. If you want to easily use it for encryption it gets a
little bit more hands on.

The purpose of this post is to document all the setup for myself so I can easily
get up and going when I migrate to different computers.


## Installation and setup {#installation-and-setup}

Follow the [trezor-agent installation instructions](https://github.com/romanz/trezor-agent/blob/master/doc/INSTALL.md) to get set up. Once you are
finished you are in theory all good to go.


## Basic usage {#basic-usage}

After you are set up, you can use the trezor-agent for:

-   [SSH](https://github.com/romanz/trezor-agent/blob/master/doc/README-SSH.md)
-   [GPG](https://github.com/romanz/trezor-agent/blob/master/doc/README-GPG.md)

The official documentation does a great job explaining the use. If you want the full convenience of the `trezor-agent`, I would strongly recommend setting up the LaunchAgent for SSH and GPG however.


### Set up SSH LaunchAgent and config {#set-up-ssh-launchagent-and-config}

This will take care of setting up a SSH socket for you and allow you to connect to different sources without having to go through the trezor-agent command.

To get started add an export of the socket ot an environment variable. Stick it
in your .bashrc or .zshrc to have it available at all times.

```shell
export SSH_AUTH_SOCK="$HOME/.ssh/trezor-agent/S.ssh"
```

In your `$HOME/Library/LaunchAgents` folder, add the following in a file. I named it `trezor-ssh-socket.plist`. Thanks [rryter](https://gist.github.com/rryter/f5f439fd67ea049cad3a9e64bbc98269) for the original plist file.

<a id="code-snippet--trezor-ssh-socket.plist"></a>
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd>
<plist version="1.0">
<dict>
	<key>KeepAlive</key>
	<true/>
	<key>Label</key>
	<string>Trezor SSH Socket</string>
	<key>ProgramArguments</key>
	<array>
		<string>sh</string>
		<string>-c</string>
		<string>ln -s -f $SSH_TREZOR_SOCK ~/.ssh/trezor-agent/S.ssh &amp;&amp; /opt/homebrew/bin/trezor-agent --foreground --sock-path $SSH_TREZOR_SOCK ~/.ssh/trezor.conf 2&gt; ~/.ssh/trezor-agent/error.log</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>Sockets</key>
	<dict>
		<key>ssh</key>
		<array>
			<dict>
				<key>SecureSocketWithKey</key>
				<string>SSH_TREZOR_SOCK</string>
				<key>SockFamily</key>
				<string>Unix</string>
				<key>SockPathMode</key>
				<integer>384</integer>
			</dict>
		</array>
	</dict>
	<key>ThrottleInterval</key>
	<integer>0</integer>
</dict>
</plist>
```

Hold up! This here LaunchAgent mentions some config file? `\~/.ssh/trezor.conf`?

This `trezor.conf` is where you stick the pubkeys that you want the trezor to
authenticate with.

Say you are using the `mjau@example.com` id to ssh to a server. Stick it in the
conf file by doing the following:

```shell
trezor-agent mjau@example.com >> ~/.ssh/trezor.conf
```

Make sure you load the agent:

```shell
launchctl load ~/Library/LaunchAgents/trezor.ssh.socket.plist
```

Now you can use your vanilla ssh command to connect. This is of course assuming
you have added the pubkey for mjau@example.com to the authorized keys of the
server.

```shell
ssh mjau@some-cool-server
```

If you have the Trezor connected you should automagically get the pin entry.


### Generating a key for Github {#generating-a-key-for-github}

Did I mention that this now works if you set up for example your github account over ssh?

By default the keys generated have the ecdsa-sha2-nistp256 algorithm. Github
requires ed25519. Thankfully its easy peasy to generate a key like that with
trezor-agent:

```shell
trezor-agent -e ed25519 git@github
```

Stick the result both in the github settings and in the trezor.conf file. Next
time you do a `git pull` from a github repo, enjoy hardware key fantasticness.


### Doom emacs {#doom-emacs}

Are you using Doom Emacs and want to be able to SSH directly in there?

Add this to your config as Doom has an environment variable whitelist

```lisp
(when noninteractive
  (add-to-list 'doom-env-whitelist "^SSH_AUTH_SOCK$"))
```
