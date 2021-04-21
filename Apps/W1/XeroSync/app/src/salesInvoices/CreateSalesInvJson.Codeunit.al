codeunit 2459 "XS Create Sales Inv. Json"
{
    var
        CurrencyIsMissingErr: Label 'Currency %1 was not found in Xero. Invoice %2 cannot be synced.';

    procedure CreateSalesInvoiceJson(var SalesInvoiceHeader: Record "Sales Invoice Header") SalesInvoiceDataJsonTxt: Text
    var
        Handled: Boolean;
    begin
        OnBeforeCreateSalesInvoiceJson(SalesInvoiceHeader, Handled);

        SalesInvoiceDataJsonTxt := DoCreateSalesInvoiceJson(SalesInvoiceHeader, Handled);

        OnAfterCreateSalesInvoiceJson(SalesInvoiceDataJsonTxt);
    end;

    local procedure DoCreateSalesInvoiceJson(var SalesInvoiceHeader: Record "Sales Invoice Header"; var Handled: Boolean) SalesInvoiceDataJsonTxt: Text
    var
        Customer: Record Customer;
        SalesInvoiceLine: Record "Sales Invoice Line";
        CustomerJsonObject: JsonObject;
        SalesInvoiceObject: JsonObject;
        SalesInvoiceLineJArray: JsonArray;
    begin
        if Handled then
            exit;

        FindCustomer(SalesInvoiceHeader, Customer);

        CustomerJsonObject := CreateCustomerJsonObject(Customer);

        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        if SalesInvoiceLine.FindSet() then
            repeat
                AddSalesLineToJsonArray(SalesInvoiceLine, SalesInvoiceLineJArray, SalesInvoiceHeader);
            until SalesInvoiceLine.Next() = 0;
        CreateInvoiceGeneralData(SalesInvoiceObject, SalesInvoiceHeader, CustomerJsonObject, SalesInvoiceLineJArray);

        SalesInvoiceObject.WriteTo(SalesInvoiceDataJsonTxt);
    end;

    local procedure FindCustomer(var SalesInvoiceHeader: Record "Sales Invoice Header"; var Customer: Record Customer)
    begin
        Customer.Get(SalesInvoiceHeader."Sell-to Customer No.");
    end;

    local procedure CreateCustomerJsonObject(var Customer: Record Customer) CustomerJsonObject: JsonObject
    var
        XeroSyncManagement: Codeunit "XS Xero Sync Management";
        CustomerJsonText: Text;
        ChangeType: Option Create,Update,Delete," ";
    begin
        CustomerJsonText := XeroSyncManagement.CreateCustomerDataJson(Customer, ChangeType::Update);
        CustomerJsonObject.ReadFrom(CustomerJsonText);
    end;

    local procedure AddSalesLineToJsonArray(var SalesInvoiceLine: Record "Sales Invoice Line"; var SalesInvoiceLineJArray: JsonArray; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SyncSetup: Record "Sync Setup";
        Customer: Record Customer;
        Item: Record Item;
        XSXeroSyncManagement: Codeunit "XS Xero Sync Management";
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        SalesInvoiceLineJObject: JsonObject;
        Discount: Decimal;
        DiscountAmount: Decimal;
        LineDiscount: Decimal;
    begin
        SyncSetup.GetSingleInstance();
        JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'Description', SalesInvoiceLine.Description);
        JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'Quantity', SalesInvoiceLine.Quantity);
        JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'UnitAmount', SalesInvoiceLine."Unit Price");

        SalesInvoiceHeader.CalcFields(Amount);
        if SalesInvoiceHeader.Amount <> 0 then begin
            DiscountAmount := SalesInvoiceHeader."Invoice Discount Value";
            Discount := Round(DiscountAmount / (SalesInvoiceHeader.Amount + DiscountAmount) * 100);
            LineDiscount := SalesInvoiceLine."Line Discount %";
            JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'DiscountRate', LineDiscount + Discount - (Discount * LineDiscount / 100));
        end;
        JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'TaxAmount', SalesInvoiceLine."Amount Including VAT" - SalesInvoiceLine.Amount);
        if XSXeroSyncManagement.IsGBTenant() then
            if Item.Get(SalesInvoiceLine."No.") then begin
                JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'ItemCode', SalesInvoiceLine."No.");
                if Item."XS Tax Type" <> '' then
                    JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'TaxType', Item."XS Tax Type")
                else
                    JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'TaxType', SyncSetup."XS Default Tax Type");
                if Item."XS Account Code" <> '' then
                    JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'AccountCode', Item."XS Account Code")
                else
                    JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'AccountCode', SyncSetup."XS Default AccountCode");
            end else begin
                JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'TaxType', SyncSetup."XS Default Tax Type");
                JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'AccountCode', SyncSetup."XS Default AccountCode");
            end;

        if not XSXeroSyncManagement.IsGBTenant() then begin
            if Item.Get(SalesInvoiceLine."No.") then begin
                JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'ItemCode', SalesInvoiceLine."No.");
                if Item."XS Account Code" <> '' then
                    JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'AccountCode', Item."XS Account Code")
                else
                    JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'AccountCode', SyncSetup."XS Default AccountCode");
            end;
            if Customer.Get(SalesInvoiceHeader."Sell-to Customer No.") and
                    (Customer."XS Tax Type" <> '') then
                JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'TaxType', Customer."XS Tax Type")
            else
                JsonObjectHelper.AddValueToJObject(SalesInvoiceLineJObject, 'TaxType', SyncSetup."XS Default Tax Type");
        end;

        JsonObjectHelper.AddDataToJArray(SalesInvoiceLineJArray, SalesInvoiceLineJObject);
        JsonObjectHelper.CleanJsonObject(SalesInvoiceLineJObject);
    end;

    local procedure CreateInvoiceGeneralData(var SalesInvoiceObject: JsonObject; var SalesInvoiceHeader: Record "Sales Invoice Header"; var CustomerJsonObject: JsonObject; var LineItems: JsonArray)
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
    begin
        JsonObjectHelper.AddValueToJObject(SalesInvoiceObject, 'Type', 'ACCREC');
        JsonObjectHelper.AddObjectAsValueToJObject(SalesInvoiceObject, 'Contact', CustomerJsonObject);
        JsonObjectHelper.AddValueToJObject(SalesInvoiceObject, 'Date', SalesInvoiceHeader."Posting Date");
        JsonObjectHelper.AddValueToJObject(SalesInvoiceObject, 'DueDate', SalesInvoiceHeader."Due Date");
        JsonObjectHelper.AddValueToJObject(SalesInvoiceObject, 'InvoiceNumber', SalesInvoiceHeader."No.");
        JsonObjectHelper.AddValueToJObject(SalesInvoiceObject, 'Reference', SalesInvoiceHeader."Your Reference");
        if (SalesInvoiceHeader."Currency Code" <> '') then
            if IsCurrencyAvailableInXero(SalesInvoiceHeader."Currency Code") then
                JsonObjectHelper.AddValueToJObject(SalesInvoiceObject, 'CurrencyCode', SalesInvoiceHeader."Currency Code")
            else
                Error(CurrencyIsMissingErr, SalesInvoiceHeader."Currency Code", SalesInvoiceHeader."No.");
        JsonObjectHelper.AddArrayAsValueToJObject(SalesInvoiceObject, 'LineItems', LineItems);
    end;

    local procedure IsCurrencyAvailableInXero(CurrencyCode: Code[10]): Boolean
    var
        XSRESTWebServiceParameters: Record "XS REST Web Service Parameters" temporary;
        XSCommunicateWithXero: Codeunit "XS Communicate With Xero";
        Token: JsonToken;
        Response: JsonArray;
        XeroCurrencyToken: JsonToken;
        XeroCurrencyText: Text;
    begin
        if (CurrencyCode = '') then
            exit(true);

        if not XSCommunicateWithXero.QueryXeroCurrencies(XSRESTWebServiceParameters, Response) then
            exit(false);
        foreach Token in Response Do begin
            Token.AsObject().Get('Code', XeroCurrencyToken);
            XeroCurrencyText := DelChr(Format(XeroCurrencyToken), '<>', '"');
            if CurrencyCode = UpperCase(XeroCurrencyText) then
                exit(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSalesInvoiceJson(var SalesInvoice: Record "Sales Invoice Header"; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSalesInvoiceJson(var SalesInvoiceDataJsonTxt: Text);
    begin
    end;
}