codeunit 11385 "Create Reminder Level BE"
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
                    Rec.Validate("Additional Fee (LCY)", 7.8);
                2:
                    Rec.Validate("Additional Fee (LCY)", 15.6);
                3:
                    Rec.Validate("Additional Fee (LCY)", 23.2);
            end;
    end;
}