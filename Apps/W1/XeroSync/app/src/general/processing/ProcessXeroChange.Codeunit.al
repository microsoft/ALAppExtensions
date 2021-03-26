codeunit 2421 "XS Process Xero Change"
{
    procedure ProcessXeroChange(var SyncChange: Record "Sync Change") Success: Boolean
    var
        Handled: Boolean;
    begin
        OnBeforeProcessXeroChange(SyncChange, Handled, Success);

        Success := DoProcessXeroChange(SyncChange, Handled, Success);

        OnAfterProcessXeroChange(SyncChange, Success);
    end;

    local procedure DoProcessXeroChange(var SyncChange: Record "Sync Change"; var Handled: Boolean; var Success: Boolean): Boolean;
    var
        SyncMapping: record "Sync Mapping";
    begin
        if Handled then
            exit(Success);

        if not IsXeroHandler(SyncChange) then exit;

        if SyncChange."Change Type" <> SyncChange."Change Type"::Create then
            FindSyncMapping(SyncChange, SyncMapping);

        case SyncChange.Direction of
            SyncChange.Direction::Incoming:
                exit(HandleIncomingChange(SyncChange, SyncMapping));
            SyncChange.Direction::Outgoing,
            SyncChange.Direction::Bidirectional:
                exit(HandleOutgoingChange(SyncChange, SyncMapping));
        end;
    end;

    local procedure IsXeroHandler(var SyncChange: Record "Sync Change"): boolean
    var
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
    begin
        exit(SyncChange."Sync Handler" = XeroSyncManagement.GetXeroHandler());
    end;

    local procedure FindSyncMapping(var SyncChange: Record "Sync Change"; var SyncMapping: Record "Sync Mapping")
    var
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
    begin
        case SyncChange.Direction of
            SyncChange.Direction::Incoming:
                SyncMapping.SetRange("External Id", SyncChange."External ID");
            SyncChange.Direction::Outgoing,
            SyncChange.Direction::Bidirectional:
                SyncMapping.SetRange("Internal ID", SyncChange."Internal ID");
        end;
        SyncMapping.SetRange(Handler, XeroSyncManagement.GetXeroHandler());
        SyncMapping.FindFirst();
    end;

    local procedure HandleIncomingChange(var SyncChange: Record "Sync Change"; var SyncMapping: Record "Sync Mapping"): Boolean
    begin
        case SyncChange."Change Type" of
            SyncChange."Change Type"::Create:
                exit(HandleIncomingCreateEntity(SyncChange));
            SyncChange."Change Type"::Update:
                exit(HandleIncomingUpdateEntity(SyncChange, SyncMapping));
            SyncChange."Change Type"::Delete:
                exit(HandleIncomingDeleteEntity(SyncChange, SyncMapping));
        end;
    end;

    local procedure HandleIncomingCreateEntity(var SyncChange: Record "Sync Change") IsSuccessful: Boolean
    var
        Item: Record Item;
        Customer: record Customer;
        XeroUpdatedDateUtc: Text;
        RecLastModified: DateTime;
        Success: Boolean;
    begin
        case SyncChange."XS NAV Entity ID" of
            Database::Item:
                begin
                    XeroUpdatedDateUtc := SyncChange.CreateEntityFromXero(Success);
                    if not Success then
                        exit;
                    Item.Get(SyncChange."Internal ID");
                    RecLastModified := Item."Last DateTime Modified";
                end;
            Database::Customer:
                begin
                    XeroUpdatedDateUtc := SyncChange.CreateEntityFromXero(Success);
                    if not Success then
                        exit;
                    Customer.Get(SyncChange."Internal ID");
                    RecLastModified := Customer."Last Modified Date Time";
                end;
        end;
        if Success then
            IsSuccessful := CreateSyncMapping(SyncChange, RecLastModified, XeroUpdatedDateUtc);
    end;

    local procedure HandleIncomingDeleteEntity(var SyncChange: Record "Sync Change"; var SyncMapping: Record "Sync Mapping") IsSuccessful: Boolean;
    var
        DoDeleteSyncMapping: Boolean;
        DeletedInNAVDateTime: DateTime;
    begin
        SyncChange.ProcessDeleteFromXero(DoDeleteSyncMapping);
        if DoDeleteSyncMapping then
            IsSuccessful := DeleteSyncMapping(SyncMapping)
        else
            IsSuccessful := MakeSyncMappingInactive(SyncMapping, DeletedInNAVDateTime);
    end;

    local procedure HandleIncomingUpdateEntity(var SyncChange: Record "Sync Change"; var SyncMapping: Record "Sync Mapping") IsSuccessful: Boolean;
    var
        Item: Record Item;
        Customer: record Customer;
        XeroUpdatedDateUtc: Text;
        RecLastModified: DateTime;
        Success: Boolean;
        FalseIncomingChange: Boolean;
    begin
        case SyncChange."XS NAV Entity ID" of
            Database::Item:
                begin
                    XeroUpdatedDateUtc := SyncChange.UpdateEntityFromXero(Success, FalseIncomingChange);
                    if (not Success) or (FalseIncomingChange) then begin
                        IsSuccessful := FalseIncomingChange;
                        exit;
                    end;
                    Item.Get(SyncChange."Internal ID");
                    RecLastModified := Item."Last DateTime Modified";
                end;
            Database::Customer:
                begin
                    XeroUpdatedDateUtc := SyncChange.UpdateEntityFromXero(Success, FalseIncomingChange);
                    if (not Success) or (FalseIncomingChange) then begin
                        IsSuccessful := FalseIncomingChange;
                        exit;
                    end;
                    Customer.Get(SyncChange."Internal ID");
                    RecLastModified := Customer."Last Modified Date Time";
                end;
        end;
        if Success then
            IsSuccessful := UpdateSyncMapping(SyncChange, RecLastModified, XeroUpdatedDateUtc, SyncMapping);
    end;

    local procedure CreateSyncMapping(var SyncChange: Record "Sync Change"; RecLastModified: DateTime; XeroUpdatedDateUtc: Text) IsSuccessful: Boolean;
    var
        SyncMapping: Record "Sync Mapping";
    begin
        SyncMapping.Init();
        SyncMapping."External Id" := SyncChange."External ID";
        SyncMapping."Internal ID" := SyncChange."Internal ID";
        SyncMapping.Handler := SyncChange."Sync Handler";
        SyncMapping."XS NAV Entity ID" := SyncChange."XS NAV Entity ID";
        SyncMapping."XS Last Synced Xero" := CopyStr(XeroUpdatedDateUtc, 1, maxstrlen(SyncMapping."XS Last Synced Xero"));
        case SyncChange.Direction of
            SyncChange.Direction::Incoming:
                if SyncChange."XS Xero Json Response".HasValue() then begin
                    SyncChange.CalcFields("XS Xero Json Response");
                    SyncMapping."XS Xero Json Response" := SyncChange."XS Xero Json Response";
                end;
            SyncChange.Direction::Outgoing,
            SyncChange.Direction::Bidirectional:
                begin
                    if SyncChange."NAV Data".HasValue() then begin
                        SyncChange.CalcFields("NAV Data");
                        SyncMapping."XS NAV Data" := SyncChange."NAV Data";
                    end;
                    if SyncChange."XS Xero Json Response".HasValue() then begin
                        SyncChange.CalcFields("XS Xero Json Response");
                        SyncMapping."XS Xero Json Response" := SyncChange."XS Xero Json Response";
                    end;
                end;
        end;
        SyncMapping."Last Synced Internal" := RecLastModified;
        SyncMapping."XS Active" := true;
        IsSuccessful := SyncMapping.Insert(true);
        // CreateNewSyncChangeToUpdateCustNoInXero(SyncChange, SyncMapping); // TODO Remove?
    end;

    local procedure CreateNewSyncChangeToUpdateCustNoInXero(var SyncChange: Record "Sync Change"; var SyncMapping: Record "Sync Mapping") // TODO Remove?
    var
        Customer: Record Customer;
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
    begin
        if SyncChange."XS NAV Entity ID" = Database::Customer then
            if (SyncChange."Change Type" = SyncChange."Change Type"::Create) or
                ((SyncChange.Direction = SyncChange.Direction::Incoming) and (SyncChange."Change Type" = SyncChange."Change Type"::Update)) then begin
                Customer.Get(SyncMapping."Internal ID");
                XeroSyncManagement.UpdateXeroContactWithNAVCustomerNo(Customer, SyncMapping);
            end;
    end;

    local procedure UpdateSyncMapping(var SyncChange: Record "Sync Change"; RecLastModified: DateTime; XeroUpdatedDateUtc: Text; var SyncMapping: Record "Sync Mapping") IsSuccessful: Boolean;
    begin
        SyncMapping."XS Last Synced Xero" := CopyStr(XeroUpdatedDateUtc, 1, maxstrlen(SyncMapping."XS Last Synced Xero"));
        SyncMapping."Last Synced Internal" := RecLastModified;
        SyncMapping."External Id" := SyncChange."External ID";
        if SyncChange."XS Xero Json Response".HasValue() then begin
            SyncChange.CalcFields("XS Xero Json Response");
            SyncMapping."XS Xero Json Response" := SyncChange."XS Xero Json Response";
        end;
        if SyncMapping."XS Active" = false then
            SyncMapping."XS Active" := true;
        IsSuccessful := SyncMapping.Modify(true);
        if SyncChange."XS ReMapped" then
            CreateNewSyncChangeToUpdateCustNoInXero(SyncChange, SyncMapping);
    end;

    local procedure DeleteSyncMapping(var SyncMapping: Record "Sync Mapping"): Boolean
    begin
        exit(SyncMapping.Delete(true));
    end;

    local procedure MakeSyncMappingInactive(var SyncMapping: Record "Sync Mapping"; DeletedInNAVDateTime: DateTime): Boolean
    begin
        SyncMapping.Validate("XS Active", false);
        SyncMapping.Validate("Last Synced Internal", DeletedInNAVDateTime);
        exit(SyncMapping.Modify(true));
    end;

    local procedure HandleOutgoingChange(var SyncChange: Record "Sync Change"; var SyncMapping: Record "Sync Mapping"): Boolean
    begin
        case SyncChange."Change Type" of
            SyncChange."Change Type"::Create:
                exit(HandleOutgoingCreateEntity(SyncChange, SyncMapping));
            SyncChange."Change Type"::Delete:
                exit(HandleOutgoingDeleteEntity(SyncChange, SyncMapping));
            SyncChange."Change Type"::Update:
                exit(HandleOutgoingUpdateEntity(SyncChange, SyncMapping));
        end;
    end;

    local procedure HandleOutgoingCreateEntity(var SyncChange: Record "Sync Change"; var SyncMapping: Record "Sync Mapping") IsSuccessful: Boolean;
    var
        Item: Record Item;
        Customer: record Customer;
        SalesInvoice: Record "Sales Invoice Header";
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
        RecLastModifiedDateTime: DateTime;
        ReMapped: Boolean;
        XeroUpdatedDateUtc: Text;
        FilterValue: Text;
        Success: Boolean;
    begin
        case SyncChange."XS NAV Entity ID" of
            Database::Item:
                begin
                    XeroUpdatedDateUtc := SyncChange.PushSyncChangeToXero(Success);
                    Item.Get(SyncChange."Internal ID");
                    RecLastModifiedDateTime := Item."Last DateTime Modified";
                    FilterValue := Item."No.";
                end;
            Database::Customer:
                begin
                    XeroUpdatedDateUtc := SyncChange.PushSyncChangeToXero(Success);
                    Customer.Get(SyncChange."Internal ID");
                    RecLastModifiedDateTime := Customer."Last Modified Date Time";
                    // TODO: Discuss how to find the customer
                    FilterValue := Customer.Name;
                end;
            Database::"Sales Invoice Header":
                begin
                    XeroUpdatedDateUtc := SyncChange.PushSyncChangeToXero(Success);
                    SalesInvoice.Get(SyncChange."Internal ID");
                    RecLastModifiedDateTime := CurrentDateTime();
                end;
        end;

        if not Success then
            exit;

        ReMapped := XeroSyncManagement.ReMapSyncMappingIfNeeded(SyncMapping, SyncChange, SyncChange."XS NAV Entity ID", FilterValue);
        if not ReMapped then
            IsSuccessful := CreateSyncMapping(SyncChange, RecLastModifiedDateTime, XeroUpdatedDateUtc)
        else
            IsSuccessful := UpdateSyncMapping(SyncChange, RecLastModifiedDateTime, XeroUpdatedDateUtc, SyncMapping)
    end;

    local procedure HandleOutgoingDeleteEntity(var SyncChange: Record "Sync Change"; var SyncMapping: Record "Sync Mapping") IsSuccessStatusCode: Boolean;
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        RecRef: RecordRef;
        JsonResponse: JsonArray;
        DeleteEntityRequestText: Text;
        XeroID: Text;
    begin
        case SyncChange."XS NAV Entity ID" of
            Database::Item:
                XeroID := JsonObjectHelper.GetExternalIDFromBLOB(SyncChange."XS NAV Entity ID", SyncMapping);
            Database::Customer:
                begin
                    RecRef.GetTable(SyncChange);
                    DeleteEntityRequestText := JsonObjectHelper.GetBLOBDataAsText(RecRef, SyncChange.FieldNo("NAV Data"));
                    XeroID := JsonObjectHelper.GetExternalIDFromBLOB(SyncChange."XS NAV Entity ID", SyncMapping);
                end;
        end;
        IsSuccessStatusCode := SyncChange.PushDataToXero(SyncChange."XS NAV Entity ID", SyncChange.Direction, SyncChange."Change Type", XeroID, DeleteEntityRequestText, JsonResponse);
        if IsSuccessStatusCode then
            DeleteSyncMapping(SyncMapping);
    end;

    local procedure HandleOutgoingUpdateEntity(var SyncChange: Record "Sync Change"; var SyncMapping: Record "Sync Mapping") IsSuccessful: Boolean;
    var
        Item: Record Item;
        Customer: record Customer;
        XeroUpdatedDateUtc: Text;
        Success: Boolean;
        RecLastModifiedDateTime: DateTime;
    begin
        case SyncChange."XS NAV Entity ID" of
            Database::Item:
                begin
                    XeroUpdatedDateUtc := SyncChange.PushSyncChangeToXero(Success);
                    Item.Get(SyncChange."Internal ID");
                    RecLastModifiedDateTime := Item."Last DateTime Modified";
                end;
            Database::Customer:
                begin
                    XeroUpdatedDateUtc := SyncChange.PushSyncChangeToXero(Success);
                    Customer.Get(SyncChange."Internal ID");
                    RecLastModifiedDateTime := Customer."Last Modified Date Time";
                end;
        end;

        if not Success then
            exit;

        IsSuccessful := UpdateSyncMapping(SyncChange, RecLastModifiedDateTime, XeroUpdatedDateUtc, SyncMapping);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessXeroChange(var SyncChange: Record "Sync Change"; var Handled: Boolean; var HandledSuccess: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessXeroChange(var SyncChange: Record "Sync Change"; var Success: Boolean);
    begin
    end;
}