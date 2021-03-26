codeunit 2403 "XS Customer Create From Xero"
{
    TableNo = "Sync Change";

    trigger OnRun()
    begin
        CustomerCreateFromXero(Rec);
    end;

    var
        XeroSyncTracker: Codeunit "XS Xero Sync Tracker";
        UpdatedDateUTC: Text;

    procedure CustomerCreateFromXero(var SyncChange: Record "Sync Change")
    var
        Handled: Boolean;
    begin
        OnBeforeCustomerCreateFromXero(SyncChange, UpdatedDateUTC, Handled);

        UpdatedDateUTC := DoCustomerCreateFromXero(SyncChange, Handled);

        OnAfterCustomerCreateFromXero(UpdatedDateUTC);
    end;

    local procedure DoCustomerCreateFromXero(var SyncChange: Record "Sync Change"; var Handled: Boolean) UpdatedDateUTC: Text
    var
        Customer: Record Customer;
        TempCustomer: Record Customer temporary;
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        RecRef: RecordRef;
        CustomerJson: JsonObject;
        CustomerIsNotSynchronizedErr: Label 'Customer (%1) is not synchronized. Direction: %2';
    begin
        if Handled then
            exit;

        RecRef.GetTable(SyncChange);

        CustomerJson := JsonObjectHelper.GetBLOBDataAsJsonObject(RecRef, SyncChange.FieldNo("XS Xero Json Response"));

        UpdatedDateUTC := GetCustomerData(CustomerJson, TempCustomer);
        OnBeforeInsertCustomer(CustomerJson, TempCustomer);
        if DoInsertCustomer(TempCustomer, Customer) then
            SyncChange.UpdateSyncChangeWithInternalID(Customer.RecordId())
        else
            SyncChange.UpdateSyncChangeWithErrorMessage(StrSubstNo(CustomerIsNotSynchronizedErr, Customer.Name, SyncChange.Direction));
    end;

    local procedure GetCustomerData(var CustomerJson: JsonObject; var TempCustomer: Record Customer) UpdatedDateUTC: Text
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        MiniCustomerTemplate: Record "Mini Customer Template";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        Token: JsonToken;
        Contact: Text;
        DetailsToken: JsonToken;
    begin
        JsonObjectHelper.SetJsonObject(CustomerJson);
        ConfigTemplateHeader.SetRange(Enabled, true);
        ConfigTemplateHeader.SetRange("Table ID", Database::Customer);
        if ConfigTemplateHeader.FindFirst() then
            MiniCustomerTemplate.InsertCustomerFromTemplate(ConfigTemplateHeader, TempCustomer)
        else
            TempCustomer.Init();

        UpdatedDateUTC := JsonObjectHelper.GetJsonValueAsText('UpdatedDateUTC');

        TempCustomer.Validate(Name, CopyStr(JsonObjectHelper.GetJsonValueAsText('Name'), 1, MaxStrLen(TempCustomer.Name)));

        Contact := JsonObjectHelper.GetJsonValueAsText('FirstName');
        Contact := Contact + ' ' + JsonObjectHelper.GetJsonValueAsText('LastName');
        TempCustomer.Validate(Contact, CopyStr(Contact, 1, MaxStrLen(TempCustomer.Contact)));

        TempCustomer.Validate("E-Mail", CopyStr(JsonObjectHelper.GetJsonValueAsText('EmailAddress'), 1, MaxStrLen(TempCustomer."E-Mail")));

        TempCustomer.Validate("XS Tax Type", CopyStr(JsonObjectHelper.GetJsonValueAsText('AccountsReceivableTaxType'), 1, MaxStrLen(TempCustomer."XS Tax Type")));

        TempCustomer.Validate("Currency Code", GetCurrencyCode(CopyStr(JsonObjectHelper.GetJsonValueAsText('DefaultCurrency'), 1, 10)));

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

    local procedure GetCurrencyCode(CurrencyFromXero: Code[10]): Code[10]
    var
        Currency: Record Currency;
    begin
        if Currency.Get(CurrencyFromXero) then
            exit(CurrencyFromXero);
        exit('');
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

    local procedure DoInsertCustomer(var TempCustomer: Record Customer; var Customer: Record Customer): Boolean
    begin
        Customer := TempCustomer;
        exit(Customer.Insert(true));
    end;

    procedure GetUpdatedDateUTC(): Text
    begin
        exit(UpdatedDateUTC);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertCustomer(var CustomerJson: JsonObject; var TempCustomer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCustomerCreateFromXero(var SyncChange: Record "Sync Change"; var UpdatedDateUTC: Text; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCustomerCreateFromXero(var UpdatedDateUTC: Text);
    begin
    end;
}