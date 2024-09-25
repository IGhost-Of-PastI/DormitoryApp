/****************************************************************************
** Meta object code from reading C++ file 'backupactions.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.6.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../../content/backupactions.h"
#include <QtCore/qmetatype.h>

#if __has_include(<QtCore/qtmochelpers.h>)
#include <QtCore/qtmochelpers.h>
#else
QT_BEGIN_MOC_NAMESPACE
#endif


#include <memory>

#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'backupactions.h' doesn't include <QObject>."
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
struct qt_meta_stringdata_CLASSBackupActionsENDCLASS_t {};
static constexpr auto qt_meta_stringdata_CLASSBackupActionsENDCLASS = QtMocHelpers::stringData(
    "BackupActions",
    "QML.Element",
    "auto",
    "isTaskActiveChanged",
    "",
    "getParam",
    "section",
    "param",
    "setParam",
    "value",
    "doBackup",
    "setTaskToBackup",
    "deleteTaskToBackup",
    "isTaskExist",
    "restoreFromBackup",
    "backupFilePath",
    "isTaskActive"
);
#else  // !QT_MOC_HAS_STRING_DATA
struct qt_meta_stringdata_CLASSBackupActionsENDCLASS_t {
    uint offsetsAndSizes[34];
    char stringdata0[14];
    char stringdata1[12];
    char stringdata2[5];
    char stringdata3[20];
    char stringdata4[1];
    char stringdata5[9];
    char stringdata6[8];
    char stringdata7[6];
    char stringdata8[9];
    char stringdata9[6];
    char stringdata10[9];
    char stringdata11[16];
    char stringdata12[19];
    char stringdata13[12];
    char stringdata14[18];
    char stringdata15[15];
    char stringdata16[13];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(sizeof(qt_meta_stringdata_CLASSBackupActionsENDCLASS_t::offsetsAndSizes) + ofs), len 
Q_CONSTINIT static const qt_meta_stringdata_CLASSBackupActionsENDCLASS_t qt_meta_stringdata_CLASSBackupActionsENDCLASS = {
    {
        QT_MOC_LITERAL(0, 13),  // "BackupActions"
        QT_MOC_LITERAL(14, 11),  // "QML.Element"
        QT_MOC_LITERAL(26, 4),  // "auto"
        QT_MOC_LITERAL(31, 19),  // "isTaskActiveChanged"
        QT_MOC_LITERAL(51, 0),  // ""
        QT_MOC_LITERAL(52, 8),  // "getParam"
        QT_MOC_LITERAL(61, 7),  // "section"
        QT_MOC_LITERAL(69, 5),  // "param"
        QT_MOC_LITERAL(75, 8),  // "setParam"
        QT_MOC_LITERAL(84, 5),  // "value"
        QT_MOC_LITERAL(90, 8),  // "doBackup"
        QT_MOC_LITERAL(99, 15),  // "setTaskToBackup"
        QT_MOC_LITERAL(115, 18),  // "deleteTaskToBackup"
        QT_MOC_LITERAL(134, 11),  // "isTaskExist"
        QT_MOC_LITERAL(146, 17),  // "restoreFromBackup"
        QT_MOC_LITERAL(164, 14),  // "backupFilePath"
        QT_MOC_LITERAL(179, 12)   // "isTaskActive"
    },
    "BackupActions",
    "QML.Element",
    "auto",
    "isTaskActiveChanged",
    "",
    "getParam",
    "section",
    "param",
    "setParam",
    "value",
    "doBackup",
    "setTaskToBackup",
    "deleteTaskToBackup",
    "isTaskExist",
    "restoreFromBackup",
    "backupFilePath",
    "isTaskActive"
};
#undef QT_MOC_LITERAL
#endif // !QT_MOC_HAS_STRING_DATA
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_CLASSBackupActionsENDCLASS[] = {

 // content:
      12,       // revision
       0,       // classname
       1,   14, // classinfo
       8,   16, // methods
       1,   84, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // classinfo: key, value
       1,    2,

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       3,    0,   64,    4, 0x06,    2 /* Public */,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
       5,    2,   65,    4, 0x02,    3 /* Public */,
       8,    3,   70,    4, 0x02,    6 /* Public */,
      10,    0,   77,    4, 0x02,   10 /* Public */,
      11,    0,   78,    4, 0x02,   11 /* Public */,
      12,    0,   79,    4, 0x02,   12 /* Public */,
      13,    0,   80,    4, 0x02,   13 /* Public */,
      14,    1,   81,    4, 0x02,   14 /* Public */,

 // signals: parameters
    QMetaType::Void,

 // methods: parameters
    QMetaType::QString, QMetaType::QString, QMetaType::QString,    6,    7,
    QMetaType::Void, QMetaType::QString, QMetaType::QString, QMetaType::QString,    6,    7,    9,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Bool,
    QMetaType::Void, QMetaType::QString,   15,

 // properties: name, type, flags
      16, QMetaType::Bool, 0x00015903, uint(0), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject BackupActions::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_CLASSBackupActionsENDCLASS.offsetsAndSizes,
    qt_meta_data_CLASSBackupActionsENDCLASS,
    qt_static_metacall,
    nullptr,
    qt_metaTypeArray<
        // property 'isTaskActive'
        bool,
        // Q_OBJECT / Q_GADGET
        BackupActions,
        // method 'isTaskActiveChanged'
        void,
        // method 'getParam'
        QString,
        const QString &,
        const QString &,
        // method 'setParam'
        void,
        const QString &,
        const QString &,
        const QString &,
        // method 'doBackup'
        void,
        // method 'setTaskToBackup'
        void,
        // method 'deleteTaskToBackup'
        void,
        // method 'isTaskExist'
        bool,
        // method 'restoreFromBackup'
        void,
        QString
    >,
    nullptr
} };

void BackupActions::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<BackupActions *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->isTaskActiveChanged(); break;
        case 1: { QString _r = _t->getParam((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 2: _t->setParam((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QString>>(_a[3]))); break;
        case 3: _t->doBackup(); break;
        case 4: _t->setTaskToBackup(); break;
        case 5: _t->deleteTaskToBackup(); break;
        case 6: { bool _r = _t->isTaskExist();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 7: _t->restoreFromBackup((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (BackupActions::*)();
            if (_t _q_method = &BackupActions::isTaskActiveChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
    } else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<BackupActions *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< bool*>(_v) = _t->isTaskActive(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = static_cast<BackupActions *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setIsTaskActive(*reinterpret_cast< bool*>(_v)); break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    } else if (_c == QMetaObject::BindableProperty) {
    }
}

const QMetaObject *BackupActions::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *BackupActions::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_CLASSBackupActionsENDCLASS.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int BackupActions::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 8)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 8;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 8)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 8;
    }else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    }
    return _id;
}

// SIGNAL 0
void BackupActions::isTaskActiveChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}
QT_WARNING_POP
