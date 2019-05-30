$app = Get-WmiObject -Class Win32_Product | Where-Object { 
    $_.Name -match "Deep Security Agent" 
}
$app.Uninstall()
echo "$(Get-Date -format T) - DSA Uninstalled Finished"



