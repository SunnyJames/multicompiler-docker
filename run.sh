#!/usr/bin/env bash

docker run --name multicompiler-container -it -v $(pwd)/workspace:/workspace multicompiler
