#!/bin/bash
# Build script that should simplify Jenkins configuration.

# Exit if any command returns non-zero
set -e

if [ -z "$DRONE_BUILD_DIR" ]; then
    export DRONE_BUILD_DIR=`pwd`
fi

echo "Build path: $DRONE_BUILD_DIR"

if [ -d revelator ]; then
  echo "******** Checking for latest version of Revelator ********"
  cd revelator
  git pull
  cd ..
else
  echo "******** Downloading Revelator ********"
  git clone https://github.com/mpdehaan/revelator.git
  git clone https://github.com/hakimel/reveal.js reveal_js_261
  echo "Removing reveal.js README so it does not overwrite projects README"
  rm reveal_js_261/README.md

fi

echo "******** Looping over folders ********"
for i in section_one section_two
  do
    echo "******** Syntax Check on $i ********"
    python $DRONE_BUILD_DIR/syntax_check.py $DRONE_BUILD_DIR/$i/*.yml
    echo "******** Creating output folder for $i ********"
    mkdir -p output/$i
    echo "******** Build Single on $i ********"
    python $DRONE_BUILD_DIR/build_single.py $DRONE_BUILD_DIR/$i > $i_comp.yml
    echo "******** Generating Slides on $i ********"
    python revelator/write_it $i_comp.yml output/$i
  done
