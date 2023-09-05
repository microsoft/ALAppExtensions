codeunit 51751 "Bus Queue Response Handler"
{
    Access = Internal;
    TableNo = "Bus Queue Response";
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Event Subscription" = R;

    trigger OnRun()
    var
        BusQueueResponseRaiseEvent: Codeunit "Bus Queue Response Raise Event";
        BusQueueResponse: Codeunit "Bus Queue Response";
    begin
        BusQueueResponse.SetBusQueueResponse(Rec);
        BusQueueResponseRaiseEvent.OnAfterInsertBusQueueResponse(BusQueueResponse);
    end;
    
    internal procedure IsOnAfterInsertBusQueueResponseSubscribed(): Boolean
    var
        EventSubscription: Record "Event Subscription";
    begin
        EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
        EventSubscription.SetRange("Publisher Object ID", Codeunit::"Bus Queue Response Raise Event");
        EventSubscription.SetRange("Published Function", 'OnAfterInsertBusQueueResponse');
        
        exit(not EventSubscription.IsEmpty());
    end;
}