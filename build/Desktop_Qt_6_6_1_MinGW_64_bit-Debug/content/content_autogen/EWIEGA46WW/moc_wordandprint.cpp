/****************************************************************************
** Meta object code from reading C++ file 'wordandprint.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.6.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../../content/wordandprint.h"
#include <QtCore/qmetatype.h>

#if __has_include(<QtCore/qtmochelpers.h>)
#include <QtCore/qtmochelpers.h>
#else
QT_BEGIN_MOC_NAMESPACE
#endif


#include <memory>

#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'wordandprint.h' doesn't include <QObject>."
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
struct qt_meta_stringdata_CLASSWordAndPrintENDCLASS_t {};
static constexpr auto qt_meta_stringdata_CLASSWordAndPrintENDCLASS = QtMocHelpers::stringData(
    "WordAndPrint",
    "QML.Singleton",
    "true",
    "QML.Element",
    "auto",
    "importInWord",
    "",
    "tablename"
);
#else  // !QT_MOC_HAS_STRING_DATA
struct qt_meta_stringdata_CLASSWordAndPrintENDCLASS_t {
    uint offsetsAndSizes[16];
    char stringdata0[13];
    char stringdata1[14];
    char stringdata2[5];
    char stringdata3[12];
    char stringdata4[5];
    char stringdata5[13];
    char stringdata6[1];
    char stringdata7[10];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(sizeof(qt_meta_stringdata_CLASSWordAndPrintENDCLASS_t::offsetsAndSizes) + ofs), len 
Q_CONSTINIT static const qt_meta_stringdata_CLASSWordAndPrintENDCLASS_t qt_meta_stringdata_CLASSWordAndPrintENDCLASS = {
    {
        QT_MOC_LITERAL(0, 12),  // "WordAndPrint"
        QT_MOC_LITERAL(13, 13),  // "QML.Singleton"
        QT_MOC_LITERAL(27, 4),  // "true"
        QT_MOC_LITERAL(32, 11),  // "QML.Element"
        QT_MOC_LITERAL(44, 4),  // "auto"
        QT_MOC_LITERAL(49, 12),  // "importInWord"
        QT_MOC_LITERAL(62, 0),  // ""
        QT_MOC_LITERAL(63, 9)   // "tablename"
    },
    "WordAndPrint",
    "QML.Singleton",
    "true",
    "QML.Element",
    "auto",
    "importInWord",
    "",
    "tablename"
};
#undef QT_MOC_LITERAL
#endif // !QT_MOC_HAS_STRING_DATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSWordAndPrintENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       2,   14, // classinfo
       1,   18, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // classinfo: key, value
       1,    2,
       3,    4,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
       5,    1,   24,    6, 0x02,    1 /* Public */,

 // methods: parameters
    QMetaType::Bool, QMetaType::QString,    7,

       0        // eod
};

Q_CONSTINIT const QMetaObject WordAndPrint::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_CLASSWordAndPrintENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSWordAndPrintENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_metaTypeArray<
        // Q_OBJECT / Q_GADGET
        WordAndPrint,
        // method 'importInWord'
        bool,
        QString
    >,
    nullptr
} };

void WordAndPrint::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<WordAndPrint *>(_o);
        (void)_t;
        switch (_id) {
        case 0: { bool _r = _t->importInWord((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    }
}

const QMetaObject *WordAndPrint::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *WordAndPrint::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_CLASSWordAndPrintENDCLASS.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int WordAndPrint::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 1)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 1)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 1;
    }
    return _id;
}
QT_WARNING_POP
