codeunit 20109 "AMC Bank Upg. Notification"
{
    trigger OnRun()
    begin
        Message(UpgNotificationLbl);
    end;

    var
        UpgNotificationLbl: Label 'We have updated the AMC Banking 365 Fundamentals extension.\\Before you can use the extension you must provide some information. Go to the AMC Banking Setup page and run the Assisted Setup action.';
}