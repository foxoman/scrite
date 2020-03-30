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

#ifndef HOURGLASS_H
#define HOURGLASS_H

#include <QCursor>
#include <QGuiApplication>

class HourGlass
{
public:
    HourGlass(const QCursor &cursor=QCursor(Qt::WaitCursor)) {
        qApp->setOverrideCursor(cursor);
    }

    ~HourGlass() {
        qApp->restoreOverrideCursor();
    }
};

#endif // HOURGLASS_H