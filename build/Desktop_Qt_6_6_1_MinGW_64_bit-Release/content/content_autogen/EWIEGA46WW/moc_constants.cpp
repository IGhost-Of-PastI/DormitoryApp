/****************************************************************************
** Meta object code from reading C++ file 'constants.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.6.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../../content/constants.h"
#include <QtCore/qmetatype.h>

#if __has_include(<QtCore/qtmochelpers.h>)
#include <QtCore/qtmochelpers.h>
#else
QT_BEGIN_MOC_NAMESPACE
#endif


#include <memory>

#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'constants.h' doesn't include <QObject>."
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
struct qt_meta_stringdata_CLASSConstantsENDCLASS_t {};
static constexpr auto qt_meta_stringdata_CLASSConstantsENDCLASS = QtMocHelpers::stringData(
    "Constants",
    "QML.Singleton",
    "true",
    "QML.Element",
    "auto",
    "settingsFile",
    "backupCategoryName",
    "databaseCategoryName"
);
#else  // !QT_MOC_HAS_STRING_DATA
struct qt_meta_stringdata_CLASSConstantsENDCLASS_t {
    uint offsetsAndSizes[16];
    char stringdata0[10];
    char stringdata1[14];
    char stringdata2[5];
    char stringdata3[12];
    char stringdata4[5];
    char stringdata5[13];
    char stringdata6[19];
    char stringdata7[21];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(sizeof(qt_meta_stringdata_CLASSConstantsENDCLASS_t::offsetsAndSizes) + ofs), len 
Q_CONSTINIT static const qt_meta_stringdata_CLASSConstantsENDCLASS_t qt_meta_stringdata_CLASSConstantsENDCLASS = {
    {
        QT_MOC_LITERAL(0, 9),  // "Constants"
        QT_MOC_LITERAL(10, 13),  // "QML.Singleton"
        QT_MOC_LITERAL(24, 4),  // "true"
        QT_MOC_LITERAL(29, 11),  // "QML.Element"
        QT_MOC_LITERAL(41, 4),  // "auto"
        QT_MOC_LITERAL(46, 12),  // "settingsFile"
        QT_MOC_LITERAL(59, 18),  // "backupCategoryName"
        QT_MOC_LITERAL(78, 20)   // "databaseCategoryName"
    },
    "Constants",
    "QML.Singleton",
    "true",
    "QML.Element",
    "auto",
    "settingsFile",
    "backupCategoryName",
    "databaseCategoryName"
};
#undef QT_MOC_LITERAL
#endif // !QT_MOC_HAS_STRING_DATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSConstantsENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       2,   14, // classinfo
       0,    0, // methods
       3,   18, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // classinfo: key, value
       1,    2,
       3,    4,

 // properties: name, type, flags
       5, QMetaType::QString, 0x00015401, uint(-1), 0,
       6, QMetaType::QString, 0x00015401, uint(-1), 0,
       7, QMetaType::QString, 0x00015401, uint(-1), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject Constants::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_CLASSConstantsENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSConstantsENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_metaTypeArray<
        // property 'settingsFile'
        QString,
        // property 'backupCategoryName'
        QString,
        // property 'databaseCategoryName'
        QString,
        // Q_OBJECT / Q_GADGET
        Constants
    >,
    nullptr
} };

void Constants::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<Constants *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< QString*>(_v) = _t->settingsFile(); break;
        case 1: *reinterpret_cast< QString*>(_v) = _t->backupCategoryName(); break;
        case 2: *reinterpret_cast< QString*>(_v) = _t->databaseCategoryName(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
    } else if (_c == QMetaObject::ResetProperty) {
    } else if (_c == QMetaObject::BindableProperty) {
    }
    (void)_o;
    (void)_id;
    (void)_c;
    (void)_a;
}

const QMetaObject *Constants::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *Constants::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_CLASSConstantsENDCLASS.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int Constants::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 3;
    }
    return _id;
}
QT_WARNING_POP
