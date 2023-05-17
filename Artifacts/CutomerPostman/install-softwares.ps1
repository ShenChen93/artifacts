[CmdletBinding()]




###################################################################################################

#

# PowerShell configurations

#




# NOTE: Because the $ErrorActionPreference is "Stop", this script will stop on first failure.

#       This is necessary to ensure we capture errors inside the try-catch-finally block.

$ErrorActionPreference = "Stop"




# Hide any progress bars, due to downloads and installs of remote components.

$ProgressPreference = "SilentlyContinue"




# Ensure we force use of TLS 1.2 for all downloads.

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12




# Allow certian operations, like downloading files, to execute.

Set-ExecutionPolicy Bypass -Scope Process -Force




# Discard any collected errors from a previous execution.

$Error.Clear()




###################################################################################################

#

# Handle all errors in this script.

#




trap

{

    # NOTE: This trap will handle all errors. There should be no need to use a catch below in this

    #       script, unless you want to ignore a specific error.

    $message = $Error[0].Exception.Message

    if ($message)

    {

        Write-Host -Object "`nERROR: $message" -ForegroundColor Red

    }




    Write-Host "`nThe artifact failed to apply.`n"




    # IMPORTANT NOTE: Throwing a terminating error (using $ErrorActionPreference = "Stop") still

    # returns exit code zero from the PowerShell script when using -File. The workaround is to

    # NOT use -File when calling this script and leverage the try-catch-finally block and return

    # a non-zero exit code from the catch block.

    exit -1

}




function Ensure-PowerShell

{

    [CmdletBinding()]

    param(

        [int] $Version

    )




    if ($PSVersionTable.PSVersion.Major -lt $Version)

    {

        throw "The current version of PowerShell is $($PSVersionTable.PSVersion.Major). Prior to running this artifact, ensure you have PowerShell $Version or higher installed."

    }

}




Write-Host "start of ps1" + (Get-Date).DateTime

Write-Output $PSVersionRequired




$env:computername




Write-Host 'Configuring PowerShell session.'

Ensure-PowerShell -Version $PSVersionRequired

Enable-PSRemoting -Force -SkipNetworkProfileCheck | Out-Null

hostname

Write-Host "Preparing to install the Postman."




try

{

    $PWD.Path 

    Write-Output $PSScriptRoot




    Push-Location $PSScriptRoot




    

    #Expand-Archive -LiteralPath sqldeveloper-22.2.1.234.1810-x64.zip -DestinationPath . 




    #Write-Host Unzipped sql developer successfully




    Write-Host "Installing postmantest."

    #$p = Start-Process -Wait "Postman-win64-Setup.exe" -ArgumentList "/s" -PassThru

    & .\Postman-win64-Setup.exe -s /123 /SP- /SUPPRESSMSGBOXES /VERYSILENT /NORESTART /MERGETASKS="!runcode" -n 900 >$NULL

    #Start-Process -Wait .\sqldeveloper\sqldeveloper.exe --ArgumentList "/silent/debug/force/waitforcompletion" -PassThru

    Write-Host "`nThe artifacts was applied successfully.`n"

}catch{

    # Catch will pick up any non zero error code returned

    # You can do anything you like in this block to deal with the error, examples below:

    # $_ returns the error details

    # This will just write the error

    Write-Host "installation returned the following error $_"

    # If you want to pass the error upwards as a system error and abort your powershell script or function

    Throw "Aborted installation returned $_"

}

finally

{

    Write-Host "CONSOLEEXITCODE : $LASTEXITCODE"

    #$p.Kill();

    Write-Host "end of ps1" + (Get-Date).DateTime

    Pop-Location

}