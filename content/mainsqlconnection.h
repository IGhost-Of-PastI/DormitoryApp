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
class SQLConnectionMenager
{
    SQLConnectionMenager() = delete;
public:
    void SuspendConnection();
    void ResumeConnection();
    static QSqlDatabase& getConnection();
private:
   inline static QSqlDatabase* m_connection =nullptr;
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

struct QMLPair
{
public:
    Q_GADGET
    Q_PROPERTY(QString key MEMBER key)
    Q_PROPERTY(QString value MEMBER value)
public:
    friend bool operator==(const QMLPair& lhs, const QMLPair& rhs);
    friend bool operator!=(const QMLPair& lhs, const QMLPair& rhs);
    QString key;
    QString value;
};


struct ColumnInfo
{
private:
    Q_GADGET
    Q_PROPERTY(QString columnName MEMBER columnName)
    Q_PROPERTY(bool isPK MEMBER isPK)
    Q_PROPERTY(QString columnType MEMBER columnType)
    Q_PROPERTY(qint32 maxLength MEMBER maxLength)
    Q_PROPERTY(bool isFK MEMBER isFK)
    Q_PROPERTY(bool isNullable MEMBER isNullable)
    Q_PROPERTY(QMLPair fkColumnInfo MEMBER fkColumnInfo)
public:
    friend bool operator==(const ColumnInfo& lhs, const ColumnInfo& rhs);
    QString columnName;
    bool isPK;
    bool isNullable;
    QString columnType;
    qint32 maxLength;
    bool isFK;
    QMLPair fkColumnInfo;
};
Q_DECLARE_METATYPE(QMLPair)
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
    Q_INVOKABLE QVariantList getColumnsInfo(const QString& tablename);
    Q_INVOKABLE QVariantList getFKValues(QString table, QString column);
    //Фукнция добавления в БД
    Q_INVOKABLE bool addLog(qint64 action_id,qint64 staff_id,QJsonDocument action_description);
    Q_INVOKABLE bool deleteRecord(const QString& tablename,const QString& column_id,const QString& column_value);
    Q_INVOKABLE bool updateRecord(const QString& tablename, QVariantList columns, QVariantList values, QString id_column,QString id_value);
    Q_INVOKABLE bool insertRecord(const QString& tablename, QVariantList columns, QVariantList values);
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

