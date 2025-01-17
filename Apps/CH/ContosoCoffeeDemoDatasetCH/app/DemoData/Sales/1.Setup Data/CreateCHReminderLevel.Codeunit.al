codeunit 11612 "Create CH Reminder Level"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Reminder Level", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertReminderLevel(var Rec: Record "Reminder Level")
    var
        CreateReminderTerms: Codeunit "Create Reminder Terms";
    begin
        if Rec."Reminder Terms Code" = CreateReminderTerms.Domestic() then
            case Rec."No." of
                1:
                    Rec.Validate("Additional Fee (LCY)", 9.2);
                2:
                    Rec.Validate("Additional Fee (LCY)", 18.5);
                3:
                    Rec.Validate("Additional Fee (LCY)", 27.5);
            end;
    end;
}