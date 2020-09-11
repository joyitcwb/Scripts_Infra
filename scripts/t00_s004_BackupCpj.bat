cd c:\preambulo\bkp
REM ### Inicio das declarações de variáveis ###
set diretorio="C:\joy\backup\cpj\sql"
REM se quiser o backup seja compactado, troque o valor de "zip" para 1 se não quiser, troque para 0.
set zip=0
REM marque 1 para versão E. Irá lançar na auditoria.
set aud=0
REM Informe o usuário que receberá o aviso do becape.
set user=99
REM troque localhost pelo ip do servidor.
set servidor=10.1.1.214
REM troque root pelo usuário do banco de dados.
set usuario=root
REM troque root pela senha do banco de dados.
set senha=root
REM troque cpjwcs pelo nome da base de dados.
set base=cpjwcs
REM troque 3306 pela porta do banco de dados.
set porta=3306
REM armazena e organiza a data do computador.
set date=
for /F "tokens=1-3 delims=/ " %%a in ('date /T') do set date=%%a%%b%%c
REM armazena e organiza a hora do computador.
set time=
for /F "tokens=1-3 delims=: " %%a in ('time /T') do set time=%%c%%a%%b
REM armazena e organiza a data e hora do computador em apenas uma variavel.
set date_time=%date%_%time%
REM ### Fim das declarações de variáveis ###

IF [%zip%] EQU [1] (
C:\Preambulo\BKP\mysqldump  --default-character-set=latin1 --skip-opt --create-options --extended-insert --set-charset --flush-logs --single-transaction --disable-keys --routines -h%servidor% -u%usuario% -p%senha% -P%porta% %base% > %base%.sql
7za.exe a -tzip -mmt %base%_%date_time%.zip %base%.sql
set nome=%base%_%date_time%.zip
set tam=
for %%I in (%base%.sql) do set tam=%%~zI
) ELSE (
C:\Preambulo\BKP\mysqldump  --default-character-set=latin1 --skip-opt --create-options --extended-insert --set-charset --flush-logs --single-transaction --disable-keys --routines -h%servidor% -u%usuario% -p%senha% -P%porta% %base% > C:\joy\backup\cpj\sql\%base%_%date_time%.sql
set nome=%base%_%date_time%.sql
set tam= 
for %%I in (%base%_%date_time%.sql) do set tam=%%~zI
)

REM prepara lançamento na auditoria
set /A tam=%tam%/1024 
echo insert into auditoria (usuario, aviso_usuario, data_hora, operacao, tabela, chave, ocorrencia) values (99, %user%, now(0), 'I', 'bkp', '%nome%', 'Becape realizado. Tamanho do arquivo: %tam% KB') > resul.txt

if [%aud%] EQU [1] (
mysql -h%servidor% -u%usuario% -p%senha% -P%porta% %base% < resul.txt
)