codeunit 51763 "Bus Queue Test Subscriber"
{
    Access = Internal;
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    var
        ReasonPhrase: Text;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bus Queue Response Raise Event", OnAfterInsertBusQueueResponse, '', true, true)]
    local procedure OnAfterInsertBusQueueResponse(BusQueueResponse: Codeunit "Bus Queue Response")
    begin
        ReasonPhrase := BusQueueResponse.GetReasonPhrase();
    end;

    internal procedure ClearReasonPhrase()
    begin
        ReasonPhrase := '';
    end;

    internal procedure GetReasonPhrase(): Text
    begin
        exit(ReasonPhrase);
    end;
}