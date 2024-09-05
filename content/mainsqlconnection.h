#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
//#include <string>
#include <QJsonObject>

struct UserInfo
{
    Q_GADGET
    QString Login;
    QJsonObject RolePrevelages;
    QString Dormitory;
};

class MainSQLConnection : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

//    Q_PROPERTY(QSqlDatabase* connection READ connection CONSTANT)
public:
    explicit MainSQLConnection(QObject *parent = nullptr);
    ~MainSQLConnection();
   /* QSqlDatabase connection() const {
        return m_connection;
    }*/

    Q_INVOKABLE bool Autorize(const QString &Login,const QString &Password);
private:
    QSqlDatabase m_connection;
    UserInfo m_userinfo;
};

