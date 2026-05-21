. C:\pos\landing\img\_capture.ps1
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

function Get-Root {
    $h = Get-PosWindow
    return [System.Windows.Automation.AutomationElement]::FromHandle($h)
}

function Find-Element([System.Windows.Automation.AutomationElement]$root, [string]$nameOrId) {
    # Try by Name
    $byName = $root.FindFirst(
        [System.Windows.Automation.TreeScope]::Descendants,
        (New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::NameProperty, $nameOrId))
    )
    if ($byName) { return $byName }
    # Try by AutomationId
    return $root.FindFirst(
        [System.Windows.Automation.TreeScope]::Descendants,
        (New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::AutomationIdProperty, $nameOrId))
    )
}

function Invoke-Element($element) {
    if ($null -eq $element) { throw "Element is null" }
    $pattern = $element.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
    $pattern.Invoke()
}

function Click-ByName([string]$name) {
    $root = Get-Root
    $el = Find-Element $root $name
    if ($null -eq $el) { throw "Element not found: $name" }
    Invoke-Element $el
    Start-Sleep -Milliseconds 600
}

function Press-Pin([string]$pin) {
    foreach ($digit in $pin.ToCharArray()) {
        Click-ByName ([string]$digit)
        Start-Sleep -Milliseconds 200
    }
}
