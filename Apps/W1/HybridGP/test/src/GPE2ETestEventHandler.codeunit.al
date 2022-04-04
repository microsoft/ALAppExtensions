codeunit 139677 "GP E2E Test Event Handler"
{
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid GP Management", 'OnCreateSessionForUpgrade', '', false, false)]
    local procedure HandleOnCreateSessionForUpgrade(var CreateSession: Boolean)
    begin
        CreateSession := false;
    end;
}