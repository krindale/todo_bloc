param(
    [Parameter(Mandatory=$true)]
    [string]$Title,
    [Parameter(Mandatory=$true)]
    [string]$Message
)

try {
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null

    $toastXml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    $textNodes = $toastXml.GetElementsByTagName("text")
    $textNodes.Item(0).AppendChild($toastXml.CreateTextNode($Title)) | Out-Null
    $textNodes.Item(1).AppendChild($toastXml.CreateTextNode($Message)) | Out-Null

    $toast = [Windows.UI.Notifications.ToastNotification]::new($toastXml)
    $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Todo App")
    $notifier.Show($toast)
    
    Write-Output "SUCCESS: Toast notification sent successfully"
} catch {
    Write-Output "ERROR: $($_.Exception.Message)"
    exit 1
}
