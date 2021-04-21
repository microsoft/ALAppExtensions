codeunit 2460 "XS Push Sales Inv. To Xero"
{
    procedure PushSalesInvoiceToXero(var SyncChange: Record "Sync Change"; var Success: Boolean) UpdatedDateUtc: Text
    var
        Handled: Boolean;
    begin
        OnBeforePushSalesInvoiceToXero(Handled);

        DoPushSalesInvoiceToXero(SyncChange, Success, Handled);

        OnAfterPushSalesInvoiceToXero();
    end;

    local procedure DoPushSalesInvoiceToXero(var SyncChange: Record "Sync Change"; var Success: Boolean; var Handled: Boolean) UpdatedDateUtc: Text
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        Item: Record Item;
        SyncChangeEntity: Record "Sync Change";
        SyncMappingEntity: Record "Sync Mapping";
        SalesInvoiceLine: Record "Sales Invoice Line";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        XSCommunicateWithXero: Codeunit "XS Communicate With Xero";
        RecRef: RecordRef;
        SalesInvoiceJson: Text;
        JsonResponse: JsonArray;
        IsSuccessStatusCode: Boolean;
        DummyDateTime: DateTime;
        CustomerToken: JsonToken;
        ValidationError: Text;
        CustomerDoesntExistErr: Label 'Sales Invoice is not synchronized because the customer (%1) does not exist.';
        CustomerIsNotSynchedErr: Label 'Sales Invoice is not synchronized because the customer (%1) is not synchronized yet.';
        ItemDoesntExistErr: Label 'Sales Invoice is not synchronized because the item (%1 - %2) does not exist.';
        ItemIsNotSynchedTxt: Label 'Sales Invoice is not synchronized because the item (%1 - %2) is not synchronized yet.';
        InvoiceNotSynchronizedErr: Label '%1 Invoice %2: %3';
    begin
        if Handled then
            exit;

        SalesInvoiceHeader.Get(SyncChange."Internal ID");

        DummyDateTime := CurrentDateTime();

        if not FindCustomer(SalesInvoiceHeader, Customer) then begin
            SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(CustomerDoesntExistErr, Customer.Name));
            exit;
        end;

        if not FindSyncMappingForEntity(SyncMappingEntity, Customer.RecordId()) then begin
            SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(CustomerIsNotSynchedErr, Customer.Name));
            exit;
        end;

        IsSuccessStatusCode := SyncChange.FetchDataFromXero(Database::Customer, SyncChange.Direction::Incoming, GetExternalID(SyncMappingEntity, Database::Customer), DummyDateTime, false, JsonResponse);
        if not IsSuccessStatusCode then begin
            SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(CustomerDoesntExistErr, Customer.Name));
            exit;
        end;

        foreach CustomerToken in JsonResponse do
            if XeroContactIsArchived(CustomerToken) then
                exit;

        if not EntityIsSynched(SyncChangeEntity, Customer.RecordId()) then begin
            SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(CustomerIsNotSynchedErr, Customer.Name));
            exit;
        end;

        FindSalesInvoiceLines(SalesInvoiceLine, SalesInvoiceHeader);
        if SalesInvoiceLine.FindFirst() then
            repeat
                if not FindItem(SalesInvoiceLine, Item) then begin
                    SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(ItemDoesntExistErr, Item."No.", Item.Description));
                    exit;
                end;

                Clear(SyncMappingEntity);
                if not FindSyncMappingForEntity(SyncMappingEntity, Item.RecordId()) then begin
                    SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(ItemIsNotSynchedTxt, Item."No.", Item.Description));
                    exit;
                end;

                IsSuccessStatusCode := SyncChange.FetchDataFromXero(Database::Item, SyncChange.Direction::Incoming, GetExternalID(SyncMappingEntity, Database::Item), DummyDateTime, false, JsonResponse);
                if not IsSuccessStatusCode then begin
                    SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(ItemDoesntExistErr, Item."No.", Item.Description));
                    exit;
                end;

                Clear(SyncChangeEntity);
                if not EntityIsSynched(SyncChangeEntity, Item.RecordId()) then begin
                    SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(ItemIsNotSynchedTxt, Item."No.", Item.Description));
                    exit;
                end;
            until SalesInvoiceLine.Next() = 0;

        RecRef.GetTable(SyncChange);

        SalesInvoiceJson := JsonObjectHelper.GetBLOBDataAsText(RecRef, SyncChange.FieldNo("NAV Data"));

        IsSuccessStatusCode := SyncChange.PushDataToXero(SyncChange."XS NAV Entity ID", SyncChange.Direction::Outgoing, SyncChange."Change Type", '', SalesInvoiceJson, JsonResponse);

        if IsSuccessStatusCode then begin
            UpdatedDateUtc := UpdateSyncChangeWithXeroData(SyncChange, JsonResponse, DummyDateTime);
            Success := true;
        end else begin
            ValidationError := XSCommunicateWithXero.ParseJsonForValidationErrors(JsonResponse);
            SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(InvoiceNotSynchronizedErr, SyncChange.Direction, SalesInvoiceHeader."No.", ValidationError));
        end;
    end;

    local procedure FindCustomer(var SalesInvoiceHeader: Record "Sales Invoice Header"; var Customer: Record Customer): Boolean
    begin
        Customer.SetRange("No.", SalesInvoiceHeader."Sell-to Customer No.");
        exit(Customer.FindFirst());
    end;

    local procedure EntityIsSynched(var SyncChange: Record "Sync Change"; EntityRecordId: RecordId): Boolean
    begin
        SyncChange.SetRange("Internal ID", EntityRecordId);
        exit(SyncChange.IsEmpty());
    end;

    local procedure FindSyncMappingForEntity(var SyncMapping: Record "Sync Mapping"; EntityRecordId: RecordId): Boolean
    begin
        SyncMapping.SetRange("Internal ID", EntityRecordId);
        SyncMapping.SetRange("XS Active", true);
        exit(SyncMapping.FindFirst());
    end;

    local procedure FindSalesInvoiceLines(var SalesInvoiceLines: Record "Sales Invoice Line"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        SalesInvoiceLines.SetRange("Document No.", SalesInvoiceHeader."No.");
    end;

    local procedure FindItem(var SalesInvoiceLine: Record "Sales Invoice Line"; var Item: Record Item): Boolean
    begin
        Item.SetRange("No.", SalesInvoiceLine."No.");
        exit(Item.FindFirst());
    end;

    local procedure GetExternalID(var SyncMapping: Record "Sync Mapping"; NAVEntityID: Integer) ExternalID: Text
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
        RecRef: RecordRef;
        JObject: JsonObject;
        ExternalIDTag: Text;
    begin
        RecRef.GetTable(SyncMapping);
        case NAVEntityID of
            Database::Item:
                ExternalIDTag := XeroSyncManagement.GetJsonTagForItemID();
            Database::Customer:
                ExternalIDTag := XeroSyncManagement.GetJsonTagForCustomerID();
        end;
        JObject := JsonObjectHelper.GetBLOBDataAsJsonObject(RecRef, SyncMapping.FieldNo("XS Xero Json Response"));
        JsonObjectHelper.SetJsonObject(JObject);
        ExternalID := JsonObjectHelper.GetJsonValueAsText(ExternalIDTag);
    end;

    local procedure XeroContactIsArchived(var CustomerToken: JsonToken): Boolean
    var
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        CustomerStatus: Text;
    begin
        JsonObjectHelper.SetJsonObject(CustomerToken);
        CustomerStatus := JsonObjectHelper.GetJsonValueAsText(XeroSyncManagement.GetJsonTagForCustomerStatus());
        if CustomerStatus = 'ARCHIVED' then
            exit(true);
    end;

    local procedure UpdateSyncChangeWithXeroData(var SyncChange: Record "Sync Change"; var JsonResponse: JsonArray) UpdatedDateUtc: Text
    var
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        SalesInvoiceToken: JsonToken;
    begin
        foreach SalesInvoiceToken in JsonResponse do begin
            JsonObjectHelper.SetJsonObject(SalesInvoiceToken);
            SyncChange."External ID" := JsonObjectHelper.GetJsonValueAsText(XeroSyncManagement.GetJsonTagForInvoiceID());
            UpdatedDateUtc := JsonObjectHelper.GetJsonValueAsText(XeroSyncManagement.GetJsonTagForUpdatedTimeUTC());
            SyncChange.Modify(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePushSalesInvoiceToXero(var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPushSalesInvoiceToXero();
    begin
    end;
}