codeunit 139674 "BC Last E2E Event Handler"
{
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Management", 'OnCreateSessionForUpgrade', '', false, false)]
    local procedure HandleOnCreateSessionForUpgrade(var CreateSession: Boolean)
    begin
        CreateSession := false;
    end;
}