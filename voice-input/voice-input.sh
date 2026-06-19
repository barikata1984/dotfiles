#!/bin/bash
exec pixi run --manifest-path "$(dirname "$(readlink -f "$0")")/pixi.toml" start
