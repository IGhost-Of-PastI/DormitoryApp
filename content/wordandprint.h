#ifndef WORDANDPRINT_H
#define WORDANDPRINT_H

#include <QObject>
#include <QQmlEngine>
#include <QAxObject>
#include <QTableView>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlError>
#include <QCoreApplication>
#include "mainsqlconnection.h"

class WordAndPrint : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT
public:
    explicit WordAndPrint(QObject *parent = nullptr);
    Q_INVOKABLE bool importInWord(QString tablename);
    //Q_INVOKABLE bool printDoc();
signals:
};

#endif // WORDANDPRINT_H
