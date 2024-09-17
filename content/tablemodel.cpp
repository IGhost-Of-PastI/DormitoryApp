#include "tablemodel.h"

void TableModel::setFilterQML(QString column, QString value)
{
    QString filter ="";
    if (column!="" || value!="")
    {
        filter=QString(R"("%1"='%2')").arg(column,value);
    }
    this->setFilter(filter);
}

void TableModel::setSortQML(QString column, SortEnum sortorder)
{
    int index=-1;
    QSqlQuery query;
    query.prepare("SELECT getColumnIndex(:tablename, :columnName)");
    query.bindValue(":tablename",this->m_tablename);
    query.bindValue(":columnName",column);
    if (!query.exec())
    {
        qDebug()<<"Error getting index of column:" << query.lastError() ;

    }
 qDebug()<<query.lastQuery();
    while(query.next())
    {
index= query.value(0).toInt();
    }

    Qt::SortOrder qtsortorder;
    if (sortorder==SortEnum::ASC) {qtsortorder= Qt::SortOrder::AscendingOrder;}
    else {qtsortorder=Qt::SortOrder::DescendingOrder;};
    if (index !=-1)
    {
        this->setSort(index-1,qtsortorder);
    }
}

QString TableModel::tablename() const
{
    return m_tablename;
}

void TableModel::setTablename(const QString &newTablename)
{
    if (m_tablename != newTablename)
    {
        m_tablename = newTablename;
        QStringList columnlist;
        // this->set
        QSqlQuery columnnames(this->database());
        columnnames.prepare("Select * from get_table_columns(:tablename)");
        columnnames.bindValue(":tablename",m_tablename);
        if (!columnnames.exec()) {
            qDebug() << "Error executing stored procedure:" << columnnames.lastError();
        }
        while (columnnames.next())
        {
            columnlist.append(columnnames.value(0).toString());
        }
        this->setTable(m_tablename);
        //this->setEditStrategy(QSqlTableModel::OnRowChange);
       /* for (int i=0;i<columnlist.length();i++)
        {
            this->setHeaderData(i,Qt::Horizontal,columnlist[i]);
        }*/

       /*QSqlQuery relationsquery(this->database());
        relationsquery.prepare("Select * from get_foreign_keys(:tablename)");
        relationsquery.bindValue(":tablename",m_tablename);
        // (QString("Select * from get_foreign_keys(%1)").arg(tablename));

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

            this->setRelation(columnlist.indexOf(column_name),QSqlRelation(rtable_name,rcolumn_name,"Name"));
        }*/
       if (!this->select()) {
            qDebug() << "Error selecting data:" << this->lastError();
        }

        emit tablenameChanged();
    }

}
