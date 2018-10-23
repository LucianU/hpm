# hpm
Project that aims to mimic npm. That is, the goal is to add dependencies to the
cabal file from the command line. This avoids errors done while editing the file
directly. It also makes the process of adding a dependency less tedious.

## Install
To use this application, first make sure you have installed `stack`. Then, clone this repo, enter its root directory in the terminal and run:

    stack install hpm


## Usage
There is only one available command: `add`. To add a new dependency, run:

    hpm add <dep_name>

The command is idempotent. That means it won't add a dependency, if it already exists.