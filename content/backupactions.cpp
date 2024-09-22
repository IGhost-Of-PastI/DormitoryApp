#include "backupactions.h"
#include "constants.h"

inline void BackupActions::updateIsTaskActive()
{
   setIsTaskActive(isTaskExist());
}

BackupActions::BackupActions(QObject *parent)
    : QObject{parent}
{
  //  createOrUpdateBatchFile();
    updateIsTaskActive();
}

QString BackupActions::getParam(const QString &section, const QString &param)
{
    QSettings settings(settingsFile,QSettings::IniFormat);
    settings.beginGroup(section);
    return settings.value(param).toString();
}

void BackupActions::setParam(const QString &section, const QString &param,const QString& value)
{
    QSettings settings(settingsFile,QSettings::IniFormat);
    settings.beginGroup(section);
    settings.setValue(param,value);
}

void BackupActions::doBackup()
{
    QProcess backupProcess;
    backupProcess.setProgram(backupExe);
    backupProcess.start();


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
    QSettings settings(settingsFile,QSettings::IniFormat);
    settings.beginGroup(constan.backupCategoryName());
    int interval = settings.value("shedule").toInt();
    QTime startTime= QTime::fromString(settings.value("startTime").toString(),"HH:mm");
    QProcess setTaskProcess;
    QFile batchFile(backupExe);
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

void BackupActions::restoreFromBackup(QString backupFilePath)
{
    QSettings settingsBase(settingsFile,QSettings::IniFormat);
    settingsBase.beginGroup("DatabaseInfo");
    QString host=settingsBase.value("host").toString();
    QString port=settingsBase.value("port").toString();
    QString user=settingsBase.value("user").toString();
   // QString password=settingsBase.value("password").toString();
    QString database=settingsBase.value("database").toString();
    QSettings settingsPGrestore(settingsFile,QSettings::IniFormat);
    settingsPGrestore.beginGroup("BackupSection");
    QString pgrestorePath=settingsPGrestore.value("pathpgrestore").toString();

    QProcess restoreProcess;
    restoreProcess.setProgram(pgrestorePath);
    restoreProcess.setArguments(QStringList({
        "-h",host,
        "-p",port,
        "-U",user,
        "-d",database,
        "-F","t",
        "-v",backupFilePath
    }));
    //QString program = QString("pg_restore -h %1 -p %2 -U %3 -d %4 -F t -v %5").arg(host,port,user,database,backupFilePath);

    restoreProcess.start();

    if (!restoreProcess.waitForFinished()) {
        qWarning() << "Процесс не завершился успешно:" << restoreProcess.errorString();
    } else {
        qDebug() << "Процесс завершился успешно.";
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
