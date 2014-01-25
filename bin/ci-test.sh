#!/bin/bash

BASE_OPTIONS="-workspace iOpenSongs.xcworkspace -scheme Beta"
TEST_OPTIONS="-freshInstall"

# build tests
xctool $BASE_OPTIONS -sdk iphonesimulator build-tests

# run tests
xctool $BASE_OPTIONS run-tests $TEST_OPTIONS -test-sdk iphonesimulator6.1 -simulator ipad
xctool $BASE_OPTIONS run-tests $TEST_OPTIONS -test-sdk iphonesimulator6.1 -simulator iphone
xctool $BASE_OPTIONS run-tests $TEST_OPTIONS -test-sdk iphonesimulator7.0 -simulator ipad
xctool $BASE_OPTIONS run-tests $TEST_OPTIONS -test-sdk iphonesimulator7.0 -simulator iphone

