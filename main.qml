import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

import QtQuick.Layouts 1.1

import Process 1.0


ApplicationWindow
{
    visible: true
    width: 800
    height: 600
    title: qsTr("Test")

    // Menu bar
    menuBar: MenuBar
    {
        Menu
        {
            title: qsTr("File")
            MenuItem
            {
                text: qsTr("&Open")
                onTriggered: console.log("Open action triggered");
            }
            MenuItem
            {
                text: qsTr("Exit")
                onTriggered: Qt.quit();
            }
        }
    }

    MessageDialog
    {
        id: messageDialog
        title: qsTr("Info")

        function show(caption)
        {
            messageDialog.text = caption;
            messageDialog.open();
        }
    }

    // The data from cpuinfo will be extracted from C++ side and put in Text
    Text
    {
        id: text
    }

    // The process that reads data from C++ side
    Process
    {
        id: process
        onReadyRead: text.text = readAll();
    }

    // Here we start the process that reads data from cpuinfo
    Timer
    {
        triggeredOnStart: true
        running: true
        onTriggered: process.start("/bin/cat", [ "/proc/cpuinfo" ]);
    }

    // This is only used to color the background
    Rectangle
    {
        width: 1800
        height: 1600
        color: "lightgray"
    }

    // A short test to check the number of processors
    function check()
    {
        var mtext = text.text;
        var count = (mtext.match(/processor/g) || []).length;
        return count;
    }

    // Function for processing and inserting the data in the TableView
    // Also, inserts the data in the combobox
    function insert(index)
    {
        var type = new Array(0);
        var description = new Array(0);
        var position = new Array(0);

        var mText = text.text;


        var str= "";
        for (var k = 0; k < mText.length; k++)
        {
            if ((mText.charAt(k) != '\n') && (mText.charAt(k) != ':'))
                str += mText.charAt(k);

            if (mText.charAt(k) === ':')
            {
                type.push(str)
                str = "";

                var str2 = "";
                while ((mText.charAt(k + 1) !== '\n') && (k < mText.length - 1))
                {
                    if ((mText.charAt(k) != '\n') && (mText.charAt(k) != ':'))
                        str2 += mText.charAt(k + 1);
                    ++k;
                }

                description.push(str2);
            }
        }

        var idx = 0;
        var length = type.length;
        for (var i = 0; i < length; i++)
        {
           libraryModel.append({"type": type[i], "description": description[i]})

           if (type[i].trim() === "processor")
           {
                var temp = type[i] + " " + description[i];
                cbItems.append({"text": temp})
                position[idx] = i;

                ++idx;
           }
        }

        if (index > 0)
        {
            position[idx] =  position[idx - 1] + position[1];
            var pos1 = position[index - 1]
            var pos2 = position[index]

            libraryModel.clear();

            for (var ii = 0; ii < length; ii++)
            {
                if ((ii >= pos1) && (ii < pos2))
                  libraryModel.append({"type": type[ii], "description": description[ii]})
            }
        }
    }

    MainForm {
        anchors.fill: parent
        button1.onClicked:
        {
            var nbProcessors = check()
            messageDialog.show(qsTr("System has") + " " + nbProcessors + qsTr(" processors."));
        }

        button2.onClicked:
        {
            if (libraryModel.count > 0)
            {
                cbItems.clear()
                libraryModel.clear()
                cbItems.append({"text": "All processors"})
            }

            var index = 0;

            insert(index);
        }
    }

    ListModel {
        id: libraryModel
    }

    // The table that show the data
    TableView {
        x:     5
        y:     5
        width: 640
        height: 480


        TableViewColumn {
            role: "type"
            title: "Type"
            width: 180
        }
        TableViewColumn {
            role: "description"
            title: "Description"
            width: 3200
        }
        model: libraryModel

    }

    // The combobox that helps to select the processor
    ComboBox {
        id: combo
        currentIndex: 0
        model: ListModel {
            id: cbItems
            ListElement { text: "All processors"}
        }

        x: 200
        y: 489
        width: 150
        height: 27

        onCurrentIndexChanged:
        {
            cbItems.clear()
            libraryModel.clear()
            cbItems.append({"text": "All processors"})
            insert(currentIndex)
        }
    }
}
