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
rem name         If the second argument is present it is considered
rem                        to be new service name                                           
rem
rem $Id: service.bat 600659 2007-12-03 20:15:09Z jim $
rem ---------------------------------------------------------------------------

set SERVICE_BASE=%n0
set VERSION=1.0.1-SNAPSHOT-jackofall
set CURRENT_DIR=%cd%

rem Guess JSERVICE_HOME if not defined
if not "%JSERVICE_HOME%" == "" goto gotHome
set JSERVICE_HOME=%cd%

if exist "%JSERVICE_HOME%\%SERVICE_BASE%.exe" goto okHome
set JSERVICE_HOME=%cd%

:gotHome
if exist "%JSERVICE_HOME%\%SERVICE_BASE%.exe" goto okHome
echo The %SERVICE_BASE%.exe was not found...
echo The JSERVICE_HOME environment variable is not defined correctly.
echo This environment variable is needed to run this program
goto end
rem Make sure prerequisite environment variables are set
if not "%JAVA_HOME%" == "" goto okHome
echo The JAVA_HOME environment variable is not defined
echo This environment variable is needed to run this program
goto end 
:okHome
if not "%JSERVICE_BASE%" == "" goto gotBase
set JSERVICE_BASE=%JSERVICE_HOME%
:gotBase

set EXECUTABLE=%JSERVICE_HOME%\%SERVICE_BASE%.exe

rem Set default Service name
set VM_NAME=VirtualBoxVM
set SERVICE_NAME=%SERVICE_BASE%_%VM_NAME%
set DISPLAYNAME="Virtual Machine: %VM_NAME%"

if "%1" == "" goto displayUsage
if "%2" == "" goto setServiceName
set VM_NAME=%2
set SERVICE_NAME=%SERVICE_BASE%_%2
set DISPLAYNAME="Virtual Machine: %2"

:setServiceName
if %1 == install goto doInstall
if %1 == remove goto doRemove
if %1 == uninstall goto doRemove
if %1 == status goto doStatus
if %1 == querystatus goto doStatus
if %1 == showconfig goto doQueryConfig
if %1 == query goto doQueryConfig
if %1 == queryconfig goto doQueryConfig
echo Unknown parameter "%1"

:displayUsage
echo.
echo Usage: %0 install <virtual_machine>     To install the virtual machines launcher service
echo Usage: %0 remove <virtual_machine>      To uninstall the virtual machines launcher service
echo Usage: %0 status <virtual_machine>      To show current status of the virtual machines launcher service
echo Usage: %0 showconfig <virtual_machine>  To show configuration of the virtual machines launcher service
goto end

:doRemove
rem Remove the service
"%EXECUTABLE%" -uninstall %SERVICE_NAME%
goto end

:doStatus
rem Show current status of the service
"%EXECUTABLE%" -status %SERVICE_NAME%
echo The service '%SERVICE_NAME%' status
goto end

:doQueryConfig
rem Show configuration of the service
"%EXECUTABLE%" -queryconfig %SERVICE_NAME%
goto end

:doInstall
rem Install the service
echo Installing the service '%SERVICE_NAME%' ...
echo Using JSERVICE_HOME:    %JSERVICE_HOME%
echo Using JSERVICE_BASE:    %JSERVICE_BASE%
echo Using JAVA_HOME:        %JAVA_HOME%
echo Using VM_NAME:          %VM_NAME%

rem Use the environment variables as an example
rem Each command line option is prefixed with PR_

rem CLASS_PATH
SET CLASS_PATH="%JSERVICE_HOME%\%SERVICE_BASE%-%VERSION%.jar"

rem START_CLASS, (required) this must be the fully qualified class name
SET START_CLASS=com.chris.MyService
rem START_METHOD, (optional)
SET START_METHOD=main
if not %START_METHOD% == "" SET START_METHOD=-method %START_METHOD%
rem START_PARAMS, (optional)
SET START_PARAMS=start
if not %START_PARAMS% == "" SET START_PARAMS=-params "%START_PARAMS%"
rem Set the list of START_ARGS
SET START_ARGS=-start %START_CLASS% %START_METHOD% %START_PARAMS%

rem STOP_CLASS,  (optional) Defaults to the same class as the %START_CLASS%
if %STOP_CLASS% == "" SET STOP_CLASS=%START_CLASS%
rem STOP_METHOD, (optional) Defaults to using the same method as %START_METHOD%
if %STOP_METHOD% == "" SET START_METHOD=-method %START_METHOD%
rem STOP_PARAMS, (optional)
if %STOP_PARAMS% == "" SET STOP_PARAMS=stop
if not %STOP_PARAMS% == "" SET STOP_PARAMS=-params "%STOP_PARAMS%"
rem Set the list of STOP_ARGS
SET STOP_ARGS=-stop %STOP_CLASS% %STOP_METHOD% %STOP_PARAMS%

rem Set the server jvm from JAVA_HOME
set JVM=%JAVA_HOME%\jre\bin\server\jvm.dll
if exist "%JVM%" goto foundJvm
rem Set the client jvm from JAVA_HOME
set JVM=%JAVA_HOME%\jre\bin\client\jvm.dll
if exist "%JVM%" goto foundJvm
set JVM=auto

:foundJvm
echo Using JVM:              %JVM%
echo Using install command:  "%EXECUTABLE% -install %SERVICE_NAME% %JVM% -Djava.class.path=%CLASS_PATH% %START_ARGS% %STOP_ARGS% -current %CURRENT_DIR% -description %DISPLAYNAME%"

rem Install the service
"%EXECUTABLE% -install %SERVICE_NAME% %JVM% -Djava.class.path=%CLASS_PATH% %START_ARGS% %STOP_ARGS% -current %CURRENT_DIR% -description %DISPLAYNAME%"

if not errorlevel 1 goto installed
echo Failed installing '%SERVICE_NAME%' service
goto end

:installed
echo The service '%SERVICE_NAME%' has been installed.
rem Start the newly installed service
net start %SERVICE_NAME%

:end
cd %CURRENT_DIR%
rem Clear the environment variables. They are not needed any more.
set EXECUTABLE=
set JVM=
set CLASS_PATH=

set START_CLASS=
set START_METHOD=
set START_PARAMS=
set START_ARGS=

set STOP_CLASS=
set STOP_METHOD=
set STOP_PARAMS=
set STOP_ARGS=

set CURRENT_DIR=
set JSERVICE_HOME=
set JSERVICE_BASE=
set VM_NAME=
set DISPLAYNAME=
set SERVICE_NAME=
