/****************************************************************************
**
** Copyright (C) TERIFLIX Entertainment Spaces Pvt. Ltd. Bengaluru
** Author: Prashanth N Udupa (prashanth.udupa@teriflix.com)
**
** This code is distributed under GPL v3. Complete text of the license
** can be found here: https://www.gnu.org/licenses/gpl-3.0.txt
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/

#ifndef QTEXTDOCUMENTPAGEDPRINTER_H
#define QTEXTDOCUMENTPAGEDPRINTER_H

#include <QObject>
#include <QTextDocument>
#include <QPagedPaintDevice>

#include "errorreport.h"
#include "progressreport.h"

class QTextDocumentPagedPrinter;

class HeaderFooter : public QObject
{
    Q_OBJECT

public:
    enum Type
    {
        Header,
        Footer
    };
    Q_ENUM(Type)

    HeaderFooter(Type type, QObject *parent=nullptr);
    ~HeaderFooter();

    Q_PROPERTY(Type type READ type CONSTANT)
    Type type() const { return m_type; }

    enum Field
    {
        Nothing,

        Title, // query QTextDocument::property("#title") for this.
        Author, // query QTextDocument::property("#author") for this.
        Contact, // query QTextDocument::property("#contact") for this.
        Version, // query QTextDocument::property("#version") for this.
        Subtitle, // query QTextDocument::property("#subtitle") for this.

        AppName,
        AppVersion,

        Date,
        Time,
        DateTime,

        PageNumber,
        PageNumberOfCount
    };
    Q_ENUM(Field)

    Q_PROPERTY(Field left READ left WRITE setLeft NOTIFY leftChanged)
    void setLeft(Field val);
    Field left() const { return m_left; }
    Q_SIGNAL void leftChanged();

    Q_PROPERTY(Field center READ center WRITE setCenter NOTIFY centerChanged)
    void setCenter(Field val);
    Field center() const { return m_center; }
    Q_SIGNAL void centerChanged();

    Q_PROPERTY(Field right READ right WRITE setRight NOTIFY rightChanged)
    void setRight(Field val);
    Field right() const { return m_right; }
    Q_SIGNAL void rightChanged();

    Q_PROPERTY(QFont font READ font WRITE setFont NOTIFY fontChanged)
    void setFont(const QFont &val);
    QFont font() const { return m_font; }
    Q_SIGNAL void fontChanged();

private:
    void prepare(const QMap<Field,QString> &fieldValues, const QRectF &rect);
    void paint(QPainter *paint, const QRectF &rect, int pageNr, int pageCount);
    void finish();

private:
    friend class QTextDocumentPagedPrinter;
    Type m_type = Header;
    char m_padding1[4];
    QFont m_font;
    Field m_left = Nothing;
    Field m_center = Nothing;
    Field m_right = Nothing;
    char m_padding2[4];

    struct ColumnContent
    {
        QRectF columnRect;
        QString content;
        int flags;
    };
    QVector<ColumnContent> m_columns;
};

class QTextDocumentPagedPrinter : public QObject
{
    Q_OBJECT

public:
    QTextDocumentPagedPrinter(QObject *parent=nullptr);
    ~QTextDocumentPagedPrinter();

    Q_PROPERTY(HeaderFooter* header READ header CONSTANT)
    HeaderFooter* header() const { return m_header; }

    Q_PROPERTY(HeaderFooter* footer READ footer CONSTANT)
    HeaderFooter* footer() const { return m_footer; }

    Q_INVOKABLE bool print(QTextDocument *document, QPagedPaintDevice *device);

private:
    void printPage(int pageNr, int pageCount, QPainter *painter, const QTextDocument *doc, const QRectF &body);

private:
    HeaderFooter* m_header = new HeaderFooter(HeaderFooter::Header, this);
    HeaderFooter* m_footer = new HeaderFooter(HeaderFooter::Footer, this);
    ErrorReport *m_errorReport = new ErrorReport(this);
    ProgressReport *m_progressReport = new ProgressReport(this);
    QPagedPaintDevice* m_printer = nullptr;
    QTextDocument* m_textDocument = nullptr;
    QRectF m_headerRect;
    QRectF m_footerRect;
};

#endif // QTEXTDOCUMENTPAGEDPRINTER_H