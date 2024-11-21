codeunit 12234 "Create Reminder Level IT"
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
        case Rec."Reminder Terms Code" of
            CreateReminderTerms.Domestic():
                begin
                    if Rec."No." = 1 then
                        Rec.Validate("Additional Fee (LCY)", 7.8);
                    if Rec."No." = 2 then
                        Rec.Validate("Additional Fee (LCY)", 15.6);
                    if Rec."No." = 3 then
                        Rec.Validate("Additional Fee (LCY)", 23.2);
                end;
        end;
    end;
}