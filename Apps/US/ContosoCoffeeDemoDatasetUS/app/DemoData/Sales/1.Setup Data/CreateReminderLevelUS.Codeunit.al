codeunit 10533 "Create Reminder Level US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Reminder Level", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Reminder Level")
    var
        CreateReminderTerms: Codeunit "Create Reminder Terms";
    begin
        if Rec."Reminder Terms Code" = CreateReminderTerms.Domestic() then
            case Rec."No." of
                1:
                    ValidateRecordFields(Rec, 7.7);
                2:
                    ValidateRecordFields(Rec, 15.5);
                3:
                    ValidateRecordFields(Rec, 23);
            end;
    end;

    local procedure ValidateRecordFields(var ReminderLevel: Record "Reminder Level"; AdditionalFeeLCY: Decimal)
    begin
        ReminderLevel.Validate("Additional Fee (LCY)", AdditionalFeeLCY);
    end;
}