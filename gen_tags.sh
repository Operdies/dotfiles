[ -d ~/.cache/ctags ] || (echo "Creating ctags cache dir.." && mkdir -p ~/.cache/ctags)
[ -f ~/.cache/ctags/tags ] || (echo "Generating ctags..." && fd -e h . /usr/include | ctags -f ~/.cache/ctags/tags -L - --kinds-C=+p --fields=+aS --extras=+q --sort=foldcase)

