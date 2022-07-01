# Overview
This repo contains a collection of scripts and instructions for compiling and running Unreal Engine 5 from scratch under Wine.

## Prerequisites

1. Lutris

## Instructions

1. Setup Lutris
   1. Clone ```wine-tkg``` repo and compile with latest wine staging
   2. Create new application entry in Lutris
   3. Set runner to ```wine-tkg```
   4. Disable Esync but keep Fsync enabled (if supported by kernel)
2. Setup Prefix
   1. Use winetricks uninstaller to uninstall wine mono if present in prefix
   2. Use winetricks to install ```dotnet48``` in prefix
   3. Use winecfg to set prefix windows version to windows 10
   4. Download ```buildtools``` for vs 2019
   5. Run buildtools installer in prefix using wine console
       1. Launch with following arguments
           1. ``/norestart``
       2. Install required listed on the unreal engine release notes webpage here (https://docs.unrealengine.com/5.0/en-US/unreal-engine-5-0-release-notes/)
       3. After install, type wineboot in console to emulate system restart
3. Setup UE5 source code
    1. Clone unreal engine 5 repo on host system (not in wine prefix)
    2. Apply ```wine_fixes.patch``` to UE5 source code
4. Compile UnrealBuildTool
    1. In wine console: 
       1. Change directory to engine source
       2. Run ```dotnet msbuild /target:build /property:Configuration=Development /nologo Engine\Source\Programs\UnrealBuildTool\UnrealBuildTool.csproj /verbosity:normal```
5. Compile Engine
   1. To compile core engine and editor run the following commands in the wine console (from source root folder): 
       1. ```Engine\Build\BatchFiles\Build.bat ShaderCompileWorker Win64 Development -waitmutex```
       2. ```Engine\Build\BatchFiles\Build.bat UnrealEditor Win64 Development -waitmutex```
   2. To compile existing project/game
       1. ```Engine\Build\BatchFiles\Build.bat <Project Name> Win64 Development -waitmutex```

## Notes
1. ```dotnet48``` is required by the mstools installed


