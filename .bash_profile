# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=/usr/local/bin:/opt/ruby-enterprise/bin:$PATH:$HOME/bin
EDITOR=vim
export EDITOR
export PATH
#eval `ssh-agent`
shopt -s checkwinsize
export TERM=putty

/usr/bin/keychain --nogui ~/.ssh/id_dsa
host=`uname -n`
[ -f $HOME/.keychain/$host-sh ] && \
        . $HOME/.keychain/$host-sh
[ -f $HOME/.keychain/$host-sh-gpg ] && \
        . $HOME/.keychain/$host-sh-gpg

#source ~/.ssh-agent > /dev/null

unset USERNAME
echo;fortune;echo

