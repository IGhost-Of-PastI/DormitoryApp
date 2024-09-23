import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import content


Item {
    property date from:new Date()
    property date to: new Date()
    Action
    {
        id:aOpenFilter
        onTriggered:
        {
          calendarDialog.open();
        }
    }

    Dialog
    {
        width: 500
        height:650
        id:calendarDialog
        modal: true
        standardButtons: Dialog.Yes | Dialog.Cancel
        contentItem:Column
                {
                    spacing:10
            Text {
                font.pointSize: 12
                text: "Выбор фильтра"
                wrapMode: Text.WordWrap
            }
            Column
            {
                clip:true
                spacing: 10
                //height: 250
                Row{
                     clip:true
                    spacing: 10
                    Label
                    {
                        height: contentHeight
                        width: contentWidth
                        text:"C:"
                    }
                    CustomCalendar
                    {
                        id:fromCalendar
                        withTime:true
                    }
                }
            }
            Column
            {
                clip:true
                spacing: 10
               // height: 250
                Row{
                    clip:true
                    spacing: 10
                    Label
                    {
                         height: contentHeight
                        width: contentWidth
                        text:"До:"
                    }
                    CustomCalendar
                    {
                        id:toCalendaer
                        withTime:true
                    }
                }
            }
        }

        onAccepted:
        {
            from= fromCalendar.getDate();
            to=toCalendaer.getDate();
          //  from.setDate(fromCalendar.getData());//= new Date(fromCalendar.getData());
            //new Date(fromCalendar.getData());
          //  to= new Date(toCalendaer.getData());
          //  fromDate.text=from.toLocaleString();
          //  toDate.text=to.toLocaleString();
        }
    }

    Row
    {
        Button
        {
            id:openFilterDialog
            text: "Открыть"
            onClicked:
            {
                aOpenFilter.trigger();
            }
        }
        Column{
            Label
            {
                id:fromDate
                text: from.toLocaleString()
            }
            Label
            {
                id:toDate
                text: to.toLocaleString()
            }
        }
    }



}
