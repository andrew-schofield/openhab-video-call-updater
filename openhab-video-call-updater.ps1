$SettingsObject = Get-Content -Path settings.json | ConvertFrom-Json

function Update-OpenHAB {
    param([string]$item, [bool]$state)

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer " + $SettingsObject.openhabtoken)
    $headers.Add("Content-Type", "text/plain")

    $body = If ($state -eq $True) { "ON" } Else { "OFF" }

    $url = $SettingsObject.openhabbasepath + $item + '/state'

    Invoke-RestMethod $url -Method 'PUT' -Headers $headers -Body $body
}

function Check-Process {
	param([string]$processname, [string]$openhabitem, [int]$offcallcount = 0)
	
	$process = Get-Process $processname -EA 0
	if($process) {
		$processCount = (Get-NetUDPEndpoint -OwningProcess ($process).Id -EA 0|Measure-Object).count

		if (!$processCount.Equals($offcallcount)) {
			Update-OpenHAB -item $openhabitem -state $True
		}
		else {    
			Update-OpenHAB -item $openhabitem -state $False
		}
	}
	else {		
		Update-OpenHAB -item $openhabitem -state $False
	}
	Remove-Variable process
}

While($True) {

	Foreach ($process in $SettingsObject.processes) {
		Check-Process -processname $process.processname -openhabitem $process.openhabitem -offcallcount $process.nocallprocesscount
	}
	
	Start-Sleep -Seconds 30
}