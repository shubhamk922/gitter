# Gitter CLI Tool (Go Language)

Build your own Git-like command line tool that mimics core Git functionality using Go language.

## Objective

Create a CLI tool with behavior similar to Git, supporting commands like `init`, `add`, `commit`, `status`, etc. The goal is to understand the internal workings of Git and build a minimal yet extensible version of it.


## Supported Commands

| Command                  | Description                                                                 |
|--------------------------|-----------------------------------------------------------------------------|
| `gitter help`            | Lists all supported commands and their usage                                |
| `gitter init`            | Initializes a new Gitter repository (default branch: `main`)                |
| `gitter checkout branch` | Switches branches                                         |
| `gitter add <files>`     | Adds file(s) to the staging index                                           |
| `gitter status`          | Displays current working tree state (staged, unstaged, untracked)          |
| `gitter commit -m "msg"` | Commits staged files with a message                                         
| `gitter log`             | Displays commit history in reverse order                                    |
| `gitter reset`           | Moves your current branch (HEAD) to a different commit                      |


## Important Notes
- Root file for the project is the gitter file. Do not rename or modify its filename.
- While uploading your project as a zip, do not alter the folder structure. Keep everything as it is.
- Also do not remove `#!/usr/bin/env python3` line from gitter file.

**To verify your code:**

1. Add your solution to the code.  
2. Make the test script executable and run it using the following commands in order:

   1. chmod +x ./run_test.sh  
   2. ./run_test.sh  
   
3. This will execute all test cases and generate a file named gitter_test_results.txt.  
4. Refresh your File Explorer to view the newly created results file.