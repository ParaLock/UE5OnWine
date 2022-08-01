# Overview
This repo contains a collection of scripts and instructions for compiling and running Unreal Engine 5 from source under Wine.

## Prerequisites

1. Lutris

## Instructions

1. Setup Lutris
   1. Clone ```wine-tkg``` repo and compile with latest wine staging as wine branch
   2. Copy built ```wine-tkg``` package to lutris runners directory
   3. Create new application entry in Lutris
   4. Set runner to ```wine-tkg```
   5. Disable Esync but keep Fsync enabled (if supported by kernel)
2. Setup Wine Prefix
   1. Use winetricks uninstaller to uninstall wine mono if present in prefix
   2. Use winetricks to install ```dotnet48``` in prefix
   3. Download ```msbuild tools 2022``` installer
   4. Run ```<msbuild tools installer>.exe 
       --add Microsoft.NetCore.Component.Runtime.3.1
       --add Microsoft.NetCore.Component.SDK
       --add Microsoft.Net.Component.4.6.2.TargetingPack
       --add Microsoft.VisualStudio.Component.Windows10SDK.18362 --quiet --wait```
   5. Run ```<msbuild tools installer>.exe --noweb --includeRecommended --includeOptional --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.MSBuildTools --quiet --wait```

3. Setup UE5 source code
    1. Clone unreal engine 5 repo on host system (not in wine prefix)
    2. Apply ```fix_ubt_build.patch``` to UE5 source code
       1. ```git apply --ignore-space-change --ignore-whitespace <patch name>```
4. Compile UnrealBuildTool
    1. In wine console: 
       1. Make sure prefix is set to windows 7 mode
       2. Change to engine source root directory
       3. Run ```GenerateProjectFiles.bat```
5. Compile Engine
   1. To compile core engine and editor run the following commands in the wine console (from source root folder): 
       1. ```Engine\Build\BatchFiles\Build.bat ShaderCompileWorker Win64 Development -waitmutex```
       2. ```Engine\Build\BatchFiles\Build.bat UnrealEditor Win64 Development -waitmutex```
   2. To compile existing project/game
       1. Add ```DisablePlugins.Add("VisualStudioSourceCodeAccess");``` to <ProjectName>.Target.cs
       2. Add ```DisablePlugins.Add("ADOSupport");``` to <ProjectName>.Target.cs
       3. Run ```Engine\Build\BatchFiles\Build.bat <ProjectName>Editor Development Win64 "<path to uproject file>" -Progress -waitmutex```
   3. To run compiled project in editor
       1. Run ```Engine/Binaries/Win64/UnrealEditor.exe "<path to uproject file>"```
6. Packaging Project
   1. Make sure wine prefix is in windows 7 mode
   2. Apply build_uat.patch
   3. Compile UAT
       1. Run ```Engine/Build/BatchFiles/BuildUAT.bat```
   4. Execute packaging 
       1. Run ```Engine/Build/BatchFiles/RunUAT.bat BuildCookRun -platform=Win64 -map=Small_City_LVL -FastCook -project="<project location>" -clientconfig=Shipping -cook -stage -package -verbose```
## Notes
1. ```dotnet48``` is required by the mstools installer


