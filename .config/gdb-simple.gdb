# simple 'cycle' script that prints backtrace on SIGSEGV and quits
# also cares about your SIGINT and quits instantly
#
# produces 'gdb-sigsegv.txt' / 'gdb.sigint.txt' in PWD
#
# don't forget to if you haven't already:
#   echo 'set startup-quietly on' >> "${HOME}/.gdbearlyinit"
#
# EXAMPLE: $ gdb -x "THIS_SCRIPT_PATH" --args ./my-program arg1 arg2
set debuginfod enabled off

set confirm off
set pagination off

set backtrace past-main on

set print pretty on

# set verbose on

# quit on normal 'exit_group'
# catch syscall 231
# catch signal SIGCHLD
# commands
#     quit
# end

# print backtrace on SIGINT
catch signal SIGINT
commands
    echo Saving full bt to gdb-sigint.txt\n
    set logging enabled off
    set logging redirect on
    set logging overwrite on
    set logging file gdb-sigint.txt
    set logging enabled on
    bt full
    quit
end

# print backtrace on SIGSEGV
catch signal SIGSEGV
commands
    echo [GDB] Caught signal SIGSEGV, Segmentation fault!\n
    bt

    set logging enabled off
    set logging redirect on
    set logging overwrite on
    set logging file gdb-sigsev.txt
    set logging enabled on
    echo ...BACKTRACE\n
    bt
    echo \n
    echo ...FULL-BACKTRACE\n
    bt full
    echo \n
    echo ...LOCALS\n
    info locals

    quit
end


# use: raise(SIGTRAP);

init-if-undefined $_exitcode = -1

run
if ($_exitcode != -1)
  quit
end
