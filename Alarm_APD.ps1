Import-Module VMware.VimAutomation.Core -ErrorAction SilentlyContinue
Import-Module VMware.VimAutomation.Storage -ErrorAction SilentlyContinue
Import-Module VMware.VimAutomation.Vds -ErrorAction SilentlyContinue


function New-AlarmDefinition {
<#
	.SYNOPSIS
		This cmdlet creates a new alarm defintion on the specified entity in vCenter.
	.DESCRIPTION
		This cmdlet creates a new alarm defintion on the specified entity in vCenter.
		An alarm trigger is required in order to create a new alarm definition.
		They can be created by using the New-AlarmTrigger cmdlet.
	
		After the alarm definition is created, if alarm actions are required use
		the cmdlet New-AlarmAction to create actions for the alarm.
	.PARAMETER Name
		Specifies the name of the alarm you want to create.
	.PARAMETER Description
		Specifies the description for the alarm.
	.PARAMETER Entity
		Specifies where to create the alarm. To create the alarm at the root
		level of vCenter use the entity 'Datacenters', otherwise specify any
		object name.
	.PARAMETER Trigger
		Specifies the alarm event, state, or metric trigger(s). The alarm
		trigger(s) are created with the New-AlarmTrigger cmdlet. For more
		information about triggers, run Get-Help New-AlarmTrigger.
	.PARAMETER Enabled
		Specifies if the alarm is enabled when it is created. If unset, the
		default value is true.	
	.PARAMETER ActionRepeatMinutes
		Specifies the frequency how often the actions should repeat when an alarm
		does not change state.
	.PARAMETER ReportingFrequency
		Specifies how often the alarm is triggered, measured in minutes. A zero
		value means the alarm is allowed to trigger as often as possible. A
		nonzero value means that any subsequent triggers are suppressed for a
		period of minutes following a reported trigger. 
	
		If unset, the default value is 0. Allowed range is 0 - 60. 
	.PARAMETER ToleranceRange
		Specifies the tolerance range for the metric triggers, measure in
		percentage. A zero value means that the alarm triggers whenever the metric
		value is above or below the specified value. A nonzero means that the
		alarm triggers only after reaching a certain percentage above or below
		the nominal trigger value.
	
		If unset, the default value is 0. Allowed range is 0 - 100.
	.PARAMETER Server
		Specifies the vCenter Server system on which you want to run the cmdlet.
		If no value is passed to this parameter, the command runs on the default
		server, $DefaultVIServer. For more information about default servers,
		see the description of Connect-VIServer.
	.OUTPUTS
		VMware.Vim.ManagedObjectReference
	.NOTES
		This cmdlet requires a connection to vCenter to create the alarm action.
	.LINKS
		http://pubs.vmware.com/vsphere-6-0/topic/com.vmware.wssdk.apiref.doc/vim.alarm.AlarmSpec.html
	.EXAMPLE
		PS C:\> $trigger = New-AlarmTrigger -StateType runtime.connectionState -StateOperator isEqual -YellowStateCondition disconnected -RedStateCondition notResponding -ObjectType HostSystem
		PS C:\> New-AlarmDefinition -Name 'Host Connection' -Description 'Host Connection State Alarm -Entity Datacenters -Trigger $trigger -ActionRepeatMinutes 10
		Type  Value
		----  -----
		Alarm alarm-1801
	
		This will create a host connection state alarm trigger and store it in
		the variable $trigger. Then it will create a new alarm 'Host Connection'
		on the root level of vCenter and set the action to repeat every 10 mins.
#>
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[Alias('AlarmName')]
		[string]$Name,
		
		[string]$Description,
		
		[Parameter(Mandatory = $true)]
		[string]$Entity,
		
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[VMware.Vim.AlarmExpression[]]$Trigger,
		
		[boolean]$Enabled = $true,
		
		[ValidateRange(0, 60)]
		[int32]$ActionRepeatMinutes,
		
		[ValidateRange(0, 60)]
		[int32]$ReportingFrequency = 0,
		
		[ValidateRange(0, 100)]
		[int32]$ToleranceRange = 0,
		
		[string]$Server
	)
	BEGIN {
		Write-Verbose -Message "Adding parameters with default values to PSBoundParameters"
		foreach ($Key in $MyInvocation.MyCommand.Parameters.Keys) {
			$Value = Get-Variable $Key -ValueOnly -ErrorAction SilentlyContinue
			if ($Value -and !$PSBoundParameters.ContainsKey($Key)) {
				$PSBoundParameters[$Key] = $Value
			}
		}
	}
	PROCESS {
		try {
			if ($PSBoundParameters.ContainsKey('Server')) {
				$Object = Get-Inventory -Name $PSBoundParameters['Entity'] -ErrorAction Stop -Server $PSBoundParameters['Server']
				$AlarmMgr = Get-View AlarmManager -ErrorAction Stop -Server $PSBoundParameters['Server']
			} else {
				$Object = Get-Inventory -Name $PSBoundParameters['Entity'] -ErrorAction Stop -Server $global:DefaultVIServer
				$AlarmMgr = Get-View AlarmManager -ErrorAction Stop -Server $global:DefaultVIServer
			}
			
			if ($PSCmdlet.ShouldProcess($global:DefaultVIServer, "Create alarm $($PSBoundParameters['Name'])")) {
				$Alarm = New-Object -TypeName VMware.Vim.AlarmSpec
				$Alarm.Name = $PSBoundParameters['Name']
				$Alarm.Description = $PSBoundParameters['Description']
				$Alarm.Enabled = $PSBoundParameters['Enabled']
				$Alarm.Expression = New-Object -TypeName VMware.Vim.OrAlarmExpression
				$Alarm.Expression.Expression += $PSBoundParameters['Trigger']
				$Alarm.Setting = New-Object -TypeName VMware.Vim.AlarmSetting
				$Alarm.Setting.ReportingFrequency = $PSBoundParameters['ReportingFrequency'] * 60
				$Alarm.Setting.ToleranceRange = $PSBoundParameters['ToleranceRange'] * 100
				$Alarm.ActionFrequency = $PSBoundParameters['ActionRepeatMinutes'] * 60
				$AlarmMgr.CreateAlarm($Object.Id, $Alarm)
			}
		} catch {
			$PSCmdlet.ThrowTerminatingError($_)
		}
	}
} #End of New-AlarmDefinition function

function Get-EventId {
<#
	.SYNOPSIS
		This cmdlet collects all of the available events from vCenter.
	.DESCRIPTION
		This cmdlet collects all of the available events from vCenter. It will
		provide the event type, event type id (if applicable), category,
		description, and summary of the event. The information can be used to
		identify the available events on vCenter as well as gathering the event
		type and event type id (if applicable) required for configuring an alarm.
	
		If the event type is 'EventEx' or 'ExtendedEvent' both the event type
		and event type id will be required to create a new event based vCenter
		alarm.
	
		The event types can be unique across vCenters. If you are connected to 
		more than one vCenter events from each vCenter will be generated. A
		vCenter property is available to help determine the correct event type
		on a given vCenter. This is extrememly useful when trying to create
		a event based vCenter alarm.
	.PARAMETER Category
		Specifies the name of the event category you would like to see. Allowed
		values are 'info', 'warning', 'error', and 'user'.
	.OUTPUTS
		System.Management.Automation.PSCustomObject
	.NOTES
		This cmdlet requires a connection to vCenter to collect event data.
	.EXAMPLE
		PS C:\> Get-EventId -Category Error
		
		EventType   : ExtendedEvent
		EventTypeId : ad.event.ImportCertFailedEvent
		Category    : error
		Description : Import certificate failure
		FullFormat  : Import certificate failed.
		vCenter		: vCenter01
		EventType   : ExtendedEvent
		EventTypeId : ad.event.JoinDomainFailedEvent
		Category    : error
		Description : Join domain failure
		FullFormat  : Join domain failed.
		vCenter		: vCenter01
		EventType   : ExtendedEvent
		EventTypeId : ad.event.LeaveDomainFailedEvent
		Category    : error
		Description : Leave domain failure
		FullFormat  : Leave domain failed.
		vCenter		: vCenter01
		.....
#>
	[CmdletBinding()]
	param (
		[VMware.Vim.EventCategory]$Category
	)
	
	foreach ($Mgr in (Get-View EventManager)) {
		$vCenter = $Mgr.Client.ServiceUrl.Split('/')[2]
		if ($PSBoundParameters.ContainsKey('Category')) {
			$Events += $Mgr.Description.EventInfo | Where-Object -FilterScript {
				$_.Category -eq $PSBoundParameters['Category']
			}
		} else {
			$Events += $Mgr.Description.EventInfo
		}
		
		$Events | ForEach-Object -Process {
			$Hash = [ordered]@{}
			$Hash.Add('EventType', $_.Key)
			if ($_.Key -eq 'ExtendedEvent' -or $_.Key -eq 'EventEx') {
				$Hash.Add('EventTypeId', $_.FullFormat.Split('|')[0])
			}
			$Hash.Add('Category', $_.Category)
			$Hash.Add('Description', $_.Description)
			if ($Hash['EventType'] -eq 'ExtendedEvent' -or $Hash['EventType'] -eq 'EventEx') {
				$Hash.Add('FullFormat', $_.FullFormat.Split('|')[1])
			} else {
				$Hash.Add('FullFormat', $_.FullFormat)
			}
			$Hash.Add('vCenter', $vCenter)
			New-Object -TypeName System.Management.Automation.PSObject -Property $Hash
		}
	}
} #End of Get-EventId function

function New-AlarmTrigger {
<#
	.SYNOPSIS
		This cmdlet creates a vCenter event, state, or metric alarm trigger.
	.DESCRIPTION
		This cmdlet creates a vCenter event, state, or metric alarm trigger.
		The trigger is used with the New-AlarmDefinition cmdlet to create a new
		alarm in vCenter. This cmdlet will only create one alarm trigger. If more
		triggers are required store the triggers in an array.
	.PARAMETER EventType
		Specifies the type of the event to trigger on. The event types can be
		discovered by using the Get-EventId cmdlet. If the the event type is
		'EventEx' or 'ExtendedEvent' the EventTypeId parameter is required.
	.PARAMETER EventTypeId
		Specifies the id of the event type. Only used when the event type is an
		'EventEx' or 'ExtendedEvent'.
	.PARAMETER Status
		Specifies the status of the event. Allowed values are green, yellow, or
		red.
	.PARAMETER StateType
		Specifies the state type to trigger on. Allowed values are
		runtime.powerstate (HostSystem), summary.quickStats.guestHeartbeatStatus
		(VirtualMachine), or runtime.connectionState (VirtualMachine).
	.PARAMETER StateOperator
		Specifies the operator condition on the target state. Allowed values are
		'isEqual' or 'isUnequal'.
	.PARAMETER YellowStateCondition
		Specifies the yellow state condition. When creating a state alarm
		trigger at least one condition must be specified for a valid trigger to
		be created. If the parameter is not set, the yellow condition is unset.
	.PARAMETER RedStateCondition
		Specifies the red state condition. When creating a state alarm trigger
		at least one condition must be specified for a valid trigger to be
		created. If the parameter is not set, the red condition is unset.
	.PARAMETER MetricId
		Specifies the id of the metric to trigger on. The metric ids can be
		discovered by using the Get-MetricId cmdlet.
	.PARAMETER MetricOperator
		Specifies the operator condition on the target metric. Allowed values
		are 'isAbove' or 'isBelow'.
	.PARAMETER Yellow
		Specifies the threshold value that triggers a yellow status. Allowed
		range is 1% - 100%.
	.PARAMETER YellowInterval
		Specifies the time interval in minutes for which the yellow condition
		must be true before the yellow status is triggered. If unset, the yellow
		status is triggered immediately when the yellow condition becomes true.
	.PARAMETER Red
		Specifies the threshold value that triggers a red status. Allowed range
		is 1% - 100%.
	.PARAMETER RedInterval
		Specifies the time interval in minutes for which the red condition must
		be true before the red status is triggered. If unset, the red status is
		triggered immediately when the red condition becomes true.
	.PARAMETER ObjectType
		Specifies the type of object on which the event is logged, the object
		type containing the state condition or the type of object containing the
		metric. 
		
		When creating a state alarm trigger the only acceptable values are
		'HostSystem' or 'VirtualMachine'. The supported state types for each object
		are as follows:
			VirtualMachine type: runtime.powerState or summary.quickStats.guestHeartbeatStatus
			HostSystem type: runtime.connectionState
	.OUTPUTS
		(Event|State|Metric)AlarmExpression	
	.NOTES
		This cmdlet requires the PowerCLI module to be imported. 
	.LINK
		Event Alarm Trigger
		http://pubs.vmware.com/vsphere-6-0/topic/com.vmware.wssdk.apiref.doc/vim.alarm.EventAlarmExpression.html
		
		State Alarm Trigger
		http://pubs.vmware.com/vsphere-6-0/topic/com.vmware.wssdk.apiref.doc/vim.alarm.StateAlarmExpression.html
	
		Metric Alarm Trigger
		http://pubs.vmware.com/vsphere-6-0/topic/com.vmware.wssdk.apiref.doc/vim.alarm.MetricAlarmExpression.html
	.EXAMPLE
		PS C:\> New-AlarmTrigger -EventType "DasDisabledEvent" -Status Red -ObjectType ClusterComputeResource
		
		Comparisons :
		EventType   : DasDisabledEvent
		ObjectType  : ClusterComputeResource
		Status      : red
		
		Creates an event trigger on 'DasDisabledEvent' (HA Disabled) with a
		status on 'Red'. The object type is a ClusterComputerResource because
		this event occurs at a cluster level.
	.EXAMPLE
		PS C:\> New-AlarmTrigger -MetricId (Get-MetricId | Where Name -EQ 'cpu.usage.average').Key -Operator isAbove -Yellow 90 -YellowInterval 30 -Red 98 -RedInterval 15 -ObjectType HostSytem
		
		Operator       : isAbove
		Type           : HostSytem
		Metric         : VMware.Vim.PerfMetricId
		Yellow         : 9000
		YellowInterval : 30
		Red            : 9800
		RedInterval    : 15
		
		Creates a trigger on the 'cpu.usage.average' metric where the warning
		condition must be above 90% for 30mins and the alert condition must be
		above 98% for 15mins. The object type is a HostSystem.
	.EXAMPLE
		PS C:\temp> New-AlarmTrigger -StateType runtime.connectionState -StateOperator isEqual -YellowStateCondition Disconnected -RedStateCondition notResponding -ObjectType HostSystem
		Operator  : isEqual
		Type      : HostSystem
		StatePath : runtime.connectionState
		Yellow    : Disconnected
		Red       : notResponding
		
		Creates a trigger on the 'runtime.connectionState' condition where the
		warning condition is 'disconnected' and the alert condition is
		'notResponding'. The object type is a HostSystem.
#>
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Event')]
		[string]$EventType,
		
		[Parameter(ParameterSetName = 'Event')]
		[string]$EventTypeId,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'Event')]
		[ValidateSet('Green', 'Yellow', 'Red')]
		[string]$Status,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'State')]
		[ValidateSet('runtime.powerState', 'summary.quickStats.guestHeartbeatStatus', 'runtime.connectionState')]
		[string]$StateType,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'State')]
		[VMware.Vim.StateAlarmOperator]$StateOperator,
		
		[Parameter(ParameterSetName = 'State')]
		[ValidateSet('disconnected', 'notResponding', 'connected', 'noHeartbeat', 'intermittentHeartbeat', 'poweredOn', 'poweredOff', 'suspended')]
		[string]$YellowStateCondition,
		
		[Parameter(ParameterSetName = 'State')]
		[ValidateSet('disconnected', 'notResponding', 'connected', 'noHeartbeat', 'intermittentHeartbeat', 'poweredOn', 'poweredOff', 'suspended')]
		[string]$RedStateCondition,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'Metric')]
		[string]$MetricId,
		
		[Parameter(Mandatory = $true, ParameterSetName = 'Metric')]
		[VMware.Vim.MetricAlarmOperator]$MetricOperator,
		
		[Parameter(ParameterSetName = 'Metric')]
		[ValidateRange(1, 100)]
		[int32]$Yellow,
		
		[Parameter(ParameterSetName = 'Metric')]
		[ValidateRange(1, 90)]
		[int32]$YellowInterval,
		
		[Parameter(ParameterSetName = 'Metric')]
		[ValidateRange(1, 100)]
		[int32]$Red,
		
		[Parameter(ParameterSetName = 'Metric')]
		[ValidateRange(1, 90)]
		[int32]$RedInterval,
		
		[Parameter(Mandatory = $true)]
		[ValidateSet('ClusterComputeResource', 'Datacenter', 'Datastore', 'DistributedVirtualSwitch', 'HostSystem', 'Network', 'ResourcePool', 'VirtualMachine')]
		[string]$ObjectType
	)
	try {
		if ($PSCmdlet.ShouldProcess("vCenter alarm", "Create $($PSCmdlet.ParameterSetName) trigger")) {
			if ($PSCmdlet.ParameterSetName -eq 'Event') {
				$Expression = New-Object -TypeName VMware.Vim.EventAlarmExpression
				$Expression.EventType = $PSBoundParameters['EventType']
				if ($PSBoundParameters.ContainsKey('EventTypeId')) {
					$Expression.EventTypeId = $PSBoundParameters['EventTypeId']
				}
				$Expression.ObjectType = $PSBoundParameters['ObjectType']
				$Expression.Status = $PSBoundParameters['Status']
				$Expression
			} elseif ($PSCmdlet.ParameterSetName -eq 'Metric') {
				$Expression = New-Object -TypeName VMware.Vim.MetricAlarmExpression
				$Expression.Metric = New-Object -TypeName VMware.Vim.PerfMetricId
				$Expression.Metric.CounterId = $PSBoundParameters['MetricId']
				$Expression.Metric.Instance = ""
				$Expression.Operator = $PSBoundParameters['MetricOperator']
				$Expression.Red = ($PSBoundParameters['Red'] * 100)
				$Expression.RedInterval = ($PSBoundParameters['RedInterval'] * 60)
				$Expression.Yellow = ($PSBoundParameters['Yellow'] * 100)
				$Expression.YellowInterval = ($PSBoundParameters['YellowInterval'] * 60)
				$Expression.Type = $PSBoundParameters['ObjectType']
				$Expression
			} elseif ($PSCmdlet.ParameterSetName -eq 'State') {
				$Expression = New-Object -TypeName VMware.Vim.StateAlarmExpression
				$Expression.Operator = $PSBoundParameters['StateOperator']
				$Expression.Type = $PSBoundParameters['ObjectType']
				$Expression.StatePath = $PSBoundParameters['StateType']
				
				if ($PSBoundParameters.ContainsKey('RedStateCondition')) {
					if ($PSBoundParameters['RedStateCondition'] -eq 'intermittentHeartbeat') {
						$Expression.Red = 'yellow'
					} elseif ($PSBoundParameters['RedStateCondition'] -eq 'noHeartbeat') {
						$Expression.Red = 'red'
					} else {
						$Expression.Red = $PSBoundParameters['RedStateCondition']
					}
				}
				
				if ($PSBoundParameters.ContainsKey('YellowStateCondition')) {
					if ($PSBoundParameters['YellowStateCondition'] -eq 'intermittentHeartbeat') {
						$Expression.Yellow = 'yellow'
					} elseif ($PSBoundParameters['YellowStateCondition'] -eq 'noHeartbeat') {
						$Expression.Yellow = 'red'
					} else {
						$Expression.Yellow = $PSBoundParameters['YellowStateCondition']
					}
				}
				$Expression
			}
		}
	} catch {
		$PSCmdlet.ThrowTerminatingError($_)
	}
} #End of New-AlarmTrigger function

#Get-EventId | Where-Object -FilterScript { $_.Description -match 'Lost Storage Connectivity' }

#$EventType = Get-EventId | Where-Object -FilterScript { $_.EventTypeId -eq 'esx.problem.storage.connectivity.lost' }
$EventType = Get-EventId | Where-Object -FilterScript { $_.EventTypeId -eq 'esx.problem.storage.apd.start' }


$Trigger = New-AlarmTrigger -EventType $EventType.EventType -EventTypeId $EventType.EventTypeId -Status Red -ObjectType HostSystem

New-AlarmDefinition -Name "SG Alarm All paths are down" -Description "All paths are down" -Entity Datacenters -Trigger $Trigger 
#New-AlarmDefinition -Name "SG Alarm All paths are down" -Description "All paths are down" -Entity Datacenters -Trigger $Trigger -ActionRepeatMinutes 5

Get-AlarmDefinition -Name "SG Alarm All paths are down" | New-AlarmAction -Snmp
Get-AlarmDefinition -Name "SG Alarm All paths are down" | Get-AlarmAction -ActionType SendSNMP | New-AlarmActionTrigger -StartStatus "Green" -EndStatus "Yellow"


##
#---Set Alarm Action for High Priority Alarms---
#Foreach ($HighPriorityAlarm in $HighPriorityAlarms) {
#Get-AlarmDefinition -Name $HighPriorityAlarm.name | Get-AlarmAction -ActionType SendEmail| Remove-AlarmAction -Confirm:$false
#Get-AlarmDefinition -name "SG Alarm All paths are down" | Set-AlarmDefinition -ActionRepeatMinutes (60 * 4) # 4 hours

#Get-AlarmDefinition -Name "SG Alarm All paths are down" | New-AlarmAction -Email -To @($AlertEmailRecipients)
#Get-AlarmDefinition -Name "SG Alarm All paths are down" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Green" -EndStatus "Yellow"
#Get-AlarmDefinition -Name "SG Alarm All paths are down" | Get-AlarmAction -ActionType SendEmail | Get-AlarmActionTrigger | Select -First 1 | Remove-AlarmActionTrigger -Confirm:$false
#Get-AlarmDefinition -Name "SG Alarm All paths are down" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Red" -Repeat
#Get-AlarmDefinition -Name "SG Alarm All paths are down" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Red" -EndStatus "Yellow"
#Get-AlarmDefinition -Name "SG Alarm All paths are down" | Get-AlarmAction -ActionType SendEmail | New-AlarmActionTrigger -StartStatus "Yellow" -EndStatus "Green"
