#!/bin/bash

# Generate list of arguments to pass to Sourcery
function sourceryArguments {
  # Environment variables from BuildConfig to map into AppSecrets
  local arguments=(
    "GOOGLE_CLIENT_ID" "YOUTUBE_KEY"
  )
  local combinedArgs

  local argumentsIndices=${!arguments[*]}
  for index in $argumentsIndices
  do
    # Make the arguments list comma-separated
    if [ $index -gt 0 ];
    then
      combinedArgs="${combinedArgs},"
    fi

    # Append the argument name and escaped argument value
    local argument=${arguments[$index]}
    local argumentName="${argument}"
    local argumentValue="\"${!argument}\""
    local argumentPair="${argumentName}=${argumentValue}"
    combinedArgs="${combinedArgs}${argumentPair}"
  done
  echo $combinedArgs
}

sourceryArgs=$(sourceryArguments)

# Generate AppSecrets using the arguments list created above
mkdir -p WidgetTube/Generated
Pods/Sourcery/bin/sourcery --sources WidgetTube \
  --templates Templates/AppSecrets.stencil \
  --output WidgetTube/Generated \
  --args $sourceryArgs
