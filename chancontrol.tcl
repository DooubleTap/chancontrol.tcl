# chancontrol.tcl v4.0.1
# Description;
# This script is essential for channel management eggdrops. 
# It includes the basic commands like !op !deop !voice !devoice !topic !rehash !adduser
# Simply wget the file into /eggdrop/scripts/ 
# Add: "source scripts/chancontrol.tcl" at the bottom of your eggdrop's config file.
# .rehash in DCC or Telnet and type !bot in your channel to get the help file via /notice
# Any bugs or edits can be pushed via github
# Essential Credits: 
# GoGers (Anto) on Dal.Net This script is based on his pubcommand.tcl v3.0 
# jack3 on freenode and undernet for his amazing patience and teaching skills. 
# The people on #eggdrop on freenode and undernet too, for their time and free weed. 

##Commands

bind pub o !invite pub_do_invite
bind pub o !op pub_do_op
bind pub o !deop pub_do_deop
bind pub o !voice pub_do_voice
bind pub o !devoice pub_do_devoice
bind pub o !topic pub_do_topic
bind pub o !perm pub_do_perm
bind pub o !kick pub_do_kick
bind pub o !unban pub_do_unban
bind pub o !unperm pub_do_unperm
bind pub o !bans pub_do_bans
bind pub m !mode pub_do_mode
bind pub m !away pub_do_away
bind pub m !back pub_do_back
bind pub o !bot pub_do_bot
bind pub m !rehash pub_do_rehash
bind pub m !restart pub_do_restart
bind pub m !jump pub_do_jump
bind pub m !save pub_do_save
bind pub m !ban ban:pub
bind pub m !kban kban:pub
bind pub m !chattr chattr:pub
bind pub m !act pub:act
bind pub m !say pub:say
bind pub m !global pub:global
bind pub m !access pub_access
bind pub m !info pub_info

proc pub_do_invite {nick host handle channel text} {
	global botnick
	set who [lindex [split $text] 0]
	if {$who eq ""} {
		putserv "PRIVMSG $channel :Usage: !invite <Nick to invite> (Note: I tell on you via /notice)"
		return 0
	}
	if {[string tolower $who] eq [string tolower $nick]} {
		putserv "privmsg $channel :You bloody twot.."
		return 0
	}
	if {[string tolower $who] eq [string tolower $botnick]} {
		putserv "PRIVMSG $channel :well, i'm already here.."
		return 0
	}

	if {[onchan $who $channel]} {
		putserv "PRIVMSG $channel :$who is \037ALREADY\037 in \002$channel\002."
		return 0
	}
	putserv "INVITE $who :$channel"
	putserv "PRIVMSG $channel :Done, invited $who in here."
	putserv "NOTICE $who :You have been invited in $channel by $nick."
	return 0
}

proc pub_do_bot {nick host hand channel text} {
	puthelp "NOTICE $nick :Listing Simple management commands. Make sure you have the required flags."
	puthelp "NOTICE $nick :Channel Ranking: !op <nick> - !deop <nick> - !voice <nick>  - !devoice <nick> - !topic <whatever>"
	puthelp "NOTICE $nick :User management: !adduser <handle> <*!*@host.name> - !chattr <Handle> <+|-flags>"
	puthelp "NOTICE $nick :Disruptive user solutions: !ban <nick/host> - !unban <host> - !perm <nick> <reason>  - !kick <nick> - !bans"
	puthelp "NOTICE $nick :Bot settigns: !rehash - !restart - !jump - !save - !away <msg> - !back - !join #chan - !part #chan - !botnick <newnick>"
	puthelp "NOTICE $nick :!bot - Brings up this menu."
	return
}

#op event
proc pub_do_op {nick host handle channel testes} {
	set who [lindex $testes 0]
	if {$who eq ""} {
		if {![botisop $channel]} {
			putserv "PRIVMSG $channel : I need op to do that."
			return 1
		}
		if {[isop $channel]} {
			putserv "PRIVMSG $channel :Hmm"
			return 1
		}
		putserv "MODE $channel +o $nick"
		return 1
	}
	if {![botisop $channel]} {
		putserv "PRIVMSG $channel :I need op to do that."
		return 1
	}

	if {[isop $who $channel]} {
		putserv "PRIVMSG $channel :$who is ALREADY op"
		return 1
	}

	putserv "MODE $channel +o $who"
	putlog "$nick made me op $who in $channel."
}
#End of pub_do_op

#Deop event
proc pub_do_deop {nick host handle channel testes} {
	global botnick
	set who [lindex $testes 0]
	if {$who eq ""} {
		putserv "PRIVMSG $channel :Usage: !deop <Nick to Deop>"
		return 1
	}
	if {[string tolower $who] == [string tolower $botnick]} {
		putserv "MODE $channel -o $nick"
		putserv "PRIVMSG $channel :You think that's funny?"
		return 1
	}
	if {[string tolower $who] == [string tolower $nick]} {
		putserv "MODE $channel -o $nick"
		return 1
	}
	if {[matchattr $who +n]} {
		putserv "MODE $channel -o $nick"
		return 1
	}
	if {![isop $who $channel]} {
		putserv "NOTICE $nick :Fail"
		return 1
	}
	putserv "MODE $channel -o $who"
	return 1
}
#end of pub_do_deop

#voice event
proc pub_do_voice {nick host handle channel testes  } {
	set who [lindex $testes 0]
	if {$who eq ""} {
		if {![botisop $channel]} {
			putserv "PRIVMSG $channel :I'm not an op."
			return 1
		}
		if {[isvoice $channel]} {
			return 1
		}
		putserv "MODE $channel +v $nick"
		return 1
	}
	if {![botisop $channel]} {
		putserv "PRIVMSG $channel :I'm not an op."
		return 1
	}

	if {[isvoice $who $channel]} {
		return 1
	}

	putserv "MODE $channel +vvvvv $who "
	putlog "$nick made me op $who in $channel."
}
#End of pub_do_voice

#Devoice someone
proc pub_do_devoice {nick host handle channel testes} {
	global botnick
	set who [lindex $testes 0]
	if {$who eq ""} {
		putserv "PRIVMSG $channel :Usage: !devoice <Nick to Devoice>"
		return 1
	}
	if {[string tolower $who] == [string tolower $botnick]} {
		putserv "MODE $channel -v $nick"
		return 1
	}
	if {[string tolower $who] == [string tolower $nick]} {
		putserv "MODE $channel -v $nick"
		return 1
	}
	if {[matchattr $who +n]} {
		putserv "MODE $channel -v $nick"
		return 1
	}
	if {![isvoice $who $channel]} {
		putserv "PRIVMSG $channel :That user is already devoice'd."
		return 1
	}
	putserv "MODE $channel -v $who"
	return 1
}
#end of pub_do_devoice

#Change topic on channel
proc pub_do_topic {user host handle channel testes} {
	set what [lrange $testes 0 end]
	if {$what eq ""} {
		putserv "PRIVMSG $channel :Usage: !topic <Topic you want.>"
		return 1
	}
	if {![botisop $channel]} {
		putserv "PRIVMSG $channel :I need to be op'd on that channel to change the topic."
		return 1
	}

	putserv "TOPIC $channel :$what"
	return 1
}
#end of pub_do_topic

#Permban someone
proc pub_do_perm {nick host handle channel testes} {
	global botnick
	set why [lrange $testes 1 end]
	set who [lindex $testes 0]
	set ban [maskhost [getchanhost $who $channel]]
	if {$who eq ""} {
		putserv "PRIVMSG $channel :Usage: !perm <Nick to blacklist>"
		set ban [maskhost [getchanhost $channel]]
		return 1
	}
	if {![onchan $who $channel]} {
		putserv "PRIVMSG $channel :$who aint on $channel."
		return 1
	}
	if {[string tolower $who] == [string tolower $botnick]} {
		putserv "KICK $channel $nick :I am not going to ban myself!"
		return 1
	}
	if {[matchattr $who +n]} {
		putserv "NOTICE $who :$nick tried to permban you. Better have a talk with him."
		putserv "PRIVMSG $channel :Not going to happen!"
		return 1
	}
	newchanban $channel $ban $nick $why
	stick $ban $channel
	putserv "KICK $channel $who :$why" 
	putlog "$nick made me permban $who who was $ban and the reason was $why."
	putserv "PRIVMSG $channel :PermBanned: $who on $channel with reason: $why."
	return 1
}
#end of pub_do_perm
#ban

proc ban:pub {nick uhost hand chan arg} {
	set ban [lindex $arg 0]
	if {$ban eq ""} {
		putserv "PRIVMSG $chan :Usage: !ban <nick/host>"
		set ban [maskhost [getchanhost $chan]]
		return 1
	}

	if {[string match *!*@* $ban]} {pushmode $chan +b $ban} {pushmode $chan +b *!*@[lindex [split [getchanhost $ban] @] 1]}
}

#end
#kban

proc kban:pub {nick uhost hand chan arg} {ban:pub $nick $uhost $hand $chan $arg;pub_do_kick $nick $uhost $hand $chan $arg}

#Kick someone
proc pub_do_kick {nick uhost hand chan arg} {
	global botnick
	set who [lindex $arg 0]
	set why [lrange $arg 1 end]
	if {![onchan $who $chan]} {
		putserv "PRIVMSG $chan :$who isnt on $chan."
		return 1
	}
	if {[string tolower $who] eq [string tolower $botnick]} {
		putserv "KICK $chan $nick :hah. not funny."
		return 1
	}
	if {$who eq ""} {
		putserv "PRIVMSG $chan :Useage: !k <nick to kick>"
		return 1
	}
	if {$who eq $nick} {
		putserv "PRIVMSG $chan :Why the hell do you want to kick yourself $nick?"
		return 1
	}
	if {[matchattr $who +n]} {
		putserv "KICK $chan $nick :Trying to kick my owner eh? ;Þ"
		return 1
	}
	putserv "KICK $chan $who :$why"
	return 1
}
#End of pub_do_kick

#Delete a host from the banlist.
proc pub_do_unban {nick host handle channel testes} {
	set who [lindex $testes 0]
	if {$who eq ""} {
		putserv "NOTICE $nick :Usage: <Host to unban>"
		return 1
	}
	putserv "MODE $channel -b $who"
	putlog "$nick made me Delete $who from banlist."
	return 1
}
#end of pub_do_unban

#Remove user from shitlist
proc pub_do_unperm {nick host handle channel testes} {
	set who [lindex $testes 0]
	if {$who eq ""} {
		putserv "NOTICE $nick :Usage: !unperm <blacklisted user to remove from said list>"
		return 1
	}
	killchanban $channel $who
	putlog "$nick made me Delete $who from blacklist."
	return 1
}
#end of pub_do_unperm

#banlist
proc pub_do_bans {nick uhost hand chan text} {
	puthelp "NOTICE $nick :-Ban List for ($chan.)-"
	foreach {a b c d} [banlist $chan] {
		puthelp "NOTICE $nick :- [format %-12s%-12s%-12s%-12s $a $b $c $d]"
	}
	puthelp "NOTICE $nick :-End of list-"
}
#end of banlist

#Set the bot away.
proc pub_do_away {nick host handle channel testes} {
	set why [lrange $testes 0 end]
	if {$why eq ""} {
		putserv "NOTICE $nick :!away <The away msg you want me to use.>"
		return 1
	}
	putserv "AWAY :$why"
	putserv "NOTICE $nick :Away MSG set to $why."
	return 1
}
#end of pub_do_away

#Set the bot back.
proc pub_do_back {nick host handle channel testes} {
	putserv "AWAY :"
	putserv "NOTICE $nick :I'm back."
}
#end of pub_do_back

#Change the mode in the channel
proc pub_do_mode {nick host handle channel testes} {
	set who [lindex $testes 0]
	if {![botisop $channel]} {
		putserv "NOTICE $nick :I'm not op'd in $channel!"
		return 1
	}
	if {$who eq ""} {
		putserv "NOTICE $nick :Usage: !mode <Channel mode you want to set>"
		return 1
	}
	putserv "MODE $channel $who"
	return 1
}
#end of pub_do_mode


#Set the rehash
proc pub_do_rehash  {nick host handle channel testes} {
	global botnick
	set who [lindex $testes 0]
	if {$who eq ""} {
		rehash
		putquick "NOTICE $nick : Rehashing TCL script(s) and variables"
		return 1
	}
}

#Set the restart
proc pub_do_restart  {nick host handle channel testes} {
	global botnick
	set who [lindex $testes 0]
	if {$who eq ""} {
		restart
		putquick "NOTICE $nick : Restarting Bot TCL script(s) and variables"
		return 1
	}
}

#Set the jump
proc pub_do_jump  {nick host handle channel testes} {
	global botnick
	set who [lindex $testes 0]
	if {$who eq ""} {
		jump
		putquick "NOTICE $nick : Changing Servers"
		return 1
	}
}

#Set the save
proc pub_do_save  {nick host handle channel testes} {
	global botnick
	set who [lindex $testes 0]
	if {$who eq ""} {
		save
		putquick "NOTICE $nick :Saving user file"
		putquick "NOTICE $nick :Saving Channel File"
		return 1
	}
}

#Hop the bot!

# Set this to 1 if the bot should hop upon getting deopped, 0 if it should ignore it.
set hopondeop 1

# Set this to 1 if the bot should kick those who deop it upon returning, 0 if not.
# NOTE: The bot owner will be immune to this kick even if it is enabled.
set kickondeop 1

#Don't Edit anything below!

bind pub m "!hop" hop:pub
bind pub m "!cycle" hop:pub
bind msg m "hop" hop:msg
bind mode - * hop:mode

proc hop:pub { nick uhost hand chan text } {
	putlog "Hopping channel $chan at $nick's Request"
	putserv "PRIVMSG $chan :Cycle Command used by $nick"
	putserv "PART :$chan :brb in a jiffy"
	putserv "JOIN :$chan"
	putserv "PRIVMSG $chan :Hi!"
}

proc hop:msg { nick uhost hand text } {
	putlog "Hopping channel $text at $nick's Request"
	putserv "PART :$text :brb in a jiffy"
	putserv "JOIN :$text"
}

proc hop:mode { nick uhost hand chan mc vict } {
	global hopondeop kickondeop botnick owner
	if {$mc eq "-o" && $vict eq $botnick && $hopondeop eq 1} {
		putlog "Hopping channel $chan due to deop"
		putserv "PART :$chan :Trying to fix something"
		putserv "JOIN :$chan"
		putserv "PRIVMSG $chan :"
		if {$nick != $owner && $kickondeop eq 1} {
			putserv "KICK $chan $nick"
		}
	}
}
#join/part section, newly added

bind pub m "!join" join:pub

proc join:pub { nick uhost hand chan text } {
	putlog "Joining channel $text by $nick's Request"
	putserv "PRIVMSG $chan :Joining channel $text by $nick's Request"
	putserv "JOIN :$text"
	channel add $text
}

bind pub m "!part" part:pub

proc part:pub { nick uhost hand chan text } {
	set chan [lindex $text 0]
	if {![isdynamic $chan]} {
		puthelp "privmsg $chan :$nick: That channel isn't dynamic!"
		return 0
	}
	if {![validchan $chan]} {
		puthelp "privmsg $chan :$nick: That channel doesn't exist!"
		return 0
	}

	putlog "Parting $chan by $nick's Request"
	putserv "PART :$chan :bbl"
	channel remove $chan
}

# End - join/part
# botnick - small routine to bot to change nicks.

bind pub m "!botnick" botnick:pub

proc botnick:pub { mynick uhost hand chan text  } {
	putlog "Changing botnick "
	putserv "PRIVMSG $chan :I guess ill edit my birth certificate after this, to: $text "
	set nick $text
}
# end botnick

#end
#uptime

bind pub m "!uptime" uptime:pub

proc uptime:pub {nick host handle chan arg} {
	global uptime
	set uu [unixtime]
	set tt [incr uu -$uptime]
	puthelp "privmsg $chan :$nick: My uptime is [duration $tt]."
}

#End of uptime

#addchattr with flags


proc chattr:pub {nick uhost handle chan arg} {
	set handle [lindex $arg 0]
	set flags [lindex $arg 1]
	if {![validuser $handle]} {
		puthelp "privmsg $chan :$nick: That handle doesn't exist!"
		return 0
	}
	if {$flags eq ""} {
		puthelp "privmsg $chan :$nick: Syntax: .chattr <handle> <+|-><flags>"
		return 0
	}
	chattr $handle $flags
	puthelp "privmsg $chan :Added that! $nick."
}
#adduser
bind pub m "!adduser" adduser:pub

proc adduser:pub {nick uhost handle chan arg} {
	set handle [lindex $arg 0]
	set hostmask [lindex $arg 1]
	if {[validuser $handle]} {
		puthelp "privmsg $chan :$nick: That user already exists!"
		return 0
	}
	if {$hostmask eq ""} {
		set host [getchanhost $handle]
		if {$host eq ""} {
			puthelp "privmsg $chan :$nick: I can't get $handle's host."
			puthelp "privmsg $chan :$nick: Syntax: !adduser <handle> <hostmask (nick!user@host) wildcard acceptable>"
			return 0
		}
		if {![validuser $handle]}  {
			adduser $handle *!$host
			puthelp "privmsg $chan :Done! $nick."
		}
	}
	if {![validuser $handle]}  {
		adduser $handle $hostmask
		puthelp "privmsg $chan :Done! $nick."

	}
}
#end
#deluser
bind pub m "!deluser" deluser:pub

proc deluser:pub {nick uhost handle chan arg} {
	set handle [lindex $arg 0]
	set hostmask [lindex $arg 1]
	if {[validuser $handle]} {
		deluser $handle
		puthelp "privmsg $chan :$nick: User has been deleted from my database !"
		return 0
	}
	if {![validuser $handle]} {
		puthelp "privmsg $chan :$nick: User does not exisit on  my database !"
		return 0
	}
}

#access
proc pub_access {nick uhost handle chan arg} {

	if {![validuser [lindex $arg 0]]} {puthelp "privmsg $chan :[lindex $arg 0] does not exist in my database. (use !adduser)";return}
	if {[matchattr [lindex $arg 0] n]} {puthelp "privmsg $chan :[lindex $arg 0] is an \002Owner\002 (+n)";return}
	if {[matchattr [lindex $arg 0] m]} {puthelp "privmsg $chan :[lindex $arg 0] is a \002Master\002 (+m)";return}
	if {[matchattr [lindex $arg 0] o]} {puthelp "privmsg $chan :[lindex $arg 0] is an \002Operator\002 (+o)";return}
	if {[matchattr [lindex $arg 0] f]} {puthelp "privmsg $chan :[lindex $arg 0] is an \002Friendly user\002 (+f)";return}
	puthelp "privmsg $chan :[lindex $arg 0] is a basic user"
}

#info
proc pub_info {nick uhost handle chan arg} {
	if {$arg eq "none"} {
		setuser $handle info ""
		puthelp "privmsg $chan :Done! $nick."
	}
	if {$arg != "none" && $arg != ""} {
		setuser $handle info $arg
		puthelp "privmsg $chan :Done! $nick."
	}
	if {$arg eq ""} {
		if {[getuser $handle info] == ""} {
			puthelp "privmsg $chan :$nick: You don't have an info."
			return 0
		}
		puthelp "privmsg $chan :$nick: Your info is: [getuser $handle info]"
	}
}


#end
#say & act

proc pub:say {nick uhost handle chan arg} {puthelp "privmsg $chan :$arg"}
proc pub:global {nick uhost handle chan arg} {
	foreach chan [channels] {
		puthelp "privmsg $chan :[global announcement] $arg"
	}
}
proc pub:act {nick uhost handle chan arg} {puthelp "privmsg $chan :\001ACTION $arg\001"}

putlog "chancontrol.tcl 4.2.0 by Sebastien @ freenode"
putlog "based on pubcommand.tcl v3.0 by anto @ dal.net"
