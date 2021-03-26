codeunit 2404 "XS Customer Update From Xero"
{
    var
        XeroSyncTracker: Codeunit "XS Xero Sync Tracker";

    procedure CustomerUpdateFromXero(var SyncChange: Record "Sync Change"; var Success: Boolean; var FalseIncomingChange: Boolean) UpdatedDateUTC: Text
    var
        Handled: Boolean;
    begin
        OnBeforeCustomerUpdateFromXero(SyncChange, UpdatedDateUTC, Handled);

        UpdatedDateUTC := DoCustomerUpdateFromXero(SyncChange, Success, FalseIncomingChange, Handled);

        OnAfterCustomerUpdateFromXero(UpdatedDateUTC);
    end;

    local procedure DoCustomerUpdateFromXero(var SyncChange: Record "Sync Change"; var Success: Boolean; var FalseIncomingChange: Boolean; var Handled: Boolean) UpdatedDateUTC: Text
    var
        Customer: Record Customer;
        TempCustomer: Record Customer temporary;
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
        RecRef: RecordRef;
        RecRefCustomer: RecordRef;
        RecRefTempCustomer: RecordRef;
        CustomerJson: JsonObject;
        DoUpdate: Boolean;
        CustomerDoesntExistErr: Label 'Customer can not be updated from Xero because the customer does not exist.';
        CustomerIsNotSynchronizedErr: Label 'Customer (%1) is not synchronized. Direction: %2';
    begin
        if Handled then
            exit;

        RecRef.GetTable(SyncChange);

        CustomerJson := JsonObjectHelper.GetBLOBDataAsJsonObject(RecRef, SyncChange.FieldNo("XS Xero Json Response"));

        if not GetCustomer(CustomerJson, Customer) then
            SyncChange.UpdateSyncChangeWithErrorMessage(CustomerDoesntExistErr);

        UpdatedDateUTC := GetCustomerData(CustomerJson, TempCustomer);

        RecRefCustomer.GetTable(Customer);
        RecRefTempCustomer.GetTable(TempCustomer);

        DoUpdate := XeroSyncManagement.CompareRecords(RecRefTempCustomer, RecRefCustomer, Database::Customer);

        if not DoUpdate then begin
            FalseIncomingChange := true;
            exit;
        end;

        OnBeforeUpdateCustomer(CustomerJson, TempCustomer);
        RecRefCustomer.SetTable(Customer);
        if DoUpdateCustomer(Customer) then begin
            SyncChange.UpdateSyncChangeWithInternalID(Customer.RecordId());
            Success := true;
        end else
            SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(CustomerIsNotSynchronizedErr, Customer.Name, SyncChange.Direction));
    end;

    local procedure GetCustomer(var CustomerJson: JsonObject; var Customer: Record Customer): Boolean
    var
        SyncMapping: Record "Sync Mapping";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        RecID: RecordId;
    begin
        JsonObjectHelper.SetJsonObject(CustomerJson);
        SyncMapping.SetRange("External Id", JsonObjectHelper.GetJsonValueAsText('ContactID'));
        if SyncMapping.FindFirst() then
            RecID := SyncMapping."Internal ID";
        exit(Customer.Get(RecID));
    end;

    local procedure GetCustomerData(var CustomerJson: JsonObject; var TempCustomer: Record Customer) UpdatedDateUTC: Text
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        Token: JsonToken;
        Contact: Text;
        DetailsToken: JsonToken;
    begin
        JsonObjectHelper.SetJsonObject(CustomerJson);

        UpdatedDateUTC := JsonObjectHelper.GetJsonValueAsText('UpdatedDateUTC');

        TempCustomer.Validate(Name, CopyStr(JsonObjectHelper.GetJsonValueAsText('Name'), 1, MaxStrLen(TempCustomer.Name)));

        Contact := JsonObjectHelper.GetJsonValueAsText('FirstName');
        Contact := Contact + ' ' + JsonObjectHelper.GetJsonValueAsText('LastName');

        TempCustomer.Contact := CopyStr(Contact, 1, MaxStrLen(TempCustomer.Contact));

        TempCustomer.Validate("E-Mail", CopyStr(JsonObjectHelper.GetJsonValueAsText('EmailAddress'), 1, MaxStrLen(TempCustomer."E-Mail")));

        TempCustomer.Validate("Currency Code", GetCurrencyCode(CopyStr(JsonObjectHelper.GetJsonValueAsText('DefaultCurrency'), 1, 10)));
        TempCustomer.Validate("XS Tax Type", CopyStr(JsonObjectHelper.GetJsonValueAsText('AccountsReceivableTaxType'), 1, MaxStrLen(TempCustomer."XS Tax Type")));

        Token := JsonObjectHelper.GetJsonToken('Addresses');
        if Token.IsArray() then
            foreach DetailsToken in Token.AsArray() do
                ReadAddressArrayData(DetailsToken, TempCustomer);

        Token := JsonObjectHelper.GetJsonToken('Phones');
        if Token.IsArray() then
            foreach DetailsToken in Token.AsArray() do
                ReadPhoneArrayData(DetailsToken, TempCustomer);

        XeroSyncTracker.SetCalledFromXeroSync(true);
        BindSubscription(XeroSyncTracker);
    end;

    local procedure GetCurrencyCode(CurrencyFromXero: Code[10]): Code[10]
    var
        Currency: Record Currency;
    begin
        if Currency.Get(CurrencyFromXero) then
            exit(CurrencyFromXero);
        exit('');
    end;

    local procedure ReadAddressArrayData(var AddressToken: JsonToken; var TempCustomer: Record Customer)
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
    begin
        JsonObjectHelper.SetJsonObject(AddressToken);
        if JsonObjectHelper.GetJsonValueAsText('AddressType') = 'POBOX' then begin
            TempCustomer.Validate(Address, CopyStr(JsonObjectHelper.GetJsonValueAsText('AddressLine1'), 1, MaxStrLen(TempCustomer.Address)));
            TempCustomer.Validate(City, CopyStr(JsonObjectHelper.GetJsonValueAsText('City'), 1, MaxStrLen(TempCustomer.City)));
            TempCustomer.Validate("Country/Region Code", GetCountryRegionCode(JsonObjectHelper.GetJsonValueAsText('Country')));
            TempCustomer.Validate("Post Code", CopyStr(JsonObjectHelper.GetJsonValueAsText('PostalCode'), 1, MaxStrLen(TempCustomer."Post Code")));
            TempCustomer.Validate(County, CopyStr(JsonObjectHelper.GetJsonValueAsText('Region'), 1, MaxStrLen(TempCustomer.County)));
        end;
    end;

    local procedure GetCountryRegionCode(CountryName: Text) CountryRegionCode: Code[10]
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.SetRange(Name, CountryName);
        if CountryRegion.FindFirst() then
            CountryRegionCode := CountryRegion.Code;
    end;

    local procedure ReadPhoneArrayData(var PhoneToken: JsonToken; var TempCustomer: Record Customer)
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        PhoneNumber: Text;
    begin
        JsonObjectHelper.SetJsonObject(PhoneToken);
        if JsonObjectHelper.GetJsonValueAsText('PhoneType') = 'DEFAULT' then begin
            PhoneNumber := JsonObjectHelper.GetJsonValueAsText('PhoneCountryCode');
            PhoneNumber := PhoneNumber + JsonObjectHelper.GetJsonValueAsText('PhoneAreaCode');
            PhoneNumber := PhoneNumber + JsonObjectHelper.GetJsonValueAsText('PhoneNumber');
            TempCustomer.Validate("Phone No.", CopyStr(PhoneNumber, 1, MaxStrLen(TempCustomer."Phone No.")));
        end;

        JsonObjectHelper.SetJsonObject(PhoneToken);
        if JsonObjectHelper.GetJsonValueAsText('PhoneType') = 'FAX' then begin
            PhoneNumber := JsonObjectHelper.GetJsonValueAsText('PhoneCountryCode');
            PhoneNumber := PhoneNumber + JsonObjectHelper.GetJsonValueAsText('PhoneAreaCode');
            PhoneNumber := PhoneNumber + JsonObjectHelper.GetJsonValueAsText('PhoneNumber');
            TempCustomer.Validate("Fax No.", CopyStr(PhoneNumber, 1, MaxStrLen(TempCustomer."Fax No.")));
        end;
    end;

    local procedure DoUpdateCustomer(var Customer: Record Customer): Boolean
    begin
        exit(Customer.Modify(true));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateCustomer(var CustomerJson: JsonObject; var Customer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCustomerUpdateFromXero(var SyncChange: Record "Sync Change"; UpdatedDateUTC: Text; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCustomerUpdateFromXero(UpdatedDateUTC: Text);
    begin
    end;
}