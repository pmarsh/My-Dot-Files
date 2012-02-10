# .bashrc

# User specific aliases and functions

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi
set -o vi


# Enable options:
shopt -s cdspell
shopt -s cdable_vars
shopt -s checkhash
shopt -s checkwinsize
shopt -s sourcepath
shopt -s no_empty_cmd_completion
shopt -s cmdhist
shopt -s histappend histreedit histverify
shopt -s extglob 

alias edit_conflicts="${EDITOR:-vim} \$(svn status|awk '/^C/{print \$2}')"
alias edit_code="${EDITOR:-vim} \$(svn st | awk '/^[AM].*p[ml]/{print \$2}')"
alias edit_tests="${EDITOR:-vim} \$(svn st | awk '/^[AM].*\.t$/{print \$2}')"
alias uxterm="uxterm -fa 'Inconsolata-10' -bg black"

export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTTIMEFORMAT="%H:%M > "
export HISTIGNORE="&:bg:fg:ll:h"
export HOSTFILE=$HOME/.hosts

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

alias h='history'
alias j='jobs -l'
alias which='type -a'
alias ..='cd ..'
alias path='echo -e ${PATH//:/\\n}'

alias du='du -kh'       # Makes a more readable output.
alias df='df -kTh'

alias ll="ls -l --group-directories-first"
alias ls='ls -hF --color'  # add colors for filetype recognition
alias la='ls -Al'          # show hidden files
alias lx='ls -lXB'         # sort by extension
alias lk='ls -lSr'         # sort by size, biggest last
alias lc='ls -ltcr'        # sort by and show change time, most recent last
alias lu='ls -ltur'        # sort by and show access time, most recent last
alias lt='ls -ltr'         # sort by date, most recent last
alias lm='ls -al |more'    # pipe through 'more'
alias lr='ls -lR'          # recursive ls
alias tree='tree -Csu'     # nice alternative to 'recursive ls'

alias more='less'
export PAGER=less
export LESSCHARSET='latin1'
export LESSOPEN='|/usr/bin/lesspipe.sh %s 2>&-'
# Use this if lesspipe.sh exists
export LESS='-i -N -w  -z-4 -g -e -M -X -F -R -P%t?f%f \
:stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'

# Find a file with a pattern in name:
function ff() { find . -type f -iname '*'$*'*' -ls ; }

# Find a file with pattern $1 in name and Execute $2 on it:
function fe() { find . -type f -iname '*'${1:-}'*' -exec ${2:-file} {} \;  ; }

function fstr()
{
  OPTIND=1
  local case=""
  local usage="fstr: find string in files.
  Usage: fstr [-i] \"pattern\" [\"filename pattern\"] "
  while getopts :it opt
  do
    case "$opt" in
      i) case="-i " ;;
      *) echo "$usage"; return;;
    esac
  done
  shift $(( $OPTIND - 1 ))
  if [ "$#" -lt 1 ]; then
    echo "$usage"
    return;
  fi
  find . -type f -name "${2:-*}" -print0 | \
  xargs -0 egrep --color=always -sn ${case} "$1" 2>&- | more 
}


function lowercase()  # move filenames to lowercase
{
  for file ; do
    filename=${file##*/}
    case "$filename" in
      */*) dirname==${file%/*} ;;
      *) dirname=.;;
    esac
    nf=$(echo $filename | tr A-Z a-z)
    newname="${dirname}/${nf}"
    if [ "$nf" != "$filename" ]; then
      mv "$file" "$newname"
      echo "lowercase: $file --> $newname"
    else
      echo "lowercase: $file not changed."
    fi
  done
}


function swap()  # Swap 2 filenames around, if they exist
{                #(from Uzi's bashrc).
  local TMPFILE=tmp.$$ 

  [ $# -ne 2 ] && echo "swap: 2 arguments needed" && return 1
  [ ! -e $1 ] && echo "swap: $1 does not exist" && return 1
  [ ! -e $2 ] && echo "swap: $2 does not exist" && return 1

  mv "$1" $TMPFILE 
  mv "$2" "$1"
  mv $TMPFILE "$2"
}

function extract()      # Handy Extract Program.
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xvjf $1     ;;
      *.tar.gz)    tar xvzf $1     ;;
      *.bz2)       bunzip2 $1      ;;
      *.rar)       unrar x $1      ;;
      *.gz)        gunzip $1       ;;
      *.tar)       tar xvf $1      ;;
      *.tbz2)      tar xvjf $1     ;;
      *.tgz)       tar xvzf $1     ;;
      *.zip)       unzip $1        ;;
      *.Z)         uncompress $1   ;;
      *.7z)        7z x $1         ;;
      *)           echo "'$1' cannot be extracted via >extract<" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}



function parse_git_branch {
git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}
#PS1="\[\033[1;36m\][\[\033[1;32m\]\u\[\033[0;32m\]@\[\033[0;31m\]\h\[\033[0;37m\]:\W\[\033[1;36m\]]\033[1:31m\]\$(parse_git_branch)\033[1;36m$ \[\033[1;37m\]"
PS1="[\[\033[32m\]\w]\[\033[0m\]\n\[\033[1;36m\]\u@\h\[\033[1;33m\] \$(parse_git_branch) -> \[\033[0m\]"


function to () {
if test "$2"; then
  cd "$(apparix "$1" "$2" || echo .)";
else
  cd "$(apparix "$1" || echo .)";
fi
pwd
}
function bm () {
if test "$2"; then
  apparix --add-mark "$1" "$2";
elif test "$1"; then
  apparix --add-mark "$1";
else
  apparix --add-mark;
fi
}
function portal () {
if test "$1"; then
  apparix --add-portal "$1";
else
  apparix --add-portal;
fi
}
# function to generate list of completions from .apparixrc
function _apparix_aliases ()
{   cur=$2
  dir=$3
  COMPREPLY=()
  if [ "$1" == "$3" ]
  then
    COMPREPLY=( $( cat $HOME/.apparix{rc,expand} | \
    grep "j,.*$cur.*," | cut -f2 -d, ) )
  else
    dir=`apparix -favour rOl $dir 2>/dev/null` || return 0
    eval_compreply="COMPREPLY=( $(
    cd "$dir"
    \ls -d *$cur* | while read r
  do
    [[ -d "$r" ]] &&
    [[ $r == *$cur* ]] &&
    echo \"${r// /\\ }\"
  done
  ) )"
  eval $eval_compreply
fi
return 0
}
# command to register the above to expand when the 'to' command's args are
# being expanded
complete -F _apparix_aliases to
complete -A hostname   rsh rcp telnet rlogin r ftp ping disk
complete -A export     printenv
complete -A variable   export local readonly unset
complete -A enabled    builtin
complete -A alias      alias unalias
complete -A function   function
complete -A user       su mail finger

complete -A helptopic  help     # Currently, same as builtins.
complete -A shopt      shopt
complete -A stopped -P '%' bg
complete -A job -P '%'     fg jobs disown

complete -A directory  mkdir rmdir
complete -A directory   -o default cd
complete -f -o default -X '!*.+(zip|ZIP|z|Z|gz|GZ|bz2|BZ2)' extract

if [[ -s /home/pmarsh/.rvm/scripts/rvm ]] ; then source /home/pmarsh/.rvm/scripts/rvm ; fi
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
