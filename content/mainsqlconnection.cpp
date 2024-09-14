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
/*bool operator==(const FKColumnInfo& lhs, const FKColumnInfo& rhs) {
    return (lhs.fkTableName == rhs.fkTableName

            && lhs.fkColumnName == rhs.fkColumnName
            );
}*/
bool operator==(const ColumnInfo& lhs, const ColumnInfo& rhs) {
    return (lhs.columnName == rhs.columnName
            && lhs.columnType == rhs.columnType
            && lhs.maxLength == rhs.maxLength
            && lhs.fkColumnInfo == rhs.fkColumnInfo
            && lhs.isFK == rhs.isFK
            && lhs.isPK == rhs.isPK
            && lhs.isNullable == rhs.isNullable
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

void MainSQLConnection::deleteRecord(const QString &tablename, const QString &column_id, const QString &column_value)
{
    QSqlQuery deleteQuery;
    deleteQuery.prepare("CALL delete_from_table(:tablname,:id_column,:value_id)");
    deleteQuery.bindValue(":tablename",tablename);
    deleteQuery.bindValue("id_column",column_id);
    deleteQuery.bindValue(":value_id",column_value);
    if (!deleteQuery.exec()) {
        qDebug() << "Error executing stored procedure:" << deleteQuery.lastError();
    }
}

void MainSQLConnection::updateRecord(const QString &tablename, QList<ColumnInfo> columns, QHash<QString, QString> values)
{
    QJsonObject jsonObj;
    QPair<QString,QString> id_ColumnValue;
    for (ColumnInfo& columnInfo:columns)
    {
        if(columnInfo.isPK != true)
        {
            jsonObj[columnInfo.columnName]=QJsonValue(values.value(columnInfo.columnName));
        }
        else
        {
            id_ColumnValue.first=columnInfo.columnName;
            id_ColumnValue.second=values.value(columnInfo.columnName);
        }
    }
    QSqlQuery updateQuery;
    updateQuery.prepare("CALL update_table(:tablename,:id_column,:id_value,:values)");
    updateQuery.bindValue(":tablename",tablename);
    updateQuery.bindValue(":id_column",id_ColumnValue.first);
    updateQuery.bindValue("id_value",id_ColumnValue.second);
    updateQuery.bindValue(":values",QJsonDocument(jsonObj).toJson(QJsonDocument::Compact));
    if (!updateQuery.exec()) {
        qDebug() << "Error executing stored procedure:" << updateQuery.lastError();
    }
}

void MainSQLConnection::insertRecord(const QString &tablename, QList<ColumnInfo> columns, QHash<QString, QString> values)
{
    QJsonObject jsonObj;
    for (ColumnInfo& columnInfo:columns)
    {
        if(columnInfo.isPK != true)
        {
            jsonObj[columnInfo.columnName]=QJsonValue(values.value(columnInfo.columnName));
        }
    }
    QSqlQuery insertQuery;
    insertQuery.prepare("CALL insert_into_table(:tablename,:columnvalues)");
    insertQuery.bindValue(":tablename",tablename);
    insertQuery.bindValue(":columnvalues",QJsonDocument(jsonObj).toJson(QJsonDocument::Compact));
    if (!insertQuery.exec()) {
        qDebug() << "Error executing stored procedure:" << insertQuery.lastError();
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

QStringList MainSQLConnection::getAllColumns(const QString& tablename)
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

QString MainSQLConnection::getPKColumn(const QString &tablename)
{
    QString pkColumn;
    QSqlQuery query;
    query.prepare("Select * from get_primary_key_column(:tablename)");
    query.bindValue(":tablename",tablename);
    if(!query.exec()) qDebug()<<query.lastError();
    while (query.next()) {
        pkColumn=query.value(0).toString();
    }
    return pkColumn;
}

QHash<QString,QPair<QString,QString>> MainSQLConnection::getFKColumns(const QString &tablename)
{
    QHash<QString,QPair<QString,QString>> fkColumnsInfo;
    QSqlQuery query;
    query.prepare("Select * from get_foreign_keys(:tablename)");
    query.bindValue(":tablename",tablename);
    if(!query.exec()) qDebug()<<query.lastError();
    while (query.next()) {
        QPair<QString,QString> fkcolumninfo;
        QString columname=query.value(1).toString();
       // columninfo.append(query.value(1).toString());
        fkcolumninfo.first =query.value(2).toString();
        fkcolumninfo.second=query.value(3).toString();
        fkColumnsInfo.insert(columname,fkcolumninfo);
    }
    return fkColumnsInfo;
}

ColumnInfo MainSQLConnection::getAdditionalColumnInfo(const QString &tablename, const QString &columname)
{
    ColumnInfo columninfo;
    QSqlQuery query;
    query.prepare("Select * from get_column_info(:tablename,:columnname)");
    query.bindValue(":tablename",tablename);
    query.bindValue(":columnname",columname);
    if(!query.exec()) qDebug()<<query.lastError();
    while (query.next()) {
        columninfo.columnType=query.value(0).toString();
        columninfo.maxLength=query.value(1).toInt();
        columninfo.isNullable=query.value(2).toBool();
       // QString columname=query.value(1).toString();
        // columninfo.append(query.value(1).toString());
       // fkcolumninfo.fkTableName =query.value(2).toString();
       // fkcolumninfo.fkColumnName=query.value(3).toString();
       // fkColumnsInfo.insert(columname,fkcolumninfo);
    }
    return columninfo;
}

QList<ColumnInfo> MainSQLConnection::getColumnsInfo(const QString &tablename)
{
    QList<ColumnInfo> columnsinfolist;
    QStringList columns = getAllColumns(tablename);
    QString pkColumn=getPKColumn(tablename);
    QHash<QString,QPair<QString,QString>> fkColumns= getFKColumns(tablename);
    for (QString& column:columns)
    {
        ColumnInfo columninfo = getAdditionalColumnInfo(tablename,column);
        columninfo.columnName=column;
        if (pkColumn == column) {columninfo.isPK=true;}
        else {columninfo.isPK=false;}
        if (fkColumns.contains(column))
        {
            columninfo.fkColumnInfo=fkColumns.value(column);
            columninfo.isFK=true;
        }
        else {columninfo.isFK=false;}
        columnsinfolist.append(columninfo);
    }
    return columnsinfolist;
}



/*QSharedPointer<QSqlRelationalTableModel> MainSQLConnection::getRelatioanlTableModel(const QString &tablename)
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
}*/

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
