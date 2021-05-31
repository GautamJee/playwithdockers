#!/bin/bash
service ssh start
service xrdp start
exec "$@"
