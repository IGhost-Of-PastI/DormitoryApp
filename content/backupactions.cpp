#include "backupactions.h"
#include "constants.h"

inline void BackupActions::updateIsTaskActive()
{
   setIsTaskActive(isTaskExist());
}

BackupActions::BackupActions(QObject *parent)
    : QObject{parent}
{
    createOrUpdateBatchFile();
    updateIsTaskActive();
}

void BackupActions::doBackup()
{
    QProcess backupProcess;

    backupProcess.start(batchFileName);

    if (!backupProcess.waitForFinished()) {
        qWarning() << "Процесс не завершился успешно:" << backupProcess.errorString();
    } else {
        QByteArray stdOutput = backupProcess.readAllStandardOutput();
        QByteArray stdError = backupProcess.readAllStandardError();

        if (!stdError.isEmpty()) {
            qWarning() << "Процесс завершился с ошибками:" << stdError;
        } else {
            qDebug() << "Процесс завершился успешно.";
            qDebug() << "Вывод процесса:" << stdOutput;
        }
    }
}

void BackupActions::setTaskToBackup() //Проверено добавление
{
    Constants constan;
    //TooDO
    QSettings settings("settings.ini",QSettings::IniFormat);
    settings.beginGroup(constan.backupCategoryName());
    int interval = settings.value("shedule").toInt();
    QTime startTime= QTime::fromString(settings.value("startTime").toString(),"HH:mm:ss");
    QProcess setTaskProcess;
    QFile batchFile(batchFileName);
    QFileInfo batchFileInfo(batchFile);
    qDebug()<<batchFileInfo.absoluteFilePath();
    //QString program;
    if(isTaskExist())
    {
        setTaskProcess.setProgram("schtasks");
        setTaskProcess.setArguments({"/change",
                                     "/tn",backupTaskName,
                                     "/tr",batchFileInfo.absoluteFilePath(),
                                     "/st", QString::number(interval),
                                     "/ri",startTime.toString("HH:mm"),
                                     "/f"});
      //  program= QString(R"(schtasks /change /tn %1 /tr "%2" /st %3 /ri %4 /f)").
      //            arg(backupTaskName,batchFileInfo.absoluteFilePath(),QString::number(interval),startTime.toString("HH:mm"));
    }
    else
    {
        setTaskProcess.setProgram("schtasks");
        setTaskProcess.setArguments(QStringList{"/create",
                                                "/tn",backupTaskName,
                                                "/tr",batchFileInfo.absoluteFilePath(),
                                                "/sc","daily",
                                                "/mo",QString::number(interval),
                                                "/st",startTime.toString("HH:mm"),
                                                "/f"});
        //program= QString(R"(schtasks /create /tn %1 /tr "%2" /sc daily /mo %3 /st %4 /f)").
          //        arg(backupTaskName,batchFileInfo.absoluteFilePath(),QString::number(interval),startTime.toString("HH:mm"));
    }
    qDebug()<<setTaskProcess.program();
    setTaskProcess.start();
//    setTaskProcess.start(program);
        if (setTaskProcess.waitForFinished()) {
        // Проверяем статус завершения
        if (setTaskProcess.exitStatus() == QProcess::NormalExit) {
            qDebug() << "Процесс завершился успешно с кодом:" << setTaskProcess.exitCode();
        } else {
            qDebug() << "Процесс завершился с ошибкой. Код ошибки:" << setTaskProcess.exitCode();
            qDebug() << "Сообщение об ошибке:" << setTaskProcess.readAllStandardError();
        }
    } else {
        qDebug() << "Процесс не был запущен или завершился с таймаутом.";
        qDebug() << "Ошибка:" << setTaskProcess.errorString();
    }
    updateIsTaskActive();
}

void BackupActions::deleteTaskToBackup() //Проверено работате
{
    QProcess deleteTask;
    deleteTask.setProgram("schtasks");
    deleteTask.setArguments(QStringList({"/delete","/tn",backupTaskName,"/f"}));
    //QString program=QString("schtasks /delete /tn %1 /f").arg(backupTaskName);

    deleteTask.start();

    if (deleteTask.waitForFinished()) {
        // Проверяем статус завершения
        if (deleteTask.exitStatus() == QProcess::NormalExit) {
            qDebug() << "Процесс завершился успешно с кодом:" << deleteTask.exitCode();
        } else {
            qDebug() << "Процесс завершился с ошибкой. Код ошибки:" << deleteTask.exitCode();
            qDebug() << "Сообщение об ошибке:" << deleteTask.readAllStandardError();
        }
    } else {
        qDebug() << "Процесс не был запущен или завершился с таймаутом.";
        qDebug() << "Ошибка:" << deleteTask.errorString();
    }
    updateIsTaskActive();
}

bool BackupActions::isTaskExist() ///Проверено работает
{
    QProcess process;
    //QString program = QString("schtasks /query /tn %1").arg(backupTaskName);
    process.setProgram("schtasks");
    process.setArguments(QStringList({"/query","/tn",backupTaskName}));

    process.start();
    //process.start(program);
    process.waitForFinished();

    int exitCode = process.exitCode();
    return (exitCode == 0);
}

void BackupActions::restoreFromBackup(QString host, QString port, QString user, QString database, QString backupFilePath)
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

void BackupActions::createOrUpdateBatchFile()
{
    QDir dir;
    QString content=R"(
@echo off
setlocal enabledelayedexpansion

REM Путь к ini-файлу
set "iniFile=%~dp0settings.ini"

REM Функция для чтения значений из ini-файла с использованием PowerShell
:readIni
for /f "tokens=*" %%A in ('powershell -Command "Get-Content -Path '%iniFile%' | ForEach-Object { if ($_ -match '^\[%1\]') { $sectionFound = $true } elseif ($sectionFound -and $_ -match '^\[(.+)\]') { $sectionFound = $false } elseif ($sectionFound -and $_ -match '^(?!;)(.+?)=(.+)$') { if ($matches[1] -eq '%2') { Write-Output $matches[2] } } }"') do (
    set "%3=%%A"
)
exit /b

REM Чтение параметров из секции [Database]
call :readIni "DatabaseInfo" "host" dbHost
call :readIni "DatabaseInfo" "port" dbPort
call :readIni "DatabaseInfo" "name" dbName
call :readIni "DatabaseInfo" "user" dbUser
call :readIni "DatabaseInfo" "password" dbPassword

REM Чтение параметров из секции [Backup]
call :readIni "BackupSection" "path" backupDir

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
    echo Ошибка: Параметр "path" не найден в секции [Backup].
    exit /b 1
)

REM Создание директории для бэкапа, если она не существует
if not exist "%backupDir%" mkdir "%backupDir%"

REM Формирование имени файла бэкапа
set "date=%date:~6,4%-%date:~3,2%-%date:~0,2%"
set "backupFile=%dbName%_backup_%date%.tar"
set "backupPath=%backupDir%\%backupFile%"

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

bool BackupActions::isTaskActive() const
{
    return m_isTaskActive;
}

void BackupActions::setIsTaskActive(bool newIsTaskActive)
{
    if (m_isTaskActive == newIsTaskActive)
        return;
    m_isTaskActive = newIsTaskActive;
    emit isTaskActiveChanged();
}
