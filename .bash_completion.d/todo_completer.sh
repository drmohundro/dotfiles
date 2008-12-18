# todo.sh completion by Pedro Melo <melo@simplicidade.org>
# 
# for updates see: http://todotxt.com/library/todo_completer.sh/

# Modified by Gina Trapani 7/20/2006
# - added new options (fqv) and command listall in todo.sh 1.7
# - removed @ symbols (threw an error)
# Modified by Gina Trapani 7/29/2006
# - added new command options, listall/ls/lsa/a/p/app/prep/lsp

seq_replacement()
{ 
    local lower upper output;
    lower=$1 upper=$2;
    while [ $lower -le $upper ];
    do
        output="$output $lower";
        lower=$[ $lower + 1 ];
    done;
    echo $output
}

_todo_sh()
{
  local cur prev commands options command expand_options

  long_commands='add append archive del do list listpri listall \
            prepend pri replace remdup report'
  short_commands='a app ls lsp lsa  prep p'
  options="-d -f -p -h -v -V"

  if [ -n "$TODOSH_DONT_COMPLETE_SHORT_COMMANDS" ] ; then
    commands=$long_commands
  else
    commands="$long_commands $short_commands"
  fi

  if [ -n "$TODOSH_OTHER_COMMANDS" ] ; then
    commands="$commands $TODOSH_OTHER_COMMANDS"
  fi

  TODOSHRC=${TODOSHRC:-${HOME}/.todo}
  if [[ -r $TODOSHRC ]] ; then
    . $TODOSHRC
  fi

  if [[ ! -r $TODO_FILE ]] ; then
    echo "ERROR: cannot read todo.txt file."
    echo "Make sure TODOSHRC is set with the correct .todo config file";
    return 0
  fi

  expand_options=1
  command=""
  up_to=$(($COMP_CWORD-1))
  for i in `seq_replacement 1 $up_to` ; do
    cur=${COMP_WORDS[i]}
    if [[ "${cur}" != -* ]] ; then
      expand_options=0
      if [[ -z "${command}" ]] ; then
        command=${cur}
      fi
    fi
  done

  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}

  if [[ ${expand_options} == 1 && ${cur} == -* ]] ; then
     COMPREPLY=( $( compgen -W "$options" -- $cur ) )
  elif [[ -z "${command}" ]] ; then
      COMPREPLY=( $( compgen -W "$commands" -- $cur ) )
  else
    case "${command}" in
      add|a|list|ls|listall|lsa)
        local contexts=$(perl -ne 'END { print "$_\n" foreach sort { $p{$a} <=> $p{$b} } keys %p; } $p{$_}++ foreach /\B(\@\w+)/g' $TODO_FILE)
        local projects=$(perl -ne 'END { print "$_\n" foreach sort { $p{$a} <=> $p{$b} } keys %p; } $p{$_}++ foreach /\b(p-\w+)/g' $TODO_FILE)
        local projects_plus=$(perl -ne 'END { print "$_\n" foreach sort { $p{$a} <=> $p{$b} } keys %p; } $p{$_}++ foreach /\B(\+\w+)/g' $TODO_FILE)
        COMPREPLY=( $(compgen -W "${projects} ${projects_plus} ${contexts}" -- ${cur}) )
        return 0
        ;;

     append|app|del|rm|do|prepend|prep|pri|p|replace)
        local n_todos=$(wc -l $TODO_FILE | awk '{print $1}')
        local tasks=$(seq_replacement 1 $n_todos)
        COMPREPLY=( $(compgen -W "${tasks}" -- ${cur}) )
        return 0
        ;;

      listpri | lsp)
        local pris=$(egrep -o '\(\w+\)' $TODO_FILE | cut -c2 | sort | uniq -c | sort -rn | awk '{ print $2 }')
        COMPREPLY=( $(compgen -W "${pris}" -- ${cur}) )
        return 0
        ;;

      *)
        ;;
    esac
  fi

  return 0
}

complete -F _todo_sh -o default todo.sh 
