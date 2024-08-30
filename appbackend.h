#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QSqlDatabase>

class appbackend : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QSqlDatabase connection READ connection CONSTANT)
public:
    explicit appbackend(QObject *parent = nullptr);
    //~appbackend();

    QSqlDatabase connection() const {
        return m_connection;
    }
private:
    QSqlDatabase m_connection;
};

//#endif // APPBACKEND_H
