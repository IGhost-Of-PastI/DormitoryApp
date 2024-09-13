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
    Q_INVOKABLE void addLog(qint64 action_id,qint64 staff_id,QJsonDocument action_description);
    Q_INVOKABLE QStringList getAllViews();
    Q_INVOKABLE QStringList getAllColumns(QString tablename);
    Q_INVOKABLE QStringList getAllTables();
    Q_INVOKABLE QSharedPointer<QSqlRelationalTableModel> getRelatioanlTableModel(const QString& tablename);
    Q_INVOKABLE UserInfo autorize(const QString &Login,const QString &Password);

    UserInfo userinfo() const;
    void setUserinfo(const UserInfo &newUserinfo);

signals:
    void userinfoChanged();

private:
    QSqlDatabase m_connection;
    UserInfo m_userinfo;
};

