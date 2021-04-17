#!/bin/bash

if ! hash flux 2>/dev/null; then
  curl -s https://toolkit.fluxcd.io/install.sh | sudo bash
fi

flux check --pre