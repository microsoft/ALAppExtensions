codeunit 139675 "Cloud Mig E2E Event Handler"
{
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnHandleRunReplication', '', false, false)]
    local procedure HandleReplicationRunCompleted(var Handled: Boolean; var RunId: Text; ReplicationType: Option)
    begin
        Handled := true;
        RunId := CreateGuid();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", 'OnCreateSessionForDataFixAfterReplication', '', false, false)]
    local procedure HandleOnCreateSessionForDataFixAfterReplication(var CreateSession: Boolean)
    begin
        CreateSession := false;
    end;
}