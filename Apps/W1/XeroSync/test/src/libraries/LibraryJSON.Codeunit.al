codeunit 130301 "XS Library - JSON"
{
    var
        LibraryRandom: Codeunit "Library - Random";
        XSLibraryRandom: Codeunit "XS Library - Random";


    procedure CreateJsonResponseSalesInvoiceXero(ExternalId: Text; CreatedSalesInvoices: JsonArray)
    var
        SalesInvoice: JsonObject;
    begin
        SalesInvoice.Add('InvoiceID', ExternalId);
        CreatedSalesInvoices.Add(SalesInvoice);
    end;

    procedure CreateFullJsonResponseItemXero(ExternalId: Text; CreatedItems: JsonArray)
    var
        WholeJsonResponse: JsonObject;
        Item: JsonObject;
    begin
        WholeJsonResponse.Add('Id', ExternalId);
        WholeJsonResponse.Add('Status', 'OK');
        WholeJsonResponse.Add('ProviderName', LibraryRandom.RandText(15));
        WholeJsonResponse.Add('DateTimeUTC', XSLibraryRandom.CreateRandomUTCDate());

        Item.Add('ItemID', ExternalId);
        Item.Add('Code', 'ACTIVE');
        Item.Add('UpdatedDateUTC', LibraryRandom.RandText(10));
        Item.Add('PurchaseDetails', CreatePurchaseObject());
        Item.Add('SalesDetails', CreateSalesObject());
        Item.Add('Name', LibraryRandom.RandText(10));
        Item.Add('IsTrackedAsInventory', 'false');
        Item.Add('IsSold', 'true');
        Item.Add('IsPurchased', 'true');
        CreatedItems.Add(Item);
    end;

    local procedure CreatePurchaseObject() CreatedPurchaseObject: JsonObject
    begin
        CreatedPurchaseObject.Add('UnitPrice', LibraryRandom.RandDec(15, 2));
        CreatedPurchaseObject.Add('TaxType', '');
    end;

    local procedure CreateSalesObject() CreatedSalesObject: JsonObject
    begin
        CreatedSalesObject.Add('UnitPrice', LibraryRandom.RandDec(15, 2));
        CreatedSalesObject.Add('TaxType', '');
    end;

    procedure CreateFullJsonResponseCustomerXero(ExternalId: Text; CreatedContacts: JsonArray)
    var
        WholeJsonResponse: JsonObject;
        Contact: JsonObject;
        Addresses: JsonArray;
        Phones: JsonArray;
        DummyJArray: JsonArray;
    begin
        WholeJsonResponse.Add('Id', LibraryRandom.RandText(36));
        WholeJsonResponse.Add('Status', 'OK');
        WholeJsonResponse.Add('ProviderName', LibraryRandom.RandText(15));
        WholeJsonResponse.Add('DateTimeUTC', XSLibraryRandom.CreateRandomUTCDate());

        Contact.Add('ContactID', ExternalId);
        Contact.Add('ContactStatus', 'ACTIVE');
        Contact.Add('Name', LibraryRandom.RandText(10));
        Contact.Add('FirstName', LibraryRandom.RandText(12));
        Contact.Add('LastName', LibraryRandom.RandText(12));
        Contact.Add('EmailAddress', XSLibraryRandom.CreateRandomEmail());
        Contact.Add('BankAccountDetails', LibraryRandom.RandText(12));
        Contact.Add('TaxNumber', CreateGBValidVATNumber());

        Addresses.Add(CreateAddresses('STREET'));
        Addresses.Add(CreateAddresses('POBOX'));
        Contact.Add('Addresses', Addresses);

        Phones.Add(CreatePhone('DDI'));
        Phones.Add(CreatePhone('DEFAULT'));
        Phones.Add(CreatePhone('FAX'));
        Phones.Add(CreatePhone('MOBILE'));
        Contact.Add('Phones', Phones);

        Contact.Add('UpdatedDateUTC', XSLibraryRandom.CreateRandomUTCDate());
        Contact.Add('ContactGroups', DummyJArray);
        Contact.Add('IsSupplier', 'false');
        Contact.Add('IsCustomer', 'true');
        Contact.Add('ContactPersons', DummyJArray);
        Contact.Add('HasAttachments', 'false');
        Contact.Add('HasValidationErrors', 'false');
        CreatedContacts.Add(Contact);

        WholeJsonResponse.Add('Contacts', CreatedContacts);
    end;

    local procedure CreateGBValidVATNumber() ValidVATNo: Text
    var
        i: Integer;
    begin
        ValidVATNo := 'GB';
        for i := 1 to 9 do
            ValidVATNo := ValidVATNo + AddDigit();
    end;

    local procedure AddDigit(): Text
    begin
        exit(Format(LibraryRandom.RandInt(9)));
    end;

    local procedure CreateAddresses(AddressType: Text) CreatedAddress: JsonObject;
    begin
        CreatedAddress.Add('AddressType', AddressType);
        CreatedAddress.Add('City', LibraryRandom.RandText(10));
        CreatedAddress.Add('Region', LibraryRandom.RandText(10));
        CreatedAddress.Add('PostalCode', LibraryRandom.RandText(10));
        CreatedAddress.Add('Country', LibraryRandom.RandText(10));
    end;

    local procedure CreatePhone(PhoneType: Text) CreatedPhone: JsonObject;
    begin
        CreatedPhone.Add('PhoneType', PhoneType);
        CreatedPhone.Add('PhoneNumber', '12345678');
        CreatedPhone.Add('PhoneAreaCode', '123');
        CreatedPhone.Add('PhoneCountryCode', '45');
    end;
}