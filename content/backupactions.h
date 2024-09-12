#ifndef BACKUPACTIONS_H
#define BACKUPACTIONS_H

#include <QObject>
#include <QQmlEngine>
#include <QProcess>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSettings>
#include <QTime>

class BackupActions : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit BackupActions(QObject *parent = nullptr);
    const QString batchFileName="backup.bat";
    const QString backupTaskName="BackupDataBasePSQL";

    Q_INVOKABLE void doBackup();
    \
    Q_INVOKABLE void setTaskToBackup(int interval,QTime startTime);
    Q_INVOKABLE void deleteTaskToBackup();
    Q_INVOKABLE bool isTaskExist();

    Q_INVOKABLE void restoreFromBackup(QString host, QString port, QString user, QString database, QString backupFilePath);
    void createOrUpdateBatchFile();
signals:
};

#endif // BACKUPACTIONS_H
