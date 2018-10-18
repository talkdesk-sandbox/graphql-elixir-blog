#!/bin/bash
wait-for-it $PGHOST:$PGPORT

mix do ecto.migrate, phx.server
