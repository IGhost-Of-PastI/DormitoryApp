#ifndef BACKUPACTIONS_H
#define BACKUPACTIONS_H

#include <QObject>
#include <QQmlEngine>

class BackupActions : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit BackupActions(QObject *parent = nullptr);

signals:
};

#endif // BACKUPACTIONS_H
