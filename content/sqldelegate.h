#ifndef SQLDELEGATE_H
#define SQLDELEGATE_H

#include <QObject>
#include <QQmlEngine>

class SQLDelegate : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit SQLDelegate(QObject *parent = nullptr);

signals:
};

#endif // SQLDELEGATE_H
