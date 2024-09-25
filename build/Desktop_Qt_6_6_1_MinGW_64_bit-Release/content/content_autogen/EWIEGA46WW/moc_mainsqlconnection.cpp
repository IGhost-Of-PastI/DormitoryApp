/****************************************************************************
** Meta object code from reading C++ file 'mainsqlconnection.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.6.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../../content/mainsqlconnection.h"
#include <QtCore/qmetatype.h>

#if __has_include(<QtCore/qtmochelpers.h>)
#include <QtCore/qtmochelpers.h>
#else
QT_BEGIN_MOC_NAMESPACE
#endif


#include <memory>

#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'mainsqlconnection.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 68
#error "This file was generated using the moc from 6.6.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {

#ifdef QT_MOC_HAS_STRINGDATA
struct qt_meta_stringdata_CLASSUserInfoENDCLASS_t {};
static constexpr auto qt_meta_stringdata_CLASSUserInfoENDCLASS = QtMocHelpers::stringData(
    "UserInfo",
    "isAutorized",
    "surname",
    "name",
    "patronymic",
    "iD",
    "dormitoryName",
    "roleName",
    "acceses"
);
#else  // !QT_MOC_HAS_STRING_DATA
struct qt_meta_stringdata_CLASSUserInfoENDCLASS_t {
    uint offsetsAndSizes[18];
    char stringdata0[9];
    char stringdata1[12];
    char stringdata2[8];
    char stringdata3[5];
    char stringdata4[11];
    char stringdata5[3];
    char stringdata6[14];
    char stringdata7[9];
    char stringdata8[8];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(sizeof(qt_meta_stringdata_CLASSUserInfoENDCLASS_t::offsetsAndSizes) + ofs), len 
Q_CONSTINIT static const qt_meta_stringdata_CLASSUserInfoENDCLASS_t qt_meta_stringdata_CLASSUserInfoENDCLASS = {
    {
        QT_MOC_LITERAL(0, 8),  // "UserInfo"
        QT_MOC_LITERAL(9, 11),  // "isAutorized"
        QT_MOC_LITERAL(21, 7),  // "surname"
        QT_MOC_LITERAL(29, 4),  // "name"
        QT_MOC_LITERAL(34, 10),  // "patronymic"
        QT_MOC_LITERAL(45, 2),  // "iD"
        QT_MOC_LITERAL(48, 13),  // "dormitoryName"
        QT_MOC_LITERAL(62, 8),  // "roleName"
        QT_MOC_LITERAL(71, 7)   // "acceses"
    },
    "UserInfo",
    "isAutorized",
    "surname",
    "name",
    "patronymic",
    "iD",
    "dormitoryName",
    "roleName",
    "acceses"
};
#undef QT_MOC_LITERAL
#endif // !QT_MOC_HAS_STRING_DATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSUserInfoENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       8,   14, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       4,       // flags
       0,       // signalCount

 // properties: name, type, flags
       1, QMetaType::Bool, 0x00015003, uint(-1), 0,
       2, QMetaType::QString, 0x00015003, uint(-1), 0,
       3, QMetaType::QString, 0x00015003, uint(-1), 0,
       4, QMetaType::QString, 0x00015003, uint(-1), 0,
       5, QMetaType::LongLong, 0x00015003, uint(-1), 0,
       6, QMetaType::QString, 0x00015003, uint(-1), 0,
       7, QMetaType::QString, 0x00015003, uint(-1), 0,
       8, QMetaType::QString, 0x00015003, uint(-1), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject UserInfo::staticMetaObject = { {
    nullptr,
    qt_meta_stringdata_CLASSUserInfoENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSUserInfoENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_stringdata_CLASSUserInfoENDCLASS_t,
        // property 'isAutorized'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'surname'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'name'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'patronymic'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'iD'
        QtPrivate::TypeAndForceComplete<qint64, std::true_type>,
        // property 'dormitoryName'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'roleName'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'acceses'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<UserInfo, std::true_type>
    >,
    nullptr
} };

void UserInfo::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
if (_c == QMetaObject::ReadProperty) {
        auto *_t = reinterpret_cast<UserInfo *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< bool*>(_v) = _t->isAutorized; break;
        case 1: *reinterpret_cast< QString*>(_v) = _t->surname; break;
        case 2: *reinterpret_cast< QString*>(_v) = _t->name; break;
        case 3: *reinterpret_cast< QString*>(_v) = _t->patronymic; break;
        case 4: *reinterpret_cast< qint64*>(_v) = _t->iD; break;
        case 5: *reinterpret_cast< QString*>(_v) = _t->dormitoryName; break;
        case 6: *reinterpret_cast< QString*>(_v) = _t->roleName; break;
        case 7: *reinterpret_cast< QString*>(_v) = _t->acceses; break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = reinterpret_cast<UserInfo *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0:
            if (_t->isAutorized != *reinterpret_cast< bool*>(_v)) {
                _t->isAutorized = *reinterpret_cast< bool*>(_v);
            }
            break;
        case 1:
            if (_t->surname != *reinterpret_cast< QString*>(_v)) {
                _t->surname = *reinterpret_cast< QString*>(_v);
            }
            break;
        case 2:
            if (_t->name != *reinterpret_cast< QString*>(_v)) {
                _t->name = *reinterpret_cast< QString*>(_v);
            }
            break;
        case 3:
            if (_t->patronymic != *reinterpret_cast< QString*>(_v)) {
                _t->patronymic = *reinterpret_cast< QString*>(_v);
            }
            break;
        case 4:
            if (_t->iD != *reinterpret_cast< qint64*>(_v)) {
                _t->iD = *reinterpret_cast< qint64*>(_v);
            }
            break;
        case 5:
            if (_t->dormitoryName != *reinterpret_cast< QString*>(_v)) {
                _t->dormitoryName = *reinterpret_cast< QString*>(_v);
            }
            break;
        case 6:
            if (_t->roleName != *reinterpret_cast< QString*>(_v)) {
                _t->roleName = *reinterpret_cast< QString*>(_v);
            }
            break;
        case 7:
            if (_t->acceses != *reinterpret_cast< QString*>(_v)) {
                _t->acceses = *reinterpret_cast< QString*>(_v);
            }
            break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    } else if (_c == QMetaObject::BindableProperty) {
    }
    (void)_o;
    (void)_id;
    (void)_c;
    (void)_a;
}
namespace {

#ifdef QT_MOC_HAS_STRINGDATA
struct qt_meta_stringdata_CLASSQMLPairENDCLASS_t {};
static constexpr auto qt_meta_stringdata_CLASSQMLPairENDCLASS = QtMocHelpers::stringData(
    "QMLPair",
    "key",
    "value"
);
#else  // !QT_MOC_HAS_STRING_DATA
struct qt_meta_stringdata_CLASSQMLPairENDCLASS_t {
    uint offsetsAndSizes[6];
    char stringdata0[8];
    char stringdata1[4];
    char stringdata2[6];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(sizeof(qt_meta_stringdata_CLASSQMLPairENDCLASS_t::offsetsAndSizes) + ofs), len 
Q_CONSTINIT static const qt_meta_stringdata_CLASSQMLPairENDCLASS_t qt_meta_stringdata_CLASSQMLPairENDCLASS = {
    {
        QT_MOC_LITERAL(0, 7),  // "QMLPair"
        QT_MOC_LITERAL(8, 3),  // "key"
        QT_MOC_LITERAL(12, 5)   // "value"
    },
    "QMLPair",
    "key",
    "value"
};
#undef QT_MOC_LITERAL
#endif // !QT_MOC_HAS_STRING_DATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSQMLPairENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       2,   14, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       4,       // flags
       0,       // signalCount

 // properties: name, type, flags
       1, QMetaType::QString, 0x00015003, uint(-1), 0,
       2, QMetaType::QString, 0x00015003, uint(-1), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject QMLPair::staticMetaObject = { {
    nullptr,
    qt_meta_stringdata_CLASSQMLPairENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSQMLPairENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_stringdata_CLASSQMLPairENDCLASS_t,
        // property 'key'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'value'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<QMLPair, std::true_type>
    >,
    nullptr
} };

void QMLPair::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
if (_c == QMetaObject::ReadProperty) {
        auto *_t = reinterpret_cast<QMLPair *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< QString*>(_v) = _t->key; break;
        case 1: *reinterpret_cast< QString*>(_v) = _t->value; break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = reinterpret_cast<QMLPair *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0:
            if (_t->key != *reinterpret_cast< QString*>(_v)) {
                _t->key = *reinterpret_cast< QString*>(_v);
            }
            break;
        case 1:
            if (_t->value != *reinterpret_cast< QString*>(_v)) {
                _t->value = *reinterpret_cast< QString*>(_v);
            }
            break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    } else if (_c == QMetaObject::BindableProperty) {
    }
    (void)_o;
    (void)_id;
    (void)_c;
    (void)_a;
}
namespace {

#ifdef QT_MOC_HAS_STRINGDATA
struct qt_meta_stringdata_CLASSColumnInfoENDCLASS_t {};
static constexpr auto qt_meta_stringdata_CLASSColumnInfoENDCLASS = QtMocHelpers::stringData(
    "ColumnInfo",
    "columnName",
    "isPK",
    "columnType",
    "maxLength",
    "isFK",
    "isNullable",
    "fkColumnInfo",
    "QMLPair"
);
#else  // !QT_MOC_HAS_STRING_DATA
struct qt_meta_stringdata_CLASSColumnInfoENDCLASS_t {
    uint offsetsAndSizes[18];
    char stringdata0[11];
    char stringdata1[11];
    char stringdata2[5];
    char stringdata3[11];
    char stringdata4[10];
    char stringdata5[5];
    char stringdata6[11];
    char stringdata7[13];
    char stringdata8[8];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(sizeof(qt_meta_stringdata_CLASSColumnInfoENDCLASS_t::offsetsAndSizes) + ofs), len 
Q_CONSTINIT static const qt_meta_stringdata_CLASSColumnInfoENDCLASS_t qt_meta_stringdata_CLASSColumnInfoENDCLASS = {
    {
        QT_MOC_LITERAL(0, 10),  // "ColumnInfo"
        QT_MOC_LITERAL(11, 10),  // "columnName"
        QT_MOC_LITERAL(22, 4),  // "isPK"
        QT_MOC_LITERAL(27, 10),  // "columnType"
        QT_MOC_LITERAL(38, 9),  // "maxLength"
        QT_MOC_LITERAL(48, 4),  // "isFK"
        QT_MOC_LITERAL(53, 10),  // "isNullable"
        QT_MOC_LITERAL(64, 12),  // "fkColumnInfo"
        QT_MOC_LITERAL(77, 7)   // "QMLPair"
    },
    "ColumnInfo",
    "columnName",
    "isPK",
    "columnType",
    "maxLength",
    "isFK",
    "isNullable",
    "fkColumnInfo",
    "QMLPair"
};
#undef QT_MOC_LITERAL
#endif // !QT_MOC_HAS_STRING_DATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSColumnInfoENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       7,   14, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       4,       // flags
       0,       // signalCount

 // properties: name, type, flags
       1, QMetaType::QString, 0x00015003, uint(-1), 0,
       2, QMetaType::Bool, 0x00015003, uint(-1), 0,
       3, QMetaType::QString, 0x00015003, uint(-1), 0,
       4, QMetaType::Int, 0x00015003, uint(-1), 0,
       5, QMetaType::Bool, 0x00015003, uint(-1), 0,
       6, QMetaType::Bool, 0x00015003, uint(-1), 0,
       7, 0x80000000 | 8, 0x0001500b, uint(-1), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject ColumnInfo::staticMetaObject = { {
    nullptr,
    qt_meta_stringdata_CLASSColumnInfoENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSColumnInfoENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_stringdata_CLASSColumnInfoENDCLASS_t,
        // property 'columnName'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'isPK'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'columnType'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'maxLength'
        QtPrivate::TypeAndForceComplete<qint32, std::true_type>,
        // property 'isFK'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'isNullable'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'fkColumnInfo'
        QtPrivate::TypeAndForceComplete<QMLPair, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<ColumnInfo, std::true_type>
    >,
    nullptr
} };

void ColumnInfo::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::RegisterPropertyMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 6:
            *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QMLPair >(); break;
        }
    }  else if (_c == QMetaObject::ReadProperty) {
        auto *_t = reinterpret_cast<ColumnInfo *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< QString*>(_v) = _t->columnName; break;
        case 1: *reinterpret_cast< bool*>(_v) = _t->isPK; break;
        case 2: *reinterpret_cast< QString*>(_v) = _t->columnType; break;
        case 3: *reinterpret_cast< qint32*>(_v) = _t->maxLength; break;
        case 4: *reinterpret_cast< bool*>(_v) = _t->isFK; break;
        case 5: *reinterpret_cast< bool*>(_v) = _t->isNullable; break;
        case 6: *reinterpret_cast< QMLPair*>(_v) = _t->fkColumnInfo; break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = reinterpret_cast<ColumnInfo *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0:
            if (_t->columnName != *reinterpret_cast< QString*>(_v)) {
                _t->columnName = *reinterpret_cast< QString*>(_v);
            }
            break;
        case 1:
            if (_t->isPK != *reinterpret_cast< bool*>(_v)) {
                _t->isPK = *reinterpret_cast< bool*>(_v);
            }
            break;
        case 2:
            if (_t->columnType != *reinterpret_cast< QString*>(_v)) {
                _t->columnType = *reinterpret_cast< QString*>(_v);
            }
            break;
        case 3:
            if (_t->maxLength != *reinterpret_cast< qint32*>(_v)) {
                _t->maxLength = *reinterpret_cast< qint32*>(_v);
            }
            break;
        case 4:
            if (_t->isFK != *reinterpret_cast< bool*>(_v)) {
                _t->isFK = *reinterpret_cast< bool*>(_v);
            }
            break;
        case 5:
            if (_t->isNullable != *reinterpret_cast< bool*>(_v)) {
                _t->isNullable = *reinterpret_cast< bool*>(_v);
            }
            break;
        case 6:
            if (_t->fkColumnInfo != *reinterpret_cast< QMLPair*>(_v)) {
                _t->fkColumnInfo = *reinterpret_cast< QMLPair*>(_v);
            }
            break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    } else if (_c == QMetaObject::BindableProperty) {
    }
    (void)_o;
}
namespace {

#ifdef QT_MOC_HAS_STRINGDATA
struct qt_meta_stringdata_CLASSMainSQLConnectionENDCLASS_t {};
static constexpr auto qt_meta_stringdata_CLASSMainSQLConnectionENDCLASS = QtMocHelpers::stringData(
    "MainSQLConnection",
    "QML.Singleton",
    "true",
    "QML.Element",
    "auto",
    "userinfoChanged",
    "",
    "getAllViews",
    "getAllTables",
    "getAllColumns",
    "tablename",
    "getPKColumn",
    "getFKColumns",
    "QHash<QString,std::pair<QString,QString>>",
    "getAdditionalColumnInfo",
    "ColumnInfo",
    "columname",
    "getColumnsInfo",
    "getFKValues",
    "table",
    "column",
    "addLog",
    "action_id",
    "staff_id",
    "action_description",
    "deleteRecord",
    "column_id",
    "column_value",
    "updateRecord",
    "columns",
    "values",
    "id_column",
    "id_value",
    "insertRecord",
    "autorize",
    "UserInfo",
    "Login",
    "Password",
    "userinfo"
);
#else  // !QT_MOC_HAS_STRING_DATA
struct qt_meta_stringdata_CLASSMainSQLConnectionENDCLASS_t {
    uint offsetsAndSizes[78];
    char stringdata0[18];
    char stringdata1[14];
    char stringdata2[5];
    char stringdata3[12];
    char stringdata4[5];
    char stringdata5[16];
    char stringdata6[1];
    char stringdata7[12];
    char stringdata8[13];
    char stringdata9[14];
    char stringdata10[10];
    char stringdata11[12];
    char stringdata12[13];
    char stringdata13[42];
    char stringdata14[24];
    char stringdata15[11];
    char stringdata16[10];
    char stringdata17[15];
    char stringdata18[12];
    char stringdata19[6];
    char stringdata20[7];
    char stringdata21[7];
    char stringdata22[10];
    char stringdata23[9];
    char stringdata24[19];
    char stringdata25[13];
    char stringdata26[10];
    char stringdata27[13];
    char stringdata28[13];
    char stringdata29[8];
    char stringdata30[7];
    char stringdata31[10];
    char stringdata32[9];
    char stringdata33[13];
    char stringdata34[9];
    char stringdata35[9];
    char stringdata36[6];
    char stringdata37[9];
    char stringdata38[9];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(sizeof(qt_meta_stringdata_CLASSMainSQLConnectionENDCLASS_t::offsetsAndSizes) + ofs), len 
Q_CONSTINIT static const qt_meta_stringdata_CLASSMainSQLConnectionENDCLASS_t qt_meta_stringdata_CLASSMainSQLConnectionENDCLASS = {
    {
        QT_MOC_LITERAL(0, 17),  // "MainSQLConnection"
        QT_MOC_LITERAL(18, 13),  // "QML.Singleton"
        QT_MOC_LITERAL(32, 4),  // "true"
        QT_MOC_LITERAL(37, 11),  // "QML.Element"
        QT_MOC_LITERAL(49, 4),  // "auto"
        QT_MOC_LITERAL(54, 15),  // "userinfoChanged"
        QT_MOC_LITERAL(70, 0),  // ""
        QT_MOC_LITERAL(71, 11),  // "getAllViews"
        QT_MOC_LITERAL(83, 12),  // "getAllTables"
        QT_MOC_LITERAL(96, 13),  // "getAllColumns"
        QT_MOC_LITERAL(110, 9),  // "tablename"
        QT_MOC_LITERAL(120, 11),  // "getPKColumn"
        QT_MOC_LITERAL(132, 12),  // "getFKColumns"
        QT_MOC_LITERAL(145, 41),  // "QHash<QString,std::pair<QStri..."
        QT_MOC_LITERAL(187, 23),  // "getAdditionalColumnInfo"
        QT_MOC_LITERAL(211, 10),  // "ColumnInfo"
        QT_MOC_LITERAL(222, 9),  // "columname"
        QT_MOC_LITERAL(232, 14),  // "getColumnsInfo"
        QT_MOC_LITERAL(247, 11),  // "getFKValues"
        QT_MOC_LITERAL(259, 5),  // "table"
        QT_MOC_LITERAL(265, 6),  // "column"
        QT_MOC_LITERAL(272, 6),  // "addLog"
        QT_MOC_LITERAL(279, 9),  // "action_id"
        QT_MOC_LITERAL(289, 8),  // "staff_id"
        QT_MOC_LITERAL(298, 18),  // "action_description"
        QT_MOC_LITERAL(317, 12),  // "deleteRecord"
        QT_MOC_LITERAL(330, 9),  // "column_id"
        QT_MOC_LITERAL(340, 12),  // "column_value"
        QT_MOC_LITERAL(353, 12),  // "updateRecord"
        QT_MOC_LITERAL(366, 7),  // "columns"
        QT_MOC_LITERAL(374, 6),  // "values"
        QT_MOC_LITERAL(381, 9),  // "id_column"
        QT_MOC_LITERAL(391, 8),  // "id_value"
        QT_MOC_LITERAL(400, 12),  // "insertRecord"
        QT_MOC_LITERAL(413, 8),  // "autorize"
        QT_MOC_LITERAL(422, 8),  // "UserInfo"
        QT_MOC_LITERAL(431, 5),  // "Login"
        QT_MOC_LITERAL(437, 8),  // "Password"
        QT_MOC_LITERAL(446, 8)   // "userinfo"
    },
    "MainSQLConnection",
    "QML.Singleton",
    "true",
    "QML.Element",
    "auto",
    "userinfoChanged",
    "",
    "getAllViews",
    "getAllTables",
    "getAllColumns",
    "tablename",
    "getPKColumn",
    "getFKColumns",
    "QHash<QString,std::pair<QString,QString>>",
    "getAdditionalColumnInfo",
    "ColumnInfo",
    "columname",
    "getColumnsInfo",
    "getFKValues",
    "table",
    "column",
    "addLog",
    "action_id",
    "staff_id",
    "action_description",
    "deleteRecord",
    "column_id",
    "column_value",
    "updateRecord",
    "columns",
    "values",
    "id_column",
    "id_value",
    "insertRecord",
    "autorize",
    "UserInfo",
    "Login",
    "Password",
    "userinfo"
};
#undef QT_MOC_LITERAL
#endif // !QT_MOC_HAS_STRING_DATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSMainSQLConnectionENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       2,   14, // classinfo
      14,   18, // methods
       1,  164, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // classinfo: key, value
       1,    2,
       3,    4,

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       5,    0,  102,    6, 0x06,    2 /* Public */,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
       7,    0,  103,    6, 0x02,    3 /* Public */,
       8,    0,  104,    6, 0x02,    4 /* Public */,
       9,    1,  105,    6, 0x02,    5 /* Public */,
      11,    1,  108,    6, 0x02,    7 /* Public */,
      12,    1,  111,    6, 0x02,    9 /* Public */,
      14,    2,  114,    6, 0x02,   11 /* Public */,
      17,    1,  119,    6, 0x02,   14 /* Public */,
      18,    2,  122,    6, 0x02,   16 /* Public */,
      21,    3,  127,    6, 0x02,   19 /* Public */,
      25,    3,  134,    6, 0x02,   23 /* Public */,
      28,    5,  141,    6, 0x02,   27 /* Public */,
      33,    3,  152,    6, 0x02,   33 /* Public */,
      34,    2,  159,    6, 0x02,   37 /* Public */,

 // signals: parameters
    QMetaType::Void,

 // methods: parameters
    QMetaType::QStringList,
    QMetaType::QStringList,
    QMetaType::QStringList, QMetaType::QString,   10,
    QMetaType::QString, QMetaType::QString,   10,
    0x80000000 | 13, QMetaType::QString,   10,
    0x80000000 | 15, QMetaType::QString, QMetaType::QString,   10,   16,
    QMetaType::QVariantList, QMetaType::QString,   10,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::QString,   19,   20,
    QMetaType::Bool, QMetaType::LongLong, QMetaType::LongLong, QMetaType::QJsonDocument,   22,   23,   24,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString,   10,   26,   27,
    QMetaType::QString, QMetaType::QString, QMetaType::QVariantList, QMetaType::QVariantList, QMetaType::QString, QMetaType::QString,   10,   29,   30,   31,   32,
    QMetaType::QString, QMetaType::QString, QMetaType::QVariantList, QMetaType::QVariantList,   10,   29,   30,
    0x80000000 | 35, QMetaType::QString, QMetaType::QString,   36,   37,

 // properties: name, type, flags
      38, 0x80000000 | 35, 0x0001590b, uint(0), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject MainSQLConnection::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_CLASSMainSQLConnectionENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSMainSQLConnectionENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_metaTypeArray<
        // property 'userinfo'
        UserInfo,
        // Q_OBJECT / Q_GADGET
        MainSQLConnection,
        // method 'userinfoChanged'
        void,
        // method 'getAllViews'
        QStringList,
        // method 'getAllTables'
        QStringList,
        // method 'getAllColumns'
        QStringList,
        const QString &,
        // method 'getPKColumn'
        QString,
        const QString &,
        // method 'getFKColumns'
        QHash<QString,QPair<QString,QString>>,
        const QString &,
        // method 'getAdditionalColumnInfo'
        ColumnInfo,
        const QString &,
        const QString &,
        // method 'getColumnsInfo'
        QVariantList,
        const QString &,
        // method 'getFKValues'
        QVariantList,
        QString,
        QString,
        // method 'addLog'
        bool,
        qint64,
        qint64,
        QJsonDocument,
        // method 'deleteRecord'
        bool,
        const QString &,
        const QString &,
        const QString &,
        // method 'updateRecord'
        QString,
        const QString &,
        QVariantList,
        QVariantList,
        QString,
        QString,
        // method 'insertRecord'
        QString,
        const QString &,
        QVariantList,
        QVariantList,
        // method 'autorize'
        UserInfo,
        const QString &,
        const QString &
    >,
    nullptr
} };

void MainSQLConnection::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<MainSQLConnection *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->userinfoChanged(); break;
        case 1: { QStringList _r = _t->getAllViews();
            if (_a[0]) *reinterpret_cast< QStringList*>(_a[0]) = std::move(_r); }  break;
        case 2: { QStringList _r = _t->getAllTables();
            if (_a[0]) *reinterpret_cast< QStringList*>(_a[0]) = std::move(_r); }  break;
        case 3: { QStringList _r = _t->getAllColumns((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QStringList*>(_a[0]) = std::move(_r); }  break;
        case 4: { QString _r = _t->getPKColumn((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 5: { QHash<QString,std::pair<QString,QString>> _r = _t->getFKColumns((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QHash<QString,std::pair<QString,QString>>*>(_a[0]) = std::move(_r); }  break;
        case 6: { ColumnInfo _r = _t->getAdditionalColumnInfo((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast< ColumnInfo*>(_a[0]) = std::move(_r); }  break;
        case 7: { QVariantList _r = _t->getColumnsInfo((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 8: { QVariantList _r = _t->getFKValues((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 9: { bool _r = _t->addLog((*reinterpret_cast< std::add_pointer_t<qint64>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<qint64>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QJsonDocument>>(_a[3])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 10: { bool _r = _t->deleteRecord((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 11: { QString _r = _t->updateRecord((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QVariantList>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QVariantList>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[5])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 12: { QString _r = _t->insertRecord((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QVariantList>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QVariantList>>(_a[3])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 13: { UserInfo _r = _t->autorize((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast< UserInfo*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (MainSQLConnection::*)();
            if (_t _q_method = &MainSQLConnection::userinfoChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
    } else if (_c == QMetaObject::RegisterPropertyMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 0:
            *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< UserInfo >(); break;
        }
    }  else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<MainSQLConnection *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< UserInfo*>(_v) = _t->userinfo(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = static_cast<MainSQLConnection *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setUserinfo(*reinterpret_cast< UserInfo*>(_v)); break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    } else if (_c == QMetaObject::BindableProperty) {
    }
}

const QMetaObject *MainSQLConnection::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *MainSQLConnection::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_CLASSMainSQLConnectionENDCLASS.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int MainSQLConnection::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 14)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 14;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 14)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 14;
    }else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    }
    return _id;
}

// SIGNAL 0
void MainSQLConnection::userinfoChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}
QT_WARNING_POP
