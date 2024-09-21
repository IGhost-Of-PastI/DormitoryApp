#include "additionalfunctions.h"

AdditionalFunctions::AdditionalFunctions(QObject *parent)
    : QObject{parent}
{}

QString AdditionalFunctions::uriToFileSysPath(QUrl uri)
{
    return uri.toLocalFile();
}
