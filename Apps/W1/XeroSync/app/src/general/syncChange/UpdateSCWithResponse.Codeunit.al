codeunit 2426 "XS Update SC With Response"
{
    procedure UpdateSyncChangeWithJsonResponse(NAVEntityID: Integer; var SyncChange: Record "Sync Change"; var JsonResponse: JsonArray) UpdatedDateUtc: Text
    var
        Handled: Boolean;
    begin
        OnBeforeUpdateSyncChangeWithJsonResponse(Handled);

        UpdatedDateUtc := DoUpdateSyncChangeWithJsonResponse(NAVEntityID, SyncChange, JsonResponse, Handled);

        OnAfterUpdateSyncChangeWithJsonResponse();
    end;

    local procedure DoUpdateSyncChangeWithJsonResponse(NAVEntityID: Integer; var SyncChange: Record "Sync Change"; var JsonResponse: JsonArray; var Handled: Boolean) UpdatedDateUtc: Text
    var
        EntityIDTag: Text;
        Token: JsonToken;
    begin
        if Handled then
            exit;

        EntityIDTag := GetEntityIDTag(NAVEntityID);

        foreach Token in JsonResponse do begin
            OnBeforeUpdateSyncChange(SyncChange);

            UpdatedDateUtc := PrepareSyncChangeData(SyncChange, Token, EntityIDTag);

            DoUpdateSyncChange(SyncChange);
        end;
    end;

    local procedure GetEntityIDTag(NAVEntityID: Integer) EntityIDTag: Text;
    var
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
    begin
        case NAVEntityID of
            Database::Item:
                EntityIDTag := XeroSyncManagement.GetJsonTagForItemID();
            Database::Customer:
                EntityIDTag := XeroSyncManagement.GetJsonTagForCustomerID();
        end;
    end;

    local procedure PrepareSyncChangeData(var SyncChange: Record "Sync Change"; Token: JsonToken; EntityIDTag: Text) UpdatedDateUtc: Text
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
        OutStream: OutStream;
    begin
        JsonObjectHelper.SetJsonObject(Token);
        SyncChange."External ID" := JsonObjectHelper.GetJsonValueAsText(EntityIDTag);
        UpdatedDateUtc := JsonObjectHelper.GetJsonValueAsText(XeroSyncManagement.GetJsonTagForUpdatedTimeUTC());

        SyncChange."XS Xero Json Response".CreateOutStream(OutStream, TextEncoding::UTF8);
        Token.WriteTo(OutStream);
    end;

    local procedure DoUpdateSyncChange(var SyncChange: Record "Sync Change")
    begin
        SyncChange.Modify(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateSyncChange(var SyncChange: Record "Sync Change")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateSyncChangeWithJsonResponse(var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateSyncChangeWithJsonResponse();
    begin
    end;
}