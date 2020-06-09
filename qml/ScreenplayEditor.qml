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

import Scrite 1.0
import QtQuick 2.13
import QtQuick.Window 2.13
import Qt.labs.settings 1.0
import QtQuick.Controls 2.13

Rectangle {
    // This editor has to specialize in rendering scenes within a ScreenplayAdapter
    // The adapter may contain a single scene or an entire screenplay, that doesnt matter.
    // This way we can avoid having a SceneEditor and ScreenplayEditor as two distinct
    // QML components.

    id: screenplayEditor
    property ScreenplayFormat screenplayFormat: scriteDocument.displayFormat
    property ScreenplayPageLayout pageLayout: screenplayFormat.pageLayout
    property alias source: screenplayAdapter.source

    property alias zoomLevel: zoomSlider.zoomLevel
    property int zoomLevelModifier: 0
    color: primaryColors.windowColor
    border.width: 1
    border.color: primaryColors.borderColor
    clip: true

    ScreenplayAdapter {
        id: screenplayAdapter
        source: scriteDocument.screenplay
        onCurrentIndexChanged: {
            if(mainUndoStack.screenplayEditorActive)
                app.execLater(contentView, 100, function() {
                    contentView.scrollIntoView(currentIndex)
                })
            else
                contentView.positionViewAtIndex(currentIndex, ListView.Beginning)
        }
    }

    ScreenplayTextDocument {
        id: screenplayTextDocument
        screenplay: screenplayAdapter.screenplay
        formatting: scriteDocument.printFormat
        syncEnabled: true
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: sceneListPanelLoader.active ? sceneListPanelLoader.width : 0
        anchors.bottomMargin: statusBar.height

        Item {
            id: pageRulerArea
            width: pageLayout.paperWidth * screenplayEditor.zoomLevel * Screen.devicePixelRatio
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter

            RulerItem {
                id: ruler
                width: parent.width
                height: 20
                font.pixelSize: 10
                leftMargin: pageLayout.leftMargin * Screen.devicePixelRatio
                rightMargin: pageLayout.rightMargin * Screen.devicePixelRatio
                zoomLevel: screenplayEditor.zoomLevel

                property real leftMarginPx: leftMargin * zoomLevel
                property real rightMarginPx: rightMargin * zoomLevel
                property real topMarginPx: pageLayout.topMargin * Screen.devicePixelRatio * zoomLevel
                property real bottomMarginPx: pageLayout.bottomMargin * Screen.devicePixelRatio * zoomLevel
            }

            Rectangle {
                id: contentArea
                anchors.top: ruler.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: 5
                clip: true
                color: screenplayAdapter.elementCount > 0 ? "white" : Qt.rgba(0,0,0,0)

                ListView {
                    id: contentView
                    anchors.fill: parent
                    model: screenplayAdapter
                    delegate: Loader {
                        width: contentView.width
                        property var componentData: modelData
                        sourceComponent: modelData.scene ? contentComponent : breakComponent
                    }
                    snapMode: ListView.NoSnap
                    boundsBehavior: Flickable.StopAtBounds
                    boundsMovement: Flickable.StopAtBounds
                    cacheBuffer: 10
                    ScrollBar.vertical: verticalScrollBar
                    header: Item {
                        width: contentView.width
                        height: screenplayAdapter.isSourceScreenplay ? ruler.topMarginPx : 0
                    }
                    footer: Item {
                        width: contentView.width
                        height: ruler.bottomMarginPx
                    }

                    Component.onCompleted: positionViewAtIndex(screenplayAdapter.currentIndex, ListView.Beginning)

                    property int firstItemIndex: screenplayAdapter.elementCount > 0 ? Math.max(indexAt(width/2, contentY+1), 0) : 0
                    property int lastItemIndex: screenplayAdapter.elementCount > 0 ? Math.min(indexAt(width/2, contentView.contentY+height-2), screenplayAdapter.elementCount-1) : 0

                    function isVisible(index) {
                        return index >= firstItemIndex && index <= lastItemIndex
                    }

                    function scrollIntoView(index) {
                        if(moving || flicking)
                            return

                        var topIndex = firstItemIndex
                        var bottomIndex = lastItemIndex

                        if(index >= topIndex && index <= bottomIndex)
                            return // item is already visible

                        if(index < topIndex && topIndex-index <= 2) {
                            contentView.contentY -= height*0.2
                        } else if(index > bottomIndex && index-bottomIndex <= 2) {
                            contentView.contentY += height*0.2
                        } else {
                            positionViewAtIndex(index, ListView.Beginning)
                        }
                    }

                    function ensureVisible(item, rect) {
                        if(item === null)
                            return

                        var pt = item.mapToItem(contentView.contentItem, rect.x, rect.y)
                        var startY = contentView.contentY
                        var endY = contentView.contentY + contentView.height - rect.height
                        if( startY < pt.y && pt.y < endY )
                            return

                        var newContentY = 0
                        if( pt.y < startY )
                            contentView.contentY = pt.y
                        else if( pt.y > endY )
                            contentView.contentY = (pt.y + 2*rect.height) - contentView.height
                    }
                }
            }
        }
    }

    ScrollBar {
        id: verticalScrollBar
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: statusBar.top
        orientation: Qt.Vertical
        minimumSize: 0.1
        policy: screenplayAdapter.elementCount > 0 ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    }

    Rectangle {
        id: statusBar
        height: 30
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: primaryColors.windowColor
        border.width: 1
        border.color: primaryColors.borderColor
        clip: true

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 20
            text: screenplayTextDocument.currentPage + " of " + screenplayTextDocument.pageCount
        }

        Item {
            width: pageRulerArea.width
            height: parent.height
            anchors.centerIn: parent

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: ruler.leftMarginPx
                anchors.rightMargin: ruler.rightMarginPx
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: height*0.1
                font.family: headingFontMetrics.font.family
                font.pixelSize: parent.height * 0.6
                elide: Text.ElideRight
                text: {
                    var scene = null
                    var element = null
                    if(contentView.isVisible(screenplayAdapter.currentIndex)) {
                        scene = screenplayAdapter.currentScene
                        element = screenplayAdapter.currentElement
                    } else {
                        var data = screenplayAdapter.at(contentView.firstItemIndex)
                        scene = data ? data.scene : null
                        element = data ? data.screenplayElement : null
                    }
                    return scene && scene.heading.enabled ? "[" + element.sceneNumber + "] " + scene.heading.text : ''
                }
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Slider {
                id: zoomSlider
                property var zoomLevels: screenplayFormat.fontZoomLevels
                property real zoomLevel: zoomLevels[value]
                property bool initialized: false
                anchors.verticalCenter: parent.verticalCenter
                from: 0; to: zoomLevels.length-1
                stepSize: 1
                onZoomLevelChanged: {
                    if(initialized)
                        screenplayFormat.devicePixelRatio = Screen.devicePixelRatio * zoomLevel
                }
                Component.onCompleted: {
                    var list = zoomLevels
                    var zoomOneIndex = -1
                    for(var i=0; i<list.length; i++) {
                        zoomOneIndex = (list[i] === 1.0) ? i : -1
                        if(zoomOneIndex >= 0)
                            break
                    }
                    zoomOneIndex = Math.min(Math.max(zoomOneIndex+zoomLevelModifier, from), to)
                    value = zoomOneIndex
                    screenplayFormat.devicePixelRatio = Screen.devicePixelRatio * zoomLevel
                    initialized = true
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(zoomSlider.zoomLevel * 100) + "%"
            }
        }
    }

    Component {
        id: breakComponent

        Item {
            property int theIndex: componentData.rowNumber
            property Scene theScene: componentData.scene
            property ScreenplayElement theElement: componentData.screenplayElement
            height: breakText.contentHeight+16

            Rectangle {
                anchors.fill: breakText
                anchors.margins: -4
                color: primaryColors.windowColor
                border.width: 1
                border.color: primaryColors.borderColor
            }

            Text {
                id: breakText
                anchors.centerIn: parent
                width: parent.width-16
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 30
                font.bold: true
                text: parent.theElement.sceneID
            }
        }
    }

    Component {
        id: contentComponent

        Rectangle {
            id: contentItem
            property int theIndex: componentData.rowNumber
            property Scene theScene: componentData.scene
            property ScreenplayElement theElement: componentData.screenplayElement

            width: contentArea.width
            height: contentItemLayout.height
            color: "white"
            readonly property var binder: sceneDocumentBinder
            readonly property var editor: sceneTextEditor

            SceneDocumentBinder {
                id: sceneDocumentBinder
                scene: contentItem.theScene
                textDocument: sceneTextEditor.textDocument
                cursorPosition: sceneTextEditor.cursorPosition
                characterNames: scriteDocument.structure.characterNames
                screenplayFormat: screenplayEditor.screenplayFormat
                forceSyncDocument: !sceneTextEditor.activeFocus
                onDocumentInitialized: sceneTextEditor.cursorPosition = 0
                onRequestCursorPosition: app.execLater(contentItem, 100, function() { contentItem.assumeFocusAt(position) })
                property var currentParagraphType: currentElement ? currentElement.type : SceneHeading.Action
                onCurrentParagraphTypeChanged: {
                    if(currentParagraphType === SceneElement.Action) {
                        ruler.paragraphLeftMargin = 0
                        ruler.paragraphRightMargin = 0
                    } else {
                        var elementFormat = screenplayEditor.screenplayFormat.elementFormat(currentParagraphType)
                        ruler.paragraphLeftMargin = ruler.leftMargin + pageLayout.contentWidth * elementFormat.leftMargin * Screen.devicePixelRatio
                        ruler.paragraphRightMargin = ruler.rightMargin + pageLayout.contentWidth * elementFormat.rightMargin * Screen.devicePixelRatio
                    }
                }
            }

            Column {
                id: contentItemLayout
                width: parent.width

                Loader {
                    id: sceneHeadingAreaLoader
                    width: parent.width
                    active: contentItem.theScene !== null
                    sourceComponent: sceneHeadingArea
                    onItemChanged: {
                        if(item) {
                            item.theScene = contentItem.theScene
                            item.theElement = contentItem.theElement
                        }
                    }
                }

                TextArea {
                    // Basic editing functionality
                    id: sceneTextEditor
                    width: parent.width
                    height: Math.ceil(contentHeight + topPadding + bottomPadding)
                    topPadding: sceneEditorFontMetrics.lineSpacing
                    bottomPadding: sceneEditorFontMetrics.lineSpacing
                    leftPadding: ruler.leftMarginPx
                    rightPadding: ruler.rightMarginPx
                    palette: app.palette
                    selectByMouse: true
                    selectByKeyboard: true
                    background: Item {
                        id: sceneTextEditorBackground

                        ResetOnChange {
                            id: document
                            trackChangesOn: sceneDocumentBinder.documentLoadCount + zoomSlider.value
                            from: null
                            to: screenplayTextDocument
                            delay: 100
                        }

                        ScreenplayElementPageBreaks {
                            id: pageBreaksEvaluator
                            screenplayElement: contentItem.theElement
                            screenplayDocument: document.value
                        }

                        Repeater {
                            model: pageBreaksEvaluator.pageBreaks

                            PainterPathItem {
                                id: pageBreakLine
                                property rect cursorRect: modelData.position >= 0 ? sceneTextEditor.positionToRectangle(modelData.position) : Qt.rect(0,0,0,0)
                                x: 0
                                y: (modelData.position >= 0 ? cursorRect.y : -sceneHeadingAreaLoader.height) - height/2
                                width: sceneTextEditorBackground.width
                                height: 3
                                renderingMechanism: PainterPathItem.UseQPainter
                                renderType: PainterPathItem.OutlineOnly
                                outlineColor: primaryColors.a700.background
                                outlineStyle: PainterPathItem.DashDotLine
                                outlineWidth: 1

                                painterPath: PainterPath {
                                    MoveTo { x: 0; y: 1 }
                                    LineTo { x: pageBreakLine.width; y: 1 }
                                }

                                Text {
                                    font: defaultFontMetrics.font
                                    text: "Pg " + modelData.pageNumber + ". "
                                    anchors.left: parent.left
                                    anchors.top: parent.bottom
                                    anchors.margins: 5
                                    color: pageBreakLine.outlineColor
                                }
                            }
                        }
                    }
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font: screenplayFormat.defaultFont2
                    placeholderText: activeFocus ? "" : "Click here to type your scene content..."
                    onActiveFocusChanged: {
                        if(activeFocus) {
                            contentView.ensureVisible(sceneTextEditor, cursorRectangle, contentItem.theIndex)
                            screenplayAdapter.currentIndex = contentItem.theIndex
                            globalSceneEditorToolbar.sceneEditor = contentItem
                        } else if(globalSceneEditorToolbar.sceneEditor === contentItem)
                            globalSceneEditorToolbar.sceneEditor = null
                        sceneHeadingAreaLoader.item.sceneHasFocus = activeFocus
                        contentItem.theScene.undoRedoEnabled = activeFocus
                    }

                    FocusTracker.window: qmlWindow
                    FocusTracker.indicator.target: mainUndoStack
                    FocusTracker.indicator.property: "screenplayEditorActive"

                    onCursorRectangleChanged: {
                        if(activeFocus && contentView.isVisible(contentItem.theIndex))
                            contentView.ensureVisible(sceneTextEditor, cursorRectangle, contentItem.theIndex)
                    }

                    // Support for transliteration.
                    property bool userIsTyping: false
                    EventFilter.events: [51,6] // Wheel, ShortcutOverride
                    EventFilter.onFilter: {
                        if(event.type === 51) {
                            // We want to avoid TextArea from processing Ctrl+Z
                            // and other such shortcuts.
                            result.acceptEvent = false
                            result.filter = true
                        } else if(event.type === 6) {
                            // Enter, Tab and other keys must not trigger
                            // Transliteration. Only space should.
                            sceneTextEditor.userIsTyping = event.hasText
                        }
                    }
                    Transliterator.enabled: contentItem.theScene && !contentItem.theScene.isBeingReset && userIsTyping
                    Transliterator.textDocument: textDocument
                    Transliterator.cursorPosition: cursorPosition
                    Transliterator.hasActiveFocus: activeFocus
                    Transliterator.onAboutToTransliterate: {
                        contentItem.theScene.beginUndoCapture(false)
                        contentItem.theScene.undoRedoEnabled = false
                    }
                    Transliterator.onFinishedTransliterating: {
                        app.execLater(Transliterator, 0, function() {
                            contentItem.theScene.endUndoCapture()
                            contentItem.theScene.undoRedoEnabled = true
                        })
                    }

                    // Support for auto completion
                    Item {
                        id: cursorOverlay
                        x: parent.cursorRectangle.x
                        y: parent.cursorRectangle.y
                        width: parent.cursorRectangle.width
                        height: parent.cursorRectangle.height
                        visible: parent.cursorVisible
                        ToolTip.text: '<font name="' + sceneDocumentBinder.currentFont.family + '"><font color="lightgray">' + sceneDocumentBinder.completionPrefix.toUpperCase() + '</font>' + completer.suggestion.toUpperCase() + '</font>';
                        ToolTip.visible: completer.hasSuggestion

                        Completer {
                            id: completer
                            strings: sceneDocumentBinder.autoCompleteHints
                            completionPrefix: sceneDocumentBinder.completionPrefix
                        }

                        // Context menus must ideally show up directly below the cursor
                        // So, we keep the menu loaders inside the cursorOverlay
                        MenuLoader {
                            id: editorContextMenu
                            anchors.bottom: parent.bottom
                            menu: Menu2 {
                                onAboutToShow: sceneTextEditor.persistentSelection = true
                                onAboutToHide: sceneTextEditor.persistentSelection = false

                                MenuItem2 {
                                    focusPolicy: Qt.NoFocus
                                    text: "Cut\t" + app.polishShortcutTextForDisplay("Ctrl+X")
                                    enabled: sceneTextEditor.selectionEnd > sceneTextEditor.selectionStart
                                    onClicked: { sceneTextEditor.cut(); editorContextMenu.close() }
                                }

                                MenuItem2 {
                                    focusPolicy: Qt.NoFocus
                                    text: "Copy\t" + app.polishShortcutTextForDisplay("Ctrl+C")
                                    enabled: sceneTextEditor.selectionEnd > sceneTextEditor.selectionStart
                                    onClicked: { sceneTextEditor.copy(); editorContextMenu.close() }
                                }

                                MenuItem2 {
                                    focusPolicy: Qt.NoFocus
                                    text: "Paste\t" + app.polishShortcutTextForDisplay("Ctrl+V")
                                    enabled: sceneTextEditor.canPaste
                                    onClicked: { sceneTextEditor.paste(); editorContextMenu.close() }
                                }

                                MenuSeparator {  }

                                MenuItem2 {
                                    focusPolicy: Qt.NoFocus
                                    text: "Split Scene"
                                    enabled: sceneDocumentBinder && sceneDocumentBinder.currentElement && sceneDocumentBinder.currentElementCursorPosition >= 0 && screenplayAdapter.isSourceScreenplay
                                    onClicked: {
                                        screenplayAdapter.splitElement(screenplayAdapter.theElement, sceneDocumentBinder.currentElement, sceneDocumentBinder.currentElementCursorPosition)
                                        editorContextMenu.close()
                                    }
                                }

                                MenuSeparator {  }

                                Menu2 {
                                    title: "Format"
                                    width: 250

                                    Repeater {
                                        model: [
                                            { "value": SceneElement.Action, "display": "Action" },
                                            { "value": SceneElement.Character, "display": "Character" },
                                            { "value": SceneElement.Dialogue, "display": "Dialogue" },
                                            { "value": SceneElement.Parenthetical, "display": "Parenthetical" },
                                            { "value": SceneElement.Shot, "display": "Shot" },
                                            { "value": SceneElement.Transition, "display": "Transition" }
                                        ]

                                        MenuItem2 {
                                            focusPolicy: Qt.NoFocus
                                            text: modelData.display + "\t" + app.polishShortcutTextForDisplay("Ctrl+" + (index+1))
                                            enabled: sceneDocumentBinder.currentElement !== null
                                            onClicked: {
                                                sceneDocumentBinder.currentElement.type = modelData.value
                                                editorContextMenu.close()
                                            }
                                        }
                                    }
                                }

                                Menu2 {
                                    title: "Translate"
                                    enabled: sceneTextEditor.selectionEnd > sceneTextEditor.selectionStart

                                    Repeater {
                                        model: app.enumerationModel(app.transliterationEngine, "Language")

                                        MenuItem2 {
                                            focusPolicy: Qt.NoFocus
                                            visible: index > 0
                                            text: modelData.key
                                            onClicked: {
                                                sceneTextEditor.Transliterator.transliterateToLanguage(sceneTextEditor.selectionStart, sceneTextEditor.selectionEnd, modelData.value)
                                                editorContextMenu.close()
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        MenuLoader {
                            id: doubleEnterMenu
                            anchors.bottom: parent.bottom
                            menu: Menu2 {
                                width: 200
                                onAboutToShow: sceneTextEditor.persistentSelection = true
                                onAboutToHide: sceneTextEditor.persistentSelection = false
                                EventFilter.target: app
                                EventFilter.events: [6]
                                EventFilter.onFilter: {
                                    result.filter = true
                                    result.acceptEvent = true

                                    if(screenplayAdapter.isSourceScreenplay && event.key === Qt.Key_N) {
                                        newSceneMenuItem.handle()
                                        return
                                    }

                                    if(event.key === Qt.Key_H) {
                                        editHeadingMenuItem.handle()
                                        return
                                    }

                                    if(sceneDocumentBinder.currentElement === null) {
                                        result.filter = false
                                        result.acceptEvent = false
                                        sceneTextEditor.forceActiveFocus()
                                        doubleEnterMenu.close()
                                        return
                                    }

                                    switch(event.key) {
                                    case Qt.Key_A:
                                        sceneDocumentBinder.currentElement.type = SceneElement.Action
                                        break;
                                    case Qt.Key_C:
                                        sceneDocumentBinder.currentElement.type = SceneElement.Character
                                        break;
                                    case Qt.Key_D:
                                        sceneDocumentBinder.currentElement.type = SceneElement.Dialogue
                                        break;
                                    case Qt.Key_P:
                                        sceneDocumentBinder.currentElement.type = SceneElement.Parenthetical
                                        break;
                                    case Qt.Key_S:
                                        sceneDocumentBinder.currentElement.type = SceneElement.Shot
                                        break;
                                    case Qt.Key_T:
                                        sceneDocumentBinder.currentElement.type = SceneElement.Transition
                                        break;
                                    default:
                                        result.filter = false
                                        result.acceptEvent = false
                                    }

                                    sceneTextEditor.forceActiveFocus()
                                    doubleEnterMenu.close()
                                }

                                MenuItem2 {
                                    id: editHeadingMenuItem
                                    text: "&Heading (H)"
                                    onClicked: handle()

                                    function handle() {
                                        if(contentItem.theScene.headingenabled === false)
                                            contentItem.theScene.headingenabled = true
                                        sceneHeadingLoader.viewOnly = false
                                        doubleEnterMenu.close()
                                    }
                                }

                                Repeater {
                                    model: [
                                        { "value": SceneElement.Action, "display": "Action" },
                                        { "value": SceneElement.Character, "display": "Character" },
                                        { "value": SceneElement.Dialogue, "display": "Dialogue" },
                                        { "value": SceneElement.Parenthetical, "display": "Parenthetical" },
                                        { "value": SceneElement.Shot, "display": "Shot" },
                                        { "value": SceneElement.Transition, "display": "Transition" }
                                    ]

                                    MenuItem2 {
                                        text: modelData.display + " (" + modelData.display[0] + ")"
                                        onClicked: {
                                            if(sceneDocumentBinder.currentElement)
                                                sceneDocumentBinder.currentElement.type = modelData.value
                                            sceneTextEditor.forceActiveFocus()
                                            doubleEnterMenu.close()
                                        }
                                    }
                                }

                                MenuSeparator { }

                                MenuItem2 {
                                    id: newSceneMenuItem
                                    text: "&New Scene (N)"
                                    onClicked: handle()
                                    enabled: allowSplitSceneRequest

                                    function handle() {
                                        contentItem.theScene.removeLastElementIfEmpty()
                                        scriteDocument.createNewScene()
                                        doubleEnterMenu.close()
                                    }
                                }
                            }
                        }
                    }
                    Keys.onTabPressed: {
                        if(completer.suggestion !== "") {
                            userIsTyping = false
                            insert(cursorPosition, completer.suggestion)
                            userIsTyping = true
                            Transliterator.enableFromNextWord()
                            event.accepted = true
                        } else
                            sceneDocumentBinder.tab()
                    }
                    Keys.onBacktabPressed: sceneDocumentBinder.backtab()

                    // Double enter menu and split-scene handling.
                    Keys.onReturnPressed: {
                        if(event.modifiers & Qt.ControlModifier) {
                            screenplayAdapter.splitElement(screenplayAdapter.theElement, sceneDocumentBinder.currentElement, sceneDocumentBinder.currentElementCursorPosition)
                            event.accepted = true
                            return
                        }

                        if(binder.currentElement === null || binder.currentElement.text === "") {
                            doubleEnterMenu.show()
                            event.accepted = true
                        } else
                            event.accepted = false
                    }

                    // Context menu
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        enabled: !editorContextMenu.active && sceneTextEditor.activeFocus
                        cursorShape: Qt.IBeamCursor
                        onClicked: {
                            sceneTextEditor.persistentSelection = true
                            editorContextMenu.popup()
                            mouse.accept = true
                        }
                    }

                    // Scrolling up and down
                    Keys.onUpPressed: {
                        if(sceneDocumentBinder.canGoUp())
                            event.accepted = false
                        else {
                            event.accepted = true
                            contentItem.scrollToPreviousScene()
                        }
                    }
                    Keys.onDownPressed: {
                        if(sceneDocumentBinder.canGoDown())
                            event.accepted = false
                        else {
                            event.accepted = true
                            contentItem.scrollToNextScene()
                        }
                    }
                    Keys.onPressed: {
                        if(event.key === Qt.Key_PageUp) {
                            event.accepted = true
                            contentItem.scrollToPreviousScene()
                        } else if(event.key === Qt.Key_PageDown) {
                            event.accepted = true
                            contentItem.scrollToNextScene()
                        } else
                            event.accepted = false
                    }
                }
            }

            function assumeFocus() {
                if(!sceneTextEditor.activeFocus)
                    sceneTextEditor.forceActiveFocus()
            }

            function assumeFocusAt(pos) {
                if(!sceneTextEditor.activeFocus)
                    sceneTextEditor.forceActiveFocus()
                if(pos < 0)
                    sceneTextEditor.cursorPosition = sceneDocumentBinder.lastCursorPosition()
                else
                    sceneTextEditor.cursorPosition = pos
            }

            function scrollToPreviousScene() {
                var idx = screenplayAdapter.previousSceneElementIndex()
                if(idx === 0 && idx === theIndex) {
                    contentView.positionViewAtBeginning()
                    assumeFocusAt(0)
                    return
                }

                contentView.scrollIntoView(idx)
                var item = contentView.itemAtIndex(idx).item
                item.assumeFocusAt(-1)
            }

            function scrollToNextScene() {
                var idx = screenplayAdapter.nextSceneElementIndex()
                if(idx === screenplayAdapter.elementCount-1 && idx === theIndex) {
                    contentView.positionViewAtEnd()
                    assumeFocusAt(-1)
                    return
                }

                contentView.scrollIntoView(idx)
                var item = contentView.itemAtIndex(idx).item
                item.assumeFocusAt(0)
            }
        }
    }

    Component {
        id: sceneHeadingArea

        Rectangle {
            id: headingItem
            property Scene theScene
            property bool sceneHasFocus: false
            property ScreenplayElement theElement

            height: sceneHeadingLayout.height + 16
            color: Qt.tint(theScene.color, "#E7FFFFFF")

            Item {
                width: ruler.leftMarginPx
                height: sceneHeadingLoader.height + 16

                Text {
                    font: headingFontMetrics.font
                    text: "[" + theElement.sceneNumber + "]"
                    height: sceneHeadingLoader.height
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: parent.width * 0.075
                }
            }

            Column {
                id: sceneHeadingLayout
                spacing: 5
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: ruler.leftMarginPx
                anchors.rightMargin: ruler.rightMarginPx
                anchors.verticalCenter: parent.verticalCenter

                Loader {
                    id: sceneHeadingLoader
                    width: parent.width
                    height: item ? item.contentHeight : headingFontMetrics.lineSpacing
                    property bool viewOnly: true
                    property SceneHeading sceneHeading: headingItem.theScene.heading
                    sourceComponent: {
                        if(sceneHeading.enabled)
                            return viewOnly ? sceneHeadingViewer : sceneHeadingEditor
                        return sceneHeadingDisabled
                    }

                    Connections {
                        target: sceneHeadingLoader.item
                        ignoreUnknownSignals: true
                        onEditRequest: sceneHeadingLoader.viewOnly = false
                        onEditingFinished: sceneHeadingLoader.viewOnly = true
                    }
                }

                Loader {
                    id: sceneCharactersListLoader
                    width: parent.width
                    readonly property bool editorHasActiveFocus: headingItem.sceneHasFocus
                    property Scene scene: headingItem.theScene
                    sourceComponent: sceneCharactersList
                }
            }
        }
    }

    FontMetrics {
        id: defaultFontMetrics
        readonly property SceneElementFormat format: scriteDocument.formatting.elementFormat(SceneElement.Action)
        font: format ? format.font2 : scriteDocument.formatting.defaultFont2
    }

    FontMetrics {
        id: headingFontMetrics
        readonly property SceneElementFormat format: scriteDocument.formatting.elementFormat(SceneElement.Heading)
        font: format.font2
    }

    Component {
        id: sceneHeadingDisabled

        Item {
            property real contentHeight: headingFontMetrics.lineSpacing

            Text {
                text: "no scene heading"
                anchors.verticalCenter: parent.verticalCenter
                color: primaryColors.c10.text
                font: headingFontMetrics.font
                opacity: 0.25
            }
        }
    }

    Component {
        id: sceneHeadingEditor

        Item {
            property real contentHeight: height
            height: layout.height + 4
            Component.onCompleted: {
                locTypeEdit.forceActiveFocus()
            }

            signal editingFinished()

            FocusTracker.window: qmlWindow
            FocusTracker.onHasFocusChanged: {
                if(!FocusTracker.hasFocus)
                    editingFinished()
            }

            Row {
                id: layout
                anchors.left: parent.left
                anchors.right: parent.right

                TextField2 {
                    id: locTypeEdit
                    font: headingFontMetrics.font
                    width: Math.max(contentWidth, 80)
                    anchors.verticalCenter: parent.verticalCenter
                    text: sceneHeading.locationType
                    completionStrings: scriteDocument.structure.standardLocationTypes()
                    onEditingComplete: sceneHeading.locationType = text
                    tabItem: locEdit
                }

                Text {
                    id: sep1Text
                    font: headingFontMetrics.font
                    text: ". "
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextField2 {
                    id: locEdit
                    font: headingFontMetrics.font
                    width: parent.width - locTypeEdit.width - sep1Text.width - momentEdit.width - sep2Text.width
                    anchors.verticalCenter: parent.verticalCenter
                    text: sceneHeading.location
                    enableTransliteration: true
                    completionStrings: scriteDocument.structure.allLocations()
                    onEditingComplete: sceneHeading.location = text
                    tabItem: momentEdit
                }

                Text {
                    id: sep2Text
                    font: headingFontMetrics.font
                    text: "- "
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextField2 {
                    id: momentEdit
                    font: headingFontMetrics.font
                    width: Math.max(contentWidth, 150);
                    anchors.verticalCenter: parent.verticalCenter
                    text: sceneHeading.moment
                    completionStrings: scriteDocument.structure.standardMoments()
                    onEditingComplete: sceneHeading.moment = text
                    tabItem: sceneContentEditor
                }
            }
        }
    }

    Component {
        id: sceneHeadingViewer

        Item {
            property real contentHeight: sceneHeadingText.contentHeight
            signal editRequest()

            Text {
                id: sceneHeadingText
                width: parent.width
                font: headingFontMetrics.font
                text: sceneHeading.text
                anchors.verticalCenter: parent.verticalCenter
                wrapMode: Text.WordWrap
                color: headingFontMetrics.format.textColor
            }

            MouseArea {
                anchors.fill: parent
                onClicked: parent.editRequest()
            }
        }
    }

    Component {
        id: sceneCharactersList

        Flow {
            spacing: 5
            flow: Flow.LeftToRight

            Text {
                id: sceneCharactersListHeading
                text: "Characters: "
                font.bold: true
                topPadding: 5
                bottomPadding: 5
                font.pointSize: 12
            }

            Repeater {
                model: scene ? scene.characterNames : 0

                TagText {
                    id: characterNameLabel
                    property var colors: {
                        if(containsMouse)
                            return accentColors.c900
                        return editorHasActiveFocus ? accentColors.c600 : accentColors.c10
                    }
                    border.width: editorHasActiveFocus ? 0 : 1
                    border.color: colors.text
                    color: colors.background
                    textColor: colors.text
                    text: modelData
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 2
                    bottomPadding: 2
                    font.pointSize: 12
                    closable: scene.isCharacterMute(modelData)
                    onClicked: requestCharacterMenu(modelData)
                    onCloseRequest: scene.removeMuteCharacter(modelData)
                }
            }

            Loader {
                id: newCharacterInput
                width: active && item ? Math.max(item.contentWidth, 100) : 0
                active: false
                sourceComponent: Item {
                    property alias contentWidth: textViewEdit.contentWidth
                    height: textViewEdit.height

                    TextViewEdit {
                        id: textViewEdit
                        width: parent.width
                        y: -fontDescent
                        readOnly: false
                        font.capitalization: Font.AllUppercase
                        font.pointSize: 12
                        horizontalAlignment: Text.AlignLeft
                        wrapMode: Text.NoWrap
                        completionStrings: scriteDocument.structure.characterNames
                        onEditingFinished: {
                            scene.addMuteCharacter(text)
                            newCharacterInput.active = false
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: parent.fontAscent
                            height: 1
                            color: accentColors.borderColor
                        }
                    }
                }
            }

            Image {
                source: "../icons/content/add_box.png"
                width: sceneCharactersListHeading.height
                height: sceneCharactersListHeading.height
                opacity: 0.5

                MouseArea {
                    ToolTip.text: "Click here to capture characters who don't have any dialogues in this scene, but are still required for the scene."
                    ToolTip.delay: 1000
                    ToolTip.visible: containsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: parent.opacity = containsMouse ? 1 : 0.5
                    onClicked: newCharacterInput.active = true
                }
            }
        }
    }

    Loader {
        id: sceneListPanelLoader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.topMargin: 5
        anchors.bottomMargin: statusBar.height
        active: screenplayAdapter.isSourceScreenplay && screenplayAdapter.elementCount > 1 && globalSceneEditorToolbar.editInFullscreen
        property bool expanded: false
        readonly property int expandCollapseButtonWidth: 25
        readonly property int sceneListAreaWidth: 400
        clip: !sceneListPanelLoader.expanded
        width: active ? (expanded ? sceneListAreaWidth+expandCollapseButtonWidth : expandCollapseButtonWidth) : 0
        Behavior on width { NumberAnimation { duration: 250 } }

        FocusTracker.window: qmlWindow
        FocusTracker.onHasFocusChanged: {
            if(!FocusTracker.hasFocus)
                sceneListPanelLoader.expanded = false
        }

        sourceComponent: Item {
            id: sceneListPanel
            width: expandCollapseButton.width + (expanded ? sceneListArea.width : 0)

            BorderImage {
                source: "../icons/content/shadow.png"
                anchors.fill: sceneListArea
                horizontalTileMode: BorderImage.Stretch
                verticalTileMode: BorderImage.Stretch
                anchors { leftMargin: -11; topMargin: -11; rightMargin: -10; bottomMargin: -10 }
                border { left: 21; top: 21; right: 21; bottom: 21 }
                opacity: 0.25
                visible: sceneListArea.visible
            }

            Rectangle {
                id: sceneListArea
                color: "white"
                border.width: 1
                border.color: primaryColors.borderColor
                height: parent.height
                width: sceneListAreaWidth
                opacity: sceneListPanelLoader.expanded ? 1 : 0
                Behavior on opacity {  NumberAnimation { duration: 250 } }
                visible: opacity > 0

                ListView {
                    id: sceneListView
                    anchors.fill: parent
                    anchors.topMargin: 5
                    anchors.leftMargin: expandCollapseButton.width + 5
                    anchors.rightMargin: 5
                    anchors.bottomMargin: 5
                    clip: true
                    model: screenplayAdapter
                    currentIndex: screenplayAdapter.currentIndex
                    delegate: Rectangle {
                        width: sceneListView.width-1
                        height: scene && scene.heading.enabled ? 40 : 0
                        color: scene ? Qt.tint(scene.color, (screenplayAdapter.currentIndex === index ? "#9CFFFFFF" : "#E7FFFFFF")) : Qt.rgba(0,0,0,0)

                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 5
                            anchors.verticalCenter: parent.verticalCenter
                            font.bold: screenplayAdapter.currentIndex === index
                            font.pixelSize: 14
                            text: "[" + screenplayElement.sceneNumber + "] " + (scene && scene.heading.enabled ? scene.heading.text : "")
                            elide: Text.ElideMiddle
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: navigateToScene()
                            onDoubleClicked: {
                                navigateToScene()
                                sceneListPanelLoader.expanded = false
                            }

                            function navigateToScene() {
                                contentView.positionViewAtIndex(index, ListView.Beginning)
                                screenplayAdapter.currentIndex = index
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: expandCollapseButton
                width: expandCollapseButtonWidth
                height: sceneListPanelLoader.expanded ? parent.height-8 : expandCollapseButtonWidth*5
                color: primaryColors.button.background
                radius: (1.0-sceneListArea.opacity) * 6
                border.width: 1
                border.color: sceneListPanelLoader.expanded ? primaryColors.windowColor : primaryColors.borderColor
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 4
                anchors.leftMargin: sceneListPanelLoader.expanded ? 4 : -radius
                Behavior on height { NumberAnimation { duration: 250 } }

                Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: sceneListPanelLoader.expanded ? "../icons/navigation/arrow_left.png" : "../icons/navigation/arrow_right.png"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: sceneListPanelLoader.expanded = !sceneListPanelLoader.expanded
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: parent.radius
                    width: 1
                    color: primaryColors.borderColor
                    visible: !sceneListPanelLoader.expanded
                }
            }
        }
    }
}

















