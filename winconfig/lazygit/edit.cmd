@echo off

SETLOCAL ENABLEEXTENSIONS

SET ARG1=%~1
SET ARG2=%~2


IF "%NVIM%"=="" (
  REM Not running nested, so we can just start the file normally
  nvim %*
) ELSE (
  REM # <C-q> is my mapping to hide the floating terminal hosting lazygit without closing it.
  REM Otherwise, the buffer will be opened in the floating window
  IF %ARG1:~0,1%==+ (
    nvim --server %NVIM% --remote-send "<C-q>:e %~2<CR>%ARG1:~1%gg"; 
  ) ELSE (
    nvim --server %NVIM% --remote-send "<C-q>:e %~1<CR>"
  )
)

