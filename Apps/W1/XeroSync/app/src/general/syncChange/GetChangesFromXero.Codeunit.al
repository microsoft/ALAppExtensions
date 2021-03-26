codeunit 2422 "XS Get Changes From Xero"
{
    procedure GetChangesFromXero(var SyncChange: Record "Sync Change"; SyncSetup: Record "Sync Setup"; NAVEntityID: Integer; XeroID: Text);
    var
        Handled: Boolean;
    begin
        OnBeforeGetChangesFromXero(SyncChange, SyncSetup, NAVEntityID, XeroID, Handled);

        DoGetChangesFromXero(SyncChange, SyncSetup, NAVEntityID, XeroID, Handled);

        OnAfterGetChangesFromXero();
    end;

    local procedure DoGetChangesFromXero(var SyncChange: Record "Sync Change"; SyncSetup: Record "Sync Setup"; NAVEntityID: Integer; XeroID: Text; var Handled: Boolean);
    var
        SyncMapping: Record "Sync Mapping";
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        FetchedJsonArray: JsonArray;
        JsonTokenToSync: JsonToken;
        JsonTag: Text;
    begin
        if Handled then
            exit;

        SetSyncChangeDirection(SyncChange);

        SyncChange.FetchDataFromXero(NAVEntityID, SyncChange.Direction, XeroID, SyncSetup."XS Xero Last Sync Time", true, FetchedJsonArray);

        foreach JsonTokenToSync in FetchedJsonArray do begin
            JsonObjectHelper.SetJsonObject(JsonTokenToSync);

            Clear(SyncChange);
            SyncChange."External ID" := JsonObjectHelper.GetJsonValueAsText(GetEntityToSync(NAVEntityID));

            SetChangeType(SyncChange);

            if SyncChange."Change Type" = SyncChange."Change Type"::Create then begin
                JsonTag := GetIdentifier(NAVEntityID);
                XeroSyncManagement.ReMapSyncMappingIfNeeded(SyncMapping, SyncChange, NAVEntityID, JsonObjectHelper.GetJsonValueAsText(JsonTag));
            end;

            SyncChange.CreateSyncChangeRecord(NAVEntityID, SaveResponseJsonToText(JsonTokenToSync));
        end;

    end;

    local procedure SetSyncChangeDirection(var SyncChange: Record "Sync Change")
    begin
        SyncChange.Direction := SyncChange.Direction::Incoming;
    end;

    local procedure GetEntityToSync(NAVEntityID: Integer): Text
    var
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
    begin
        case NAVEntityID of
            Database::Item:
                exit(XeroSyncManagement.GetJsonTagForItemID());
            Database::Customer:
                exit(XeroSyncManagement.GetJsonTagForCustomerID());
        end;
    end;

    local procedure SetChangeType(var SyncChange: Record "Sync Change")
    var
        SyncMapping: Record "Sync Mapping";
    begin
        SyncMapping.SetRange("External Id", SyncChange."External ID");
        if SyncMapping.FindFirst() then
            SyncChange."Change Type" := SyncChange."Change Type"::Update
        else
            SyncChange."Change Type" := SyncChange."Change Type"::Create;
    end;

    local procedure GetIdentifier(NAVEntityID: Integer): Text
    var
        XSXeroSyncManagement: Codeunit "XS Xero Sync Management";
    begin
        case NAVEntityID of
            Database::Item:
                exit(XSXeroSyncManagement.GetJsonTagForItemCode());
            Database::Customer:
                exit(XSXeroSyncManagement.GetJsonTagForCustomerName());
        end;
    end;

    local procedure SaveResponseJsonToText(var JsonTokenToSync: JsonToken) EntityDataJsonText: Text
    begin
        JsonTokenToSync.AsObject().WriteTo(EntityDataJsonText);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetChangesFromXero(var SyncChange: Record "Sync Change"; SyncSetup: Record "Sync Setup"; NAVEntityID: Integer; XeroID: Text; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetChangesFromXero();
    begin
    end;
}