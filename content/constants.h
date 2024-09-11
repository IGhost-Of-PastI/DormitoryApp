#ifndef CONSTANTS_H
#define CONSTANTS_H

#include <QObject>
#include <QQmlEngine>

class Constants : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT
    Q_PROPERTY(QString settingsFile READ settingsFile CONSTANT)
    Q_PROPERTY(QString backupCategoryName READ backupCategoryName CONSTANT)
    Q_PROPERTY(QString databaseCategoryName READ databaseCategoryName CONSTANT)
public:
    explicit Constants(QObject *parent = nullptr);

    QString backupCategoryName() const;

    QString settingsFile() const;

    QString databaseCategoryName() const;

signals:
private:
    QString m_backupCategoryName;
    QString m_settingsFile;
    QString m_databaseCategoryName;
};

#endif // CONSTANTS_H
