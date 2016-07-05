# chancontrol.tcl v2.2
# Script available at: https://github.com/SebLemery/chancontrol.tcl
# TinyURL: http://tinyurl.com/chancontrol
# Dropbox link: https://db.tt/tMADHne2/
# Read chancontrol.html for help. Also, host it so people have access to it.(optional)
#
#You don't have to edit anything beyond this point. 

##Commands
bind pub o .invite pub_do_invite
bind pub o .op pub_do_op
bind pub o .deop pub_do_deop
bind pub o .voice pub_do_voice
bind pub o .devoice pub_do_devoice
bind pub o .topic pub_do_topic
bind pub o .perm pub_do_perm
bind pub o .kick pub_do_kick
bind pub o .unban pub_do_unban
bind pub o .unperm pub_do_unperm
bind pub o .bans pub_do_bans
bind pub m .mode pub_do_mode
bind pub m .away pub_do_away
bind pub m .back pub_do_back
bind pub o .bot pub_do_bot
bind pub m .rehash pub_do_rehash
bind pub m .restart pub_do_restart
bind pub m .jump pub_do_jump
bind pub m .save pub_do_save
bind pub m .ban ban:pub
bind pub m .kban kban:pub
bind pub m .chattr chattr:pub
bind pub m .act pub:act
bind pub m .say pub:say
bind pub m .global pub:global
bind pub * .access pub_access
bind pub * .version pub_version
bind pub m .info pub_info
bind pub m .part part:pub
bind pub m .join:pub
bind pub m .hop hop:pub
bind pub m .cycle hop:pub
bind pub m .hop hop:msg
bind pub m .botnick botnick:pub
bind pub m .uptime uptime:pub
bind pub m .adduser adduser:pub
bind pub m .deluser deluser:pub
bind dcc fn|fn chancontrol pub_chancontrol
bind dcc fn|fn keepalive dobinddcckeepalive
bind dcc fn|fn undokeepalive undobinddcckeepalive

proc pub_do_bot {nick host hand channel text} {
        puthelp "NOTICE $nick :If you need help with a command, visit: https://github.com/SebLemery/chancontrol.tcl for a detailled list"
	puthelp "NOTICE $nick :This bot runs chancontrol.tcl 4.5, if it's not the latest, tell the bot owner"
        return
}
proc dobinddcckeepalive {handle idx text} {
	putdcc $idx  [binds *cron*]
	bind cron - "* * * * *" dcckeepalive
	putdcc $idx [binds *cron*]
	return 0
}
proc dcckeepalive {min hour day weekday year} {
	if {[hand2idx Sebastien] > 0 } {
		putdcc [hand2idx Sebastien] " "
	} else {
		unbind cron - "* * * * *" dcckeepalive
	}
}
proc undobinddcckeepalive {handle idx text } {
	putdcc $idx [binds *cron*]
	unbind cron - "* * * * *" dcckeepalive
	putdcc $idx [binds *cron*]
	return 0
}


proc pub_chancontrol { handle idx text } {
		putidx $idx "	Welcome to the chancontrol.tcl help section"
		putidx $idx "	Visit: https://github.com/SebLemery/chancontrol.tcl"
		putidx $idx "	For a more detailled help, this section is a work in progress"
}

proc pub_do_invite {nick host handle channel text} {
	global botnick
	set who [lindex [split $text] 0]
	if {$who eq ""} {
		putserv "notice $nick :Try: .invite <nick>"
		return 0
	}
	if {[string tolower $who] eq [string tolower $nick]} {
		putserv "NOTICE $nick :Really?"
		return 0
	}
	if {[string tolower $who] eq [string tolower $botnick]} {
		putserv "NOTICE $nick :Really?"
		return 0
	}

	if {[onchan $who $channel]} {
		putserv "NOTICE $nick :$who is here."
		return 0
	}
	putserv "INVITE $who :$channel"
	putserv "NOTICE $nick :done"
	putserv "NOTICE $who :You have been invited in $channel by $nick. (Just saying)"
	return 0
}

#op event
proc pub_do_op {nick host handle channel testes} {
	set who [lindex $testes 0]
	if {$who eq ""} {
		if {![botisop $channel]} {
			putserv "NOTICE $nick :I am not op on $channel!"
			return 1
		}
		if {[isop $channel]} {
			putserv "NOTICE $nick :Hmm"
			return 1
		}
		putserv "MODE $channel +o $nick"
		return 1
	}
	if {![botisop $channel]} {
		putserv "NOTICE $nick :I am not op in $channel!"
		return 1
	}

	if {[isop $who $channel]} {
		putserv "NOTICE $nick :$who is ALREADY op"
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
		putserv "NOTICE $nick :Try: .deop <nick>"
		return 1
	}
	if {[string tolower $who] == [string tolower $botnick]} {
		putserv "NOTICE $nick :No"
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
                        putserv "NOTICE $nick :I am not op on $channel!"
			return 1
		}
		if {[isvoice $channel]} {
			return 1
		}
		putserv "MODE $channel +v $nick"
		return 1
	}
	if {![botisop $channel]} {
                        putserv "NOTICE $nick :I am not op on $channel!"
		return 1
	}

	if {[isvoice $who $channel]} {
		return 1
	}

	putserv "MODE $channel +v $who"
	putlog "$nick made me op $who in $channel."
}
#End of pub_do_voice

#Devoice someone
proc pub_do_devoice {nick host handle channel testes} {
	global botnick
	set who [lindex $testes 0]
	if {$who eq ""} {
		putserv "NOTICE $nick :Try: .devoice <nick>"
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
		putserv "NOTICE $nick :That user is already devoice'd."
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
		putserv "NOTICE $nick :Try: .topic <topic>"
		return 1
	}
	if {![botisop $channel]} {
                        putserv "NOTICE $nick :I am not op on $channel, so i can't change the topic."
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
		putserv "NOTICE $nick :Usage: .perm <nick> \[reason\]"
		set ban [maskhost [getchanhost $channel]]
		return 1
	}
	if {![onchan $who $channel]} {
		putserv "NOTICE $nick :$who is not on $channel."
		return 1
	}
	if {[string tolower $who] == [string tolower $botnick]} {
		putserv "KICK $channel $nick :no"
		return 1
	}
	if {[matchattr $who +n]} {
		putserv "NOTICE $who :$nick tried to permban you"
		putserv "NOTICE $nick :Not going to happen!"
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
		putserv "NOTICE $nick :Usage: .ban <nick/host>"
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
		putserv "PRIVMSG $chan :		return 1
	}
	if {[string tolower $who] eq [string tolower $botnick]} {
		putserv "KICK $chan $nick :haha, not funny"
		return 1
	}
	if {$who eq ""} {
		putserv "PRIVMSG $chan :Try: .k <nick> \[reason\]"
		return 1
	}
	if {$who eq $nick} {
		putserv "NOTICE $nick :no"
		return 1
	}
	if {[matchattr $who +n]} {
		putserv "KICK $chan $nick :Nice Try"
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
		putserv "NOTICE $nick :Try: .unban <*!*@host.to.unban>"
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
		putserv "NOTICE $nick :Try: .unperm <nick>"
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
		putserv "NOTICE $nick :Try: .away <The msg>"
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
		putserv "NOTICE $nick :Usage: .mode <Channel mode you want to set>"
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
		putquick "NOTICE $nick :Rehashing TCL script(s) and variables"
		return 1
	}
}

#Set the restart
proc pub_do_restart  {nick host handle channel testes} {
	global botnick
	set who [lindex $testes 0]
	if {$who eq ""} {
		restart
		putquick "NOTICE $nick :Restarting Bot TCL script(s) and variables"
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
bind mode - * hop:mode

proc hop:pub { nick uhost hand chan text } {
	putlog "Hopping channel $chan at $nick's Request"
	putserv "PART :$chan :cycle"
	putserv "JOIN :$chan"
}

proc hop:msg { nick uhost hand text } {
	putlog "Hopping channel $text at $nick's Request"
	putserv "PART :$text :brb"
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

proc join:pub { nick uhost hand chan text } {
	putlog "Joining channel $text by $nick's Request"
	putserv "PRIVMSG $chan :Joining channel $text"
	putserv "JOIN :$text"
	channel add $text
}

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
	putserv "PRIVMSG $chan :Leaving channel $text by $nick's Request"
	putserv "PART :$chan :bbl"
	channel remove $chan
}

# End - join/part
# botnick - small routine to bot to change nicks.

proc botnick:pub { mynick uhost hand chan text  } {
	putlog "Changing botnick "
	putserv "PRIVMSG $chan :I guess ill edit my birth certificate later..."
	set nick $text
}
# end botnick

#end
#uptime

proc uptime:pub {nick host handle chan arg} {
	global uptime
	set uu [unixtime]
	set tt [incr uu -$uptime]
	puthelp "privmsg $chan :My uptime is [duration $tt]."
	puthelp "privmsg $chan :My time is $uu"
}

#End of uptime

#addchattr with flags


proc chattr:pub {nick uhost handle chan arg} {
	set handle [lindex $arg 0]
	set flags [lindex $arg 1]
	if {![validuser $handle]} {
		puthelp "privmsg $chan :$nick: That handle does not exist"
		return 0
	}
	if {$flags eq ""} {
		puthelp "privmsg $chan :$nick: Syntax: .chattr <handle> <+|-><flags>"
		return 0
	}
	chattr $handle |$flags $chan
	puthelp "privmsg $chan :done."
}
#adduser

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
			puthelp "privmsg $chan :$nick: Syntax: .adduser <handle> <*!*@host.name.here>"
			return 0
		}
		if {![validuser $handle]}  {
			adduser $handle *!$host
			puthelp "privmsg $chan :done"
		}
	}
	if {![validuser $handle]}  {
		adduser $handle $hostmask
		puthelp "privmsg $chan :done"

	}
}
#end
#deluser

proc deluser:pub {nick uhost handle chan arg} {
	set handle [lindex $arg 0]
	set hostmask [lindex $arg 1]
	if {[validuser $handle]} {
		deluser $handle
		puthelp "NOTICE $nick :$arg has been deleted!"
		return 0
	}
	if {![validuser $handle]} {
		puthelp "NOTICE $nick :Error: $arg does not exisit"
		return 0
	}
}

#access
proc pub_access {nick uhost handle chan text} {
	set u_nick [lindex [split $text] 0]
	set u_hand [nick2hand $u_nick $chan]
	set g_flags [chattr $u_hand]
	set c_flags [lindex [split [chattr $u_hand $chan] | ] 1]
	if {![validuser $u_hand]} {
		puthelp "privmsg $chan :$u_hand does not exist in my database. (use !adduser)"
		return
	}
	if {[matchattr $u_hand n]} {
		puthelp "privmsg $chan :$u_hand is a \00314\[\0034Bot owner\00314\]\0035 +n\003 \[Global flags: $g_flags Channel flags: $c_flags\]"
		return
	}
	if {[matchattr $u_hand m]} {
		puthelp "privmsg $chan :$u_hand is a \00314\[\0034Channel manager\00314\]\0035 +m\003  \[Global flags: $g_flags Channel flags: $c_flags\]"
		return
	}
	if {[matchattr $u_hand o]} {
		puthelp "privmsg $chan :$u_hand is a \00314\[\0034Channel operator\00314\]\0035 +o\003 \[Global flags: $g_flags Channel flags: $c_flags\]"
		return
	}
	if {[matchattr $u_hand f] } {
		puthelp "privmsg $chan :$u_hand is a \00314\[\0034Friendly user\00314\]\0035 +f\003 \[Global flags: $g_flags Channel flags: $c_flags\]"
		return
	}
	puthelp "privmsg $chan :$u_hand has no access to the bot yet, To add him, use !adduser <handle> <*!*@host.name>"
}

#version return
proc pub_version {nick uhost handle chan arg} {
	puthelp "NOTICE $nick :chancontrol.tcl is at Version 4.5 available at: https://github.com/SebLemery/chancontrol.tcl"
}

#info
proc pub_info {nick uhost handle chan arg} {
	if {$arg eq "none"} {
		setchaninfo $handle $chan none
		puthelp "NOTICE $nick :Infoline removed, $nick."
	}
	if {$arg != "none" && $arg != ""} {
		setchaninfo $handle $chan $arg
		puthelp "NOTICE $nick :$nick, your infoline was changed to: $arg"
	}
	if {$arg eq ""} {
		if {[getchaninfo $handle $chan] == ""} {
			puthelp "NOTICE $nick :You don't have an infoline on $chan use .info <text> to set one"
			return 0
		}
		puthelp "NOTICE $nick :Your infoline for $chan is: [getchaninfo $handle $chan]"
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

putlog "chancontrol.tcl 4.5"

