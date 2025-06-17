#!/bin/sh
docker run -p 8080:9999 game-server ./project.x86_64 --server --headless --code code --match-id mid
