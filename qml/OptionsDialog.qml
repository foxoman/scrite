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
import QtQuick.Dialogs 1.3
import Qt.labs.settings 1.0
import QtQuick.Controls 2.13
import QtQuick.Controls.Material 2.12
import Scrite 1.0

Item {
    width: 1050
    height: 680
    readonly property color dialogColor: primaryColors.windowColor

    Component.onCompleted: {
        tabBar.currentIndex = modalDialog.arguments && modalDialog.arguments.activeTabIndex ? modalDialog.arguments.activeTabIndex : 0
        modalDialog.arguments = undefined
        // modalDialog.closeable = false
    }

    Row {
        id: tabBar
        anchors.top: parent.top
        anchors.left: parent.left
        property int currentIndex: 0
        readonly property var tabs: ["Application", "Page Setup", "Title Page", "Formatting Rules"]

        Repeater {
            id: tabRepeater
            model: tabBar.tabs

            Rectangle {
                width: tabText.contentWidth + 40
                height: tabText.contentHeight + 30
                color: selected ? "white" : Qt.rgba(0,0,0,0)
                property bool selected: tabBar.currentIndex === index

                Rectangle {
                    height: 4
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: accentColors.c500.background
                    visible: parent.selected
                }

                Text {
                    id: tabText
                    anchors.centerIn: parent
                    font.pixelSize: 16
                    text: modelData
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: tabBar.currentIndex = index
                    hoverEnabled: true
                    ToolTip.visible: containsMouse
                    ToolTip.text: {
                        if(index <= 1)
                            return "Settings in this page apply to all documents."
                        return "Settings in this page applies only to the current document."
                    }
                }
            }
        }
    }

    Item {
        anchors.left: tabBar.right
        anchors.top: parent.top
        anchors.bottom: tabBar.bottom
        anchors.right: parent.right

        Button2 {
            id: doneButton
            text: "Done"
            visible: false
            Material.background: primaryColors.c100.background
            Material.foreground: primaryColors.c100.text
            onClicked: modalDialog.close()
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Rectangle {
        id: contentPanel
        anchors.top: tabBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true

        Loader {
            anchors.fill: parent
            sourceComponent: {
                switch(tabBar.currentIndex) {
                case 0: return applicationSettingsComponent
                case 1: return pageSetupComponent
                case 2: return titlePageSettingsComponent
                case 3: return formattingRulesSettingsComponent
                }
                return unknownSettingsComponent
            }
        }
    }

    Component {
        id: applicationSettingsComponent

        Item {
            id: appSettingsPage

            Row {
                width: 700
                anchors.centerIn: parent
                spacing: 20

                Column {
                    id: appSettingsPageContent
                    width: (parent.width - parent.spacing)/2
                    spacing: 20

                    GroupBox {
                        width: parent.width
                        label: Text { text: "Auto Save" }

                        Column {
                            width: parent.width
                            spacing: 10

                            CheckBox2 {
                                text: "Enable AutoSave"
                                checked: scriteDocument.autoSave
                                onToggled: scriteDocument.autoSave = checked
                            }

                            Text {
                                width: parent.width
                                text: "Auto Save Interval (in seconds)"
                            }

                            TextField {
                                width: parent.width
                                enabled: scriteDocument.autoSave
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

                            CheckBox2 {
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
                                    border.color: primaryColors.borderColor
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
                                    border.color: primaryColors.borderColor
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
                            text: "Screenplay Editor"
                        }

                        CheckBox2 {
                            checked: screenplayEditorSettings.enableSpellCheck
                            text: "Enable spell check"
                            onToggled: screenplayEditorSettings.enableSpellCheck = checked
                        }
                    }
                }

                GroupBox {
                    width: (parent.width - parent.spacing)/2
                    label: Text { text: "Active Languages" }
                    height: Math.max(activeLanguagesView.height+45, parent.height)

                    Grid {
                        id: activeLanguagesView
                        width: parent.width
                        spacing: 5
                        columns: 2

                        Repeater {
                            model: app.transliterationEngine.getLanguages()
                            delegate: CheckBox2 {
                                width: activeLanguagesView.width/activeLanguagesView.columns
                                checkable: true
                                checked: modelData.active
                                text: modelData.key
                                onToggled: app.transliterationEngine.markLanguage(modelData.value,checked)
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: pageSetupComponent

        Item {
            property real labelWidth: 60
            property var fieldsModel: app.enumerationModelForType("HeaderFooter", "Field")

            Settings {
                id: pageSetupSettings
                fileName: app.settingsFilePath
                category: "PageSetup"
                property var paperSize: ScreenplayPageLayout.Letter
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

            Column {
                width: parent.width - 60
                spacing: 20
                anchors.centerIn: parent

                Row {
                    spacing: 20
                    width: parent.width/2 - 5

                    Text {
                        id: paperSizeLabel
                        text: "Paper Size"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    ComboBox2 {
                        width: parent.width - parent.spacing - paperSizeLabel.width
                        textRole: "key"
                        currentIndex: pageSetupSettings.paperSize
                        anchors.verticalCenter: parent.verticalCenter
                        onActivated: {
                            pageSetupSettings.paperSize = currentIndex
                            scriteDocument.formatting.pageLayout.paperSize = currentIndex
                            scriteDocument.printFormat.pageLayout.paperSize = currentIndex
                        }
                        model: app.enumerationModelForType("ScreenplayPageLayout", "PaperSize")
                    }
                }

                Row {
                    width: parent.width
                    spacing: 10

                    GroupBox {
                        width: (parent.width-parent.spacing)/2
                        label: Text { text: "Header" }

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

                                    ComboBox2 {
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

                                    ComboBox2 {
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

                                    ComboBox2 {
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
                        width: (parent.width-parent.spacing)/2
                        label: Text { text: "Footer" }

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

                                    ComboBox2 {
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

                                    ComboBox2 {
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

                                    ComboBox2 {
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
                }

                GroupBox {
                    width: parent.width
                    label: Text { text: "Watermark" }

                    Row {
                        spacing: 30
                        anchors.horizontalCenter: parent.horizontalCenter

                        Grid {
                            columns: 2
                            spacing: 10
                            verticalItemAlignment: Grid.AlignVCenter

                            Text {
                                text: "Enable"
                                width: labelWidth
                                horizontalAlignment: Text.AlignRight
                            }

                            CheckBox2 {
                                text: checked ? "ON" : "OFF"
                                checked: pageSetupSettings.watermarkEnabled
                                onToggled: pageSetupSettings.watermarkEnabled = checked
                            }

                            Text {
                                text: "Text"
                                width: labelWidth
                                horizontalAlignment: Text.AlignRight
                            }

                            TextField {
                                width: 300
                                text: pageSetupSettings.watermarkText
                                onTextEdited: pageSetupSettings.watermarkText = text
                                enabled: pageSetupSettings.watermarkEnabled
                            }

                            Text {
                                text: "Color"
                                width: labelWidth
                                horizontalAlignment: Text.AlignRight
                            }

                            Rectangle {
                                border.width: 1
                                border.color: primaryColors.borderColor
                                color: pageSetupSettings.watermarkColor
                                width: 30; height: 30
                                enabled: pageSetupSettings.watermarkEnabled
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: pageSetupSettings.watermarkColor = app.pickColor(pageSetupSettings.watermarkColor)
                                }
                            }
                        }

                        Rectangle {
                            width: 1
                            height: parent.height
                            color: primaryColors.borderColor
                        }

                        Grid {
                            columns: 2
                            spacing: 10
                            verticalItemAlignment: Grid.AlignVCenter

                            Text {
                                text: "Font Family"
                                width: labelWidth
                                horizontalAlignment: Text.AlignRight
                            }

                            ComboBox2 {
                                width: 300
                                model: systemFontInfo.families
                                currentIndex: systemFontInfo.families.indexOf(pageSetupSettings.watermarkFont)
                                onCurrentIndexChanged: pageSetupSettings.watermarkFont = systemFontInfo.families[currentIndex]
                                enabled: pageSetupSettings.watermarkEnabled
                            }

                            Text {
                                text: "Font Size"
                                width: labelWidth
                                horizontalAlignment: Text.AlignRight
                            }

                            SpinBox {
                                width: 300
                                from: 9; to: 200; stepSize: 1
                                editable: true
                                value: pageSetupSettings.watermarkFontSize
                                onValueModified: pageSetupSettings.watermarkFontSize = value
                                enabled: pageSetupSettings.watermarkEnabled
                            }

                            Text {
                                text: "Rotation"
                                width: labelWidth
                                horizontalAlignment: Text.AlignRight
                            }

                            SpinBox {
                                width: 300
                                from: -180; to: 180
                                value: pageSetupSettings.watermarkRotation
                                textFromValue: function(value,locale) { return value + " degrees" }
                                validator: IntValidator { top: 360; bottom: 0 }
                                onValueModified: pageSetupSettings.watermarkRotation = value
                                enabled: pageSetupSettings.watermarkEnabled
                            }
                        }
                    }
                }

                Button2 {
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

    Component {
        id: titlePageSettingsComponent

        Item {
            readonly property real labelWidth: 60

            Column {
                width: parent.width - 80
                anchors.centerIn: parent
                spacing: 20

                // Cover page photo field
                Rectangle {
                    id: coverPageEdit
                    /*
                  At best we can paint a 464x261 point photo on the cover page. Nothing more.
                  So, we need to provide a image preview in this aspect ratio.
                  */
                    width: 400; height: 225
                    border.width: scriteDocument.screenplay.coverPagePhoto === "" ? 1 : 0
                    border.color: "black"
                    anchors.horizontalCenter: parent.horizontalCenter

                    Loader {
                        anchors.fill: parent
                        active: scriteDocument.screenplay.coverPagePhoto !== "" && (coverPagePhoto.paintedWidth < parent.width || coverPagePhoto.paintedHeight < parent.height)
                        opacity: 0.1
                        sourceComponent: Item {
                            Image {
                                id: coverPageImage
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                source: "file://" + scriteDocument.screenplay.coverPagePhoto
                                asynchronous: true
                            }
                        }
                    }

                    Image {
                        id: coverPagePhoto
                        anchors.fill: parent
                        anchors.margins: 1
                        smooth: true; mipmap: true
                        fillMode: Image.PreserveAspectFit
                        source: scriteDocument.screenplay.coverPagePhoto !== "" ? "file:///" + scriteDocument.screenplay.coverPagePhoto : ""
                        opacity: coverPagePhotoMouseArea.containsMouse ? 0.25 : 1

                        BusyIndicator {
                            anchors.centerIn: parent
                            running: parent.status === Image.Loading
                        }
                    }

                    Text {
                        anchors.fill: parent
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        opacity: coverPagePhotoMouseArea.containsMouse ? 1 : (scriteDocument.screenplay.coverPagePhoto === "" ? 0.5 : 0)
                        text: scriteDocument.screenplay.coverPagePhoto === "" ? "Click here to set the cover page photo" : "Click here to change the cover page photo"
                    }

                    MouseArea {
                        id: coverPagePhotoMouseArea
                        anchors.fill: parent
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        hoverEnabled: true
                        enabled: !scriteDocument.readOnly
                        onClicked: fileDialog.open()
                    }

                    Column {
                        spacing: 0
                        anchors.left: parent.right
                        anchors.leftMargin: 20
                        visible: scriteDocument.screenplay.coverPagePhoto !== ""
                        enabled: visible && !scriteDocument.readOnly

                        Text {
                            text: "Cover Photo Size"
                            font.bold: true
                            topPadding: 5
                            bottomPadding: 5
                            color: primaryColors.c300.text
                            opacity: enabled ? 1 : 0.5
                        }

                        RadioButton2 {
                            text: "Small"
                            checked: scriteDocument.screenplay.coverPagePhotoSize === Screenplay.SmallCoverPhoto
                            onToggled: scriteDocument.screenplay.coverPagePhotoSize = Screenplay.SmallCoverPhoto
                        }

                        RadioButton2 {
                            text: "Medium"
                            checked: scriteDocument.screenplay.coverPagePhotoSize === Screenplay.MediumCoverPhoto
                            onToggled: scriteDocument.screenplay.coverPagePhotoSize = Screenplay.MediumCoverPhoto
                        }

                        RadioButton2 {
                            text: "Large"
                            checked: scriteDocument.screenplay.coverPagePhotoSize === Screenplay.LargeCoverPhoto
                            onToggled: scriteDocument.screenplay.coverPagePhotoSize = Screenplay.LargeCoverPhoto
                        }

                        Button2 {
                            text: "Remove"
                            onClicked: scriteDocument.screenplay.clearCoverPagePhoto()
                        }
                    }

                    FileDialog {
                        id: fileDialog
                        nameFilters: ["Photos (*.jpg *.png *.bmp *.jpeg)"]
                        selectFolder: false
                        selectMultiple: false
                        sidebarVisible: true
                        selectExisting: true
                        onAccepted: {
                            if(fileUrl != "")
                                scriteDocument.screenplay.setCoverPagePhoto(app.urlToLocalFile(fileUrl))
                        }
                    }
                }

                Row {
                    id: titlePageFields
                    width: parent.width
                    spacing: 20
                    enabled: !scriteDocument.readOnly

                    Column {
                        width: (parent.width - parent.spacing)/2

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
                                selectByMouse: true
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
                                selectByMouse: true
                                onTextEdited: scriteDocument.screenplay.subtitle = text
                                font.pixelSize: 20
                            }
                        }

                        // Based on field
                        Row {
                            spacing: 10
                            width: parent.width

                            Text {
                                width: labelWidth
                                horizontalAlignment: Text.AlignRight
                                text: "Based on"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            TextField {
                                width: parent.width-parent.spacing-labelWidth
                                text: scriteDocument.screenplay.basedOn
                                selectByMouse: true
                                onTextEdited: scriteDocument.screenplay.basedOn = text
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
                                selectByMouse: true
                                onTextEdited: scriteDocument.screenplay.version = text
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
                                text: "Written By"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            TextField {
                                width: parent.width-parent.spacing-labelWidth
                                text: scriteDocument.screenplay.author
                                selectByMouse: true
                                onTextEdited: scriteDocument.screenplay.author = text
                                font.pixelSize: 20
                            }
                        }
                    }

                    Column {
                        width: (parent.width - parent.spacing)/2

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
                                selectByMouse: true
                                onTextEdited: scriteDocument.screenplay.contact = text
                                font.pixelSize: 20
                                placeholderText: "(Optional) Production company or Studio name"
                            }
                        }

                        // Address field
                        Row {
                            spacing: 10
                            width: parent.width

                            Text {
                                width: labelWidth
                                horizontalAlignment: Text.AlignRight
                                text: "Address"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            TextField {
                                width: parent.width-parent.spacing-labelWidth
                                text: scriteDocument.screenplay.address
                                selectByMouse: true
                                onTextEdited: scriteDocument.screenplay.address = text
                                font.pixelSize: 20
                                placeholderText: "(Optional) Optional"
                            }
                        }

                        // Email field
                        Row {
                            spacing: 10
                            width: parent.width

                            Text {
                                width: labelWidth
                                horizontalAlignment: Text.AlignRight
                                text: "Email"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            TextField {
                                width: parent.width-parent.spacing-labelWidth
                                text: scriteDocument.screenplay.email
                                selectByMouse: true
                                onTextEdited: scriteDocument.screenplay.email = text
                                font.pixelSize: 20
                                placeholderText: "(Optional)"
                            }
                        }

                        // Phone field
                        Row {
                            spacing: 10
                            width: parent.width

                            Text {
                                width: labelWidth
                                horizontalAlignment: Text.AlignRight
                                text: "Phone"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            TextField {
                                width: parent.width-parent.spacing-labelWidth
                                text: scriteDocument.screenplay.phoneNumber
                                selectByMouse: true
                                onTextEdited: scriteDocument.screenplay.phoneNumber = text
                                font.pixelSize: 20
                                placeholderText: "(Optional)"
                            }
                        }

                        // Website field
                        Row {
                            spacing: 10
                            width: parent.width

                            Text {
                                width: labelWidth
                                horizontalAlignment: Text.AlignRight
                                text: "Website"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            TextField {
                                width: parent.width-parent.spacing-labelWidth
                                text: scriteDocument.screenplay.website
                                selectByMouse: true
                                onTextEdited: scriteDocument.screenplay.website = text
                                font.pixelSize: 20
                                placeholderText: "(Optional)"
                            }
                        }
                    }
                }

                CheckBox2 {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Include Title Page In Preview"
                    checked: screenplayEditorSettings.includeTitlePageInPreview
                    onToggled: screenplayEditorSettings.includeTitlePageInPreview = checked
                }
            }
        }
    }

    Component {
        id: formattingRulesSettingsComponent

        Item {
            readonly property var systemFontInfo: app.systemFontInfo()
            readonly property real labelWidth: 125
            property var pageData: pageModel.get(pageList.currentIndex)
            property SceneElementFormat displayElementFormat: scriteDocument.formatting.elementFormat(pageData.elementType)
            property SceneElementFormat printElementFormat: scriteDocument.printFormat.elementFormat(pageData.elementType)

            ListModel {
                id: pageModel

                ListElement { elementName: "Heading"; elementType: SceneElement.Heading }
                ListElement { elementName: "Action"; elementType: SceneElement.Action }
                ListElement { elementName: "Character"; elementType: SceneElement.Character }
                ListElement { elementName: "Dialogue"; elementType: SceneElement.Dialogue }
                ListElement { elementName: "Parenthetical"; elementType: SceneElement.Parenthetical }
                ListElement { elementName: "Shot"; elementType: SceneElement.Shot }
                ListElement { elementName: "Transition"; elementType: SceneElement.Transition }
            }

            Rectangle {
                id: pageList
                width: parent.width * 0.2
                color: primaryColors.c700.background
                height: parent.height
                anchors.left: parent.left
                property int currentIndex: -1

                Column {
                    width: parent.width
                    anchors.top: parent.top
                    anchors.right: parent.right

                    Repeater {
                        model: pageModel

                        Rectangle {
                            width: parent.width
                            height: 60
                            color: pageList.currentIndex === index ? contentPanel.color : primaryColors.c10.background

                            Text {
                                anchors.right: parent.right
                                anchors.rightMargin: 40
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: 18
                                font.bold: pageList.currentIndex === index
                                text: elementName
                                color: pageList.currentIndex === index ? "black" : primaryColors.c700.text
                            }

                            Image {
                                width: 24; height: 24
                                source: "../icons/navigation/arrow_right.png"
                                visible: pageList.currentIndex === index
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: pageList.currentIndex = index
                            }
                        }
                    }
                }

                Button2 {
                    text: "Reset"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    onClicked: {
                        scriteDocument.formatting.resetToDefaults()
                        scriteDocument.printFormat.resetToDefaults()
                    }
                }
            }

            Item {
                anchors.left: pageList.right
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 20
                visible: pageLoaderActive.value

                /**
                  We had an opportunity to discuss (over email, Messenger, Zoom calls etc..) about formatting.
                  The experienced writers suggested to us that we should not allow deviation from the standard
                  screenplay formatting rules.

                  As of 0.3.9, we are NOT providing the following options for element formatting.
                  1. Font Family
                  2. Block Width & Alignment

                  We now ONLY PROVIDE the following options
                  1. Font Point Size & Weight
                  2. Text Alignment
                  3. Foreground and Background Color
                  4. Line Height
                  5. Line Spacing Before

                  Also, since 0.3.9 we compute page numbers and count on the fly. This means that we should keep
                  online and print formats in sync. So, we cannot afford to let users configure both of them
                  separately. Although we need to capture print and display formats as separate ScreenplayFormat
                  instances because the DPI and DPR values for printer and displays may not be the same.
                  */

                ScrollView {
                    id: scrollView
                    ScrollBar.vertical.opacity: ScrollBar.vertical.active ? 1 : 0.2
                    ScrollBar.vertical.policy: scrollViewContent.height > height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    anchors.fill: parent

                    Column {
                        id: scrollViewContent
                        width: scrollView.width - 20
                        spacing: 0
                        enabled: !scriteDocument.readOnly

                        Item { width: parent.width; height: 10 }

                        Item {
                            width: parent.width
                            height: Math.min(340, previewText.contentHeight + previewText.topPadding + previewText.bottomPadding)

                            ScrollView {
                                anchors.fill: parent
                                ScrollBar.vertical.opacity: ScrollBar.vertical.active ? 1 : 0.2
                                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                                Component.onCompleted: ScrollBar.vertical.position = (displayElementFormat.elementType === SceneElement.Shot || displayElementFormat.elementType === SceneElement.Transition) ? 0.2 : 0

                                TextArea {
                                    id: previewText
                                    font: scriteDocument.formatting.defaultFont
                                    readOnly: true
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    background: Rectangle {
                                        color: primaryColors.c10.background
                                    }

                                    SceneDocumentBinder {
                                        screenplayFormat: scriteDocument.formatting
                                        scene: Scene {
                                            elements: [
                                                SceneElement {
                                                    type: SceneElement.Heading
                                                    text: "INT. SOMEPLACE - DAY"
                                                },
                                                SceneElement {
                                                    type: SceneElement.Action
                                                    text: "Dr. Rajkumar enters the club house like a boss. He looks around at everybody in their eyes."
                                                },
                                                SceneElement {
                                                    type: SceneElement.Character
                                                    text: "Dr. Rajkumar"
                                                },
                                                SceneElement {
                                                    type: SceneElement.Parenthetical
                                                    text: "(singing)"
                                                },
                                                SceneElement {
                                                    type: SceneElement.Dialogue
                                                    text: "If you come today, its too early. If you come tomorrow, its too late."
                                                },
                                                SceneElement {
                                                    type: SceneElement.Shot
                                                    text: "EXTREME CLOSEUP on Dr. Rajkumar's smiling face."
                                                },
                                                SceneElement {
                                                    type: SceneElement.Transition
                                                    text: "CUT TO"
                                                }
                                            ]
                                        }
                                        textDocument: previewText.textDocument
                                        cursorPosition: -1
                                        forceSyncDocument: true
                                    }
                                }
                            }
                        }

                        Item { width: parent.width; height: 10 }

                        // Default Language
                        Row {
                            spacing: 10
                            width: parent.width
                            visible: pageData.elementType !== SceneElement.Heading

                            Text {
                                width: labelWidth
                                horizontalAlignment: Text.AlignRight
                                text: "Language"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            ComboBox2 {
                                property var enumModel: app.enumerationModel(displayElementFormat, "DefaultLanguage")
                                model: enumModel
                                width: 300
                                textRole: "key"
                                currentIndex: displayElementFormat.defaultLanguageInt
                                onActivated: {
                                    displayElementFormat.defaultLanguageInt = enumModel[currentIndex].value
                                    switch(displayElementFormat.elementType) {
                                    case SceneElement.Action:
                                        paragraphLanguageSettings.actionLanguage = enumModel[currentIndex].key
                                        break;
                                    case SceneElement.Character:
                                        paragraphLanguageSettings.characterLanguage = enumModel[currentIndex].key
                                        break;
                                    case SceneElement.Parenthetical:
                                        paragraphLanguageSettings.parentheticalLanguage = enumModel[currentIndex].key
                                        break;
                                    case SceneElement.Dialogue:
                                        paragraphLanguageSettings.dialogueLanguage = enumModel[currentIndex].key
                                        break;
                                    case SceneElement.Transition:
                                        paragraphLanguageSettings.transitionLanguage = enumModel[currentIndex].key
                                        break;
                                    case SceneElement.Shot:
                                        paragraphLanguageSettings.shotLanguage = enumModel[currentIndex].key
                                        break;
                                    }
                                }
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
                                width: parent.width-2*parent.spacing-labelWidth-parent.height
                                from: 6
                                to: 62
                                stepSize: 1
                                editable: true
                                value: displayElementFormat.font.pointSize
                                onValueModified: {
                                    displayElementFormat.setFontPointSize(value)
                                    printElementFormat.setFontPointSize(value)
                                }
                            }

                            ToolButton2 {
                                icon.source: "../icons/action/done_all.png"
                                anchors.verticalCenter: parent.verticalCenter
                                ToolTip.text: "Apply this font size to all '" + pageData.elementName + "' paragraphs."
                                ToolTip.delay: 1000
                                onClicked: {
                                    displayElementFormat.applyToAll(SceneElementFormat.FontSize)
                                    printElementFormat.applyToAll(SceneElementFormat.FontSize)
                                }
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
                                width: parent.width-2*parent.spacing-labelWidth-parent.height
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 5

                                CheckBox2 {
                                    text: "Bold"
                                    font.bold: true
                                    checkable: true
                                    checked: displayElementFormat.font.bold
                                    onToggled: {
                                        displayElementFormat.setFontBold(checked)
                                        printElementFormat.setFontBold(checked)
                                    }
                                }

                                CheckBox2 {
                                    text: "Italics"
                                    font.italic: true
                                    checkable: true
                                    checked: displayElementFormat.font.italic
                                    onToggled: {
                                        displayElementFormat.setFontItalics(checked)
                                        printElementFormat.setFontItalics(checked)
                                    }
                                }

                                CheckBox2 {
                                    text: "Underline"
                                    font.underline: true
                                    checkable: true
                                    checked: displayElementFormat.font.underline
                                    onToggled: {
                                        displayElementFormat.setFontUnderline(checked)
                                        printElementFormat.setFontUnderline(checked)
                                    }
                                }
                            }

                            ToolButton2 {
                                icon.source: "../icons/action/done_all.png"
                                anchors.verticalCenter: parent.verticalCenter
                                ToolTip.text: "Apply this font style to all '" + pageData.group + "' paragraphs."
                                ToolTip.delay: 1000
                                onClicked: {
                                    displayElementFormat.applyToAll(SceneElementFormat.FontStyle)
                                    printElementFormat.applyToAll(SceneElementFormat.FontStyle)
                                }
                            }
                        }

                        // Line Height
                        Row {
                            spacing: 10
                            width: parent.width

                            Text {
                                width: labelWidth
                                horizontalAlignment: Text.AlignRight
                                text: "Line Height"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            SpinBox {
                                width: parent.width-2*parent.spacing-labelWidth-parent.height
                                from: 25
                                to: 300
                                stepSize: 5
                                value: displayElementFormat.lineHeight * 100
                                onValueModified: {
                                    displayElementFormat.lineHeight = value/100
                                    printElementFormat.lineHeight = value/100
                                }
                                textFromValue: function(value,locale) {
                                    return value + "%"
                                }
                            }

                            ToolButton2 {
                                icon.source: "../icons/action/done_all.png"
                                anchors.verticalCenter: parent.verticalCenter
                                ToolTip.text: "Apply this line height to all '" + pageData.group + "' paragraphs."
                                ToolTip.delay: 1000
                                onClicked: {
                                    displayElementFormat.applyToAll(SceneElementFormat.LineHeight)
                                    printElementFormat.applyToAll(SceneElementFormat.LineHeight)
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

                            Row {
                                spacing: parent.spacing
                                width: parent.width - 2*parent.spacing - labelWidth - parent.height
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    border.width: 1
                                    border.color: primaryColors.borderColor
                                    color: displayElementFormat.textColor
                                    width: 30; height: 30
                                    anchors.verticalCenter: parent.verticalCenter
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            displayElementFormat.textColor = app.pickColor(displayElementFormat.textColor)
                                            printElementFormat.textColor = displayElementFormat.textColor
                                        }
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
                                    border.color: primaryColors.borderColor
                                    color: displayElementFormat.backgroundColor
                                    width: 30; height: 30
                                    anchors.verticalCenter: parent.verticalCenter
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            displayElementFormat.backgroundColor = app.pickColor(displayElementFormat.backgroundColor)
                                            printElementFormat.backgroundColor = displayElementFormat.backgroundColor
                                        }
                                    }
                                }
                            }

                            ToolButton2 {
                                icon.source: "../icons/action/done_all.png"
                                anchors.verticalCenter: parent.verticalCenter
                                ToolTip.text: "Apply these colors to all '" + pageData.group + "' paragraphs."
                                ToolTip.delay: 1000
                                onClicked: {
                                    displayElementFormat.applyToAll(SceneElementFormat.TextAndBackgroundColors)
                                    printElementFormat.applyToAll(SceneElementFormat.TextAndBackgroundColors)
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
                                width: parent.width - 2*parent.spacing - labelWidth - parent.height
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 5

                                RadioButton2 {
                                    text: "Left"
                                    checkable: true
                                    checked: displayElementFormat.textAlignment === Qt.AlignLeft
                                    onCheckedChanged: {
                                        if(checked) {
                                            displayElementFormat.textAlignment = Qt.AlignLeft
                                            printElementFormat.textAlignment = Qt.AlignLeft
                                        }
                                    }
                                }

                                RadioButton2 {
                                    text: "Center"
                                    checkable: true
                                    checked: displayElementFormat.textAlignment === Qt.AlignHCenter
                                    onCheckedChanged: {
                                        if(checked) {
                                            displayElementFormat.textAlignment = Qt.AlignHCenter
                                            printElementFormat.textAlignment = Qt.AlignHCenter
                                        }
                                    }
                                }

                                RadioButton2 {
                                    text: "Right"
                                    checkable: true
                                    checked: displayElementFormat.textAlignment === Qt.AlignRight
                                    onCheckedChanged: {
                                        if(checked) {
                                            displayElementFormat.textAlignment = Qt.AlignRight
                                            printElementFormat.textAlignment = Qt.AlignRight
                                        }
                                    }
                                }

                                RadioButton2 {
                                    text: "Justify"
                                    checkable: true
                                    checked: displayElementFormat.textAlignment === Qt.AlignJustify
                                    onCheckedChanged: {
                                        if(checked) {
                                            displayElementFormat.textAlignment = Qt.AlignJustify
                                            printElementFormat.textAlignment = Qt.AlignJustify
                                        }
                                    }
                                }
                            }

                            ToolButton2 {
                                icon.source: "../icons/action/done_all.png"
                                anchors.verticalCenter: parent.verticalCenter
                                ToolTip.text: "Apply this alignment to all '" + pageData.group + "' paragraphs."
                                ToolTip.delay: 1000
                                onClicked: {
                                    displayElementFormat.applyToAll(SceneElementFormat.TextAlignment)
                                    printElementFormat.applyToAll(SceneElementFormat.TextAlignment)
                                }
                            }
                        }
                    }
                }
            }

            ResetOnChange {
                id: pageLoaderActive
                trackChangesOn: pageList.currentIndex
                from: false
                to: pageList.currentIndex >= 0 ? true : false
                delay: 100
            }

            Component.onCompleted: pageList.currentIndex = 0
        }
    }

    Component {
        id: unknownSettingsComponent

        Item {
            Text {
                anchors.centerIn: parent
                text: "This is embarrassing. We honestly dont know what to show here!"
            }
        }
    }
}
