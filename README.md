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
   2. Use winetricks to install ```dotnet472``` in prefix
   3. Download ```vs_community 2019``` installer
   4. Run ```vs_community_2019.exe --wait --quiet --includeRecommended --includeOptional --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Workload.NetCoreTools --add Microsoft.VisualStudio.Component.VC.14.29.16.10.x86.x64```
3. Setup UE5 source code
    1. Clone unreal engine 5 repo on host system (not in wine prefix)
    2. Apply ```fix_ubt_build.patch``` to UE5 source code
       1. ```git apply --ignore-space-change --ignore-whitespace <patch name>```
4. Compile UnrealBuildTool
    1. In wine console: 
       1. Change to engine source root directory
       2. Run ```GenerateProjectFiles.bat```
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
   1. Apply build_uat.patch
   2. Run ```Engine/Build/BatchFiles/BuildUAT.bat```
   3. Run ```""Z:/home/linuxdev/UnrealEngine/Engine/Build/BatchFiles/RunUAT.bat" -ScriptsForProject="C:/users/linuxdev/Documents/Unreal Projects/CitySample/CitySample2/CitySample2.uproject" Turnkey -command=VerifySdk -platform=Win64 -UpdateIfNeeded -EditorIO -EditorIOPort=33121  -project="C:/users/linuxdev/Documents/Unreal Projects/CitySample/CitySample2/CitySample2.uproject" BuildCookRun -nop4 -utf8output -nocompileeditor -skipbuildeditor -cook  -project="C:/users/linuxdev/Documents/Unreal Projects/CitySample/CitySample2/CitySample2.uproject" -targ
et=CitySample  -unrealexe="Z:\home\linuxdev\UnrealEngine\Engine\Binaries\Win64\UnrealEditor-Cmd.exe" -platform=Win64 -ddc=DerivedDataBackendGraph -stage -archive -package -build -compressed -iostore -pak -prereqs -archivedirectory="C:/users/linuxdev/Documents/Unreal Projects" -CrashReporter -clientconfig=Development"```
## Notes
1. ```dotnet48``` is required by the mstools installer


