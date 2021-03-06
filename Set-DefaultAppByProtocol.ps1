#Requires -Version 2.0

#Requires -RunAsAdministrator 

function Set-DefaultAppByProtocol { 
    <#
    .SYNOPSIS
    Defines the default application by protocol.

    .DESCRIPTION
    Defines settings in computer and user context.
    The cmdlt updates the machine registry hives (HKCR,HKLM or HKCU) with new entries/values.
    The application is  provided as the default application to open.
    Base on Windows protocol Handle.
   
    .EXAMPLE

    Set-DefaultAppByProtocol -AppName MyApp -AppScheme MySheme -AppPath C:\temp\MyAppPath -On

    Running in real mode, the protocol is registred on the system as MySheme.

    .EXAMPLE

    Set-DefaultAppByProtocol -AppName MyApp -AppScheme MySheme -AppPath C:\temp\MyAppPath -Hive HKLM
    
    Running in planning mode, the protocol is not registred on the system as MySheme.    

    .PARAMETER AppName

    Specifies the name of the default application.

    .PARAMETER AppScheme

    Specifies the scheme related to the default application.

    .PARAMETER AppPath

    Specifies the path of the default install directory of the application.

    .PARAMETER On

    Run the script in planning mode as 'WhatIf'.

    .PARAMETER Hive

    Specifies the root location in the registry.

    .INPUTS

    None. Cannot pipe objects to the script.

    .OUTPUTS

    Object. This cmdlet returns the item that it creates.

    .LINK
    https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/aa767914(v=vs.85)

    Registering an Application to a URI Scheme with registry key. It is the former method to do it.

     .LINK
    https://docs.microsoft.com/en-us/windows/uwp/launch-resume/handle-uri-activation
    
    Handle URI activation or Registering an Application to a URI Scheme with xml file. It seems like the fashion method to do it.
    
    .LINK
    https://github.com/egiberne/DefaultApps

    .NOTES

    This funtion is designed to work whether the application is installed or not installed. 

    #>
    [cmdletbinding()]
    param (
        # Name of the application
        [Parameter(Mandatory=$true  )] [string]$AppName,
        # Name of the application scheme
        [Parameter(Mandatory=$true  )] [string]$AppScheme,
        # Path of the install directory of the application
        [Parameter(Mandatory=$true  )] [string]$AppPath, 
        # Different hive to register the protocol
        [Parameter(Mandatory=$true  )] [ValidateSet('HKCR', 'HKLM', 'HKCU')][string]$Hive,
        # Switch parameter for selecting simulation mode or real mode
        [switch]$On
    )
    
    #Create a registry drive for the HKEY_CLASSES_ROOT registry hive
    switch ($Hive) {
        HKLM { $registryPath = "HKLM:SOFTWARE\Classes\$AppScheme" }
        HKCU { $registryPath = "HKCU:SOFTWARE\Classes\$AppScheme" }
        Default { 
            New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
            $registryPath = "HKCR:\$AppScheme"
        }
    }
   

    if ($On) {# "Logging Mode : Protocol will be registred" 


    New-Item -Path $registryPath -Value "URL:$AppName Protocol" -Force 

    New-ItemProperty -Path $registryPath -Name "URL Protocol" -Value " " -PropertyType String -Force
   
    New-Item -Path $registryPath"\DefaultIcon" -Value "`"$AppPath\$AppName.exe`",1" -Force

    New-Item -Path $registryPath"\shell\open\command" -Value "`"$AppPath\$AppName.exe`" `"%1`"" -Force
    }
    else {# "Planning Mode : Protocol will not be registred" 

    
    New-Item -Path $registryPath -Value "URL:$AppName Protocol" -WhatIf -Force

    New-ItemProperty -Path $registryPath -Name "URL Protocol" -Value " " -PropertyType String -WhatIf -Force
   
    New-Item -Path $registryPath"\DefaultIcon" -Value "`"$AppPath\$AppName.exe`",1" -WhatIf -Force

    New-Item -Path $registryPath"\shell\open\command" -Value "`"$AppPath\$AppName.exe`" `"%1`"" -WhatIf -Force

    }
    
}

