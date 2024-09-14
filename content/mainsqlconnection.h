#pragma once

#include <QSettings>
#include <QSharedPointer>
#include <QObject>
#include <QQmlEngine>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
//#include <string>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QSqlRelationalTableModel>
#include <QSqlRelation>
#include <QtGlobal>
#include <QList>
#include <QHash>
#include <QPair>


struct UserInfo
{

private:
    Q_GADGET
   // QML_ELEMENT
    Q_PROPERTY(bool isAutorized MEMBER isAutorized)

    Q_PROPERTY(QString surname MEMBER surname)
    Q_PROPERTY(QString name MEMBER name)
    Q_PROPERTY(QString patronymic MEMBER patronymic)
    Q_PROPERTY(qint64 iD MEMBER iD)

    Q_PROPERTY(QString dormitoryName MEMBER dormitoryName)

   // Q_PROPERTY(QString Login MEMBER Login)
    Q_PROPERTY(QString roleName MEMBER roleName)
    Q_PROPERTY(QString acceses MEMBER acceses)
public:
    friend bool operator==(const UserInfo& lhs, const UserInfo& rhs);

    bool isAutorized;

    QString surname;
    QString name;
    QString patronymic;
    qint64 iD;

    QString dormitoryName;

    QString roleName;
    QString acceses;
};

/*struct FKColumnInfo
{
private:
    Q_GADGET
     Q_PROPERTY(QString fkColumnName MEMBER fkColumnName)
     Q_PROPERTY(QString fkTableName MEMBER fkTableName)
public:
    friend bool operator==(const FKColumnInfo& lhs, const FKColumnInfo& rhs);
    QString fkTableName;
    QString fkColumnName;
};*/

struct ColumnInfo
{
private:
    Q_GADGET
    Q_PROPERTY(QString columnName MEMBER columnName)
    Q_PROPERTY(bool isPK MEMBER isPK)
    Q_PROPERTY(QString columnType MEMBER columnType)
    Q_PROPERTY(int maxLenght MEMBER maxLength)
    Q_PROPERTY(bool isFK MEMBER isFK)
    Q_PROPERTY(bool isNullable MEMBER isNullable)
    Q_PROPERTY(QPair<QString,QString> fkColumnInfo MEMBER fkColumnInfo)
public:
    friend bool operator==(const ColumnInfo& lhs, const ColumnInfo& rhs);
    QString columnName;
    bool isPK;
    bool isNullable;
    QString columnType;
    int maxLength;
    bool isFK;
    QPair<QString,QString> fkColumnInfo;
};
//Q_DECLARE_METATYPE(FKColumnInfo)
Q_DECLARE_METATYPE(ColumnInfo)
Q_DECLARE_METATYPE(UserInfo)
class MainSQLConnection : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT
    Q_PROPERTY(UserInfo userinfo READ userinfo WRITE setUserinfo NOTIFY userinfoChanged FINAL)
public:
    explicit MainSQLConnection(QObject *parent = nullptr);
    ~MainSQLConnection();
   /* QSqlDatabase connection() const {
        return m_connection;
    }*/
    //Функции получения инфомрации о таблицах
    Q_INVOKABLE QStringList getAllViews();
    Q_INVOKABLE QStringList getAllTables();
    Q_INVOKABLE QStringList getAllColumns(const QString& tablename);
    Q_INVOKABLE QString getPKColumn(const QString& tablename);
    Q_INVOKABLE QHash<QString,QPair<QString,QString>> getFKColumns (const QString& tablename);
    Q_INVOKABLE ColumnInfo getAdditionalColumnInfo(const QString& tablename,const QString& columname);
    Q_INVOKABLE QList<ColumnInfo> getColumnsInfo(const QString& tablename);
    //Фукнция добавления в БД
    Q_INVOKABLE void addLog(qint64 action_id,qint64 staff_id,QJsonDocument action_description);
    Q_INVOKABLE void deleteRecord(const QString& tablename,const QString& column_id,const QString& column_value);
    Q_INVOKABLE void updateRecord(const QString& tablename, QList<ColumnInfo> columns, QHash<QString,QString> values);
    Q_INVOKABLE void insertRecord(const QString& tablename, QList<ColumnInfo> columns, QHash<QString,QString> values);
    //Функция авторизации
    // QSharedPointer<QSqlRelationalTableModel> getRelatioanlTableModel(const QString& tablename);
    Q_INVOKABLE UserInfo autorize(const QString &Login,const QString &Password);

    UserInfo userinfo() const;
    void setUserinfo(const UserInfo &newUserinfo);

signals:
    void userinfoChanged();

private:
    QSqlDatabase m_connection;
    UserInfo m_userinfo;
};

