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

import QtQuick 2.13
import Qt.labs.settings 1.0
import QtQuick.Controls 2.13
import Scrite 1.0

Item {
    width: 850
    height: 700

    Item {
        anchors.fill: parent
        anchors.margins: 20

        Rectangle {
            anchors.fill: pageList
            anchors.margins: -4
            radius: 5
            border { width: 1; color: "black" }
        }

        ListModel {
            id: pageModel
            ListElement { name: "Settings"; group: "Application"; }
            ListElement { name: "Title Page"; group: "Screenplay" }
            ListElement { name: "Page Setup"; group: "Screenplay" }

            ListElement { name: "Heading"; group: "On Screen Format"; elementType: SceneElement.Heading }
            ListElement { name: "Action"; group: "On Screen Format"; elementType: SceneElement.Action }
            ListElement { name: "Character"; group: "On Screen Format"; elementType: SceneElement.Character }
            ListElement { name: "Dialogue"; group: "On Screen Format"; elementType: SceneElement.Dialogue }
            ListElement { name: "Parenthetical"; group: "On Screen Format"; elementType: SceneElement.Parenthetical }
            ListElement { name: "Shot"; group: "On Screen Format"; elementType: SceneElement.Shot }
            ListElement { name: "Transition"; group: "On Screen Format"; elementType: SceneElement.Transition }

            ListElement { name: "Heading"; group: "Print Format"; elementType: SceneElement.Heading }
            ListElement { name: "Action"; group: "Print Format"; elementType: SceneElement.Action }
            ListElement { name: "Character"; group: "Print Format"; elementType: SceneElement.Character }
            ListElement { name: "Dialogue"; group: "Print Format"; elementType: SceneElement.Dialogue }
            ListElement { name: "Parenthetical"; group: "Print Format"; elementType: SceneElement.Parenthetical }
            ListElement { name: "Shot"; group: "Print Format"; elementType: SceneElement.Shot }
            ListElement { name: "Transition"; group: "Print Format"; elementType: SceneElement.Transition }
        }

        ListView {
            id: pageList
            height: parent.height
            width: 170
            model: pageModel
            spacing: 5
            clip: true
            highlightMoveDuration: 0
            section.property: "group"
            section.criteria: ViewSection.FullString
            section.delegate: Rectangle {
                width: pageList.scrollBarRequired ? pageList.width - 17 : pageList.width
                height: 30
                color: "lightsteelblue"

                Text {
                    anchors.centerIn: parent
                    font.pixelSize: 14
                    font.letterSpacing: 2
                    text: section
                }
            }

            property bool scrollBarRequired: pageList.height < pageList.contentHeight
            ScrollBar.vertical: ScrollBar {
                policy: pageList.scrollBarRequired ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                minimumSize: 0.1
                palette {
                    mid: Qt.rgba(0,0,0,0.25)
                    dark: Qt.rgba(0,0,0,0.75)
                }
            }
            highlight: Rectangle {
                width: pageList.scrollBarRequired ? pageList.width - 17 : pageList.width
                color: "lightgray"
                radius: 5
            }
            delegate: Text {
                width: pageList.scrollBarRequired ? pageList.width - 17 : pageList.width
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                height: 32
                font.pixelSize: 18
                font.bold: pageList.currentIndex === index
                text: name
                MouseArea {
                    anchors.fill: parent
                    onClicked: pageList.currentIndex = index
                }
            }
        }

        Loader {
            anchors.left: pageList.right
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            active: pageList.currentIndex >= 0
            sourceComponent: {
                if(pageList.currentIndex >= 3 && pageList.currentIndex <= 9)
                    return elementFormatOptionsComponent

                if(pageList.currentIndex >= 10 && pageList.currentIndex <= 16)
                    return elementFormatOptionsComponent

                switch(pageList.currentIndex) {
                case 0: return applicationSettingsComponent
                case 1: return screenplayOptionsComponent
                case 2: return pageSetupComponent
                }
            }
        }
    }

    Component {
        id: screenplayOptionsComponent

        Item {
            property real labelWidth: 100

            Column {
                width: parent.width
                spacing: 20

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: "Title Page Settings"
                    font.pixelSize: 24
                }

                Item { width: parent.width; height: 1 }

                // Title field
                Row {
                    spacing: 10
                    width: parent.width

                    Text {
                        width: labelWidth
                        horizontalAlignment: Text.AlignRight
                        text: "Title"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        width: parent.width-parent.spacing-labelWidth
                        text: scriteDocument.screenplay.title
                        onTextEdited: scriteDocument.screenplay.title = text
                        font.pixelSize: 20
                    }
                }

                // Subtitle field
                Row {
                    spacing: 10
                    width: parent.width

                    Text {
                        width: labelWidth
                        horizontalAlignment: Text.AlignRight
                        text: "Subtitle"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        width: parent.width-parent.spacing-labelWidth
                        text: scriteDocument.screenplay.subtitle
                        onTextEdited: scriteDocument.screenplay.subtitle = text
                        font.pixelSize: 20
                    }
                }

                // Author field
                Row {
                    spacing: 10
                    width: parent.width

                    Text {
                        width: labelWidth
                        horizontalAlignment: Text.AlignRight
                        text: "Author"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        width: parent.width-parent.spacing-labelWidth
                        text: scriteDocument.screenplay.author
                        onTextEdited: scriteDocument.screenplay.author = text
                        font.pixelSize: 20
                    }
                }

                // Contact field
                Row {
                    spacing: 10
                    width: parent.width

                    Text {
                        width: labelWidth
                        horizontalAlignment: Text.AlignRight
                        text: "Contact"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        width: parent.width-parent.spacing-labelWidth
                        text: scriteDocument.screenplay.contact
                        onTextEdited: scriteDocument.screenplay.contact = text
                        font.pixelSize: 20
                    }
                }

                // Version field
                Row {
                    spacing: 10
                    width: parent.width

                    Text {
                        width: labelWidth
                        horizontalAlignment: Text.AlignRight
                        text: "Version"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        width: parent.width-parent.spacing-labelWidth
                        text: scriteDocument.screenplay.version
                        onTextEdited: scriteDocument.screenplay.version = text
                        font.pixelSize: 20
                    }
                }

                Column {
                    spacing: parent.spacing/2
                    width: parent.width-20
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Reset Paragraph Formats"
                        onClicked: scriteDocument.formatting.resetToDefaults()
                    }

                    Text {
                        color: "red"
                        width: parent.width
                        font.pixelSize: 10
                        text: "<strong>NOTE:</strong> Clicking this button will reset both print and on-screen paragraph formats."
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }

    Component {
        id: pageSetupComponent

        Item {
            property var fieldsModel: app.enumerationModelForType("HeaderFooter", "Field")

            Settings {
                id: pageSetupSettings
                fileName: app.settingsFilePath
                category: "PageSetup"
                property var headerLeft: HeaderFooter.Title
                property var headerCenter: HeaderFooter.Subtitle
                property var headerRight: HeaderFooter.PageNumber
                property real headerOpacity: 0.5
                property var footerLeft: HeaderFooter.Author
                property var footerCenter: HeaderFooter.Version
                property var footerRight: HeaderFooter.Contact
                property real footerOpacity: 0.5
                property bool watermarkEnabled: false
                property string watermarkText: "Scrite"
                property string watermarkFont: "Courier Prime"
                property int watermarkFontSize: 120
                property color watermarkColor: "lightgray"
                property real watermarkOpacity: 0.5
                property real watermarkRotation: -45
                property int watermarkAlignment: Qt.AlignCenter
            }

            ScrollView {
                id: pageSetupScroll
                width: parent.width-20
                height: parent.height
                anchors.right: parent.right
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                Column {
                    spacing: 20
                    width: pageSetupScroll.width-20

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: "Page Setup"
                        font.pixelSize: 24
                    }

                    Text {
                        width: parent.width
                        text: "PDFs are always generated in US Letter size."
                    }

                    GroupBox {
                        width: parent.width
                        label: Text {
                            text: "Header"
                            font.pixelSize: 15
                            font.bold: true
                        }

                        Row {
                            width: parent.width
                            height: 80

                            Item {
                                width: parent.width/3
                                height: childrenRect.height

                                Column {
                                    width: parent.width-10
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 10

                                    Text {
                                        text: "Left"
                                    }

                                    ComboBox {
                                        width: parent.width
                                        model: fieldsModel
                                        textRole: "key"
                                        currentIndex: pageSetupSettings.headerLeft
                                        onActivated: pageSetupSettings.headerLeft = currentIndex
                                    }
                                }
                            }

                            Item {
                                width: parent.width/3
                                height: childrenRect.height

                                Column {
                                    width: parent.width-10
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 10

                                    Text {
                                        text: "Center"
                                    }

                                    ComboBox {
                                        width: parent.width
                                        model: fieldsModel
                                        textRole: "key"
                                        currentIndex: pageSetupSettings.headerCenter
                                        onActivated: pageSetupSettings.headerCenter = currentIndex
                                    }
                                }
                            }

                            Item {
                                width: parent.width/3
                                height: childrenRect.height

                                Column {
                                    width: parent.width-10
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 10

                                    Text {
                                        text: "Right"
                                    }

                                    ComboBox {
                                        width: parent.width
                                        model: fieldsModel
                                        textRole: "key"
                                        currentIndex: pageSetupSettings.headerRight
                                        onActivated: pageSetupSettings.headerRight = currentIndex
                                    }
                                }
                            }
                        }
                    }

                    GroupBox {
                        width: parent.width
                        label: Text {
                            text: "Footer"
                            font.pixelSize: 15
                            font.bold: true
                        }

                        Row {
                            width: parent.width
                            height: 80

                            Item {
                                width: parent.width/3
                                height: childrenRect.height

                                Column {
                                    width: parent.width-10
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 10

                                    Text {
                                        text: "Left"
                                    }

                                    ComboBox {
                                        width: parent.width
                                        model: fieldsModel
                                        textRole: "key"
                                        currentIndex: pageSetupSettings.footerLeft
                                        onActivated: pageSetupSettings.footerLeft = currentIndex
                                    }
                                }
                            }

                            Item {
                                width: parent.width/3
                                height: childrenRect.height

                                Column {
                                    width: parent.width-10
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 10

                                    Text {
                                        text: "Center"
                                    }

                                    ComboBox {
                                        width: parent.width
                                        model: fieldsModel
                                        textRole: "key"
                                        currentIndex: pageSetupSettings.footerCenter
                                        onActivated: pageSetupSettings.footerCenter = currentIndex
                                    }
                                }
                            }

                            Item {
                                width: parent.width/3
                                height: childrenRect.height

                                Column {
                                    width: parent.width-10
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 10

                                    Text {
                                        text: "Right"
                                    }

                                    ComboBox {
                                        width: parent.width
                                        model: fieldsModel
                                        textRole: "key"
                                        currentIndex: pageSetupSettings.footerRight
                                        onActivated: pageSetupSettings.footerRight = currentIndex
                                    }
                                }
                            }
                        }
                    }

                    GroupBox {
                        width: parent.width
                        label: CheckBox {
                            text: "Watermark"
                            checked: pageSetupSettings.watermarkEnabled
                            onToggled: pageSetupSettings.watermarkEnabled = checked
                        }

                        Grid {
                            width: parent.width
                            columns: 2
                            spacing: 10
                            verticalItemAlignment: Grid.AlignVCenter
                            enabled: pageSetupSettings.watermarkEnabled

                            Text {
                                text: "Text"
                            }

                            TextField {
                                width: 300
                                text: pageSetupSettings.watermarkText
                                onTextEdited: pageSetupSettings.watermarkText = text
                            }

                            Text {
                                text: "Font Family"
                            }

                            ComboBox {
                                width: 300
                                model: systemFontInfo.families
                                currentIndex: systemFontInfo.families.indexOf(pageSetupSettings.watermarkFont)
                                onCurrentIndexChanged: pageSetupSettings.watermarkFont = systemFontInfo.families[currentIndex]
                            }

                            Text {
                                text: "Font Size"
                            }

                            SpinBox {
                                width: 300
                                from: 9; to: 200; stepSize: 1
                                editable: true
                                value: pageSetupSettings.watermarkFontSize
                                onValueModified: pageSetupSettings.watermarkFontSize = value
                            }

                            Text {
                                text: "Rotation"
                            }

                            SpinBox {
                                width: 300
                                from: -180; to: 180
                                value: pageSetupSettings.watermarkRotation
                                textFromValue: function(value,locale) { return value + " degrees" }
                                validator: IntValidator { top: 360; bottom: 0 }
                                onValueModified: pageSetupSettings.watermarkRotation = value
                            }

                            Text {
                                text: "Color"
                            }

                            Rectangle {
                                border.width: 1
                                border.color: "black"
                                color: pageSetupSettings.watermarkColor
                                width: 30; height: 30
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: pageSetupSettings.watermarkColor = app.pickColor(pageSetupSettings.watermarkColor)
                                }
                            }
                        }
                    }

                    Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Restore Defaults"
                        onClicked: {
                            pageSetupSettings.headerLeft = HeaderFooter.Title
                            pageSetupSettings.headerCenter = HeaderFooter.Subtitle
                            pageSetupSettings.headerRight = HeaderFooter.PageNumber
                            pageSetupSettings.footerLeft = HeaderFooter.Author
                            pageSetupSettings.footerCenter = HeaderFooter.Version
                            pageSetupSettings.footerRight = HeaderFooter.Contact
                            pageSetupSettings.watermarkEnabled = false
                            pageSetupSettings.watermarkText = "Scrite"
                            pageSetupSettings.watermarkFont = "Courier Prime"
                            pageSetupSettings.watermarkFontSize = 120
                            pageSetupSettings.watermarkColor = "lightgray"
                            pageSetupSettings.watermarkOpacity = 0.5
                            pageSetupSettings.watermarkRotation = -45
                            pageSetupSettings.watermarkAlignment = Qt.AlignCenter
                        }
                    }
                }
            }
        }
    }

    property var systemFontInfo: app.systemFontInfo()

    Component {
        id: elementFormatOptionsComponent

        ScrollView {
            id: scrollView
            property real labelWidth: 125
            property var pageData: pageModel.get(pageList.currentIndex)
            property ScreenplayFormat format: pageData.group === "On Screen Format" ? scriteDocument.formatting : scriteDocument.printFormat
            property SceneElementFormat elementFormat: format.elementFormat(pageData.elementType)

            Column {
                width: scrollView.width
                spacing: 10

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: "<strong>" + pageData.name + "</strong> (" + pageData.group + ")"
                    font.pixelSize: 24
                }

                // Font Family
                Row {
                    spacing: 10
                    width: parent.width

                    Text {
                        width: labelWidth
                        horizontalAlignment: Text.AlignRight
                        text: "Font Family"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    ComboBox {
                        width: parent.width-parent.spacing-labelWidth
                        model: systemFontInfo.families
                        currentIndex: systemFontInfo.families.indexOf(elementFormat.font.family)
                        onCurrentIndexChanged: elementFormat.font.family = systemFontInfo.families[currentIndex]
                    }
                }

                // Font Size
                Row {
                    spacing: 10
                    width: parent.width

                    Text {
                        width: labelWidth
                        horizontalAlignment: Text.AlignRight
                        text: "Font Size"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    SpinBox {
                        width: parent.width-parent.spacing-labelWidth
                        from: 9
                        to: 62
                        stepSize: 1
                        editable: true
                        value: elementFormat.font.pointSize
                        onValueModified: elementFormat.font.pointSize = value
                    }
                }

                // Font Style
                Row {
                    spacing: 10
                    width: parent.width

                    Text {
                        width: labelWidth
                        horizontalAlignment: Text.AlignRight
                        text: "Font Style"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 5

                        CheckBox {
                            text: "Bold"
                            font.bold: true
                            checkable: true
                            checked: elementFormat.font.bold
                        }

                        CheckBox {
                            text: "Italics"
                            font.italic: true
                            checkable: true
                            checked: elementFormat.font.italic
                        }

                        CheckBox {
                            text: "Underline"
                            font.underline: true
                            checkable: true
                            checked: elementFormat.font.underline
                        }
                    }
                }

                // Colors
                Row {
                    spacing: 10
                    width: parent.width

                    Text {
                        width: labelWidth
                        horizontalAlignment: Text.AlignRight
                        text: "Text Color"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        border.width: 1
                        border.color: "black"
                        color: elementFormat.textColor
                        width: 30; height: 30
                        anchors.verticalCenter: parent.verticalCenter
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: elementFormat.textColor = app.pickColor(elementFormat.textColor)
                        }
                    }

                    Text {
                        horizontalAlignment: Text.AlignRight
                        text: "Background Color"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        border.width: 1
                        border.color: "black"
                        color: elementFormat.backgroundColor
                        width: 30; height: 30
                        anchors.verticalCenter: parent.verticalCenter
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: elementFormat.backgroundColor = app.pickColor(elementFormat.backgroundColor)
                        }
                    }
                }

                // Text Alignment
                Row {
                    spacing: 10
                    width: parent.width

                    Text {
                        width: labelWidth
                        horizontalAlignment: Text.AlignRight
                        text: "Text Alignment"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 5

                        RadioButton {
                            text: "Left"
                            checkable: true
                            checked: elementFormat.textAlignment === Qt.AlignLeft
                            onCheckedChanged: {
                                if(checked)
                                    elementFormat.textAlignment = Qt.AlignLeft
                            }
                        }

                        RadioButton {
                            text: "Center"
                            checkable: true
                            checked: elementFormat.textAlignment === Qt.AlignHCenter
                            onCheckedChanged: {
                                if(checked)
                                    elementFormat.textAlignment = Qt.AlignHCenter
                            }
                        }

                        RadioButton {
                            text: "Right"
                            checkable: true
                            checked: elementFormat.textAlignment === Qt.AlignRight
                            onCheckedChanged: {
                                if(checked)
                                    elementFormat.textAlignment = Qt.AlignRight
                            }
                        }

                        RadioButton {
                            text: "Justify"
                            checkable: true
                            checked: elementFormat.textAlignment === Qt.AlignJustify
                            onCheckedChanged: {
                                if(checked)
                                    elementFormat.textAlignment = Qt.AlignJustify
                            }
                        }
                    }
                }

                // Block Margin
                Row {
                    spacing: 10
                    width: parent.width

                    Text {
                        width: labelWidth
                        horizontalAlignment: Text.AlignRight
                        text: "Block Width"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    SpinBox {
                        width: parent.width-parent.spacing-labelWidth
                        from: 0
                        to: 100
                        stepSize: 1
                        value: elementFormat.blockWidth * 100
                        onValueModified: elementFormat.blockWidth = value/100
                        textFromValue: function(value,locale) {
                            return value + "%"
                        }
                    }
                }

                // Block Alignment
                Row {
                    spacing: 10
                    width: parent.width

                    Text {
                        width: labelWidth
                        horizontalAlignment: Text.AlignRight
                        text: "Block Alignment"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 5

                        RadioButton {
                            text: "Left"
                            checkable: true
                            checked: elementFormat.blockAlignment === Qt.AlignLeft
                        }

                        RadioButton {
                            text: "Center"
                            checkable: true
                            checked: elementFormat.blockAlignment === Qt.AlignHCenter
                        }

                        RadioButton {
                            text: "Right"
                            checkable: true
                            checked: elementFormat.blockAlignment === Qt.AlignRight
                        }
                    }
                }

                Row {
                    spacing: 10
                    width: parent.width

                    Text {
                        width: labelWidth
                        horizontalAlignment: Text.AlignRight
                        text: "Margins"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Text {
                            text: "Top"
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        TextField {
                            width: 100
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                            text: elementFormat.topMargin
                            validator: IntValidator { top: 100; bottom: 0 }
                            onTextChanged: elementFormat.topMargin = text === "" ? 0 : parseInt(text)
                        }

                        Text {
                            text: "Bottom"
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        TextField {
                            width: 100
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                            text: elementFormat.bottomMargin
                            validator: IntValidator { top: 100; bottom: 0 }
                            onTextChanged: elementFormat.bottomMargin = text === "" ? 0 : parseInt(text)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: applicationSettingsComponent

        Item {
            id: appSettingsPage

            ScrollView {
                id: appSettingsScrollView
                anchors.fill: parent
                anchors.margins: 5
                contentWidth: width
                contentHeight: appSettingsPageContent.height

                Item {
                    width: appSettingsScrollView.width
                    height: appSettingsPageContent.height

                    Column {
                        id: appSettingsPageContent
                        width: appSettingsPage.width * 0.8
                        spacing: 20
                        anchors.horizontalCenter: parent.horizontalCenter

                        GroupBox {
                            width: parent.width
                            label: CheckBox {
                                text: "Enable AutoSave"
                                checked: scriteDocument.autoSave
                                onToggled: scriteDocument.autoSave = checked
                            }

                            Column {
                                width: parent.width
                                spacing: 10
                                enabled: scriteDocument.autoSave

                                Text {
                                    width: parent.width
                                    text: "Auto Save Interval (in seconds)"
                                }

                                TextField {
                                    width: parent.width
                                    text: scriteDocument.autoSaveDurationInSeconds
                                    validator: IntValidator {
                                        bottom: 1; top: 3600
                                    }
                                    onTextEdited: scriteDocument.autoSaveDurationInSeconds = parseInt(text)
                                }
                            }
                        }

                        GroupBox {
                            width: parent.width

                            Column {
                                width: parent.width
                                spacing: 10

                                CheckBox {
                                    checkable: true
                                    checked: structureCanvasSettings.showGrid
                                    text: "Show Grid in Structure Tab"
                                    onToggled: structureCanvasSettings.showGrid = checked
                                }

                                // Colors
                                Row {
                                    spacing: 10
                                    width: parent.width

                                    Text {
                                        font.pixelSize: 14
                                        text: "Background Color"
                                        horizontalAlignment: Text.AlignRight
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Rectangle {
                                        border.width: 1
                                        border.color: "black"
                                        width: 30; height: 30
                                        color: structureCanvasSettings.canvasColor
                                        anchors.verticalCenter: parent.verticalCenter

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: structureCanvasSettings.canvasColor = app.pickColor(structureCanvasSettings.canvasColor)
                                        }
                                    }

                                    Text {
                                        text: "Grid Color"
                                        font.pixelSize: 14
                                        horizontalAlignment: Text.AlignRight
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Rectangle {
                                        border.width: 1
                                        border.color: "black"
                                        width: 30; height: 30
                                        color: structureCanvasSettings.gridColor
                                        anchors.verticalCenter: parent.verticalCenter

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: structureCanvasSettings.gridColor = app.pickColor(structureCanvasSettings.gridColor)
                                        }
                                    }
                                }

                                Row {
                                    spacing: 10
                                    width: parent.width
                                    visible: app.isWindowsPlatform || app.isLinuxPlatform

                                    Text {
                                        id: wzfText
                                        text: "Zoom Speed"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Slider {
                                        from: 1
                                        to: 20
                                        orientation: Qt.Horizontal
                                        snapMode: Slider.SnapAlways
                                        value: scrollAreaSettings.zoomFactor * 100
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width-wzfText.width-parent.spacing
                                        onMoved: scrollAreaSettings.zoomFactor = value / 100
                                    }
                                }
                            }
                        }

                        GroupBox {
                            width: parent.width
                            label: Text {
                                text: "Active Languages"
                            }
                            height: activeLanguagesView.height+45

                            Grid {
                                id: activeLanguagesView
                                width: parent.width-10
                                anchors.top: parent.top
                                spacing: 5
                                columns: 3

                                Repeater {
                                    model: app.transliterationSettings.getLanguages()
                                    delegate: CheckBox {
                                        width: activeLanguagesView.width/activeLanguagesView.columns
                                        checkable: true
                                        checked: modelData.active
                                        text: modelData.key
                                        onToggled: app.transliterationSettings.markLanguage(modelData.value,checked)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
