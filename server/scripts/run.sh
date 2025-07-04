#!/bin/sh
docker run -p 9999:9999 game-server ./project.x86_64 --server --headless --code default --match-id mid
