/****************************************************************************
** Meta object code from reading C++ file 'additionalfunctions.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.6.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../../content/additionalfunctions.h"
#include <QtCore/qmetatype.h>

#if __has_include(<QtCore/qtmochelpers.h>)
#include <QtCore/qtmochelpers.h>
#else
QT_BEGIN_MOC_NAMESPACE
#endif


#include <memory>

#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'additionalfunctions.h' doesn't include <QObject>."
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
struct qt_meta_stringdata_CLASSAdditionalFunctionsENDCLASS_t {};
static constexpr auto qt_meta_stringdata_CLASSAdditionalFunctionsENDCLASS = QtMocHelpers::stringData(
    "AdditionalFunctions",
    "QML.Singleton",
    "true",
    "QML.Element",
    "auto",
    "fileSysPathtoURL",
    "",
    "path",
    "uriToFileSysPath",
    "uri"
);
#else  // !QT_MOC_HAS_STRING_DATA
struct qt_meta_stringdata_CLASSAdditionalFunctionsENDCLASS_t {
    uint offsetsAndSizes[20];
    char stringdata0[20];
    char stringdata1[14];
    char stringdata2[5];
    char stringdata3[12];
    char stringdata4[5];
    char stringdata5[17];
    char stringdata6[1];
    char stringdata7[5];
    char stringdata8[17];
    char stringdata9[4];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(sizeof(qt_meta_stringdata_CLASSAdditionalFunctionsENDCLASS_t::offsetsAndSizes) + ofs), len 
Q_CONSTINIT static const qt_meta_stringdata_CLASSAdditionalFunctionsENDCLASS_t qt_meta_stringdata_CLASSAdditionalFunctionsENDCLASS = {
    {
        QT_MOC_LITERAL(0, 19),  // "AdditionalFunctions"
        QT_MOC_LITERAL(20, 13),  // "QML.Singleton"
        QT_MOC_LITERAL(34, 4),  // "true"
        QT_MOC_LITERAL(39, 11),  // "QML.Element"
        QT_MOC_LITERAL(51, 4),  // "auto"
        QT_MOC_LITERAL(56, 16),  // "fileSysPathtoURL"
        QT_MOC_LITERAL(73, 0),  // ""
        QT_MOC_LITERAL(74, 4),  // "path"
        QT_MOC_LITERAL(79, 16),  // "uriToFileSysPath"
        QT_MOC_LITERAL(96, 3)   // "uri"
    },
    "AdditionalFunctions",
    "QML.Singleton",
    "true",
    "QML.Element",
    "auto",
    "fileSysPathtoURL",
    "",
    "path",
    "uriToFileSysPath",
    "uri"
};
#undef QT_MOC_LITERAL
#endif // !QT_MOC_HAS_STRING_DATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSAdditionalFunctionsENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       2,   14, // classinfo
       2,   18, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // classinfo: key, value
       1,    2,
       3,    4,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
       5,    1,   30,    6, 0x02,    1 /* Public */,
       8,    1,   33,    6, 0x02,    3 /* Public */,

 // methods: parameters
    QMetaType::QString, QMetaType::QString,    7,
    QMetaType::QString, QMetaType::QUrl,    9,

       0        // eod
};

Q_CONSTINIT const QMetaObject AdditionalFunctions::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_CLASSAdditionalFunctionsENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSAdditionalFunctionsENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_metaTypeArray<
        // Q_OBJECT / Q_GADGET
        AdditionalFunctions,
        // method 'fileSysPathtoURL'
        QString,
        QString,
        // method 'uriToFileSysPath'
        QString,
        QUrl
    >,
    nullptr
} };

void AdditionalFunctions::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<AdditionalFunctions *>(_o);
        (void)_t;
        switch (_id) {
        case 0: { QString _r = _t->fileSysPathtoURL((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 1: { QString _r = _t->uriToFileSysPath((*reinterpret_cast< std::add_pointer_t<QUrl>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    }
}

const QMetaObject *AdditionalFunctions::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *AdditionalFunctions::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_CLASSAdditionalFunctionsENDCLASS.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int AdditionalFunctions::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 2)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 2;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 2)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 2;
    }
    return _id;
}
QT_WARNING_POP
