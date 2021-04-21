codeunit 2454 "XS Push Item To Xero"
{
    procedure PushItemToXero(var SyncChange: Record "Sync Change"; var Success: Boolean) UpdatedDateUtc: Text
    var
        Handled: Boolean;
    begin
        OnBeforePushItemToXero(SyncChange, Handled);

        UpdatedDateUtc := DoPushItemToXero(SyncChange, Success, Handled);

        OnAfterPushItemToXero(UpdatedDateUtc);
    end;

    local procedure DoPushItemToXero(var SyncChange: Record "Sync Change"; var Success: Boolean; var Handled: Boolean) UpdatedDateUtc: Text
    var
        Item: Record Item;
        XSCommunicateWithXero: Codeunit "XS Communicate With Xero";
        JsonResponse: JsonArray;
        IsSuccessStatusCode: Boolean;
        ItemJson: Text;
        ValidationError: Text;
        ItemIsNotSynchedErr: Label '%1 Item %2: %3';
    begin
        if Handled then
            exit;

        Item.Get(SyncChange."Internal ID");

        ItemJson := SyncChange.GetJsonFromSyncChange();

        IsSuccessStatusCode := SyncChange.PushDataToXero(SyncChange."XS NAV Entity ID", SyncChange.Direction::Outgoing, SyncChange."Change Type", '', ItemJson, JsonResponse);

        if IsSuccessStatusCode then begin
            UpdatedDateUtc := SyncChange.UpdateSyncChangeWithJsonResponseData(SyncChange."XS NAV Entity ID", JsonResponse);
            Success := true;
        end else begin
            ValidationError := XSCommunicateWithXero.ParseJsonForValidationErrors(JsonResponse);
            SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(ItemIsNotSynchedErr, SyncChange.Direction, Item."No.", ValidationError));
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePushItemToXero(var SyncChange: Record "Sync Change"; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPushItemToXero(var XeroUpdatedDateUtc: Text);
    begin
    end;
}