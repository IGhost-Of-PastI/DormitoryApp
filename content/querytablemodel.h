#ifndef QUERYTABLEMODEL_H
#define QUERYTABLEMODEL_H


#include <QObject>
#include <QQmlEngine>
#include <QSqlQueryModel>
#include <QSqlTableModel>
#include <QSqlQuery>
#include <QSqlRecord>
class QueryTableModel : public QSqlQueryModel
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit QueryTableModel(QObject *parent = nullptr);
    Q_INVOKABLE QString setTableQuery(const QString& query);
signals:
};

#endif // QUERYTABLEMODEL_H
