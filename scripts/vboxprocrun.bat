@echo off
rem Licensed to the Apache Software Foundation (ASF) under one or more
rem contributor license agreements.  See the NOTICE file distributed with
rem this work for additional information regarding copyright ownership.
rem The ASF licenses this file to You under the Apache License, Version 2.0
rem (the "License"); you may not use this file except in compliance with
rem the License.  You may obtain a copy of the License at
rem
rem     http://www.apache.org/licenses/LICENSE-2.0
rem
rem Unless required by applicable law or agreed to in writing, software
rem distributed under the License is distributed on an "AS IS" BASIS,
rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
rem See the License for the specific language governing permissions and
rem limitations under the License.

if "%OS%" == "Windows_NT" setlocal
rem ---------------------------------------------------------------------------
rem NT Service Install/Uninstall script
rem
rem Options
rem install                Install the service using Tomcat6 as service name.
rem                        Service is installed using default settings.
rem remove                 Remove the service from the System.
rem
rem name        (optional) If the second argument is present it is considered
rem                        to be new service name                                           
rem
rem $Id: service.bat 600659 2007-12-03 20:15:09Z jim $
rem ---------------------------------------------------------------------------

rem Guess PROCRUN_HOME if not defined
set CURRENT_DIR=%cd%
if not "%PROCRUN_HOME%" == "" goto gotHome
set PROCRUN_HOME=%cd%
if exist "%PROCRUN_HOME%\procrun\procrun.exe" goto okHome
rem CD to the upper dir
cd ..
set PROCRUN_HOME=%cd%
:gotHome
if exist "%PROCRUN_HOME%\procrun\procrun.exe" goto okHome
echo The procrun.exe was not found...
echo The PROCRUN_HOME environment variable is not defined correctly.
echo This environment variable is needed to run this program
goto end
rem Make sure prerequisite environment variables are set
if not "%JAVA_HOME%" == "" goto okHome
echo The JAVA_HOME environment variable is not defined
echo This environment variable is needed to run this program
goto end 
:okHome
if not "%PROCRUN_BASE%" == "" goto gotBase
set PROCRUN_BASE=%PROCRUN_HOME%
:gotBase

set EXECUTABLE=%PROCRUN_HOME%\procrun\procrun.exe

rem Set default Service name
set SERVICE_NAME=JavaAppLauncherProcrun
set PR_DISPLAYNAME=Java App Launcher With Procrun Service

if "%1" == "" goto displayUsage
if "%2" == "" goto setServiceName
set SERVICE_NAME=%2
set PR_DISPLAYNAME=Procrun: %2
:setServiceName
if %1 == install goto doInstall
if %1 == remove goto doRemove
if %1 == uninstall goto doRemove
echo Unknown parameter "%1"
:displayUsage
echo.
echo Usage: vboxprocrun.bat install/remove [service_name]
goto end

:doRemove
rem Remove the service
"%EXECUTABLE%" //DS//%SERVICE_NAME%
echo The service '%SERVICE_NAME%' has been removed
goto end

:doInstall
rem Install the service
echo Installing the service '%SERVICE_NAME%' ...
echo Using PROCRUN_HOME:    %PROCRUN_HOME%
echo Using PROCRUN_BASE:    %PROCRUN_BASE%
echo Using JAVA_HOME:       %JAVA_HOME%

rem Use the environment variables as an example
rem Each command line option is prefixed with PR_

set PR_DESCRIPTION=Java App Launcher with Procrun (http://commons.apache.org/daemon/procrun.html), Currently Virtual Box (http://www.virtualbox.org) Virtual Machine
set PR_INSTALL=%EXECUTABLE%
set PR_LOGPATH=%PROCRUN_BASE%\log
set PR_CLASSPATH=%PROCRUN_HOME%\classes\;%PROCRUN_HOME%\config\
rem Set the server jvm from JAVA_HOME
set PR_JVM=%JAVA_HOME%\jre\bin\server\jvm.dll
if exist "%PR_JVM%" goto foundJvm
rem Set the client jvm from JAVA_HOME
set PR_JVM=%JAVA_HOME%\jre\bin\client\jvm.dll
if exist "%PR_JVM%" goto foundJvm
set PR_JVM=auto
:foundJvm
echo Using JVM:              %PR_JVM%
"%EXECUTABLE%" //IS//%SERVICE_NAME% --StartClass com.chris.MyService --StopClass com.chris.MyService --StartParams start --StopParams stop
if not errorlevel 1 goto installed
echo Failed installing '%SERVICE_NAME%' service
goto end
:installed
rem Clear the environment variables. They are not needed any more.
set PR_DISPLAYNAME=
set PR_DESCRIPTION=
set PR_INSTALL=
set PR_LOGPATH=
set PR_CLASSPATH=
set PR_JVM=
rem Set extra parameters
"%EXECUTABLE%" //US//%SERVICE_NAME% --StartMode jvm --StopMode jvm
rem More extra parameters
set PR_LOGPATH=%PROCRUN_BASE%\log
set PR_STDOUTPUT=auto
set PR_STDERROR=auto
"%EXECUTABLE%" //US//%SERVICE_NAME% --LogPath=%PR_LOGPATH% --StdOutput=%PR_STDOUTPUT% --StdError=%PR_STDOUTPUT%

echo The service '%SERVICE_NAME%' has been installed.

:end
cd %CURRENT_DIR%
