call Engine\Build\BatchFiles\Build.bat ShaderCompileWorker Win64 Development -waitmutex
call Engine\Build\BatchFiles\Build.bat UnrealEditor Win64 Development -waitmutex
call Engine\Build\BatchFiles\Build.bat CitySampleEditor Development Win64 "C:\users\linuxdev\Documents\Unreal Projects\CitySample\CitySample2\CitySample2.uproject" -Progress -waitmutex