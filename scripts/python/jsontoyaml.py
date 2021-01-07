#!/usr/bin/env python

# jsonenv reads a json object as input and produces
# escaped shell commands for setting environment vars

import json
import pipes
import sys
import re

env = []

def create_env(key, value):
  k = json_key_to_env(key)
  return f'{k}: "{value}"'


def json_key_to_env(key):
  split = re.findall('[a-zA-Z][^A-Z]*', key)
  joined = "_".join(split)
  upper = joined.upper()
  return upper
  

for key1, value1 in json.load(sys.stdin).items():
  if isinstance(value1, str):
    env.append(create_env(key1, value1))
  else:  
    for key2, value2 in value1.items():
      if isinstance(value2, str):
        combined = "".join([
          key1.capitalize(), 
          key2.capitalize()
        ])
        env.append(create_env(combined, value2))
      else:  
        for key3, value3 in value2.items():
          combined = "".join([
            key1.capitalize(), 
            key2.capitalize(), 
            key3.capitalize()
          ])
          env.append(create_env(combined, value3))

          
print("env:")
for item in env:
  print("  "+item)