#!/usr/bin/env bash

if [[ -f ".env" ]]; then
    source .env
fi

julia --project=. src/main.jl