/****************************************************************************
** Generated QML type registration code
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <QtQml/qqml.h>
#include <QtQml/qqmlmoduleregistration.h>

#include <additionalfunctions.h>
#include <backupactions.h>
#include <constants.h>
#include <mainsqlconnection.h>
#include <tablemodel.h>
#include <wordandprint.h>


#if !defined(QT_STATIC)
#define Q_QMLTYPE_EXPORT Q_DECL_EXPORT
#else
#define Q_QMLTYPE_EXPORT
#endif
Q_QMLTYPE_EXPORT void qml_register_types_content()
{
    qmlRegisterTypesAndRevisions<AdditionalFunctions>("content", 1);
    qmlRegisterTypesAndRevisions<BackupActions>("content", 1);
    qmlRegisterTypesAndRevisions<Constants>("content", 1);
    qmlRegisterTypesAndRevisions<MainSQLConnection>("content", 1);
    QMetaType::fromType<QAbstractTableModel *>().id();
    QMetaType::fromType<QSqlQueryModel *>().id();
    QMetaType::fromType<QSqlRelationalTableModel *>().id();
    QMetaType::fromType<QSqlTableModel *>().id();
    qmlRegisterTypesAndRevisions<TableModel>("content", 1);
    qmlRegisterAnonymousType<QAbstractItemModel, 254>("content", 1);
    qmlRegisterTypesAndRevisions<WordAndPrint>("content", 1);
    qmlRegisterModule("content", 1, 0);
}

static const QQmlModuleRegistration registration("content", qml_register_types_content);
