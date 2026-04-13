if [ "$BUILD_ALL" = "true" ]; then 
    command="run-many"
else 
    command="affected"
fi

if [ "$TARGET" != "" ]; then 
    target=$TARGET
else 
    target="build"
fi

if [ "$CONFIGURATION" != "" ]; then 
    configuration=$CONFIGURATION
else 
    configuration="dev"
fi

npx nx $command --target=$target --verbose --configuration=$configuration