codeunit 17143 "Create AU Purchase Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        UpdatePaymentTermsOnPurchaseHeader(CreatePaymentTerms.PaymentTermsDAYS30());
        InsertAddressIDForPurchaseHeader();
    end;

    local procedure UpdatePaymentTermsOnPurchaseHeader(PaymentTermsCode: Code[10]);
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if PurchaseHeader.FindSet() then
            repeat
                PurchaseHeader.Validate("Payment Terms Code", PaymentTermsCode);
                PurchaseHeader.Modify(true);
            until PurchaseHeader.Next() = 0;
    end;

    local procedure InsertAddressIDForPurchaseHeader()
    var
        PurchaseHeader: Record "Purchase Header";
        AddressID: Record "Address ID";
        CreateVendor: Codeunit "Create Vendor";
    begin
        PurchaseHeader.SetRange("Buy-from Vendor No.", CreateVendor.ExportFabrikam());
        if PurchaseHeader.FindSet() then
            repeat
                AddressID.Init();
                AddressID.Validate("Table No.", Database::"Purchase Header");
                AddressID.Validate("Table Key", PurchaseHeader.GetPosition());
                AddressID.Validate("Address Type", AddressID."Address Type"::"Buy-from");
                AddressID.Validate("Address ID", ExportFabrikamAddressIDLbl);
                AddressID.Validate("Bar Code System", AddressID."Bar Code System"::"4-State Bar Code");
                AddressID.Insert();

                AddressID.Init();
                AddressID.Validate("Table No.", Database::"Purchase Header");
                AddressID.Validate("Table Key", PurchaseHeader.GetPosition());
                AddressID.Validate("Address Type", AddressID."Address Type"::"Pay-to");
                AddressID.Validate("Address ID", ExportFabrikamAddressIDLbl);
                AddressID.Validate("Bar Code System", AddressID."Bar Code System"::"4-State Bar Code");
                AddressID.Insert();
            until PurchaseHeader.Next() = 0;

        PurchaseHeader.SetRange("Buy-from Vendor No.", CreateVendor.DomesticNodPublisher());
        if PurchaseHeader.FindSet() then
            repeat
                AddressID.Init();
                AddressID.Validate("Table No.", Database::"Purchase Header");
                AddressID.Validate("Table Key", PurchaseHeader.GetPosition());
                AddressID.Validate("Address Type", AddressID."Address Type"::"Buy-from");
                AddressID.Validate("Address ID", DomesticNodPublisherAddressIDLbl);
                AddressID.Validate("Bar Code System", AddressID."Bar Code System"::"4-State Bar Code");
                AddressID.Insert();

                AddressID.Init();
                AddressID.Validate("Table No.", Database::"Purchase Header");
                AddressID.Validate("Table Key", PurchaseHeader.GetPosition());
                AddressID.Validate("Address Type", AddressID."Address Type"::"Pay-to");
                AddressID.Validate("Address ID", DomesticNodPublisherAddressIDLbl);
                AddressID.Validate("Bar Code System", AddressID."Bar Code System"::"4-State Bar Code");
                AddressID.Insert();
            until PurchaseHeader.Next() = 0;
    end;

    var
        ExportFabrikamAddressIDLbl: Label '20077917', MaxLength = 10;
        DomesticNodPublisherAddressIDLbl: Label '20030073', MaxLength = 10;
}