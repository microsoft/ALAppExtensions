codeunit 2409 "XS Push Customer To Xero"
{
    procedure PushCustomerToXero(var SyncChange: Record "Sync Change"; var Success: Boolean) UpdatedDateUtc: Text
    var
        Handled: Boolean;
    begin
        OnBeforePushCustomerToXero(SyncChange, Handled);

        UpdatedDateUtc := DoPushCustomerToXero(SyncChange, Success, Handled);

        OnAfterPushCustomerToXero(UpdatedDateUtc);
    end;

    local procedure DoPushCustomerToXero(var SyncChange: Record "Sync Change"; var Success: Boolean; var Handled: Boolean) UpdatedDateUtc: Text
    var
        Customer: Record Customer;
        XSCommunicateWithXero: Codeunit "XS Communicate With Xero";
        CustomerJson: Text;
        JsonResponse: JsonArray;
        IsSuccessStatusCode: Boolean;
        XeroID: Text;
        ValidationError: Text;
        CustomerIsNotSynchronizedErr: Label '%1 Customer (%2): %3';
    begin
        if Handled then
            exit;

        Customer.Get(SyncChange."Internal ID");

        if SyncChange."Change Type" = SyncChange."Change Type"::Update then
            XeroID := GetCustomerXeroID(SyncChange."Internal ID");

        CustomerJson := SyncChange.GetJsonFromSyncChange();

        IsSuccessStatusCode := SyncChange.PushDataToXero(SyncChange."XS NAV Entity ID", SyncChange.Direction::Outgoing, SyncChange."Change Type", XeroID, CustomerJson, JsonResponse);

        if IsSuccessStatusCode then begin
            UpdatedDateUtc := SyncChange.UpdateSyncChangeWithJsonResponseData(SyncChange."XS NAV Entity ID", JsonResponse);
            Success := true;
        end else begin
            ValidationError := XSCommunicateWithXero.ParseJsonForValidationErrors(JsonResponse);
            SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(CustomerIsNotSynchronizedErr, SyncChange.Direction, Customer.Name, ValidationError));
        end;
    end;

    local procedure GetCustomerXeroID(RecID: RecordId) XeroID: Text
    var
        SyncMapping: Record "Sync Mapping";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
    begin
        SyncMapping.SetRange("Internal ID", RecID);
        SyncMapping.FindFirst();
        XeroID := JsonObjectHelper.GetExternalIDFromBLOB(SyncMapping."XS NAV Entity ID", SyncMapping);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePushCustomerToXero(var SyncChange: Record "Sync Change"; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPushCustomerToXero(var XeroUpdatedDateUtc: Text);
    begin
    end;
}