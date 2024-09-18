#ifndef WORDANDPRINT_H
#define WORDANDPRINT_H

#include <QObject>
#include <QQmlEngine>

class WordAndPrint : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit WordAndPrint(QObject *parent = nullptr);

signals:
};

#endif // WORDANDPRINT_H
