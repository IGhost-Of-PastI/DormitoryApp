#pragma once

#include <QObject>

class appbackend : public QObject
{
    Q_OBJECT
public:
    explicit appbackend(QObject *parent = nullptr);

signals:
};

//#endif // APPBACKEND_H
