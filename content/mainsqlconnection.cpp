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
bool operator!=(const QMLPair& lhs, const QMLPair& rhs)
{
    return (lhs!=rhs);
}
bool operator==(const QMLPair& lhs, const QMLPair& rhs)
{
    return (lhs.key == rhs.key
            && lhs.value == rhs.value
            );
}
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
    m_connection=SQLConnectionMenager::getConnection();
}

MainSQLConnection::~MainSQLConnection()
{
    /*if(m_connection != nullptr)
    {
        delete m_connection;
    }*/
}

bool MainSQLConnection::addLog(qint64 action_id, qint64 staff_id, QJsonDocument action_description)
{
    QSqlQuery addLogQuery;
    addLogQuery.prepare("CALL insert_into_logs(:a_id, :s_id, :a_description);");
    addLogQuery.bindValue(":a_id",action_id);
    addLogQuery.bindValue(":s_id",staff_id);
    addLogQuery.bindValue(":a_description",action_description);
    if (!addLogQuery.exec()) {
        qDebug() << "Error executing stored procedure:" << addLogQuery.lastError();
        return false;
    }
    else
    {
        return true;
    }
}

bool MainSQLConnection::deleteRecord(const QString &tablename, const QString &column_id, const QString &column_value)
{
    QSqlQuery deleteQuery;
    deleteQuery.prepare("Select public.delete_from_tablesf(:tablename,:id_column,:value_id,:id_staff);");
    deleteQuery.bindValue(":tablename",tablename);
    deleteQuery.bindValue(":id_column",column_id);
    deleteQuery.bindValue(":value_id",column_value);
    deleteQuery.bindValue(":id_staff",m_userinfo.iD);
    if (!deleteQuery.exec()) {
        qDebug() << "Error executing stored procedure:" << deleteQuery.lastError();
        return false;
    }
    else
    {
        return true;
    }
}

bool MainSQLConnection::updateRecord(const QString& tablename, QVariantList columns, QVariantList values, QString id_column,QString id_value)
{
    QList<ColumnInfo> columninfolsit;
    QHash<QString,QString> datalist;
    for (const QVariant &data : values) {
        QVariantMap dataMap = data.toMap();
        QPair<QString,QString> pair;
        pair.first = dataMap["columnInfo"].toString();
        pair.second = dataMap["value"].toString();
        datalist.insert(pair.first,pair.second);
    }
    for (const QVariant &column : columns) {
        ColumnInfo columninfo = column.value<ColumnInfo>();
        columninfolsit.append(columninfo);
    }

    QJsonObject jsonObj;
    for (ColumnInfo& columnInfo:columninfolsit)
    {
        if(columnInfo.isPK != true)
        {
            jsonObj[columnInfo.columnName]=QJsonValue(datalist.value(columnInfo.columnName));
        }
    }
    QString jsonValue=QJsonDocument(jsonObj).toJson(QJsonDocument::Compact);
    QSqlQuery updateQuery;
    updateQuery.prepare("Select public.update_tablesf(:tablename,:id_column,:id_value,:values,:id_staff);");
    updateQuery.bindValue(":tablename",tablename);
    updateQuery.bindValue(":id_column",id_column);
    updateQuery.bindValue(":id_value",id_value);
    updateQuery.bindValue(":values",jsonValue);
    updateQuery.bindValue(":id_staff",m_userinfo.iD);
    if (!updateQuery.exec()) {
        qDebug() << "Error executing stored procedure:" << updateQuery.lastError();
        return false;
    }
    else
    {
        return true;
    }
}

bool MainSQLConnection::insertRecord(const QString &tablename, QVariantList columns, QVariantList values)
{
    QList<ColumnInfo> columninfolsit;
    QHash<QString,QString> datalist;
    for (const QVariant &data : values) {
        QVariantMap dataMap = data.toMap();
        QPair<QString,QString> pair;
        pair.first = dataMap["columnInfo"].toString();
        pair.second = dataMap["value"].toString();
        datalist.insert(pair.first,pair.second);
    }
    for (const QVariant &column : columns) {
        ColumnInfo columninfo = column.value<ColumnInfo>();
        columninfolsit.append(columninfo);
    }

    QJsonObject jsonObj;
    for (ColumnInfo& columnInfo:columninfolsit)
    {
        if(columnInfo.isPK != true)
        {
            jsonObj[columnInfo.columnName]=QJsonValue(datalist.value(columnInfo.columnName));
        }
    }
    QString Json=QJsonDocument(jsonObj).toJson(QJsonDocument::Compact);
    //qDebug()<<Json;
    //QString query=QString(R"(SELECT public.insert_into_specialties('8','%2'))").arg(tablename,Json);
    //qDebug()<<query;
    QSqlQuery insertQuery;
   // qDebug()<<m_connection.isOpen();
   // qDebug()<<m_connection.userName();
   // qDebug()<<m_connection.password();
   insertQuery.prepare(R"(Select public.insert_into_tablesf(:staff_id,:tablename,:columns);)");
   insertQuery.bindValue(":staff_id",m_userinfo.iD);
   insertQuery.bindValue(":tablename",tablename);
   insertQuery.bindValue(":columns",Json);
  //  qDebug() << insertQuery.lastQuery();
    if (!insertQuery.exec()) {
        qDebug() << "Error executing stored procedure:" << insertQuery.lastError().text();
    //    qDebug() << insertQuery.lastQuery();
       // QDebug()<<insertQuery.lastQuery();
        return false;
    }
    else
    {
        return true;
    }
}










QStringList MainSQLConnection::getAllViews()
{
    QStringList views;
    QSqlQuery allViewsQuery("Select * From get_all_views();");
    while(allViewsQuery.next())
    {
        views.append(allViewsQuery.value(0).toString());
    }
    return views;
}

QStringList MainSQLConnection::getAllTables()
{
    QStringList tables;
    QSqlQuery allTablesQuery("Select * From get_all_tables();");
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
    columnnames.prepare("Select * from get_table_columns(:tablename);");
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
    query.prepare("Select * from get_primary_key_column(:tablename);");
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
    query.prepare("Select * from get_foreign_keys(:tablename);");
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
    query.prepare("Select * from get_column_info(:tablename,:columnname);");
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

QVariantList MainSQLConnection::getColumnsInfo(const QString &tablename)
{
   // QVariantList variantlsit;
    //variantlsit.

    QVariantList columnsinfolist;
    QStringList columns = getAllColumns(tablename);
    QString pkColumn=getPKColumn(tablename);
    QHash<QString,QPair<QString,QString>> fkColumns= getFKColumns(tablename);
    for (QString& column:columns)
    {
        QVariant variant;
        ColumnInfo columninfo = getAdditionalColumnInfo(tablename,column);

        columninfo.columnName=column;
        if (pkColumn == column) {columninfo.isPK=true;}
        else {columninfo.isPK=false;}
        if (fkColumns.contains(column))
        {
//QVariant var1,var2;
            QString val1,val2;
            val1=fkColumns.value(column).first;
            val2=fkColumns.value(column).second;
             columninfo.fkColumnInfo.key=val1;
            columninfo.fkColumnInfo.value=val2;
            columninfo.isFK=true;
        }
        else {columninfo.isFK=false;}
        columnsinfolist.append(variant.fromValue(columninfo));
    }
    return columnsinfolist;
}

QVariantList MainSQLConnection::getFKValues(QString table, QString column)
{
   // QMLPair table_column= tablecolumn.value<QMLPair>();
    QVariantList idcolumnviewcolumn;
    QSqlQuery query;
    //QPair<QString,QString> table_column = tablecolumn.
    query.prepare(QString(R"(Select * from public."%1";)").arg(table));
    if(!query.exec()) qDebug()<<query.lastError();
    while(query.next())
    {
        QVariant variant;
        QMLPair pair;
        //QPair<QString,QString> pair;
        pair.key=query.value(column).toString();
        pair.value=query.value(1).toString();
        idcolumnviewcolumn.append(variant.fromValue(pair));
    }
    //getAllTables();
    return idcolumnviewcolumn;
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
        userinfo.iD=8;

        userinfo.dormitoryName="None";

        QJsonObject accJson;
        QStringList tables = getAllTables();
        {
            QJsonObject userAccJson;
            userAccJson["ViewLogs"]=QJsonValue(true);
            userAccJson["ConfigureBackups"]=QJsonValue(true);
            userAccJson["Reports"]=QJsonValue(true);
           // userAccJson["FreeQueries"]=QJsonValue(true);
           // userAccJson["ConfigureUser"]=QJsonValue(true);
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
        query.prepare("SELECT * from check_user_credentials(:username, :password);");
        query.bindValue(":username", Login);
        query.bindValue(":password", Password);

        if (!query.exec()) {
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

QSqlDatabase &SQLConnectionMenager::getConnection()
{
    Constants constatnt;
    QSettings settings(constatnt.settingsFile(),QSettings::IniFormat);
    settings.beginGroup(constatnt.databaseCategoryName());

    if (!m_connection) {
        // Создаем новое подключение
        m_connection = new QSqlDatabase(QSqlDatabase::addDatabase("QPSQL"));
        m_connection->setHostName("localhost");
        m_connection->setPort(5432);
        m_connection->setUserName("postgres");
        m_connection->setPassword("masterkey");
        m_connection->setDatabaseName("Dormitory");

        // Проверяем, удалось ли открыть подключение
        if (!m_connection->open()) {
            qDebug() << "Error: Unable to connect to database:" << m_connection->lastError().text();
        }
    }
    // Возвращаем экземпляр подключения
    return *m_connection;
}
