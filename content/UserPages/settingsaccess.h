#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QVariant>
#include <QSettings>

class SettingsAccess : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString filename READ filename CONSTANT)
    Q_PROPERTY(QString group READ group CONSTANT)
public:
    explicit SettingsAccess(QString filename, QString group, QObject *parent = nullptr);
    QString filename() const;
    Q_INVOKABLE QVariant getValue(QString paramName);
    Q_INVOKABLE void setValue(QString paramName, QString value);
    QString group() const;

private:
    QString m_filename;
    QString m_group;
};

//#endif // SETTINGSACCESS_H
