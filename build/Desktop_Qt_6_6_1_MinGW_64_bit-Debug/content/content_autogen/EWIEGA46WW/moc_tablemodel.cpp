/****************************************************************************
** Meta object code from reading C++ file 'tablemodel.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.6.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../../content/tablemodel.h"
#include <QtCore/qmetatype.h>

#if __has_include(<QtCore/qtmochelpers.h>)
#include <QtCore/qtmochelpers.h>
#else
QT_BEGIN_MOC_NAMESPACE
#endif


#include <memory>

#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'tablemodel.h' doesn't include <QObject>."
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
struct qt_meta_stringdata_CLASSTableModelENDCLASS_t {};
static constexpr auto qt_meta_stringdata_CLASSTableModelENDCLASS = QtMocHelpers::stringData(
    "TableModel",
    "QML.Element",
    "auto",
    "tablenameChanged",
    "",
    "setQuery",
    "query",
    "setFilterQML",
    "column",
    "value",
    "setSortQML",
    "SortEnum",
    "sortorder",
    "tablename",
    "ASC",
    "DESC"
);
#else  // !QT_MOC_HAS_STRING_DATA
struct qt_meta_stringdata_CLASSTableModelENDCLASS_t {
    uint offsetsAndSizes[32];
    char stringdata0[11];
    char stringdata1[12];
    char stringdata2[5];
    char stringdata3[17];
    char stringdata4[1];
    char stringdata5[9];
    char stringdata6[6];
    char stringdata7[13];
    char stringdata8[7];
    char stringdata9[6];
    char stringdata10[11];
    char stringdata11[9];
    char stringdata12[10];
    char stringdata13[10];
    char stringdata14[4];
    char stringdata15[5];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(sizeof(qt_meta_stringdata_CLASSTableModelENDCLASS_t::offsetsAndSizes) + ofs), len 
Q_CONSTINIT static const qt_meta_stringdata_CLASSTableModelENDCLASS_t qt_meta_stringdata_CLASSTableModelENDCLASS = {
    {
        QT_MOC_LITERAL(0, 10),  // "TableModel"
        QT_MOC_LITERAL(11, 11),  // "QML.Element"
        QT_MOC_LITERAL(23, 4),  // "auto"
        QT_MOC_LITERAL(28, 16),  // "tablenameChanged"
        QT_MOC_LITERAL(45, 0),  // ""
        QT_MOC_LITERAL(46, 8),  // "setQuery"
        QT_MOC_LITERAL(55, 5),  // "query"
        QT_MOC_LITERAL(61, 12),  // "setFilterQML"
        QT_MOC_LITERAL(74, 6),  // "column"
        QT_MOC_LITERAL(81, 5),  // "value"
        QT_MOC_LITERAL(87, 10),  // "setSortQML"
        QT_MOC_LITERAL(98, 8),  // "SortEnum"
        QT_MOC_LITERAL(107, 9),  // "sortorder"
        QT_MOC_LITERAL(117, 9),  // "tablename"
        QT_MOC_LITERAL(127, 3),  // "ASC"
        QT_MOC_LITERAL(131, 4)   // "DESC"
    },
    "TableModel",
    "QML.Element",
    "auto",
    "tablenameChanged",
    "",
    "setQuery",
    "query",
    "setFilterQML",
    "column",
    "value",
    "setSortQML",
    "SortEnum",
    "sortorder",
    "tablename",
    "ASC",
    "DESC"
};
#undef QT_MOC_LITERAL
#endif // !QT_MOC_HAS_STRING_DATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSTableModelENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       1,   14, // classinfo
       4,   16, // methods
       1,   54, // properties
       1,   59, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // classinfo: key, value
       1,    2,

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       3,    0,   40,    4, 0x06,    3 /* Public */,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
       5,    1,   41,    4, 0x02,    4 /* Public */,
       7,    2,   44,    4, 0x02,    6 /* Public */,
      10,    2,   49,    4, 0x02,    9 /* Public */,

 // signals: parameters
    QMetaType::Void,

 // methods: parameters
    QMetaType::QString, QMetaType::QString,    6,
    QMetaType::Void, QMetaType::QString, QMetaType::QString,    8,    9,
    QMetaType::Void, QMetaType::QString, 0x80000000 | 11,    8,   12,

 // properties: name, type, flags
      13, QMetaType::QString, 0x00015903, uint(0), 0,

 // enums: name, alias, flags, count, data
      11,   11, 0x0,    2,   64,

 // enum data: key, value
      14, uint(TableModel::ASC),
      15, uint(TableModel::DESC),

       0        // eod
};

Q_CONSTINIT const QMetaObject TableModel::staticMetaObject = { {
    QMetaObject::SuperData::link<QSqlRelationalTableModel::staticMetaObject>(),
    qt_meta_stringdata_CLASSTableModelENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSTableModelENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_metaTypeArray<
        // property 'tablename'
        QString,
        // enum 'SortEnum'
        TableModel::SortEnum,
        // Q_OBJECT / Q_GADGET
        TableModel,
        // method 'tablenameChanged'
        void,
        // method 'setQuery'
        QString,
        QString,
        // method 'setFilterQML'
        void,
        QString,
        QString,
        // method 'setSortQML'
        void,
        QString,
        SortEnum
    >,
    nullptr
} };

void TableModel::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<TableModel *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->tablenameChanged(); break;
        case 1: { QString _r = _t->setQuery((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 2: _t->setFilterQML((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2]))); break;
        case 3: _t->setSortQML((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<SortEnum>>(_a[2]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (TableModel::*)();
            if (_t _q_method = &TableModel::tablenameChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
    } else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<TableModel *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< QString*>(_v) = _t->tablename(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = static_cast<TableModel *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setTablename(*reinterpret_cast< QString*>(_v)); break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    } else if (_c == QMetaObject::BindableProperty) {
    }
}

const QMetaObject *TableModel::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *TableModel::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_CLASSTableModelENDCLASS.stringdata0))
        return static_cast<void*>(this);
    return QSqlRelationalTableModel::qt_metacast(_clname);
}

int TableModel::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QSqlRelationalTableModel::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 4)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 4;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 4)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 4;
    }else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    }
    return _id;
}

// SIGNAL 0
void TableModel::tablenameChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}
QT_WARNING_POP
