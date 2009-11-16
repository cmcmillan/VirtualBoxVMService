rem usage genconfig.bat <pid> [-d <default configuration file>]<output file> 

call setenv.bat

if not "%2" == "-d" goto noDefaultConfig

if "%4" == "" goto defaultOutput
%wrapper_bat% -g %1 -d %3 %4
goto end

:defaultOutput
%wrapper_bat% -g %1 -d %3 %conf_file%
goto end

:noDefaultConfig
if "%2" == "" goto useDefaults
%wrapper_bat% -g %1 -d %conf_default_file% %2
goto end

:useDefaults
%wrapper_bat% -g %1 -d %conf_default_file% %conf_file%

:end
pause
