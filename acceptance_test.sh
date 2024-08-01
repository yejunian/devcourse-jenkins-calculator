#!/bin/bash

test $(curl localhost:8765/sum?a=2\&b=3) -eq 5
