codeunit 2418 "XS Xero Sync Tracker"
{
    EventSubscriberInstance = Manual;

    var
        _IsCalledFromXeroSync: Boolean;

    procedure SetCalledFromXeroSync(value: Boolean)
    begin
        _IsCalledFromXeroSync := value;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"XS Xero Sync Tracker Events", 'OnBeforeQueueEntityForSync', '', false, false)]
    local procedure TrackOnBeforeQueueEntityForSync(var IsCalledFromXeroSync: Boolean)
    begin
        IsCalledFromXeroSync := _IsCalledFromXeroSync;
    end;
}