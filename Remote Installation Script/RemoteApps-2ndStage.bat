@ECHO OFF

SETLOCAL ENABLEDELAYEDEXPANSION

GOTO SUB_VARIABLES

REM *******************************************************************************
REM *                                                                             *
REM * Version 0.01                 16/June/2009             By Nathaniel Mitchell *
REM *            - Initial creation of script, based on BACKUP script             *
REM *            - Modified script to execute commands remotely                   *
REM *            - Modified script to copy files to remote PC to execute remotely *
REM *                                                                             *
REM * Version 0.02                 17/June/2009             By Nathaniel Mitchell *
REM *            - General bug fixing                                             *
REM *            - Added functionality to delete files and copy files             *
REM *                                                                             *
REM * Version 0.1                  18/June/2009             By Nathaniel Mitchell *
REM *            - Minor bug fixes                                                *
REM *       TODO - Use Bittorrent to transfer the files                           *
REM *                                                                             *
REM * Version 0.2                  18/June/2009             By Nathaniel Mitchell *
REM *            - Attempt method to have files transferred to a local PC then run*
REM *              from there. FAILED, as PSEXEC doesn't allow network access     *
REM *                                                                             *
REM * Version 0.3                  18/June/2009             By Nathaniel Mitchell *
REM *            - Reworked script to use HTTP to download the files from a web   *
REM *              server.                                                        *
REM *            - Fix some minor bugs                                            *
REM *                                                                             *
REM * Version 0.4                  19/June/2009             By Nathaniel Mitchell *
REM *            - Minor bug fixes                                                *
REM *            - Changed to turn on and off sections of the script              *
REM *                                                                             *
REM * Version 0.5                  22/June/2009             By Nathaniel Mitchell *
REM *            - Minor bug fixes                                                *
REM *            - Updates to the changelog                                       *
REM *                                                                             *
REM *******************************************************************************
REM *******************************************************************************
REM *                                                                             *
REM * Set some variables for use in the script                                    *
REM *                                                                             *
REM *         TODAY == Today's date as yyyy-mm-dd. This HAS to come first         *
REM *                  NOTE -- ONLY modify the end of the line that has "TODAY="  *
REM *                       -- The following are what the variables mean          *
REM *                                        %%A == The day of the week           *
REM *                                        %%B == The day as a 2 digit number   *
REM *                                        %%C == The month as a 2 digit number *
REM *                                        %%D == The year as a 4 digit number  *
REM *                                                                             *
REM *      PROGRAMS == The locations of required programs                         *
REM *                                                                             *
REM *     APPSOURCE == The location of the programs to copy to the remote PC, then*
REM *                  run from the new location                                  *
REM *                                                                             *
REM *    FILESOURCE == The location of files to be copied AFTER the programs have *
REM *                  been installed                                             *
REM *                                                                             *
REM *          LIST == The list of IPs, Usernames, Passwords and Sources          *
REM *                  NOTE -- Each item needs to be separated by a comma         *
REM *                  EXAMPLE --                                                 *
REM *                     <IP>,<USER>,<PASSWORD>                                  *
REM *                                                                             *
REM *     DOWNLOADS == The list of files/websites to dowload                      *
REM *                                                                             *
REM *       APPLIST == The list of applications to install                        *
REM *                  NOTE -- You MUST becareful of your location, as the command*
REM *                          is run from remote PC as if it was started on the  *
REM *                          machine by a user                                  *
REM *                  EXAMPLE --                                                 *
REM *                          <Title>,<Command & Parametters>                    *
REM *                      Empty Windows' temp directory,del /s/f/q %windir%\temp *
REM *                                                                             *
REM *        TOCOPY == A list of files to copy and their destination, the source  *
REM *                  for the files is relative to the FILESOURCE setting        *
REM *                                                                             *
REM *      TOREMOVE == A list of files/directories to delete/remove               *
REM *                                                                             *
REM *    APPTIMEOUT == The number of seconds to wait for an application to finish *
REM *                  NOTE -- Current set to 15 minutes
REM *                                                                             *
REM *      NETDRIVE == The drive letter to use as a temporary network drive       *
REM *                                                                             *
REM *   PREREQUISTE == Do we copy the prerequiste files or not to the remote PC   *
REM *                  NOTE - This HAS to be either TRUE or FALSE                 *
REM *                                                                             *
REM *      INTERACT == Do we set the remote command to show on the desktop of the *
REM *                  remote PC                                                  *
REM *                  NOTE - This HAS to be either TRUE or FALSE                 *
REM *                                                                             *
REM *      DOWNLOAD == Do we download the files specified on the remote PC        *
REM *                  NOTE - This HAS to be either TRUE or FALSE                 *
REM *                                                                             *
REM *  DOWNLOADWAIT == Do we wait for the download to finish before proceeding    *
REM *                  with the script.                                           *
REM *                  NOTE - This HAS to be either TRUE or FALSE                 *
REM *                                                                             *
REM *       INSTALL == Do we install/run the commands as specified on the remote  *
REM *                  PC                                                         *
REM *                  NOTE - This HAS to be either TRUE or FALSE                 *
REM *                                                                             *
REM *          COPY == Do we copy the files as specified to the remote PC         *
REM *                  NOTE - This HAS to be either TRUE or FALSE                 *
REM *                                                                             *
REM *        DELETE == Do we delete the files as specified on the remote PC       *
REM *                  NOTE - This HAS to be either TRUE or FALSE                 *
REM *                                                                             *
REM *        REBOOT == Specifies if we want to reboot the remote computer at the  *
REM *                  end of the process. This should be set, to ensure all      *
REM *                  installations are completed succesfully                    *
REM *                  NOTE - This HAS to be either TRUE or FALSE                 *
REM *                                                                             *
REM *     SHUTDELAY == The timeout in seconds for the Computer to restart         *
REM *                  NOTE - Please used at least 300 seconds, to allow users to *
REM *                         complete their work AND for waiting for computers to*
REM *                         finish rebooting                                    *
REM *                                                                             *
REM *   SHUTMESSAGE == The comment/message to use when forcing the PC to reboot   *
REM *                  NOTE - There is a limit of 127 characters for this comment *
REM *                                                                             *
REM *       LOGGING == Specifies whether you want logging enabled or not          *
REM *                  NOTE - This HAS to be either TRUE or FALSE                 *
REM *                                                                             *
REM *           LOG == Specify the filename and location for the log file         *
REM *                                                                             *
REM *******************************************************************************
:SUB_VARIABLES

FOR /f "tokens=1-4 delims=/- " %%A IN ('DATE /T') DO SET TODAY=%%D-%%C-%%B

REM * Location information *
SET PROGRAMS=C:\Work\Remote-Applications\Sources
SET APPSOURCE=C:\Work\Remote-Applications\Installs
SET FILESOURCE=C:\Work\Remote-Applications\Files

REM *   Lists to process   *
SET LIST=C:\Work\IP_Lists\itunes-Failed-part2.txt
SET DOWNLOADS=C:\Work\Remote-Applications\To_Download.txt
SET APPLIST=C:\Work\Remote-Applications\To_Install.txt
SET TOCOPY=C:\Work\Remote-Applications\To_Copy.txt
SET TOREMOVE=C:\Work\Remote-Applications\To_Remove.txt

REM * Remote Execute Info  *
SET APPTIMEOUT=900

REM *   Network Settings   *
SET NETDRIVE=Q

REM * Subsection Settings  *
SET PREREQUISTE=TRUE
SET INTERACT=FALSE
SET DOWNLOAD=TRUE
SET DOWNLOADWAIT=TRUE
SET INSTALL=TRUE
SET COPY=TRUE
SET DELETE=TRUE

REM *   Shutdown Setting   *
SET REBOOT=FALSE
SET SHUTDELAY=120
SET SHUTMESSAGE="This computer will be restarted in %SHUTDELAY% seconds, please save all your work. This shutdown has been initiated by Company."

REM *     Log Settings     *
SET LOGGING=TRUE
SET LOG="C:\Work\Remote-Applications\!TODAY! - Remote Deployment - 2nd Stage.log"

GOTO SUB_MAIN

REM *******************************************************************************
REM *******************************************************************************
REM *******************************************************************************
REM *******************************************************************************
REM ****                                                                       ****
REM ****                     NO NEED TO EDIT BELOW THIS BOX                    ****
REM ****                                                                       ****
REM *******************************************************************************
REM *******************************************************************************
REM *******************************************************************************
REM *******************************************************************************
:SUB_MAIN

REM * Sets the output to either CONsole or as specified above.
IF /I NOT %LOGGING%==TRUE SET LOG=CON

REM * Clean up network drive
NET USE %NETDRIVE%: /DELETE > NUL

ECHO.  > %LOG%
ECHO. >> %LOG%
ECHO Starting at !TODAY! at !TIME! >> %LOG%
ECHO. >> %LOG%

FOR /F "usebackq tokens=1,2,3 delims=," %%i in (%LIST%) do (
   
    ECHO ****************************************************************************** >> %LOG%
    ECHO ****************************************************************************** >> %LOG%
    ECHO * >> %LOG%
    ECHO * !TODAY! !TIME! - Starting to work on %%i >> %LOG%
    
    ECHO * >> %LOG%
    ECHO * !TODAY! !TIME! - Checking to see if the computer is on via ICMP/Ping >> %LOG%
    ECHO * >> %LOG%
    
    REM * Use "TTL=" to remove/reduce false positives when a ping response comes back
    PING %%i -n 1 -w 500 | FIND /I /C "TTL=" > NUL
    
    IF ERRORLEVEL 1 (
        
        ECHO * !TODAY! !TIME! ** ERROR ** The remote PC seems to be turned off >> %LOG%
        ECHO * >> %LOG%
        ECHO ****************************************************************************** >> %LOG%
        ECHO. >> %LOG%
        ECHO. >> %LOG%
        
    ) ELSE (
        
        ECHO * !TODAY! !TIME! - Mapping %%i's C drive to %NETDRIVE% drive >> %LOG%
        REM * Creates a temporary network drive, and checks to see if there is an error
        NET USE %NETDRIVE%: \\%%i\C$ /USER:%%j %%k >> NUL
        IF ERRORLEVEL 1 (
            
            ECHO * !TODAY! !TIME! ** ERROR ** There was an error mapping the drive >> %LOG%
            ECHO * >> %LOG%
            ECHO ****************************************************************************** >> %LOG%
            ECHO. >> %LOG%
            ECHO. >> %LOG%
            
        ) ELSE (
            
            ECHO * !TODAY! !TIME! - Connected successfully >> %LOG%
            ECHO. >> %LOG%
            ECHO * !TODAY! !TIME! - Copying files from %%i >> %LOG%
            
            REM * Checks to see if we should copy the prerequiste files to the remote PC
            IF /I %PREREQUISTE%==TRUE (
                
                REM * Copies the files
                IF NOT EXIST %NETDRIVE%\RemoteApps\wget\bin\wget.exe (
                    XCOPY %APPSOURCE% "%NETDRIVE%:\RemoteApps" /S /E /V /C /I /Y >> %LOG%
                )
                
            ) ELSE (
                
                REM * Does a dummy command to ensure an errorlevel of 0
                XCOPY /? > NUL
                ECHO * !TODAY! !TIME! - Nothing to copy >> %LOG%
                
            )
            
            IF ERRORLEVEL 1 (
                
                ECHO * !TODAY! !TIME! ** ERROR ** There was an error copying the files >> %LOG%
                
            ) ELSE (
                
                ECHO * !TODAY! !TIME! - Successfully copied the files >> %LOG%
                
                IF /I %DOWNLOAD%==TRUE (
                    
                    REM * Download the required files
                    FOR /F "usebackq tokens=1,2,3 delims=," %%a in (%DOWNLOADS%) do (
                        
                        ECHO * >> %LOG%
                        ECHO * !TODAY! !TIME! - Creating "%%c" >> %LOG%
                        
                        REM * Checks to see if the command show interact with the desktop
                        IF /I %INTERACT%==TRUE (
                            
                            %PROGRAMS%\psexec \\%%i -i -n %APPTIMEOUT% cmd /c mkdir %%c >> NUL
                            
                        ) ELSE (
                            
                            %PROGRAMS%\psexec \\%%i -n %APPTIMEOUT% cmd /c mkdir %%c >> NUL
                            
                        )
                        
                        ECHO * !TODAY! !TIME! - Downloading "%%a" >> %LOG%
                        
                        REM * Checks to see if the command show interact with the desktop
                        IF /I %INTERACT%==TRUE (
                            
                            REM * Checks to see if we should wait for the download to finish
                            IF /I %DOWNLOADWAIT%==TRUE (
                                
                                %PROGRAMS%\psexec \\%%i -i -n %APPTIMEOUT% -w %%c  C:\RemoteApps\wget\bin\wget -nc -r -nH --cut-dirs=1 --level=1 %%b >> NUL
                                
                            ) ELSE (
                                
                                %PROGRAMS%\psexec \\%%i -i -d -n %APPTIMEOUT% -w %%c  C:\RemoteApps\wget\bin\wget -nc -r -nH --cut-dirs=1 --level=1 %%b >> NUL
                                
                            )
                            
                        ) ELSE (
                            
                            REM * Checks to see if we should wait for the download to finish
                            IF /I %DOWNLOADWAIT%==TRUE (
                                
                                %PROGRAMS%\psexec \\%%i -n %APPTIMEOUT% -w %%c  C:\RemoteApps\wget\bin\wget -nc -r -nH --cut-dirs=1 --level=1 %%b >> NUL
                                
                            ) ELSE (
                                
                                %PROGRAMS%\psexec \\%%i -d -n %APPTIMEOUT% -w %%c  C:\RemoteApps\wget\bin\wget -nc -r -nH --cut-dirs=1 --level=1 %%b >> NUL
                                
                            )
                        )
                    )
                )
                
                IF /I %INSTALL%==TRUE (
                    
                    REM * Install the files now.
                    FOR /F "usebackq tokens=1,2 delims=," %%a in (%APPLIST%) do (
                        
                        ECHO * >> %LOG%
                        ECHO * !TODAY! !TIME! - Installing/Running "%%a" >> %LOG%
                        
                        REM * Checks to see if the command show interact with the desktop
                        IF /I %INTERACT%==TRUE (
                            
                            %PROGRAMS%\psexec \\%%i -i -n %APPTIMEOUT% %%b >> NUL
                            
                        ) ELSE (
                            
                            %PROGRAMS%\psexec \\%%i -n %APPTIMEOUT% %%b >> NUL
                            
                        )
                    )
                )
                
                REM * Checks to see if we need to copy the files
                IF /I %COPY%==TRUE (
                    
                    REM * Copy the specified files to their specified locations
                    FOR /F "usebackq tokens=1,2 delims=," %%a in (%TOCOPY%) do (
                        
                        ECHO * !TODAY! !TIME! - Copying required files >> %LOG%
                        
                        REM * Creates the location where the files will be copied to (as a just in case)
                        REM * then copies the files
                        MKDIR "%NETDRIVE%:\%%b" >> NUL
                        XCOPY "%FILESOURCE%\%%a" "%NETDRIVE%:\%%b" /S /E /V /C /I /Y >> %LOG%
                        
                        IF ERRORLEVEL 1 (
                            
                            ECHO * !TODAY! !TIME! ** ERROR ** There was an error copying "%%a" >> %LOG%
                            
                        ) ELSE (
                            
                            ECHO * !TODAY! !TIME! - Successfully copied "%%a" >> %LOG%
                            
                        )
                    )
                )
                
                REM * Checks to see if we are deleting files
                IF /I %DELETE%==TRUE (
                    
                    FOR /F "usebackq tokens=1,2 delims=," %%a in (%TOREMOVE%) do (
                        
                        REM * Attempts to delete/remove the files and directories specified
                        ECHO * !TODAY! !TIME! - Removing "%%a" >> %LOG%
                        DEL /S/Q/F "%NETDRIVE%:\%%a" >> %LOG%
                        RMDIR /S/F "%NETDRIVE%:\%%a" >> %LOG%
                        
                    )
                )
                
                REM * Checks to see if the remote PC should be reboot, if so reboot it
                IF /I %REBOOT%==TRUE (
                    
                    ECHO * !TODAY! !TIME! - Rebooting %%i to complete installation >> %LOG%
                    SHUTDOWN -r -t %SHUTDELAY% -f -m \\%%i -c %SHUTMESSAGE% > NUL
                    
                )
            )
            
            REM * Drop the network drive, so it's cleaned up for the next PC
            NET USE %NETDRIVE%: /DELETE > NUL
            ECHO * >> %LOG%
            ECHO * !TODAY! !TIME! - Successfully deleted %NETDRIVE% drive >> %LOG%
            ECHO * >> %LOG%
            ECHO ****************************************************************************** >> %LOG%
            
        )
    )
)

ECHO ****************************************************************************** >> %LOG%
ECHO * >> %LOG%

GOTO SUB_EXIT

REM **********************************
REM *                                *
REM *          Cleanup time          *
REM *                                *
REM **********************************
:SUB_EXIT

NET USE %NETDRIVE%: /DELETE > NUL

SET TODAY=

SET PROGRAMS=
SET APPSOURCE=
SET FILESOURCE=

SET LIST=
SET DOWNLOADS=
SET APPLIST=
SET TOCOPY=
SET TOREMOVE=

SET APPTIMEOUT=

SET NETDRIVE=

SET PREREQUISTE=
SET INTERACT=
SET DOWNLOAD=
SET DOWNLOADWAIT=
SET INSTALL=
SET COPY=
SET DELETE=

SET REBOOT=
SET SHUTDELAY=
SET SHUTMESSAGE=

SET LOGGING=
SET LOG=

ENDLOCAL
