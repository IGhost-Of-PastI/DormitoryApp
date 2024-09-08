#ifndef DIRECTORYFILES_H
#define DIRECTORYFILES_H

#include <QObject>
#include <QQmlEngine>
#include <QFileSystemModel>

class DirectoryFiles : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged FINAL)
    Q_PROPERTY(QFileSystemModel* dirModel READ dirModel CONSTANT)
public:
    explicit DirectoryFiles(QObject *parent = nullptr);
    QString path() const;
    void setPath(const QString &newPath);

    QFileSystemModel *dirModel() const;

signals:
    void pathChanged();

private:
    QString m_path;
    QFileSystemModel *m_dirModel;
};

#endif // DIRECTORYFILES_H
