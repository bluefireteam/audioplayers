#!/bin/bash -e

dartanalyzer .
flutter format .
flutter test

dartdoc
