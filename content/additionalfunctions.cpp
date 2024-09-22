#include "additionalfunctions.h"

AdditionalFunctions::AdditionalFunctions(QObject *parent)
    : QObject{parent}
{}

QString AdditionalFunctions::fileSysPathtoURL(QString path)
{
    QUrl url = QUrl::fromLocalFile(path);
   // url.setPath(path);
    return url.toString();
}

QString AdditionalFunctions::uriToFileSysPath(QUrl uri)
{
    return uri.toLocalFile();
}
