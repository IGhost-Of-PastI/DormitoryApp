#include "querytablemodel.h"
#include "mainsqlconnection.h"

QueryTableModel::QueryTableModel(QObject *parent)
    : QSqlQueryModel(parent)
{
    //this->setEditStrategy(QSqlTableModel::OnManualSubmit);
}

QString QueryTableModel::setTableQuery(const QString &query)
{
   // this->clear();
    QSqlQuery sqlQuery(SQLConnectionMenager::getConnection());
    sqlQuery.prepare(query);
    if(!sqlQuery.exec())
    {
        return sqlQuery.lastQuery()+ sqlQuery.lastError().text();
    }
    else
    {
        this->setQuery(sqlQuery);
        return "";
    }

    //this->setQuery(query,SQLConnectionMenager::getConnection());
    //this->setHeaderData(0, Qt::Horizontal, "Result");
    //this->select();
    //return this->lastError().text();
}
