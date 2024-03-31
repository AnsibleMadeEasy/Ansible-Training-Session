# .profile

# Get the aliases and functions
if [ "$SHELL" = "/bin/ksh" ] && \
   [ -f ~/.kshrc ]; then
	. ~/.kshrc
elif [ "$SHELL" = "/bin/bash" ] && \
     [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin

export PATH
