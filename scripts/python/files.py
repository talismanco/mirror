import os


def get(filepath: str):
    """
    Read and return the contets of a give file path.
    """
    with open(filepath) as f:
        return f.read()


def write(filepath: str, content: str):
    """
    Read and write the contets of a give file path.
    """
    with open(filepath, "a") as file:
        file.write(content)
