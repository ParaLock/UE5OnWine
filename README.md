# Overview
This repo contains a collection of scripts and instructions for compiling and running Unreal Engine 5 from source under Wine.

## Prerequisites

1. Bottles

## Instructions

1. Setup Bottles
   1. Clone ```wine-tkg``` repo and compile with latest wine staging as wine branch
   2. Copy built ```wine-tkg``` package to bottles runners directory
2. Setup Wine Prefix
   1. Use uninstaller to uninstall wine mono if present in prefix
   2. Use bottles to install ```dotnet48``` in prefix
   3. Download ```msbuild tools 2022``` installer
   4. Run ```<msbuild tools installer>.exe 
       --add Microsoft.NetCore.Component.Runtime.3.1
       --add Microsoft.NetCore.Component.SDK
       --add Microsoft.Net.Component.4.6.2.TargetingPack
       --add Microsoft.VisualStudio.Component.Windows10SDK.18362 --quiet --wait```
   5. Run ```<msbuild tools installer>.exe --includeRecommended --includeOptional --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.MSBuildTools --quiet --wait```
   6. Set wine window renderer to vulkan
      1. Setting can be accessed in Advanced Display Settings
   7. Make sure wine prefix is in windows 10 mode
   8. Set ```ncrypt``` dll override to ```native``` in winecfg.. ```nuget``` does not seem to like the wine ncrypt dll. (Note this change can break other applications so it is best to remove override when not compiling unreal)

3. Install VSCode in prefix
4. Setup UE5 source code
    1. Clone unreal engine 5 repo on host system (not in wine prefix)
    2. Apply `fix_big_files.patch`
    3. Apply `patch.diff`
    4. Run ```Engine\Binaries\DotNET\GitDependencies\win-x64\GitDependencies.exe```
    5. Run ```Setup.bat```

4. Compile UnrealBuildTool
    1. In wine console: 
       1. Change to engine source root directory
       2. Run ```GenerateProjectFiles.bat```
5. Build Unreal Frontend
   1. Run ```Engine\Build\BatchFiles\Build.bat ShaderCompileWorker Win64 Development -waitmutex```
   2. Run ```Engine\Build\BatchFiles\Build.bat UnrealFrontend Win64 Development -waitmutex```
7. Compile Engine
   1. To compile core engine and editor run the following commands in the wine console (from source root folder): 
       1. ```Engine\Build\BatchFiles\Build.bat UnrealEditor Win64 Development -waitmutex```
   2. To compile existing project/game
       1. Add ```DisablePlugins.Add("ADOSupport");``` to <ProjectName>.Target.cs
       2. Run ```Engine\Build\BatchFiles\Build.bat <ProjectName>Editor Development Win64 "<path to uproject file>" -Progress -waitmutex```
   3. To run compiled project in editor
       1. Run ```Engine/Binaries/Win64/UnrealEditor.exe "<path to uproject file>"```
8. Packaging Project
   1. Run Unreal Frontend
   2. Disable compile UAT before running profile

## Fixes
 
1. (```GenerateProjectFiles.bat```, ```BuildUAT.bat```, ```RunUBT.bat```): ```dotnet msbuild``` does not work properly if it is allowed to run across multiple cores. Add ```-maxCpuCount:1``` to all msbuild calls which appear in various bat files to restrict msbuild to one core and fix the issue.
2. (`UnrealEditor.Target.cs`) Add ```DisablePlugins.Add("ADOSupport");``` it seems unreal has a hard time compiling the required header under wine.
3. (```WindowsPlatformFile.cpp```) It appears that Unreal does not correctly handle a specific failure mode with regards to overlapped and non overlapped file IO. The bug manifests when dealing with extremely large files (such as the cooked city sample bundle). I think the issue is that the engine is relying on a bug in the win32 API, a bug which is not present in the wine equivalent. The fix boils down to resolving an IO request using overlapped IO if the request fails under a normal IO code path. This fix is contained in ```fix_big_files.patch```.
4. (```*.csproj```) Due to some non critical (I think?) warnings that occur during dotnet execution we need to disable treatment of warnings as errors.
5. (```VisualStudioDTE.Build.cs```) For some reason wine has a hard time compiling the header associated with Visual Studio DTE functionality. To avoid including this header in the compilation process we need to set the ```WITH_VISUALSTUDIO_DTE``` preprocessor directive to 0.
6. (```RunUAT.bat```) The RunUAT.bat script is unable to correctly resolve the path to the batch files directory unless said path is hardcoded. To fix the issue, hardcode the variable SCRIPT_DIR to the absolute path of your unreal engine BatchFiles directory.
   
## Debugging
UE5 may at times freeze up or crash while being run under wine. Below is a set of recommendations for debugging and fixing various issues.
1. Freezes
   1. IF UE5 freezes up and you also notice your system becoming unresponsive for a few seconds, then check ```dmesg``` for GPU crash messages. NVIDIA drivers provide an XID which specifies the type of issue which occured.
   2. In general, GPU crashes are usually caused by shader issues. We recommend that you leverage vkd3d-proton (when in dx12 mode) to debug and fix the issue. We recommend using the vkd3d-proton breadcrumbs mechanism as your primary debugging tool. Once you have narrowed down the faulty shader in the vkd3d-proton log by examining breadcrumbs, you can decompile the shader in question, modify the decompiled shader to get around a certain issue, recompile the shader, and finally instruct vkd3d-proton to swap out the faulty shader for your new version.
   
## Notes
1. ```dotnet48``` is required by the mstools installer
2. Testing with wine-tkg version 8.7 and UE 5.2


