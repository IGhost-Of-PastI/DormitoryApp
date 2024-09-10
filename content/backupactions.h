#ifndef BACKUPACTIONS_H
#define BACKUPACTIONS_H

#include <QObject>
#include <QQmlEngine>
#include <QProcess>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSettings>

class BackupActions : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit BackupActions(QObject *parent = nullptr);
    const QString batchFileName="backup.bat";
    const QString backupTaskName="BackupDataBasePSQL";

    Q_INVOKABLE void DoBackup();
    \
    Q_INVOKABLE void SetTaskToBackup();
    Q_INVOKABLE void DeleteTaskToBackup();
    Q_INVOKABLE bool IsTaskExist();

    Q_INVOKABLE void RestoreFromBackup(QString host, QString port, QString user, QString database, QString backupFilePath);
    void CreateOrUpdateBatchFile();
signals:
};

#endif // BACKUPACTIONS_H
