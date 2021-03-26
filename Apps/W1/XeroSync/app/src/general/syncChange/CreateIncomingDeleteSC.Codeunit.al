codeunit 2423 "XS Create Incoming Delete SC"
{
    procedure CreateIncomingDeleteSyncChangesForEntity(NAVEntityID: Integer);
    var
        Handled: Boolean;
    begin
        OnBeforeCreateIncomingDeleteSyncChangesForEntity(Handled);

        DoCreateIncomingDeleteSyncChangesForEntity(NAVEntityID, Handled);

        OnAfterCreateIncomingDeleteSyncChangesForEntity();
    end;

    local procedure DoCreateIncomingDeleteSyncChangesForEntity(NAVEntityID: Integer; var Handled: Boolean);
    var
        TempSyncMapping: Record "Sync Mapping" temporary;
        ResponseEntityArray: JsonArray;
    begin
        if Handled then
            exit;

        ResponseEntityArray := GetAllEntitesFromXero(NAVEntityID);

        if not FindSyncMappings(NAVEntityID, TempSyncMapping) then
            exit;

        FindAllEntitiesToDelete(NAVEntityID, TempSyncMapping, ResponseEntityArray);

        if TempSyncMapping.FindSet() then
            repeat
                CreateSyncChangeForObjectsToDelete(NAVEntityID, TempSyncMapping);
            until TempSyncMapping.Next() = 0;
    end;

    local procedure GetAllEntitesFromXero(NAVEntityID: Integer) ResponseEntityArray: JsonArray
    var
        SyncChange: Record "Sync Change";
        DummyDateTime: DateTime;
    begin
        SyncChange.FetchDataFromXero(NAVEntityID, SyncChange.Direction::Incoming, '', DummyDateTime, false, ResponseEntityArray);
    end;

    local procedure FindSyncMappings(NAVEntityID: Integer; var TempSyncMapping: Record "Sync Mapping"): Boolean
    var
        SyncMapping: Record "Sync Mapping";
    begin
        SyncMapping.SetRange("XS NAV Entity ID", NAVEntityID);
        SyncMapping.SetRange("XS Active", true);

        if SyncMapping.FindSet() then
            repeat
                TempSyncMapping := SyncMapping;
                TempSyncMapping.Insert();
            until SyncMapping.Next() = 0;
        exit(not SyncMapping.IsEmpty());
    end;

    local procedure FindAllEntitiesToDelete(NAVEntityID: Integer; var TempSyncMapping: Record "Sync Mapping"; var EntityArray: JsonArray)
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
        EntityToken: JsonToken;
        XeroID: Text;
    begin
        foreach EntityToken in EntityArray do begin
            TempSyncMapping.SetRange("XS Do Not Delete", false);
            if TempSyncMapping.FindSet() then
                repeat
                    JsonObjectHelper.SetJsonObject(EntityToken);
                    case NAVEntityID of
                        Database::Item:
                            XeroID := JsonObjectHelper.GetJsonValueAsText(XeroSyncManagement.GetJsonTagForItemID());
                        Database::Customer:
                            XeroID := JsonObjectHelper.GetJsonValueAsText(XeroSyncManagement.GetJsonTagForCustomerID());
                    end;
                    if GetCleanExternalID(TempSyncMapping."External Id") = UpperCase(XeroID) then begin
                        TempSyncMapping."XS Do Not Delete" := true;
                        TempSyncMapping.Modify();
                    end;
                until (TempSyncMapping."XS Do Not Delete" = true) or (TempSyncMapping.Next() = 0);
        end;
    end;

    local procedure GetCleanExternalID(ExternalID: Text) CleanedExternalID: Text;
    var
        LastCharToRemove: Integer;
    begin
        LastCharToRemove := StrLen(ExternalID) - 1;
        ExternalID := ExternalID.Remove(1, 1);
        CleanedExternalID := ExternalID.Remove(LastCharToRemove, 1);
    end;

    local procedure CreateSyncChangeForObjectsToDelete(NAVEntityID: Integer; var TempSyncMapping: Record "Sync Mapping")
    var
        SyncChange: Record "Sync Change";
    begin
        if TempSyncMapping."XS Do Not Delete" = true then
            exit;

        SyncChange.Validate(Direction, SyncChange.Direction::Incoming);
        SyncChange.Validate("Change Type", SyncChange."Change Type"::Delete);
        SyncChange.Validate("External ID", TempSyncMapping."External Id");
        SyncChange.Validate("Internal ID", TempSyncMapping."Internal ID");
        SyncChange.CreateSyncChangeRecord(NAVEntityID, '');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateIncomingDeleteSyncChangesForEntity(var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateIncomingDeleteSyncChangesForEntity();
    begin
    end;
}