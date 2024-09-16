#ifndef EDITORDATAMANAGER_H
#define EDITORDATAMANAGER_H

#include <QObject>
#include <QQmlEngine>
#include "mainsqlconnection.h"

class EditorDataManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit EditorDataManager(QObject *parent = nullptr);

signals:
};

#endif // EDITORDATAMANAGER_H
