codeunit 139670 "Api Events"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Graph Mgt - General Tools", 'OnGetIsAPIEnabled', '', false, false)]
    local procedure HandleOnGetIsAPIEnabled(var Handled: Boolean; var IsAPIEnabled: Boolean)
    var
    begin
        Handled := true;
        IsAPIEnabled := true;
    end;
}