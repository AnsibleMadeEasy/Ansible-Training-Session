#
#   START ~/.cshrc
#
#   Never touch this file. To customize your csh environment edit the
#   file:
#
#       ~/.mychsrc
#
#   This file may be replaced or changed by system administrators with
#   no notice!
#

#
#   Do not modify this line. It establishes global environment settings.
#
if (-r /usr/local/etc/profiles/cshrc.global) then
    source /usr/local/etc/profiles/cshrc.global
endif

#
#   This is where the user gets his.
#
if (-r ~/.mycshrc) then
    source ~/.mycshrc
endif

cd .

#
#   END ~/.cshrc
#

