#include "constants.h"

Constants::Constants(QObject *parent)
    : QObject{parent}
{
    m_settingsFile= "settings.ini";
    m_backupCategoryName = "BackupSection";
    m_databaseCategoryName="DatabaseInfo";
}

QString Constants::backupCategoryName() const
{
    return m_backupCategoryName;
}

QString Constants::settingsFile() const
{
    return m_settingsFile;
}

QString Constants::databaseCategoryName() const
{
    return m_databaseCategoryName;
}
