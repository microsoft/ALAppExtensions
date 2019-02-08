codeunit 13664 "OIOUBL-Reminder Line Sub"
{
    [EventSubscriber(ObjectType::Table, 296, 'OnAfterInsertEvent', '', false, false)]
    procedure OnAfterInsertEventAccountCodeAssignment(var Rec: Record "Reminder Line"; RunTrigger: Boolean);
    var
        ReminderHeader: Record "Reminder Header";
    begin
        if not ReminderHeader.Get(Rec."Reminder No.") then
            exit;

        Rec."OIOUBL-Account Code" := ReminderHeader."OIOUBL-Account Code";
        Rec.Modify();
    end;
}