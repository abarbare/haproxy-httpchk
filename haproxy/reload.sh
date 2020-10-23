#!/bin/bash

while true; do
    date && kill -USR2 $(pidof haproxy) && echo "reload" && sleep 2;
done