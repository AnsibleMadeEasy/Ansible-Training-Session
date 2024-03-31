#
#   START ~/.kshrc
#
#   Avoid modifying this file ".kshrc".  
#
#   User customization should be placed in:
#
#       ~/.mykshrc
#
#   Please remember environment files may be replaced or 
#   changed by the system administrator with no notice!
#

#
#   Establish global environment settings:
#
test -r /usr/local/etc/profiles/kshrc.global && . /usr/local/etc/profiles/kshrc.global

#
#   User may have his own set up - establish if found.
#
test -r ~/.mykshrc && . ~/.mykshrc

cd .

#
#   END ~/.kshrc
#
