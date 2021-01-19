if ((Get-ChildItem -Path 'C:\joy\backup\cpj\sql\' | Sort-Object LastAccessTime -Descending | Select-Object -first 1).LastWriteTime -ge [datetime]::Today){ 
    'OK'
}
elseif ((Get-ChildItem -Path 'C:\joy\backup\cpj\sql\' | Sort-Object LastAccessTime -Descending | Select-Object -first 1).LastWriteTime -ge [datetime]::Today.AddDays(-1)){
    'OK'
}
else{
   'FAIL'
}
