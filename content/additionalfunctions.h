#ifndef ADDITIONALFUNCTIONS_H
#define ADDITIONALFUNCTIONS_H

#include <QObject>
#include <QQmlEngine>
#include <QUrl>

class AdditionalFunctions : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT
public:
    explicit AdditionalFunctions(QObject *parent = nullptr);

    Q_INVOKABLE QString uriToFileSysPath(QUrl uri);
signals:
};

#endif // ADDITIONALFUNCTIONS_H
