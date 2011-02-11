#!/usr/bin/env bash

if [ "$1" = "--version" ]
then
    "$TM_JAVA" -version 2>&1 | head -1
    exit 0
fi

SOURCE="$1"
shift

output="$TMPDIR/tm_javamate.${TM_PID:-$LOGNAME}";
mkdir -p "$output"

PACKAGEDIR=${TM_JAVA_PACKAGE//./\/}    # replace . with / in package
SOURCEDIR=$(dirname "$SOURCE")
SOURCEDIR=${SOURCEDIR/%\/$PACKAGEDIR/} # remove package prefix from path


if [ -n "$TM_JAVA_FILEGLOB" ]; then
  # "$TM_JAVAC" -d "$output" -encoding UTF8 $TM_JAVA_FILEGLOB; rc=$?;
  # echo "$TM_JAVAC" -sourcepath "$SOURCEDIR" -d "$output" -encoding UTF8 $TM_JAVA_FILEGLOB;
  "$TM_JAVAC" -sourcepath "$SOURCEDIR" -d "$output" -encoding UTF8 -g $TM_JAVA_FILEGLOB; rc=$?;
  if (($rc >= 1)); then exit $rc; fi
fi

if [[ "$SOURCE" != $TM_JAVA_FILEGLOB ]]; then
  # "$TM_JAVAC" -d "$output" -encoding UTF8 "$SOURCE"; rc=$?;
  # echo "$TM_JAVAC" -sourcepath "$SOURCEDIR" -d "$output" -encoding UTF8 $SOURCE;
  "$TM_JAVAC" -sourcepath "$SOURCEDIR" -d "$output" -encoding UTF8 -g "$SOURCE"; rc=$?;
  if (($rc >= 1)); then exit $rc; fi
fi

CLASS=$(basename -s .java "$SOURCE")
if [ "$TM_JAVA_PACKAGE" ]
then
    CLASS="$TM_JAVA_PACKAGE.$CLASS"
fi


CLASSPATH="$output:$CLASSPATH" "$TM_JAVA" -Dfile.encoding=utf-8 org.junit.runner.JUnitCore "$CLASS" $@;
# "$TM_JAVA" -Dfile.encoding=utf-8 org.junit.runner.JUnitCore "$CLASS" $@;
# CLASSPATH="$output:$CLASSPATH" "$TM_JAVA" -Dfile.encoding="utf-8" "$CLASS" $@;
exit $?;
