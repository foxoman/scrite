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

#ifndef LOCATIONREPORTGENERATOR_H
#define LOCATIONREPORTGENERATOR_H

#include "abstractreportgenerator.h"

class LocationReportGenerator : public AbstractReportGenerator
{
    Q_OBJECT
    Q_CLASSINFO("Title", "Location Report")

public:
    Q_INVOKABLE LocationReportGenerator(QObject *parent=nullptr);
    ~LocationReportGenerator();

    bool requiresConfiguration() const { return true; }

protected:
    // AbstractReportGenerator interface
    bool doGenerate(QTextDocument *textDocument);
};

#endif // LOCATIONREPORTGENERATOR_H