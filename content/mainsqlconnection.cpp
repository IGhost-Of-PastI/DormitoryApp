#include "mainsqlconnection.h"
#include "constants.h"

MainSQLConnection::MainSQLConnection(QObject *parent)
    : QObject{parent}
{
    Constants constatnt;
    QSettings settings(constatnt.settingsFile(),QSettings::IniFormat);
    settings.beginGroup(constatnt.databaseCategoryName());

    m_connection= QSqlDatabase::addDatabase("QPSQL");
    m_connection.setHostName(settings.value("host").toString());
    m_connection.setPort(settings.value("port").toInt());
    m_connection.setUserName(settings.value("user").toString());
    m_connection.setPassword(settings.value("password").toString());
    m_connection.setDatabaseName(settings.value("database").toString());

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

QSharedPointer<QSqlRelationalTableModel> MainSQLConnection::GetRelatioanlTableModel(const QString &tablename)
{
    QStringList columnlist;
    QSharedPointer<QSqlRelationalTableModel> tablemodel(new QSqlRelationalTableModel);
    QSqlQuery columnnames(QString("Select * from get_table_columns(%1)").arg(tablename));
    while (columnnames.next())
    {
        columnlist.append(columnnames.value(0).toString());
    }

    QSqlQuery relationsquery(QString("Select * from get_foreign_keys(%1)").arg(tablename));
    tablemodel->setTable(tablename);
    while (relationsquery.next())
    {
        QString column_name,rtable_name,rcolumn_name;
        column_name= relationsquery.value(1).toString();
        rtable_name = relationsquery.value(2).toString();
        rcolumn_name = relationsquery.value(3).toString();

        tablemodel->setRelation(columnlist.indexOf(column_name),QSqlRelation(rtable_name,rcolumn_name,column_name));
    }

    return tablemodel;
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
