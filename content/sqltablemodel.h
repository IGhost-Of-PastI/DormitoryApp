#ifndef SQLTABLEMODEL_H
#define SQLTABLEMODEL_H

#include <QObject>
#include <QQmlEngine>
#include <QSqlRelationalTableModel>

class SQLTableModel : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit SQLTableModel(QObject *parent = nullptr);

signals:
};

#endif // SQLTABLEMODEL_H
