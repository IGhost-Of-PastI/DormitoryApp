#ifndef TABLEMODEL_H
#define TABLEMODEL_H

#include <QObject>
#include <QQmlEngine>
#include <QSqlRelationalTableModel>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QSqlRelation>
//#include <QWidget>

/*class DBSettuper
{
public:
    static  QSqlDatabase setupDatabase() {
        QSqlDatabase db = QSqlDatabase::addDatabase("QPSQL");
        db.setHostName("localhost");
        db.setPort(5432);
        db.setUserName("postgres");
        db.setPassword("masterkey");
        db.setDatabaseName("Dormitory");

        if (!db.open()) {
            qDebug() << "Error: Unable to connect to database:" << db.lastError().text();
        }

        return db;
    }
};*/


class TableModel : public QSqlRelationalTableModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString tablename READ tablename WRITE setTablename NOTIFY tablenameChanged FINAL)
public:
    explicit TableModel(QSqlDatabase& db,QObject *parent = nullptr)
        : QSqlRelationalTableModel(parent,db) {

        if (!this->database().isOpen()) {
            qDebug() << "Error: Unable to connect to database:" << this->database().lastError().text();
        }

    }
    QString tablename() const;
    void setTablename(const QString &newTablename);
signals:
    void tablenameChanged();
private:
    QString m_tablename;
};

#endif // TABLEMODEL_H
