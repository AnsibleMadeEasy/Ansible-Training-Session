#
#   START ~/.bashrc
#
#   Avoid modifying this file ".bashrc".  
#
#   User customization should be placed in:
#
#       ~/.mybashrc
#
#   Please remember environment files may be replaced or 
#   changed by the system administrator with no notice!
#

#
#   Establish global environment settings:
#
test -r /usr/local/etc/profiles/bashrc.global && . /usr/local/etc/profiles/bashrc.global

#
#   User may have his own set up - establish if found.
#
test -r ~/.mybashrc && . ~/.mybashrc

cd .

#
#   END ~/.bashrc
#
