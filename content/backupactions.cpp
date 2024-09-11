#include "backupactions.h"
#include "constants.h"

BackupActions::BackupActions(QObject *parent)
    : QObject{parent}
{
    CreateOrUpdateBatchFile();
}

void BackupActions::DoBackup()
{
    QProcess backupProcess;
    //QString program=batchFileName;

    backupProcess.start(batchFileName);

    if (!backupProcess.waitForFinished()) {
        qWarning() << "Процесс не завершился успешно:" << backupProcess.errorString();
    } else {
        qDebug() << "Процесс завершился успешно.";
    }
}

void BackupActions::SetTaskToBackup(int interval)
{
    Constants constan;
    //TooDO
    QSettings settings("settings.ini",QSettings::IniFormat);
    settings.beginGroup(constan.backupCategoryName());

    QProcess setTaskProcess;
    QFile batchFile(batchFileName);
    QFileInfo batchFileInfo(batchFile);
    QString program;/*= QString(R"(
@echo off
set taskName=%1
set taskPath=%2
set interval=%3
set startTime=09:00

:: Проверка существования задачи
schtasks /query /tn "%taskName%" >nul 2>&1
if %errorlevel% equ 0 (
    :: Задача существует, изменяем ее
    schtasks /change /tn "%taskName%" /tr "%taskPath%" /st %startTime% /ri %interval% /f
) else (
    :: Задача не существует, создаем новую
    schtasks /create /tn "%taskName%" /tr "%taskPath%" /sc daily /mo %interval% /st %startTime% /f
)
)").arg(backupTaskName,batchFileInfo.absoluteFilePath(),interval,/*starttime*/ //);*/

    if(IsTaskExist())
    {
        program= QString(R"(schtasks /change /tn "%taskName%" /tr "%taskPath%" /st %startTime% /ri %interval% /f)");
    }
    else
    {
        program= QString(R"(schtasks /create /tn "%taskName%" /tr "%taskPath%" /sc daily /mo %interval% /st %startTime% /f)");
    }

}

void BackupActions::DeleteTaskToBackup()
{
    QProcess deleteTask;
    QString program=QString("schtasks /delete /tn %1 /f").arg();

    deleteTask.start(program);

    if (!deleteTask.waitForFinished()) {
        qWarning() << "Процесс не завершился успешно:" << deleteTask.errorString();
    } else {
        qDebug() << "Процесс завершился успешно.";
    }
}

bool BackupActions::IsTaskExist()
{
    QProcess process;
    QString program = "schtasks /query /tn";

    process.start(program, arguments);
    process.waitForFinished();

    int exitCode = process.exitCode();
    return !(exitCode == 0);
}

void BackupActions::RestoreFromBackup(QString host, QString port, QString user, QString database, QString backupFilePath)
{
    QProcess restoreProcess;
    QString program = QString("pg_restore -h %1 -p %2 -U %3 -d %4 -F t -v %5").arg(host,port,user,database,backupFilePath);

    restoreProcess.start(program);

    if (!restoreProcess.waitForFinished()) {
        qWarning() << "Процесс не завершился успешно:" << restoreProcess.errorString();
    } else {
        qDebug() << "Процесс завершился успешно.";
    }
}

void BackupActions::CreateOrUpdateBatchFile()
{
    QDir dir;
    QString content=R"(
@echo off
setlocal enabledelayedexpansion

REM Путь к ini-файлу
set "iniFile=%~dp0settings.ini"

REM Функция для чтения значений из ini-файла
:readIni
set "sectionFound="
for /f "usebackq tokens=1* delims==" %%A in (`findstr /n "^" "%iniFile%"`) do (
    set "line=%%A"
    set "value=%%B"
    if "!line:~1!"=="[%1]" set "sectionFound=1"
    if defined sectionFound (
        if "!line:~0,1!"=="[" if not "!line:~1!"=="[%1]" goto :eof
        if "!line:~0,1!" neq "[" if "!line:~0,1!" neq ";" (
            for /f "tokens=1* delims==" %%C in ("!value!") do (
                if "%%C"=="%2" set "%3=%%D"
            )
        )
    )
)
:eof
exit /b

REM Чтение параметров из секции [Database]
call :readIni "Database" "host" dbHost
call :readIni "Database" "port" dbPort
call :readIni "Database" "name" dbName
call :readIni "Database" "user" dbUser
call :readIni "Database" "password" dbPassword

REM Чтение параметров из секции [Backup]
call :readIni "Backup" "backup_dir" backupDir
call :readIni "Backup" "backup_file" backupFile

REM Проверка наличия всех необходимых параметров
if not defined dbHost (
    echo Ошибка: Параметр "host" не найден в секции [Database].
    exit /b 1
)
if not defined dbPort (
    echo Ошибка: Параметр "port" не найден в секции [Database].
    exit /b 1
)
if not defined dbName (
    echo Ошибка: Параметр "name" не найден в секции [Database].
    exit /b 1
)
if not defined dbUser (
    echo Ошибка: Параметр "user" не найден в секции [Database].
    exit /b 1
)
if not defined dbPassword (
    echo Ошибка: Параметр "password" не найден в секции [Database].
    exit /b 1
)
if not defined backupDir (
    echo Ошибка: Параметр "backup_dir" не найден в секции [Backup].
    exit /b 1
)
if not defined backupFile (
    echo Ошибка: Параметр "backup_file" не найден в секции [Backup].
    exit /b 1
)

REM Создание директории для бэкапа, если она не существует
if not exist "%backupDir%" mkdir "%backupDir%"

REM Автоинкрементация имени файла бэкапа
set "backupPath=%backupDir%\%backupFile%"
set "counter=1"
set "baseName=%backupFile:~0,-4%"
set "extension=%backupFile:~-4%"

:checkFile
if exist "%backupPath%" (
    set /a counter+=1
    set "backupPath=%backupDir%\%baseName%_%counter%%extension%"
    goto :checkFile
)

REM Выполнение бэкапа базы данных
pg_dump -h %dbHost% -p %dbPort% -U %dbUser% -F t -E UTF8 -b -v -f "%backupPath%" %dbName%

echo Бэкап базы данных завершен: %backupPath%
)";
    QString filePath = dir.filePath(batchFileName);
    QFile file(filePath);

    if (!file.exists() || file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        QString existingContent = in.readAll();
        file.close();

        if (existingContent != content) {
            if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
                QTextStream out(&file);
                out << content;
                file.close();
            }
        }
    } else {
        if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QTextStream out(&file);
            out << content;
            file.close();
        }
    }
}
