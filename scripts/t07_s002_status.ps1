if ((Get-ChildItem -Path 'C:\joy\backup\cpj\sql\' | select -last 1).LastWriteTime -ge [datetime]::Today){ 
    'OK'
}
elseif ((Get-ChildItem -Path 'C:\joy\backup\cpj\sql\' | select -last 1).LastWriteTime -ge [datetime]::Yesterday){
    'OK'
}
else{
   'FAIL'
}
