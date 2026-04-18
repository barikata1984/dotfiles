# >>> Load cuda >>>
export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH="/usr/local/cuda-12.6/lib64${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}}"
export LD_LIBRARY_PATH="/usr/local/cuda-11.8/lib64:${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}}"
export LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}}"
export LIBRARY_PATH="/usr/local/cuda/lib64/stubs:$LIBRARY_PATH"
# <<< Load cuda <<<

# >>> Set window manager according to os >>>
if [[ "$kernel_version" == *"microsoft"* ]] && [[ "$kernel_version" == *"wsl"* ]]; then
  on_microsoft_wsl="true"
else
  on_microsoft_wsl="false"
fi

if $on_microsoft_wsl; then
    export XDG_SESSION_TYPE=x11
fi
# <<< Set window manager according to os <<<

# S2_API_KEY is now injected by ~/.claude/mcp/academic-search/start.sh
# into the MCP server process only (not the shell environment).
