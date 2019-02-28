Date: 23 May 1986 0807-EDT
From: "Bernie AT&T:617-467-5664 LDP Workstations" <EIBEN@MARLBORO.DEC.COM>
To: sy.fdc@cu20b
Subject: CP/M-80 Kermit Bootstrapping Procedure Corrected

Here is a fixed version of the CP/M bootstrapping program.  The version that
has been listed in the CP/M-80 Kermit manual for the past several years failed
to store the end of the file after downloading it into memory.  The new version
stores in multiples of 2 sectors [256 bytes] and could have a 'overrun' of that
much, however without problems, since the Control-Z does the magic.  Unlike the
previous version, this program displays the data on the screen while capturing
it into memory.

Probably you want to include the 'program' - for the guy who has an editor AND
the DDT-form.  I believe that the assembler will catch typos easier than DDT -
and not everybody is fluent enough in DDT to correct typos on the fly.

The Rainbow was able to 'fetch' at 2400 baud, VT180 only checked at 1200 baud.
You might want to check on your micros, first thing to go [speed-wise] could be
the 'visual' display - although I NEEDED to see the 'bytes' trickling in - and
its also quite handy to see a 'blotch' coming on the VT180 - so you know right
away when a transfer wasn't clean.

- Bernie
