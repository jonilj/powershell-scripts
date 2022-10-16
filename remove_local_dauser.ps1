

Get-CimInstance -ClassName win32_userprofile  | Where-Object { $_.LocalPath.split('\')[-1] -like 'da*' } | Remove-CimInstance