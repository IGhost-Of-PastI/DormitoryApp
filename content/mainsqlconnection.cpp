#include "mainsqlconnection.h"

MainSQLConnection::MainSQLConnection(QObject *parent)
    : QObject{parent}
{
    m_connection= QSqlDatabase::addDatabase("QPSQL");
    m_connection.setHostName("localhost");
    m_connection.setPort(5432);
    m_connection.setUserName("postgres");
    m_connection.setPassword("masterkey");

    if (!m_connection.open()) {
        qDebug() << "Error: Unable to connect to database:" << m_connection.lastError().text();
    }
}

MainSQLConnection::~MainSQLConnection()
{
    /*if(m_connection != nullptr)
    {
        delete m_connection;
    }*/
}

bool MainSQLConnection::Autorize(const QString &Login, const QString &Password)
{
    QSqlQuery query;
    query.prepare("SELECT check_user_credentials(:username, :password)");
    query.bindValue(":username", Login);
    query.bindValue(":password", Password);

    if (!query.exec()) {
        qDebug() << "Error: Unable to execute query -" << query.lastError().text();
       // return QString();
    }

    if (query.next()) {
        //return query.value(0).toString();
    } else {
        //return QString();
    }
    return false;
}
