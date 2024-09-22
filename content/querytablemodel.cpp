#include "querytablemodel.h"
#include "mainsqlconnection.h"

QueryTableModel::QueryTableModel(QObject *parent)
    : QSqlTableModel(parent,SQLConnectionMenager::getConnection())
{
    this->setEditStrategy(QSqlTableModel::OnManualSubmit);
}

QString QueryTableModel::setTableQuery(const QString &query)
{
    this->clear();
    QSqlQuery sqlQuery;
    sqlQuery.prepare(query);
    if(!sqlQuery.exec())
    {
        return sqlQuery.lastQuery()+ sqlQuery.lastError().text();
    }
    else
    {
        while (sqlQuery.next()) {
            this->insertRecord(-1,sqlQuery.record());
        }
        return sqlQuery.lastError().text();
    }

    //this->setQuery(query,SQLConnectionMenager::getConnection());
    //this->setHeaderData(0, Qt::Horizontal, "Result");
    //this->select();
    //return this->lastError().text();
}
