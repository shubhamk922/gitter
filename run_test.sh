#!/bin/bash

# ==============================================================================
#                      GITTER COMMAND LINE INTERFACE TESTING SUITE
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. GLOBAL CONFIGURATION
# ------------------------------------------------------------------------------
RESULTS_FILE="gitter_test_results.txt"
GITTER_COMMAND="gitter"
TOTAL_TESTS=11  
TEMP_DIR="test_workspace"

# Clean up previous results file and temporary directory
rm -f "$RESULTS_FILE"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# ------------------------------------------------------------------------------
# 2. HELPER FUNCTIONS
# ------------------------------------------------------------------------------



# Function to write a separator and test name to the results file
function start_test() {
    local test_number=$1
    local test_name=$2
    echo -e "\n======================================================" >> "$RESULTS_FILE"
    echo "--- $test_number: $test_name ---" >> "$RESULTS_FILE"
    echo "======================================================" >> "$RESULTS_FILE"
}

# Function to log individual check result
function log_check() {
    local check_desc=$1
    local result=$2 # SUCCESS or FAILURE
    echo "Check: $check_desc -> $result" >> "$RESULTS_FILE"
}

# Function to write the test final status
function log_final_status() {
    local test_number=$1
    local test_name=$2
    local final_status=$3 # OVERALL PASS or OVERALL FAIL
    
    echo "" >> "$RESULTS_FILE"
    echo "Test Result Summary ($test_number): $final_status" >> "$RESULTS_FILE"
}

# ------------------------------------------------------------------------------
# Test 1: gitter help (List All Common Commands)
# ------------------------------------------------------------------------------

function test_1_list_commands() {
    local test_number="Test 1"
    local test_name="List All Common Commands ('gitter help')"
    start_test "$test_number" "$test_name"
    
    local TEST_CMD="$GITTER_COMMAND help"
    local EXPECTED_COMMANDS=(
        "init Create an empty Gitter repository"
        "add Add file contents to the index"
        "status Show the working tree status"
    )
    local OVERALL_STATUS="OVERALL PASS"

    echo "Executing: $TEST_CMD" >> "$RESULTS_FILE"

    local ACTUAL_OUTPUT=$($TEST_CMD 2>&1)
    local NORMALIZED_OUTPUT=$(echo "$ACTUAL_OUTPUT" | grep -v "These are common Gitter commands:" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/[[:space:]][[:space:]]*/ /g')
    
    for expected_line in "${EXPECTED_COMMANDS[@]}"; do
        local check_desc="Command line found (Expected: '$expected_line')"
        if echo "$NORMALIZED_OUTPUT" | grep -F -q "$expected_line"; then
            log_check "$check_desc" "PASS"
        else
            log_check "$check_desc" "FAIL"
            OVERALL_STATUS="OVERALL FAIL"
        fi
    done

    log_final_status "$test_number" "$test_name" "$OVERALL_STATUS"
}

# ------------------------------------------------------------------------------
# Test 2: gitter help init (Detailed Help Sections)
# ------------------------------------------------------------------------------

function test_2_help_init_sections() {
    local test_number="Test 2"
    local test_name="Detailed Help Sections ('gitter help init')"
    start_test "$test_number" "$test_name"
    
    local TEST_CMD="$GITTER_COMMAND help init"
    local MANDATORY_SECTIONS=(
        "NAME:"
        "SYNOPSIS:"
        "DESCRIPTION:"
    )
    local OVERALL_STATUS="OVERALL PASS"

    echo "Executing: $TEST_CMD" >> "$RESULTS_FILE"

    local ACTUAL_OUTPUT=$($TEST_CMD 2>&1)
     for mandatory_section in "${MANDATORY_SECTIONS[@]}"; do
        local check_desc="Section found (Expected: '$mandatory_section')"
        if echo "$ACTUAL_OUTPUT" | grep -E -q "^[[:space:]]*$mandatory_section"; then
            log_check "$check_desc" "PASS"
        else
            log_check "$check_desc" "FAIL"
            OVERALL_STATUS="OVERALL FAIL"
        fi
    done
    
    log_final_status "$test_number" "$test_name" "$OVERALL_STATUS"
}

# ------------------------------------------------------------------------------
# Test 3: gitter init (First Time Initialization)
# ------------------------------------------------------------------------------

function test_3_gitter_init_success() {
    local test_number="Test 3"
    local test_name="gitter init (First time initialization)"
    start_test "$test_number" "$test_name"
    
    local TEST_CMD="$GITTER_COMMAND init"
    local TEST_DIR="t3"
    local REPO_DIR=".gitter"
    
    # Pattern is generalized to prevent failure due to path variation
    local EXPECTED_OUTPUT_PATTERN="Initialized empty Gitter repository in .*" 
    local OVERALL_STATUS="OVERALL PASS"

    # Setup: Create and move into a fresh workspace
    mkdir -p "$TEMP_DIR/$TEST_DIR"
    # Use pushd to change directory safely
    pushd "$TEMP_DIR/$TEST_DIR" > /dev/null

    # Log the execution command
    echo "Executing: $TEST_CMD in $(pwd)" >> "../../$RESULTS_FILE"

    # 1. Execute the command
    local ACTUAL_OUTPUT=$($TEST_CMD 2>&1)
    local ACTUAL_EXIT_CODE=$?
    
    # ---------------------------------
    # --- Check 1: Exit Code ---
    # ---------------------------------
    local EXPECTED_EXIT_CODE=0
    local check_desc="Exit Code (Expected: $EXPECTED_EXIT_CODE, Actual: $ACTUAL_EXIT_CODE)"
    if [ "$ACTUAL_EXIT_CODE" -eq "$EXPECTED_EXIT_CODE" ]; then
        log_check "$check_desc" "PASS" # Log PASS
    else
        log_check "$check_desc" "FAIL"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # ---------------------------------
    # --- Check 2: Repository Directory Creation ---
    # ---------------------------------
    local ACTUAL_DIR_STATUS="NOT found"
    if [ -d "$REPO_DIR" ]; then
        ACTUAL_DIR_STATUS="exists"
    fi
    local check_desc="Directory creation (Expected: '$REPO_DIR' exists, Actual: $ACTUAL_DIR_STATUS)"
    if [ "$ACTUAL_DIR_STATUS" = "exists" ]; then
        log_check "$check_desc" "PASS" # Log PASS
        else
            log_check "$check_desc" "FAIL"
            OVERALL_STATUS="OVERALL FAIL"
        fi

    # ---------------------------------
    # --- Check 3: Output Message ---
    # ---------------------------------
    if echo "$ACTUAL_OUTPUT" | grep -E -q "$EXPECTED_OUTPUT_PATTERN"; then
        # PASS: Log Expected and Actual (matched)
        log_check "Output message (Expected pattern match, Actual: matched)" "PASS"
    else
        # FAIL: Log Expected Pattern and Actual Output for debugging
        echo "Check: Output message (Expected pattern: '$EXPECTED_OUTPUT_PATTERN')" "-> FAIL" >> "../../$RESULTS_FILE"
        echo -e "         Actual Output was:\n$(echo "$ACTUAL_OUTPUT" | sed 's/^/         | /')" >> "../../$RESULTS_FILE"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # Cleanup: Move back using popd
    popd > /dev/null
    
    log_final_status "$test_number" "$test_name" "$OVERALL_STATUS"
}

# ------------------------------------------------------------------------------
# Test 4: gitter add . (Stage new files)
# ------------------------------------------------------------------------------
function test_4_gitter_add_new_files() {
    local test_number="Test 4"
    local test_name="gitter add . (Stage new files)"
    start_test "$test_number" "$test_name"
    
    local TEST_DIR="t4" 
    local ADD_CMD="$GITTER_COMMAND add ."
    local STATUS_CMD="$GITTER_COMMAND status"
    local FILENAME_1="file1.txt"
    local FILENAME_2="file2.txt"
    local OVERALL_STATUS="OVERALL PASS"
    local EXPECTED_EXIT_CODE=0
    
    # Path for logging inside the subdirectory
    local RESULTS_PATH="../../$RESULTS_FILE" 

    # Setup: Create workspace, init repo, create files
    mkdir -p "$TEMP_DIR/$TEST_DIR"
    pushd "$TEMP_DIR/$TEST_DIR" > /dev/null
    
    # 1. Init repository (Suppress output)
    $GITTER_COMMAND init > /dev/null 2>&1
    
    # 2. Create untracked files
    echo "this is a test" > "$FILENAME_1"
    echo "this is another test" > "$FILENAME_2"
    
    echo "Executing: $ADD_CMD in $(pwd)" >> "$RESULTS_PATH"

    # 3. Execute gitter add .
    local ACTUAL_ADD_OUTPUT=$($ADD_CMD 2>&1)
    local ACTUAL_ADD_EXIT_CODE=$?
    
    # --- Check 1: Add command Exit Code ---
    local check_desc="Add command Exit Code (Expected: $EXPECTED_EXIT_CODE, Actual: $ACTUAL_ADD_EXIT_CODE)"
    if [ "$ACTUAL_ADD_EXIT_CODE" -eq "$EXPECTED_EXIT_CODE" ]; then
        log_check "$check_desc" "PASS" "$RESULTS_PATH"
    else
        log_check "$check_desc" "FAIL" "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # 4. Execute gitter status
    local ACTUAL_STATUS_OUTPUT=$($STATUS_CMD 2>&1)
    
    # --- Check 2: Status Output (Should show staged files) ---
    # Expected output based on user specification: "new file:"
    local EXPECTED_HEADER="Changes to be committed:"
    local EXPECTED_FILE_1_LINE="new file: $FILENAME_1"
    local EXPECTED_FILE_2_LINE="new file: $FILENAME_2" # ⭐ NEW FILE EXPECTED

    local STATUS_CHECK_PASS=0
    
    # Check for header
    if echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$EXPECTED_HEADER"; then
        # Check for both files with 'new file:' status
        if echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$EXPECTED_FILE_1_LINE" && \
           echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$EXPECTED_FILE_2_LINE"; then
            STATUS_CHECK_PASS=1
        fi
    fi

    if [ "$STATUS_CHECK_PASS" -eq 1 ]; then
        log_check "Status Output (Expected: Header + both NEW files listed)" "PASS" "$RESULTS_PATH"
    else
        # FAIL: Log Expected lines and Actual Output
        echo "Check: Status Output (Expected to find: '$EXPECTED_HEADER', '$EXPECTED_FILE_1_LINE', and '$EXPECTED_FILE_2_LINE')" "-> FAIL" >> "$RESULTS_PATH"
        echo -e "         Actual Status Output was:\n$(echo "$ACTUAL_STATUS_OUTPUT" | sed 's/^/         | /')" >> "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # Cleanup: Move back
    popd > /dev/null
    log_final_status "$test_number" "$test_name" "$OVERALL_STATUS"
}

# ------------------------------------------------------------------------------
# Test 5: gitter add <regex> 
# ------------------------------------------------------------------------------
function test_5_gitter_add_w_regex() {
    local test_number="Test 5"
    local test_name="gitter add <regex>"
    start_test "$test_number" "$test_name"
    
    local TEST_DIR="t5" 
    local ADD_CMD="$GITTER_COMMAND add *.py"
    local STATUS_CMD="$GITTER_COMMAND status"
    local EXPECTED_STATUS_PATTERN="nothing to commit, working tree clean"
    local OVERALL_STATUS="OVERALL PASS"
    local EXPECTED_EXIT_CODE=0
    
    local RESULTS_PATH="../../$RESULTS_FILE" # Path for logging inside the subdirectory

    # Setup: Create workspace, init repo
    mkdir -p "$TEMP_DIR/$TEST_DIR"
    pushd "$TEMP_DIR/$TEST_DIR" > /dev/null
    
    # 1. Init repository (Suppress output)
    $GITTER_COMMAND init > /dev/null 2>&1
    
    echo "Executing: $ADD_CMD in $(pwd)" >> "$RESULTS_PATH"

    # 2. Execute gitter add *.py (Expected: Exit 0, No output)
    local ACTUAL_ADD_OUTPUT=$($ADD_CMD 2>&1)
    local ACTUAL_ADD_EXIT_CODE=$?
    
    # --- Check 1: Add command Exit Code ---
    local check_desc="Add command Exit Code (Expected: $EXPECTED_EXIT_CODE, Actual: $ACTUAL_ADD_EXIT_CODE)"
    if [ "$ACTUAL_ADD_EXIT_CODE" -eq "$EXPECTED_EXIT_CODE" ]; then
        log_check "$check_desc" "PASS" "$RESULTS_PATH"
    else
        log_check "$check_desc" "FAIL" "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # 3. Execute gitter status
    local ACTUAL_STATUS_OUTPUT=$($STATUS_CMD 2>&1)
    
    # --- Check 2: Status Output (Should be 'nothing to commit, working tree clean') ---
    if echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$EXPECTED_STATUS_PATTERN"; then
        log_check "Status Output (Expected: 'nothing to commit, working tree clean')" "PASS" "$RESULTS_PATH"
    else
        # FAIL: Log Expected pattern and Actual Output
        echo "Check: Status Output (Expected pattern: '$EXPECTED_STATUS_PATTERN')" "-> FAIL" >> "$RESULTS_PATH"
        echo -e "         Actual Status Output was:\n$(echo "$ACTUAL_STATUS_OUTPUT" | sed 's/^/         | /')" >> "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # Cleanup: Move back
    popd > /dev/null
    log_final_status "$test_number" "$test_name" "$OVERALL_STATUS"
}

# ------------------------------------------------------------------------------
# Test 6: gitter status (Untracked file)
# ------------------------------------------------------------------------------
function test_6_gitter_status_untracked() {
    local test_number="Test 6"
    local test_name="gitter status (Untracked file)"
    start_test "$test_number" "$test_name"
    
    local TEST_DIR="t6" 
    local STATUS_CMD="$GITTER_COMMAND status"
    local FILENAME="file1.txt"
    
    # Expected status output lines
    local EXPECTED_HEADER="Untracked files:"
    local EXPECTED_FILE_LINE="$FILENAME" # The file name should appear after the header
    
    local OVERALL_STATUS="OVERALL PASS"
    local EXPECTED_EXIT_CODE=0
    local RESULTS_PATH="../../$RESULTS_FILE" # Path for logging inside the subdirectory

    # Setup: Create workspace, init repo, create file
    mkdir -p "$TEMP_DIR/$TEST_DIR"
    pushd "$TEMP_DIR/$TEST_DIR" > /dev/null
    
    # 1. Init repository (Suppress output)
    $GITTER_COMMAND init > /dev/null 2>&1
    
    # 2. Create the untracked file
    echo "this is a test" > "$FILENAME"
    
    echo "Executing: $STATUS_CMD in $(pwd)" >> "$RESULTS_PATH"

    # 3. Execute gitter status
    local ACTUAL_STATUS_OUTPUT=$($STATUS_CMD 2>&1)
    local ACTUAL_STATUS_EXIT_CODE=$?
    
    # --- Check 1: Status command Exit Code ---
    local check_desc="Status command Exit Code (Expected: $EXPECTED_EXIT_CODE, Actual: $ACTUAL_STATUS_EXIT_CODE)"
    if [ "$ACTUAL_STATUS_EXIT_CODE" -eq "$EXPECTED_EXIT_CODE" ]; then
        log_check "$check_desc" "PASS" "$RESULTS_PATH"
    else
        log_check "$check_desc" "FAIL" "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # --- Check 2: Status Output (Should show Untracked files) ---
    local STATUS_CHECK_PASS=0
    
    # Check for header and the file name in the output
    if echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$EXPECTED_HEADER"; then
        # Check for the file name appearing after the header (simple grep check)
        if echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$EXPECTED_FILE_LINE"; then
            STATUS_CHECK_PASS=1
        fi
    fi

    if [ "$STATUS_CHECK_PASS" -eq 1 ]; then
        log_check "Status Output (Expected: '$EXPECTED_HEADER' + '$EXPECTED_FILE_LINE' listed)" "PASS" "$RESULTS_PATH"
    else
        # FAIL: Log Expected lines and Actual Output
        echo "Check: Status Output (Expected to find: '$EXPECTED_HEADER' and '$EXPECTED_FILE_LINE')" "-> FAIL" >> "$RESULTS_PATH"
        echo -e "         Actual Status Output was:\n$(echo "$ACTUAL_STATUS_OUTPUT" | sed 's/^/         | /')" >> "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # Cleanup: Move back
    popd > /dev/null
    log_final_status "$test_number" "$test_name" "$OVERALL_STATUS"
}

# ------------------------------------------------------------------------------
# Test 7: gitter commit -m (Commit a staged file)
# ------------------------------------------------------------------------------
function test_7_gitter_commit_single_file() {
    local test_number="Test 7"
    local test_name="gitter commit -m (Commit a staged file)"
    start_test "$test_number" "$test_name"
    
    local TEST_DIR="t7" 
    local COMMIT_CMD="$GITTER_COMMAND commit -m \"adds file2.md\""
    local STATUS_CMD="$GITTER_COMMAND status"
    local FILENAME_1="file1.txt" # Untracked file
    local FILENAME_2="file2.md"  # Staged/Committed file
    
    # Expected status output AFTER COMMIT: only the untracked file remains
    local EXPECTED_HEADER="Untracked files:"
    local EXPECTED_UNTRACKED_FILE="$FILENAME_1"
    local UNWANTED_STAGED_STATUS="Changes to be committed:" # This header should NOT exist
    
    local OVERALL_STATUS="OVERALL PASS"
    local EXPECTED_EXIT_CODE=0
    local RESULTS_PATH="../../$RESULTS_FILE" 

    # Setup: Create workspace, init repo, create files, stage file2.md
    mkdir -p "$TEMP_DIR/$TEST_DIR"
    pushd "$TEMP_DIR/$TEST_DIR" > /dev/null
    
    # 1. Init repository (Suppress output)
    $GITTER_COMMAND init > /dev/null 2>&1
    
    # 2. Create files
    echo "this is another test" > "$FILENAME_1"
    echo "this is another test" > "$FILENAME_2"
    
    # 3. Stage file2.md only
    $GITTER_COMMAND add "$FILENAME_2" > /dev/null 2>&1
    
    echo "Executing: $COMMIT_CMD in $(pwd)" >> "$RESULTS_PATH"

    # 4. Execute gitter commit -m
    local ACTUAL_COMMIT_OUTPUT=$($COMMIT_CMD 2>&1)
    local ACTUAL_COMMIT_EXIT_CODE=$?
    
    # --- Check 1: Commit command Exit Code ---
    local check_desc="Commit command Exit Code (Expected: $EXPECTED_EXIT_CODE, Actual: $ACTUAL_COMMIT_EXIT_CODE)"
    if [ "$ACTUAL_COMMIT_EXIT_CODE" -eq "$EXPECTED_EXIT_CODE" ]; then
        log_check "$check_desc" "PASS" "$RESULTS_PATH"
    else
        log_check "$check_desc" "FAIL" "$RESULTS_PATH"
        echo "Check: Actual Commit Output was: $ACTUAL_COMMIT_OUTPUT" >> "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # 5. Execute gitter status after commit
    local ACTUAL_STATUS_OUTPUT=$($STATUS_CMD 2>&1)
    
    # --- Check 2: Status Output (Should only show file1.txt as untracked) ---
    local STATUS_CHECK_PASS=0
    
    # A. Check for Untracked Header
    if echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$EXPECTED_HEADER"; then
        
        # B. Check that ONLY the untracked file (file1.txt) is listed
        # We check if file1.txt is present, and file2.md is NOT present, and staged changes header is NOT present.
        if echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$EXPECTED_UNTRACKED_FILE" && \
           ! echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$FILENAME_2" && \
           ! echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$UNWANTED_STAGED_STATUS"; then
            STATUS_CHECK_PASS=1
        fi
    fi

    if [ "$STATUS_CHECK_PASS" -eq 1 ]; then
        log_check "Status Output (Expected: Only '$FILENAME_1' untracked)" "PASS" "$RESULTS_PATH"
    else
        # FAIL: Log Expected condition and Actual Output
        local EXPECTED_COND="Untracked files: '$FILENAME_1' present, NO staged changes, '$FILENAME_2' absent"
        echo "Check: Status Output (Expected condition: $EXPECTED_COND)" "-> FAIL" >> "$RESULTS_PATH"
        echo -e "         Actual Status Output was:\n$(echo "$ACTUAL_STATUS_OUTPUT" | sed 's/^/         | /')" >> "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # Cleanup: Move back
    popd > /dev/null
    log_final_status "$test_number" "$test_name" "$OVERALL_STATUS"
}

# ------------------------------------------------------------------------------
# Test 8: gitter commit -am (Untracked files should be ignored)
# ------------------------------------------------------------------------------
function test_8_gitter_commit_am_untracked() {
    local test_number="Test 8"
    local test_name="gitter commit -am (Untracked files ignored)"
    start_test "$test_number" "$test_name"
    
    local TEST_DIR="t8" 
    local COMMIT_CMD="$GITTER_COMMAND commit -am \"adds some new files\""
    local STATUS_CMD="$GITTER_COMMAND status"
    local FILENAME_1="file1.txt"
    local FILENAME_2="file2.md"
    
    # Expected status output: both files must remain untracked (no change)
    local EXPECTED_HEADER="Untracked files:"
    local UNWANTED_STAGED_STATUS="Changes to be committed:" # This should NOT appear
    
    local OVERALL_STATUS="OVERALL PASS"
    # Note: If no files are tracked, 'git commit -a' often fails (exit 1) 
    # or results in "nothing to commit". We'll check exit code 0 first.
    local EXPECTED_EXIT_CODE=0 
    local RESULTS_PATH="../../$RESULTS_FILE" 

    # Setup: Create workspace, init repo, create files
    mkdir -p "$TEMP_DIR/$TEST_DIR"
    pushd "$TEMP_DIR/$TEST_DIR" > /dev/null
    
    # 1. Init repository (Suppress output)
    $GITTER_COMMAND init > /dev/null 2>&1
    
    # 2. Create untracked files
    echo "this is another test" > "$FILENAME_1"
    echo "this is another test" > "$FILENAME_2"
    
    # 3. Initial status check (Expected: Untracked files) - Optional but good for debug
    
    echo "Executing: $COMMIT_CMD in $(pwd)" >> "$RESULTS_PATH"

    # 4. Execute gitter commit -am
    local ACTUAL_COMMIT_OUTPUT=$($COMMIT_CMD 2>&1)
    local ACTUAL_COMMIT_EXIT_CODE=$?
    
    # --- Check 1: Commit command Exit Code ---
    # We expect a success code (0) if it simply prints 'nothing to commit' or similar
    local check_desc="Commit command Exit Code (Expected: $EXPECTED_EXIT_CODE, Actual: $ACTUAL_COMMIT_EXIT_CODE)"
    if [ "$ACTUAL_COMMIT_EXIT_CODE" -eq "$EXPECTED_EXIT_CODE" ]; then
        log_check "$check_desc" "PASS" "$RESULTS_PATH"
    else
        log_check "$check_desc" "FAIL" "$RESULTS_PATH"
        echo "Check: Actual Commit Output was: $ACTUAL_COMMIT_OUTPUT" >> "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # 5. Execute gitter status after commit
    local ACTUAL_STATUS_OUTPUT=$($STATUS_CMD 2>&1)
    
    # --- Check 2: Status Output (Should show both files as Untracked and no staged changes) ---
    local STATUS_CHECK_PASS=0
    
    # Check if Untracked Header and both files are present, AND staged changes header is NOT present.
    if echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$EXPECTED_HEADER"; then
        if echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$FILENAME_1" && \
           echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$FILENAME_2" && \
           ! echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$UNWANTED_STAGED_STATUS"; then
            STATUS_CHECK_PASS=1
        fi
    fi

    if [ "$STATUS_CHECK_PASS" -eq 1 ]; then
        log_check "Status Output (Expected: Both files untracked, NO staged changes)" "PASS" "$RESULTS_PATH"
    else
        # FAIL: Log Expected condition and Actual Output
        local EXPECTED_COND="Status should show both '$FILENAME_1' and '$FILENAME_2' as untracked, and no staged changes."
        echo "Check: Status Output (Expected condition: $EXPECTED_COND)" "-> FAIL" >> "$RESULTS_PATH"
        echo -e "         Actual Status Output was:\n$(echo "$ACTUAL_STATUS_OUTPUT" | sed 's/^/         | /')" >> "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # Cleanup: Move back
    popd > /dev/null
    log_final_status "$test_number" "$test_name" "$OVERALL_STATUS"
}

# ------------------------------------------------------------------------------
# Test 9: gitter log (Check commit history and no commit state)
# ------------------------------------------------------------------------------
function test_9_gitter_log_history() {
    local test_number="Test 9"
    local test_name="gitter log (Commit history check)"
    start_test "$test_number" "$test_name"
    
    local TEST_DIR="t9" 
    local LOG_CMD="$GITTER_COMMAND log"
    local COMMIT_MSG_1="adds file2.md"
    local COMMIT_MSG_2="adds all files"
    local EXPECTED_NO_COMMIT_MSG="your current branch does not have any commits yet"
    
    local EXPECTED_LOG_AUTHOR="Author: user" # Expected fixed author
    local EXPECTED_LOG_HASH_PATTERN="commit [0-9a-f]{40}" # Expected 40 char hash
    local EXPECTED_LOG_DATE_PATTERN="Date: " # Date format is variable, only checking presence of 'Date:'
    
    local OVERALL_STATUS="OVERALL PASS"
    local EXPECTED_EXIT_CODE=0
    local RESULTS_PATH="../../$RESULTS_FILE" 

    # Setup: Create workspace, init repo
    mkdir -p "$TEMP_DIR/$TEST_DIR"
    pushd "$TEMP_DIR/$TEST_DIR" > /dev/null
    
    # 1. Init repository (Suppress output)
    $GITTER_COMMAND init > /dev/null 2>&1
    
    # -----------------------------------------------------------------
    # SCENARIO A: No Commits Yet
    # -----------------------------------------------------------------
    echo "Executing: $LOG_CMD (No commits) in $(pwd)" >> "$RESULTS_PATH"

    local ACTUAL_LOG_OUTPUT_A=$($LOG_CMD 2>&1)
    
    # --- Check 1: No Commit Message ---
    if echo "$ACTUAL_LOG_OUTPUT_A" | grep -q "$EXPECTED_NO_COMMIT_MSG"; then
        log_check "Log Output A (Expected: No commit message)" "PASS" "$RESULTS_PATH"
    else
        log_check "Log Output A (Expected: '$EXPECTED_NO_COMMIT_MSG', Actual: Did not find)" "FAIL" "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
        echo -e "         Actual Output A was:\n$(echo "$ACTUAL_LOG_OUTPUT_A" | sed 's/^/         | /')" >> "$RESULTS_PATH"
    fi

    # -----------------------------------------------------------------
    # SCENARIO B: Single Commit
    # -----------------------------------------------------------------
    # Create file and commit
    echo "content 1" > file1.txt
    echo "content 2" > file2.md
    $GITTER_COMMAND add file2.md > /dev/null 2>&1
    $GITTER_COMMAND commit -m "$COMMIT_MSG_1" > /dev/null 2>&1

    echo "Executing: $LOG_CMD (Single commit) in $(pwd)" >> "$RESULTS_PATH"

    local ACTUAL_LOG_OUTPUT_B=$($LOG_CMD 2>&1)

    # --- Check 2: Single Commit Content ---
    local COMMIT_CHECK_B=0
    if echo "$ACTUAL_LOG_OUTPUT_B" | grep -E -q "$EXPECTED_LOG_HASH_PATTERN" && \
       echo "$ACTUAL_LOG_OUTPUT_B" | grep -q "$EXPECTED_LOG_AUTHOR" && \
       echo "$ACTUAL_LOG_OUTPUT_B" | grep -q "$EXPECTED_LOG_DATE_PATTERN" && \
       echo "$ACTUAL_LOG_OUTPUT_B" | grep -q "$COMMIT_MSG_1"; then
        COMMIT_CHECK_B=1
    fi
    
    if [ "$COMMIT_CHECK_B" -eq 1 ]; then
        log_check "Log Output B (Expected: Commit structure + '$COMMIT_MSG_1')" "PASS" "$RESULTS_PATH"
    else
        log_check "Log Output B (Expected structure not found or wrong message)" "FAIL" "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
        echo -e "         Actual Output B was:\n$(echo "$ACTUAL_LOG_OUTPUT_B" | sed 's/^/         | /')" >> "$RESULTS_PATH"
    fi

    # -----------------------------------------------------------------
    # SCENARIO C: Multiple Commits (Commit 2)
    # -----------------------------------------------------------------
    # Stage and commit the remaining file
    $GITTER_COMMAND add . > /dev/null 2>&1
    $GITTER_COMMAND commit -m "$COMMIT_MSG_2" > /dev/null 2>&1

    echo "Executing: $LOG_CMD (Two commits) in $(pwd)" >> "$RESULTS_PATH"

    local ACTUAL_LOG_OUTPUT_C=$($LOG_CMD 2>&1)
    
    # --- Check 3: Multiple Commits Content (Checking presence of both messages) ---
    local COMMIT_CHECK_C=0
    
    # Check if both messages are present (implies both commits are listed)
    if echo "$ACTUAL_LOG_OUTPUT_C" | grep -q "$COMMIT_MSG_1" && \
       echo "$ACTUAL_LOG_OUTPUT_C" | grep -q "$COMMIT_MSG_2"; then
        # Count the number of commit hashes (should be 2)
        local COMMIT_COUNT=$(echo "$ACTUAL_LOG_OUTPUT_C" | grep -E -c "$EXPECTED_LOG_HASH_PATTERN")
        if [ "$COMMIT_COUNT" -eq 2 ]; then
            COMMIT_CHECK_C=1
        fi
    fi

    if [ "$COMMIT_CHECK_C" -eq 1 ]; then
        log_check "Log Output C (Expected: 2 commits with correct messages)" "PASS" "$RESULTS_PATH"
    else
        log_check "Log Output C (Expected 2 commits not found or wrong messages)" "FAIL" "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
        echo -e "         Actual Output C was:\n$(echo "$ACTUAL_LOG_OUTPUT_C" | sed 's/^/         | /')" >> "$RESULTS_PATH"
    fi


    # Cleanup: Move back
    popd > /dev/null
    log_final_status "$test_number" "$test_name" "$OVERALL_STATUS"
}


# ------------------------------------------------------------------------------
# Test 10: gitter reset HEAD~1 (Soft reset to previous commit)
# ------------------------------------------------------------------------------
function test_10_gitter_reset_head_one() {
    local test_number="Test 10"
    local test_name="gitter reset HEAD~1 (Undo last commit)"
    start_test "$test_number" "$test_name"
    
    local TEST_DIR="t10" 
    local RESET_CMD="$GITTER_COMMAND reset HEAD~1"
    local STATUS_CMD="$GITTER_COMMAND status"
    local LOG_CMD="$GITTER_COMMAND log"
    local FILENAME_1="file1.txt"
    local FILENAME_2="file2.md"
    
    local COMMIT_MSG_1="adds file2.md"
    local COMMIT_MSG_2="adds all files"
    
    # Expected status after reset: Changes from COMMIT_MSG_2 are now unstaged/modified
    local EXPECTED_UNTRACKED_HEADER="Untracked files:" 
    local EXPECTED_MODIFIED_HEADER="Changes not staged for commit:" # The 'modified' changes should appear here
    
    local OVERALL_STATUS="OVERALL PASS"
    local EXPECTED_EXIT_CODE=0
    local RESULTS_PATH="../../$RESULTS_FILE" 

    # Setup: Create workspace, init repo
    mkdir -p "$TEMP_DIR/$TEST_DIR"
    pushd "$TEMP_DIR/$TEST_DIR" > /dev/null
    
    # 1. Init repository and create files
    $GITTER_COMMAND init > /dev/null 2>&1
    echo "content 1" > "$FILENAME_1"
    echo "content 2" > "$FILENAME_2"
    
    # 2. First Commit (Stage file2.md)
    $GITTER_COMMAND add "$FILENAME_2" > /dev/null 2>&1
    $GITTER_COMMAND commit -m "$COMMIT_MSG_1" > /dev/null 2>&1

    # 3. Second Commit (Stage file1.txt - assumed to be 'adds all files')
    $GITTER_COMMAND add "$FILENAME_1" > /dev/null 2>&1
    $GITTER_COMMAND commit -m "$COMMIT_MSG_2" > /dev/null 2>&1

    # Ensure the second commit was successful (optional check)
    local ACTUAL_LOG_OUTPUT_PRE_RESET=$($LOG_CMD 2>&1)
    if ! echo "$ACTUAL_LOG_OUTPUT_PRE_RESET" | grep -q "$COMMIT_MSG_2"; then
        echo "Pre-reset setup failed: Second commit missing." >> "$RESULTS_PATH"
        popd > /dev/null
        log_final_status "$test_number" "$test_name" "SETUP FAIL"
        return
    fi
    
    echo "Executing: $RESET_CMD in $(pwd)" >> "$RESULTS_PATH"

    # 4. Execute gitter reset HEAD~1
    local ACTUAL_RESET_OUTPUT=$($RESET_CMD 2>&1)
    local ACTUAL_RESET_EXIT_CODE=$?
    
    # --- Check 1: Reset command Exit Code ---
    local check_desc="Reset command Exit Code (Expected: $EXPECTED_EXIT_CODE, Actual: $ACTUAL_RESET_EXIT_CODE)"
    if [ "$ACTUAL_RESET_EXIT_CODE" -eq "$EXPECTED_EXIT_CODE" ]; then
        log_check "$check_desc" "PASS" "$RESULTS_PATH"
    else
        log_check "$check_desc" "FAIL" "$RESULTS_PATH"
        echo "Check: Actual Reset Output was: $ACTUAL_RESET_OUTPUT" >> "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # 5. Check gitter log (Should only show COMMIT_MSG_1)
    local ACTUAL_LOG_OUTPUT_POST_RESET=$($LOG_CMD 2>&1)
    
    # --- Check 2: Log Output (Commit MSG 2 should be gone) ---
    local LOG_CHECK_PASS=0
    if echo "$ACTUAL_LOG_OUTPUT_POST_RESET" | grep -q "$COMMIT_MSG_1" && \
       ! echo "$ACTUAL_LOG_OUTPUT_POST_RESET" | grep -q "$COMMIT_MSG_2"; then
        LOG_CHECK_PASS=1
    fi

    if [ "$LOG_CHECK_PASS" -eq 1 ]; then
        log_check "Log Output (Expected: Only '$COMMIT_MSG_1' remains)" "PASS" "$RESULTS_PATH"
    else
        local EXPECTED_LOG="Commit '$COMMIT_MSG_1' present, '$COMMIT_MSG_2' absent."
        echo "Check: Log Output (Expected: $EXPECTED_LOG)" "-> FAIL" >> "$RESULTS_PATH"
        echo -e "         Actual Log Output was:\n$(echo "$ACTUAL_LOG_OUTPUT_POST_RESET" | sed 's/^/         | /')" >> "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # 6. Check gitter status (file1.txt should be unstaged/modified)
    local ACTUAL_STATUS_OUTPUT=$($STATUS_CMD 2>&1)
    
    # --- Check 3: Status Output (file1.txt changes should be unstaged) ---
    local STATUS_CHECK_PASS=0
    
    # We check for the UNSTAGED header AND the file name, AND the first commit's file (file2.md) should be tracked/clean
    if echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$EXPECTED_MODIFIED_HEADER"; then
        if echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$FILENAME_1" && \
           ! echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$FILENAME_2" && \
           ! echo "$ACTUAL_STATUS_OUTPUT" | grep -q "$EXPECTED_UNTRACKED_HEADER"; then
            STATUS_CHECK_PASS=1
        fi
    fi

    if [ "$STATUS_CHECK_PASS" -eq 1 ]; then
        log_check "Status Output (Expected: '$FILENAME_1' unstaged, '$FILENAME_2' clean)" "PASS" "$RESULTS_PATH"
    else
        local EXPECTED_STATUS="Status should show '$FILENAME_1' as unstaged changes."
        echo "Check: Status Output (Expected: $EXPECTED_STATUS)" "-> FAIL" >> "$RESULTS_PATH"
        echo -e "         Actual Status Output was:\n$(echo "$ACTUAL_STATUS_OUTPUT" | sed 's/^/         | /')" >> "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
    fi


    # Cleanup: Move back
    popd > /dev/null
    log_final_status "$test_number" "$test_name" "$OVERALL_STATUS"
}

# ------------------------------------------------------------------------------
# Test 11: gitter checkout -b (Create and switch to new branch)
# ------------------------------------------------------------------------------
function test_11_gitter_checkout_new_branch() {
    local test_number="Test 11"
    local test_name="gitter checkout -b (Create new branch)"
    start_test "$test_number" "$test_name"
    
    local TEST_DIR="t11" 
    local NEW_BRANCH_NAME="test_branch"
    local CHECKOUT_CMD="$GITTER_COMMAND checkout -b $NEW_BRANCH_NAME"
    
    # Expected output message
    local EXPECTED_OUTPUT="Switched to a new branch '$NEW_BRANCH_NAME'"
    
    local OVERALL_STATUS="OVERALL PASS"
    local EXPECTED_EXIT_CODE=0
    local RESULTS_PATH="../../$RESULTS_FILE" 

    # Setup: Create workspace, init repo
    mkdir -p "$TEMP_DIR/$TEST_DIR"
    pushd "$TEMP_DIR/$TEST_DIR" > /dev/null
    
    # 1. Init repository (Suppress output)
    # Note: Git requires at least one commit before creating a branch from HEAD, 
    # but Gitter might allow it immediately after init. We rely on the specification.
    $GITTER_COMMAND init > /dev/null 2>&1
    
    echo "Executing: $CHECKOUT_CMD in $(pwd)" >> "$RESULTS_PATH"

    # 2. Execute gitter checkout -b
    local ACTUAL_OUTPUT=$($CHECKOUT_CMD 2>&1)
    local ACTUAL_EXIT_CODE=$?
    
    # --- Check 1: Command Exit Code ---
    local check_desc="Checkout command Exit Code (Expected: $EXPECTED_EXIT_CODE, Actual: $ACTUAL_EXIT_CODE)"
    if [ "$ACTUAL_EXIT_CODE" -eq "$EXPECTED_EXIT_CODE" ]; then
        log_check "$check_desc" "PASS" "$RESULTS_PATH"
    else
        log_check "$check_desc" "FAIL" "$RESULTS_PATH"
        echo "Check: Actual Output was: $ACTUAL_OUTPUT" >> "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # --- Check 2: Output Message ---
    local OUTPUT_CHECK_PASS=0
    if echo "$ACTUAL_OUTPUT" | grep -q "$EXPECTED_OUTPUT"; then
        OUTPUT_CHECK_PASS=1
    fi

    if [ "$OUTPUT_CHECK_PASS" -eq 1 ]; then
        log_check "Output Message (Expected: '$EXPECTED_OUTPUT')" "PASS" "$RESULTS_PATH"
    else
        log_check "Output Message (Expected: '$EXPECTED_OUTPUT')" "FAIL" "$RESULTS_PATH"
        echo -e "         Actual Output was:\n$(echo "$ACTUAL_OUTPUT" | sed 's/^/         | /')" >> "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # --- Check 3: Verify branch was created (Check for file/ref existence - relies on Gitter implementation) ---
    local REF_PATH=".gitter/refs/heads/$NEW_BRANCH_NAME" # Standard git reference path
    
    local BRANCH_CHECK_PASS=0
    if [ -f "$REF_PATH" ]; then
        BRANCH_CHECK_PASS=1
    fi

    if [ "$BRANCH_CHECK_PASS" -eq 1 ]; then
        log_check "Internal Check (Expected: Branch ref file '$REF_PATH' exists)" "PASS" "$RESULTS_PATH"
    else
        log_check "Internal Check (Expected: Branch ref file '$REF_PATH' exists)" "FAIL" "$RESULTS_PATH"
        OVERALL_STATUS="OVERALL FAIL"
    fi

    # Cleanup: Move back
    popd > /dev/null
    log_final_status "$test_number" "$test_name" "$OVERALL_STATUS"
}

# ------------------------------------------------------------------------------
# 4. MAIN EXECUTION BLOCK (MODIFIED)
# ------------------------------------------------------------------------------

echo "--- Gitter Test Suite Execution Started ---" >> "$RESULTS_FILE"
echo "Target Command: $GITTER_COMMAND" >> "$RESULTS_FILE"
echo "Total Tests Planned: $TOTAL_TESTS" >> "$RESULTS_FILE"

# Execute all the test cases
test_1_list_commands
test_2_help_init_sections
test_3_gitter_init_success
test_4_gitter_add_new_files
test_5_gitter_add_w_regex
test_6_gitter_status_untracked
test_7_gitter_commit_single_file
test_8_gitter_commit_am_untracked
test_9_gitter_log_history
test_10_gitter_reset_head_one
test_11_gitter_checkout_new_branch

# Final Cleanup
rm -rf "$TEMP_DIR"

# Final Confirmation
echo -e "\n======================================================" >> "$RESULTS_FILE"
echo "Test suite completed. Results written to $RESULTS_FILE"
echo "======================================================" >> "$RESULTS_FILE"
echo "Please refresh the file explorer to view the test case results file."