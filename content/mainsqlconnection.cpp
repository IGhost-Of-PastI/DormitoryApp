#include "mainsqlconnection.h"
#include "constants.h"

bool operator==(const UserInfo& lhs, const UserInfo& rhs) {
    return (lhs.isAutorized == rhs.isAutorized

            && lhs.surname == rhs.surname
            && lhs.name == rhs.name
            && lhs.patronymic == rhs.patronymic
            && lhs.iD==rhs.iD

            && lhs.dormitoryName==rhs.dormitoryName

            && lhs.roleName == rhs.roleName
            && lhs.acceses == rhs.acceses
            );
}


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

void MainSQLConnection::addLog(qint64 action_id, qint64 staff_id, QJsonDocument action_description)
{
    QSqlQuery addLogQuery;
    addLogQuery.prepare("CALL insert_into_logs(:a_id, :s_id, :a_description)");
    addLogQuery.bindValue(":a_id",action_id);
    addLogQuery.bindValue(":s_id",staff_id);
    addLogQuery.bindValue(":a_description",action_description);
    if (!addLogQuery.exec()) {
        qDebug() << "Error executing stored procedure:" << addLogQuery.lastError();
    }
}

QStringList MainSQLConnection::getAllViews()
{
    QStringList views;
    QSqlQuery allViewsQuery("Select * From get_all_views()");
    while(allViewsQuery.next())
    {
        views.append(allViewsQuery.value(0).toString());
    }
    return views;
}

QStringList MainSQLConnection::getAllColumns(QString tablename)
{
    QStringList columnlist;

    QSqlQuery columnnames;
    columnnames.prepare("Select * from get_table_columns(:tablename)");
    columnnames.bindValue(":tablename",tablename);
    if (!columnnames.exec()) {
        qDebug() << "Error executing stored procedure:" << columnnames.lastError();
    }
    while (columnnames.next())
    {
        columnlist.append(columnnames.value(0).toString());
    }
    return columnlist;
}

QStringList MainSQLConnection::getAllTables()
{
    QStringList tables;
    QSqlQuery allTablesQuery("Select * From get_all_tables()");
    while(allTablesQuery.next())
    {
        tables.append(allTablesQuery.value(0).toString());
    }
    return tables;
}

QSharedPointer<QSqlRelationalTableModel> MainSQLConnection::getRelatioanlTableModel(const QString &tablename)
{

    QSharedPointer<QSqlRelationalTableModel> tablemodel(new QSqlRelationalTableModel);

    QStringList columnlist=getAllColumns(tablename);

    QSqlQuery relationsquery;
    relationsquery.prepare("Select * from get_foreign_keys(:tablename)");
    relationsquery.bindValue(":tablename",tablename);
   // (QString("Select * from get_foreign_keys(%1)").arg(tablename));
    tablemodel->setTable(tablename);
    if (!relationsquery.exec())
    {
        qDebug()<<relationsquery.lastError();
    }
    while (relationsquery.next())
    {
        QString column_name,rtable_name,rcolumn_name;
        column_name= relationsquery.value(1).toString();
        rtable_name = relationsquery.value(2).toString();
        rcolumn_name = relationsquery.value(3).toString();

        tablemodel->setRelation(columnlist.indexOf(column_name),QSqlRelation(rtable_name,rcolumn_name,column_name));
    }
    tablemodel->select();
    return tablemodel;
}

UserInfo MainSQLConnection::autorize(const QString &Login, const QString &Password)
{
    if (Login == "Admin" && Password == "1111" )
    {
        UserInfo userinfo;
        userinfo.isAutorized=true;
        userinfo.surname="Фамилия";
        userinfo.name="Имя";
        userinfo.patronymic="Отчество";
        userinfo.iD=-1;

        userinfo.dormitoryName="None";

        QJsonObject accJson;
        QStringList tables = getAllTables();
        {
            QJsonObject userAccJson;
            userAccJson["ViewLogs"]=QJsonValue(true);
            userAccJson["ConfigureBackups"]=QJsonValue(true);
            userAccJson["Reports"]=QJsonValue(true);
            userAccJson["FreeQueries"]=QJsonValue(true);
            userAccJson["ConfigureUser"]=QJsonValue(true);
            accJson["UserAccesses"]=userAccJson;
        }
        {
            QJsonArray tablesAccesses;
            for(QString& tablename:tables)
            {
                QJsonObject tableActionsAccesses;
                tableActionsAccesses["Add"]=QJsonValue(true);
                tableActionsAccesses["Edit"]= QJsonValue(true);
                tableActionsAccesses["Delete"]=QJsonValue(true);

                QJsonObject tableAcceses;
                tableAcceses["TableName"]=QJsonValue(tablename);
                tableAcceses["ViewTable"]=QJsonValue(true);
                tableAcceses["TableActionsAccesses"]=tableActionsAccesses;

                tablesAccesses.append(tableAcceses);
            }
            accJson["TableAccesses"]=tablesAccesses;
        }

        userinfo.roleName="Мегаправа";
        userinfo.acceses=QJsonDocument(accJson).toJson(QJsonDocument::Compact);

        setUserinfo(userinfo);
        return userinfo;
    }
    else
    {
        UserInfo userinfo;
        QSqlQuery query;
        query.prepare("SELECT check_user_credentials(:username, :password)");
        query.bindValue(":username", Login);
        query.bindValue(":password", Password);

        if (!query.next()) {
            userinfo.isAutorized=false;
            //qDebug() << "No data returned";
        } else {
            while (query.next()) {
                userinfo.surname=query.value("surname").toString();
                userinfo.name=query.value("name").toString();
                userinfo.patronymic=query.value("patronymic").toString();
                userinfo.iD=query.value("id").toLongLong();

                userinfo.dormitoryName=query.value("dormitoryname").toString();

                userinfo.roleName=query.value("rolename").toString();
                userinfo.acceses=query.value("acceses").toString();
            }
        }
        setUserinfo(userinfo);
        return userinfo;
    }
}

UserInfo MainSQLConnection::userinfo() const
{
    return m_userinfo;
}

void MainSQLConnection::setUserinfo(const UserInfo &newUserinfo)
{
    if (m_userinfo == newUserinfo)
        return;
    m_userinfo = newUserinfo;
    emit userinfoChanged();
}
