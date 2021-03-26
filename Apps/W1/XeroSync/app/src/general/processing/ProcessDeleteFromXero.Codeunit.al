codeunit 2415 "XS Process Delete From Xero"
{
    var
        XeroSyncTracker: Codeunit "XS Xero Sync Tracker";

    procedure ProcessDeleteFromXero(var SyncChange: Record "Sync Change"; var DoDeleteSyncMapping: Boolean) DeletedInNAVDateTime: DateTime
    var
        Handled: Boolean;
    begin
        OnBeforeDeleteEntityFromXero(Handled);

        DeletedInNAVDateTime := DoDeleteEntityFromXero(SyncChange, DoDeleteSyncMapping, Handled);

        OnAfterDeleteEntityFromXero();
    end;

    local procedure DoDeleteEntityFromXero(var SyncChange: Record "Sync Change"; var DoDeleteSyncMapping: Boolean; var Handled: Boolean): DateTime
    var
        Found: Boolean;
        Success: Boolean;
    begin
        if Handled then
            exit;

        XeroSyncTracker.SetCalledFromXeroSync(true);
        BindSubscription(XeroSyncTracker);

        Found := CheckIfEntityExists(SyncChange);

        if not Found then begin
            DoDeleteSyncMapping := false;
            exit(CurrentDateTime());
        end;

        if not FindOutgoingCreateSyncChange(SyncChange."Internal ID") then begin
            Commit();   // This is needed to be able to use "if codeunit.run"
                        // This is a legitimate commit because this process is called and totally controlled by us
            Success := TryDeleteEntity(SyncChange);
            if not Success then
                DoDeleteSyncMapping := false
            else
                DoDeleteSyncMapping := true;
        end;

        exit(CurrentDateTime());
    end;

    local procedure FindOutgoingCreateSyncChange(RecID: RecordId): Boolean
    var
        SyncChange: Record "Sync Change";
    begin
        SyncChange.SetRange("Internal ID", RecID);
        SyncChange.SetRange("Change Type", SyncChange."Change Type"::Create);
        SyncChange.SetFilter(Direction, '<>%1', SyncChange.Direction::Incoming);
        exit(not SyncChange.IsEmpty());
    end;

    local procedure CheckIfEntityExists(var SyncChange: Record "Sync Change") Found: Boolean
    var
        Item: Record Item;
        Customer: Record Customer;
    begin
        case SyncChange."XS NAV Entity ID" of
            Database::Item:
                if Item.Get(SyncChange."Internal ID") then
                    Found := true;
            Database::Customer:
                if Customer.Get(SyncChange."Internal ID") then
                    Found := true;
        end;
    end;

    local procedure TryDeleteEntity(var SyncChange: Record "Sync Change") Success: Boolean
    var
        Item: Record Item;
        Customer: Record Customer;
    begin
        case SyncChange."XS NAV Entity ID" of
            Database::Item:
                begin
                    Item.Get(SyncChange."Internal ID");
                    Success := Codeunit.Run(Codeunit::"XS Try Function Delete Item", Item);
                end;
            Database::Customer:
                begin
                    Customer.Get(SyncChange."Internal ID");
                    Success := Codeunit.Run(Codeunit::"XS Try Function Delete Cust.", Customer);
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteEntityFromXero(var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeleteEntityFromXero();
    begin
    end;
}