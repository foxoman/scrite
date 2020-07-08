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

#ifndef FILEINFO_H
#define FILEINFO_H

#include <QObject>
#include <QFileInfo>

class FileInfo : public QObject
{
    Q_OBJECT

public:
    FileInfo(QObject *parent=nullptr);
    ~FileInfo();

    Q_PROPERTY(QString absoluteFilePath READ absoluteFilePath WRITE setAbsoluteFilePath NOTIFY fileInfoChanged)
    void setAbsoluteFilePath(const QString &val);
    QString absoluteFilePath() const { return m_fileInfo.absoluteFilePath(); }

    Q_PROPERTY(QString absolutePath READ absolutePath WRITE setAbsolutePath NOTIFY fileInfoChanged)
    void setAbsolutePath(const QString &val);
    QString absolutePath() const { return m_fileInfo.absolutePath(); }

    Q_PROPERTY(QString fileName READ fileName WRITE setFileName NOTIFY fileInfoChanged)
    void setFileName(const QString &val);
    QString fileName() const { return m_fileInfo.fileName(); }

    Q_PROPERTY(QString suffix READ suffix WRITE setSuffix NOTIFY fileInfoChanged)
    void setSuffix(const QString &val);
    QString suffix() const { return m_fileInfo.suffix(); }

    Q_PROPERTY(QString baseName READ baseName WRITE setBaseName NOTIFY fileInfoChanged)
    void setBaseName(const QString &val);
    QString baseName() const { return m_fileInfo.baseName(); }

    QFileInfo fileInfo() const { return m_fileInfo; }
    Q_SIGNAL void fileInfoChanged();

private:
    void setFileInfo(const QFileInfo &val);

private:
    QFileInfo m_fileInfo;
};

#endif // FILEINFO_H
