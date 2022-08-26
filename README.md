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
   5. Run ```<msbuild tools installer>.exe --includeRecommended --includeOptional --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.MSBuildTools --quiet --wait```

3. Setup UE5 source code
    1. Clone unreal engine 5 repo on host system (not in wine prefix)
    2. Apply patches to UE5 source code
       1. ```git apply --ignore-space-change --ignore-whitespace fix_*```
    3. Make sure wine prefix is in windows 10 mode
    4. Run ```Engine\Binaries\DotNET\GitDependencies\win-x64\GitDependencies.exe```
    5. Run ```Setup.bat```
4. Compile UnrealBuildTool
    1. Fixes
       1. Set ```ncrypt``` dll override to ```native``` in winecfg.. ```nuget``` does not seem to like the wine ncrypt dll.
       2. (```CommandLineAttribute.cs```, ```AutomationTool/Program.cs```): For some reason string methods such as ```StartsWith```, ```Contains```, ```EndsWith``` do not properly compare input characters wrapped in single quotes. To fix the issue simply convert single quotes to double quotes.
       3. (```GenerateProjectFiles.bat```, ```BuildUAT.bat```, ```RunUBT.bat```): ```dotnet msbuild``` does not work properly if it is allowed to run across multiple cores. Add ```-maxCpuCount:1``` to all msbuild calls which appear in various bat files to restrict msbuild to one core and fix the issue.
    2. In wine console: 
       1. Change to engine source root directory
       2. Run ```GenerateProjectFiles.bat```
5. Build Unreal Frontend
   1. Fixes
      1. (```UserInterfaceCommand.cpp```): Unreal frontend tries to load visual studio upon start (which currently does not run under wine). Simply comment out visual studio loading code in ```UserInterfaceCommand.cpp```to fix this issue.
   3. Run ```Engine\Build\BatchFiles\Build.bat ShaderCompileWorker Win64 Development -waitmutex```
   4. Run ```Engine\Build\BatchFiles\Build.bat UnrealFrontend Win64 Development -waitmutex```
7. Compile Engine
   1. Fixes
       1. (```SProjectDialog.cpp```, ```SourceCodeNavigation```): Since visual studio does not currently work in wine you will need to comment out IDE setup and loading code in order to properly open projects and work within the Unreal Editor.
       2. (```WindowsPlatformFile.cpp```): The windows file IO code in  does not seem to handle writes to non-overlapped IO file handles correctly. ```fix_big_files.patch``` fixes this issue.
       3. (```RenderUtils.h```, ```WindowsD3D12PipelineState.cpp```): GPU vendor extensions currently do not work properly with dxvk-nvapi/vkd3d-proton so we need to tell the engine not to use them. 
   4. To compile core engine and editor run the following commands in the wine console (from source root folder): 
       1. ```Engine\Build\BatchFiles\Build.bat UnrealEditor Win64 Development -waitmutex```
   5. To compile existing project/game
       1. Add ```DisablePlugins.Add("VisualStudioSourceCodeAccess");``` to <ProjectName>.Target.cs
       2. Add ```DisablePlugins.Add("ADOSupport");``` to <ProjectName>.Target.cs
       3. Run ```Engine\Build\BatchFiles\Build.bat <ProjectName>Editor Development Win64 "<path to uproject file>" -Progress -waitmutex```
   6. To run compiled project in editor
       1. Run ```Engine/Binaries/Win64/UnrealEditor.exe "<path to uproject file>"```
8. Packaging Project
   1. Run Unreal Frontend and have fun :)

## Debugging
UE5 may at times freeze up or crash while being run under wine. Below is a set of recommendations for debugging and fixing various issues.
1. Freezes
   1. IF UE5 freezes up and you also notice your system becoming unresponsive for a few seconds, then check ```dmesg``` for GPU crash messages. NVIDIA drivers provide an XID which specifies the type of issue which occured.
   2. In general, GPU crashes are usually caused by shader issues. We recommend that you leverage vkd3d-proton (when in dx12 mode) to debug and fix the issue. We recommend using the vkd3d-proton breadcrumbs mechanism as your primary debugging tool. Once you have narrowed down the faulty shader in the vkd3d-proton log by examining breadcrumbs, you can decompile the shader in question, then use vkd3d-proton to swap out the faulty shader for your new version.
   
## Notes
1. ```dotnet48``` is required by the mstools installer


