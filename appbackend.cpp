#include "appbackend.h"

appbackend::appbackend(QObject *parent)
    : QObject{parent}
{
    m_connection= QSqlDatabase::addDatabase("QPSQL");
    m_connection.setHostName("localhost");
    m_connection.setPort(5432);
    m_connection.setUserName("postgres");
    m_connection.setPassword("masterkey");
    //m_connection.setDatabaseName();
}
