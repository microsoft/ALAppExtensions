codeunit 2406 "XS Create Customer Data Json"
{
    procedure CreateCustomerDataJson(var Customer: Record Customer; ChangeType: Option Create,Update,Delete," ") CustomerDataJsonTxt: Text
    var
        Handled: Boolean;
    begin
        OnBeforeCreateCustomerDataJson(Customer, Handled);

        CustomerDataJsonTxt := DoCreateCustomerDataJson(Customer, Handled);

        OnAfterCreateCustomerDataJson(CustomerDataJsonTxt);
    end;

    local procedure DoCreateCustomerDataJson(var Customer: Record Customer; var Handled: Boolean) CustomerDataJsonTxt: Text
    var
        CustomerJson: JsonObject;
        AddressArray: JsonArray;
        PhoneArray: JsonArray;
    begin
        if Handled then
            exit;

        CreateAddressData(Customer, AddressArray);

        CreatePhoneData(Customer, PhoneArray);

        CreateCustomerJson(CustomerJson, Customer, AddressArray, PhoneArray);

        CustomerJson.WriteTo(CustomerDataJsonTxt);
    end;

    local procedure CreateAddressData(var Customer: Record Customer; var AddressArray: JsonArray)
    begin
        AddStreetAddress(Customer, AddressArray);
    end;

    local procedure AddStreetAddress(var Customer: Record Customer; var AddressArray: JsonArray)
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        JAddress: JsonObject;
    begin
        JsonObjectHelper.AddValueToJObject(JAddress, 'AddressType', 'POBOX');
        JsonObjectHelper.AddValueToJObject(JAddress, 'AttentionTo', Customer.Contact);
        JsonObjectHelper.AddValueToJObject(JAddress, 'AddressLine1', Customer.Address);
        JsonObjectHelper.AddValueToJObject(JAddress, 'City', Customer.City);
        JsonObjectHelper.AddValueToJObject(JAddress, 'Region', Customer.County);
        JsonObjectHelper.AddValueToJObject(JAddress, 'PostalCode', Customer."Post Code");
        JsonObjectHelper.AddValueToJObject(JAddress, 'Country', GetCountryName(Customer));
        JsonObjectHelper.AddDataToJArray(AddressArray, JAddress);
    end;

    local procedure GetCountryName(var Customer: Record Customer) CountryName: Text
    var
        CountryRegion: Record "Country/Region";
    begin
        if CountryRegion.Get(Customer."Country/Region Code") then
            CountryName := CountryRegion.Name;
    end;

    local procedure CreatePhoneData(var Customer: Record Customer; var PhoneArray: JsonArray)
    begin
        CreateDefaultPhone(Customer, PhoneArray);
        CreateFax(Customer, PhoneArray);
    end;

    local procedure CreateDefaultPhone(var Customer: Record Customer; var PhoneArray: JsonArray)
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        JPhone: JsonObject;
    begin
        JsonObjectHelper.AddValueToJObject(JPhone, 'PhoneType', 'DEFAULT');
        JsonObjectHelper.AddValueToJObject(JPhone, 'PhoneNumber', Customer."Phone No.");
        JsonObjectHelper.AddDataToJArray(PhoneArray, JPhone);
    end;

    local procedure CreateFax(var Customer: Record Customer; var PhoneArray: JsonArray)
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        JPhone: JsonObject;
    begin
        JsonObjectHelper.AddValueToJObject(JPhone, 'PhoneType', 'FAX');
        JsonObjectHelper.AddValueToJObject(JPhone, 'PhoneNumber', Customer."Fax No.");
        JsonObjectHelper.AddDataToJArray(PhoneArray, JPhone);
    end;

    local procedure CreateCustomerJson(var CustomerJson: JsonObject; var Customer: Record Customer; var AddressArray: JsonArray; var PhoneArray: JsonArray)
    var
        XSXeroSyncManagement: Codeunit "XS Xero Sync Management";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
    begin
        JsonObjectHelper.AddValueToJObject(CustomerJson, 'Name', Customer.Name);
        JsonObjectHelper.AddValueToJObject(CustomerJson, 'EmailAddress', Customer."E-Mail");
        if XSXeroSyncManagement.IsGBTenant() and (Customer."Contact Type" = Customer."Contact Type"::Company) then
            JsonObjectHelper.AddValueToJObject(CustomerJson, 'TaxNumber', Customer."VAT Registration No.");
        JsonObjectHelper.AddArrayAsValueToJObject(CustomerJson, 'Addresses', AddressArray);
        JsonObjectHelper.AddArrayAsValueToJObject(CustomerJson, 'Phones', PhoneArray);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateCustomerDataJson(var Customer: Record Customer; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateCustomerDataJson(var CustomerDataJsonTxt: Text);
    begin
    end;
}