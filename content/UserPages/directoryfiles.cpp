#include "directoryfiles.h"

DirectoryFiles::DirectoryFiles(QObject *parent)
    : QObject{parent}
{
    m_dirModel=new QFileSystemModel;
}

QString DirectoryFiles::path() const
{
    return m_path;
}

void DirectoryFiles::setPath(const QString &newPath)
{
    if (m_path == newPath)
        return;
    m_path = newPath;
    emit pathChanged();
}

QFileSystemModel *DirectoryFiles::dirModel() const
{
    m_dirModel->setRootPath(m_path);
    return m_dirModel;
}
