#!/bin/bash

dartanalyzer .
dartfmt -w .
flutter test

dartdoc
