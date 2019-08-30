#!/bin/bash

helm delete --purge chartmuseum
helm repo remove chartmuseum
helm plugin remove push