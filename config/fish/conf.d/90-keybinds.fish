function push-line
    set -g __fish_pushed_line (commandline)
    commandline ""
    function on-next-prompt --on-event fish_postexec
        commandline $__fish_pushed_line
        functions --erase on-next-prompt
    end
end

function execute-and-restore
    set -g __fish_pushed_line (commandline)
    set -g __fish_cursor_pos (commandline -C)
    commandline -f execute
    function on-next-prompt --on-event fish_postexec
        commandline $__fish_pushed_line
        commandline -C $__fish_cursor_pos
        functions --erase on-next-prompt
    end
end

bind \ea execute-and-restore
bind \cq push-line
bind \es 'git status; commandline -f repaint'

