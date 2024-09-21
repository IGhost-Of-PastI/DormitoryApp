#include "querytablemodel.h"
#include "mainsqlconnection.h"

QueryTableModel::QueryTableModel(QObject *parent)
    : QSqlTableModel(parent,SQLConnectionMenager::getConnection())
{


}

QString QueryTableModel::setTableQuery(const QString &query)
{
    this->setQuery(query);
    this->select();
    return this->lastError().text();
}
