/****************************************************************************
**
** Copyright (C) Prashanth Udupa, Bengaluru
** Email: prashanth.udupa@gmail.com
**
** This code is distributed under GPL v3. Complete text of the license
** can be found here: https://www.gnu.org/licenses/gpl-3.0.txt
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/

#include "abstractreportgenerator.h"

#include <QFileInfo>
#include <QJsonArray>
#include <QJsonObject>
#include <QMetaObject>
#include <QMetaClassInfo>

AbstractReportGenerator::AbstractReportGenerator(QObject *parent)
                        :AbstractDeviceIO(parent)
{

}

AbstractReportGenerator::~AbstractReportGenerator()
{

}

bool AbstractReportGenerator::generate()
{
    QString fileName = this->fileName();
    ScriteDocument *document = this->document();
    Screenplay *screenplay = document->screenplay();

    this->error()->clear();

    if(fileName.isEmpty())
    {
        this->error()->setErrorMessage("Cannot export to an empty file.");
        return false;
    }

    if(document == nullptr)
    {
        this->error()->setErrorMessage("No document available to export.");
        return false;
    }

    QFile file(fileName);
    if( !file.open(QFile::WriteOnly) )
    {
        this->error()->setErrorMessage( QString("Could not open file '%1' for writing.").arg(fileName) );
        return false;
    }

    QPdfWriter pdfWriter(&file);
    pdfWriter.setTitle(screenplay->title().isEmpty() ? "Untitled Screenplay" : screenplay->title());
    pdfWriter.setCreator(qApp->applicationName() + " " + qApp->applicationVersion());
    pdfWriter.setPageSize(QPageSize(QPageSize::A4));
    pdfWriter.setPageMargins(QMarginsF(0.2,0.1,0.2,0.1), QPageLayout::Inch);

    this->progress()->start();
    const bool ret = this->doGenerate(&pdfWriter);
    this->progress()->finish();

    return ret;
}

QJsonObject AbstractReportGenerator::configurationFormInfo() const
{
    const QMetaObject *mo = this->metaObject();
    auto queryClassInfo = [mo](const char *key) {
        const int ciIndex = mo->indexOfClassInfo(key);
        if(ciIndex < 0)
            return QString();
        const QMetaClassInfo ci = mo->classInfo(ciIndex);
        return QString::fromLatin1(ci.value());
    };

    auto queryPropertyInfo = [queryClassInfo](const QMetaProperty &prop, const char *key) {
        const QString ciKey = QString::fromLatin1(prop.name()) + "_" + QString::fromLatin1(key);
        return queryClassInfo(qPrintable(ciKey));
    };

    QJsonObject ret;
    ret.insert("title", queryClassInfo("Title"));

    QJsonArray fields;
    for(int i=AbstractReportGenerator::staticMetaObject.propertyOffset(); i<mo->propertyCount(); i++)
    {
        const QMetaProperty prop = mo->property(i);
        if(!prop.isWritable())
            continue;

        QJsonObject field;
        field.insert("name", QString::fromLatin1(prop.name()));
        field.insert("label", queryPropertyInfo(prop, "FieldLabel"));
        field.insert("editor", queryPropertyInfo(prop, "FieldEditor"));
        fields.append(field);
    }

    ret.insert("fields", fields);

    return ret;
}

QString AbstractReportGenerator::polishFileName(const QString &fileName) const
{
    QFileInfo fi(fileName);
    if(fi.suffix() != "pdf")
        return fileName + ".pdf";
    return fileName;
}