import json
import re

_env = []


"""
Reads a stringified json object as input and produces
escaped shell commands for setting environment variables.
"""


def json2env(jsonstr: str, _key="", _nested=False):
    """
    Local increment counter
    """
    incr = 0

    """
    Create a valid json object from the given string.
    """
    val = json.loads(jsonstr)

    for k, v in val.items():
        """
        Always transform the incoming key to upperace.
        """
        k = k.upper()

        """
        Increment the local counter by 1 to keep track of stage
        of traversal.
        """
        incr = incr + 1

        if isinstance(v, dict):
            """
            If the current value in the iteration is a nested
            object, append the current key with a trailing underscore
            and call `json2env` recursively.
            """
            key = f'{_key}{k}_'
            json2env(json.dumps(v), key, True)

        else:
            """
            If the value is not a json object, create the environment
            variable entry, and print.
            """
            env = f'{_key}{k}={v}'

            """
            Add the current entry to the global `_env` array, we'll deconstruct
            this array via the final recursive complete check below.
            """
            _env.append(env)

        if _nested == False and incr == len(val.items()):
            """
            Because this is a synchronous call stack, we can check that
            are finished wih the iteration by using the `_nested` flag. If we
            aren't iterating over a nested object, and we're at the last
            position of the initial iteration, return the environment variable
            entries separated by newlines.
            """
            return "\n".join(_env)


"""
Reads the contents of a `.tool-versions` file and produces
escaped shell commands for setting environment variables.


Read more about the `.tool-versions` spec here:
https://asdf-vm.com/#/core-configuration?id=tool-versions
"""


def toolversions2env(tvstr: str):
    tvstr = re.sub(r'-', "_", tvstr)
    tvstr = re.sub(r' ', "_VERSION=", tvstr)
    tvstr = tvstr.upper()
    return tvstr
