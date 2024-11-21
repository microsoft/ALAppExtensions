codeunit 17135 "Create AU Sales Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        UpdatePaymentTermsOnSalesHeader(CreatePaymentTerms.PaymentTermsDAYS30());
        InsertAddressIDForSalesHeader();
    end;

    local procedure UpdatePaymentTermsOnSalesHeader(PaymentTermsCode: Code[10]);
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.FindSet() then
            repeat
                SalesHeader.Validate("Payment Terms Code", PaymentTermsCode);
                SalesHeader.Modify(true);
            until SalesHeader.Next() = 0;
    end;

    local procedure InsertAddressIDForSalesHeader()
    var
        SalesHeader: Record "Sales Header";
        AddressID: Record "Address ID";
        CreateCustomer: Codeunit "Create Customer";
    begin
        SalesHeader.SetRange("Sell-to Customer No.", CreateCustomer.DomesticAdatumCorporation());
        if SalesHeader.FindSet() then
            repeat
                AddressID.Init();
                AddressID.Validate("Table No.", Database::"Sales Header");
                AddressID.Validate("Table Key", SalesHeader.GetPosition());
                AddressID.Validate("Address Type", AddressID."Address Type"::"Bill-to");
                AddressID.Validate("Address ID", DomesticAdatumCorporationAddressIDLbl);
                AddressID.Validate("Bar Code System", AddressID."Bar Code System"::"4-State Bar Code");
                AddressID.Insert();

                AddressID.Init();
                AddressID.Validate("Table No.", Database::"Sales Header");
                AddressID.Validate("Table Key", SalesHeader.GetPosition());
                AddressID.Validate("Address Type", AddressID."Address Type"::"Ship-to");
                AddressID.Validate("Address ID", DomesticAdatumCorporationAddressIDLbl);
                AddressID.Validate("Bar Code System", AddressID."Bar Code System"::"4-State Bar Code");
                AddressID.Insert();

                AddressID.Init();
                AddressID.Validate("Table No.", Database::"Sales Header");
                AddressID.Validate("Table Key", SalesHeader.GetPosition());
                AddressID.Validate("Address Type", AddressID."Address Type"::"Sell-to");
                AddressID.Validate("Address ID", DomesticAdatumCorporationAddressIDLbl);
                AddressID.Validate("Bar Code System", AddressID."Bar Code System"::"4-State Bar Code");
                AddressID.Insert();
            until SalesHeader.Next() = 0;

        SalesHeader.SetRange("Sell-to Customer No.", CreateCustomer.DomesticRelecloud());
        if SalesHeader.FindSet() then
            repeat
                AddressID.Init();
                AddressID.Validate("Table No.", Database::"Sales Header");
                AddressID.Validate("Table Key", SalesHeader.GetPosition());
                AddressID.Validate("Address Type", AddressID."Address Type"::"Bill-to");
                AddressID.Validate("Address ID", DomesticRelecloudAddressIDLbl);
                AddressID.Validate("Bar Code System", AddressID."Bar Code System"::"4-State Bar Code");
                AddressID.Insert();

                AddressID.Init();
                AddressID.Validate("Table No.", Database::"Sales Header");
                AddressID.Validate("Table Key", SalesHeader.GetPosition());
                AddressID.Validate("Address Type", AddressID."Address Type"::"Ship-to");
                AddressID.Validate("Address ID", DomesticRelecloudAddressIDLbl);
                AddressID.Validate("Bar Code System", AddressID."Bar Code System"::"4-State Bar Code");
                AddressID.Insert();

                AddressID.Init();
                AddressID.Validate("Table No.", Database::"Sales Header");
                AddressID.Validate("Table Key", SalesHeader.GetPosition());
                AddressID.Validate("Address Type", AddressID."Address Type"::"Sell-to");
                AddressID.Validate("Address ID", DomesticRelecloudAddressIDLbl);
                AddressID.Validate("Bar Code System", AddressID."Bar Code System"::"4-State Bar Code");
                AddressID.Insert();
            until SalesHeader.Next() = 0;
    end;

    var
        DomesticAdatumCorporationAddressIDLbl: Label '20028478', MaxLength = 10;
        DomesticRelecloudAddressIDLbl: Label '20104226', MaxLength = 10;
}