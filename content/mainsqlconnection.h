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
    Q_GADGET
    Q_PROPERTY(bool IsAutorized MEMBER IsAutorized)

    Q_PROPERTY(QString Surname MEMBER Surname)
    Q_PROPERTY(QString Name MEMBER Name)
    Q_PROPERTY(QString Patronymic MEMBER Patronymic)
    Q_PROPERTY(qint64 ID MEMBER ID)

    Q_PROPERTY(QString DormitoryName MEMBER DormitoryName)

   // Q_PROPERTY(QString Login MEMBER Login)
    Q_PROPERTY(QString RoleName MEMBER RoleName)
    Q_PROPERTY(QJsonDocument Acceses MEMBER Acceses)
public:
    friend bool operator==(const UserInfo& lhs, const UserInfo& rhs);

    bool IsAutorized;

    QString Surname;
    QString Name;
    QString Patronymic;
    qint64 ID;

    QString DormitoryName;

    QString RoleName;
    QJsonDocument Acceses;
};

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

