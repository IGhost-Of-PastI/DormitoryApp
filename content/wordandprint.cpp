#include "wordandprint.h"
#include <windows.h>
#include<commdlg.h>

WordAndPrint::WordAndPrint(QObject *parent)
    : QObject{parent}
{}

bool WordAndPrint::importInWord(QString tablename)
{
    QSqlQuery query(SQLConnectionMenager::getConnection());
    query.prepare(QString(R"(Select * from %1)").arg(tablename));
   // query.bindValue(":tablename",tablename);
    if (!query.exec()) {
        qDebug()<<query.lastQuery();
        qWarning() << "Query execution failed: " << query.lastError().text();
    //    return;
    }

    QAxObject *wordApp = new QAxObject("Word.Application");
    wordApp->dynamicCall("SetVisible(bool Visible)", true);
    QAxObject *documents = wordApp->querySubObject("Documents");
    documents->dynamicCall("Add()");
    QAxObject *document = wordApp->querySubObject("ActiveDocument");

    QAxObject *range = document->querySubObject("Range()");
    QAxObject *table = document->querySubObject("Tables")->querySubObject("Add(Range, NumRows, NumColumns)", range->asVariant(), query.size() + 1, query.record().count());

    // Set table headers
    for (int col = 0; col < query.record().count(); ++col) {
        QAxObject *cell = table->querySubObject("Cell(Row, Column)", 1, col + 1);
        cell->querySubObject("Range")->dynamicCall("SetText(QString)", query.record().fieldName(col));
    }

    // Fill table with data
    int row = 2;
    while (query.next()) {
        for (int col = 0; col < query.record().count(); ++col) {
            QAxObject *cell = table->querySubObject("Cell(Row, Column)", row, col + 1);
            cell->querySubObject("Range")->dynamicCall("SetText(QString)", query.value(col).toString());
        }
        ++row;
    }

    QString programDir = QCoreApplication::applicationDirPath();
    QString filePath = programDir + "/document.docx";

    document->dynamicCall("SaveAs(const QString&)", filePath);
    wordApp->dynamicCall("Quit()");
    return false;
}


