#include "settingsaccess.h"

SettingsAccess::SettingsAccess(QString filename,QString group, QObject *parent)
{
    m_filename=filename;
    m_group= group;
}

QString SettingsAccess::filename() const
{
    return m_filename;
}

QVariant SettingsAccess::getValue(QString paramName)
{
    QSettings settings(m_filename+".ini",QSettings::IniFormat);
    settings.beginGroup(m_group);
    return settings.value(paramName);
}

void SettingsAccess::setValue(QString paramName, QString value)
{
    QSettings settings(m_filename+".ini", QSettings::IniFormat);
    settings.beginGroup(m_group);
    settings.setValue(paramName,value);
}

QString SettingsAccess::group() const
{
    return m_group;
}

