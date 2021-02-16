# openhab-video-call-updater

![GitHub repo size](https://img.shields.io/github/repo-size/andrew-schofield/openhab-video-call-updater)
![GitHub contributors](https://img.shields.io/github/contributors/andrew-schofield/openhab-video-call-updater)
![GitHub stars](https://img.shields.io/github/stars/andrew-schofield/openhab-video-call-updater?style=social)
![GitHub forks](https://img.shields.io/github/forks/andrew-schofield/openhab-video-call-updater?style=social)

openhab-video-call-updater is a powershell utility that allows people to do update OpenHAB with their video calling status.

This can be used to trigger an event in OpenHAB whenever you start/stop a video call in your favourite video calling application. It sends a simple ON/OFF message to a switch item configured for each application.

## Why this tool?

In my line of work, I use multiple video conferencing applications, on multiple machines, which don't have integrated calendars. Using this tool on all my machines, I can notify OpenHAB when I'm on a video call, which in turn switches on a visible notification that my children can use to know that I don't want to be disturbed.


## Prerequisites

Before you begin, ensure you have met the following requirements:
* A Windows machine.
* OpenHAB 3 (see below)

This tool is designed such that you have 1 item per video call application. This way it is possible to run this tool across multiple machines at once if necessary. In OpenHAB, you can create a group with all these items as members, and set the "One ON then ON else OFF" aggregation to set the state automatically if any of the items are ON.

## Configuring openhab-video-call-updater

### Create a `settings.json` file based on the `settings.json.template` file.

1. Configure the `openhabbaseurl` property to be the REST API url of your OpenHAB instance (see [here](https://www.openhab.org/docs/configuration/restdocs.html))
2. Configure the `openhabtoken` property to be a valid auth token for your OpenHAB instance (see [here](https://www.openhab.org/docs/configuration/apitokens.html))
3. Configure the `processes` property to contain the list of video conferencing tools you want to check for.
    - By default, Zoom, Slack, Teams, and GoToMeeting are preconfigured, simply configure the correct OpenHAB item to update.

### Adding a new tool to check for

1. Find the process name of the tool using task manager
2. Make sure your tool is running, but not in a video call
3. In powershell, run `(Get-NetUDPEndpoint -OwningProcess (Get-Process $processname -EA 0).Id -EA 0|Measure-Object).count` where `$processname` is the process name you just discovered, and make a note of the response.
4. Start a video call
5. Run the same command again, and confirm that the response is different. If it is, then this tool will work to detect if you're on a call, if not, then unfortunately this tool won't work.
6. Create a new entry in configuration file with the process name, openhab item, and the number from step 3.

## Using openhab-video-call-updater

To use openhab-video-call-updater, follow these steps:

Run `openhab-video-call-updater.ps1` from a powershell terminal. The script will update openhab every 30 seconds with the current video call statuses.

Alternatively, you can create a windows scheduled task that starts when you log on, just be sure to configure the starting directory to be the location of the script so that it will load the `settings.json` file.

## Manual changes to support OpenHAB 2.5

In `openhab-video-call-updater.ps1` find the following line:
```
$url = $SettingsObject.openhabbasepath + $item + '/state'
```
and replace it with:
```
$url = $SettingsObject.openhabbasepath + $item
```
Delete the following line:
```
$headers.Add("Authorization", "Bearer " + $SettingsObject.openhabtoken)
```
Find the following line:
```
Invoke-RestMethod $url -Method 'PUT' -Headers $headers -Body $body
```
and replace `'PUT'` with `'POST'`

## License

This project uses the following license: [MIT](https://choosealicense.com/licenses/mit/).