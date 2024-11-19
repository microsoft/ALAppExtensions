codeunit 5413 "Create Customer Discount Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCustomerVendor: Codeunit "Contoso Customer/Vendor";
    begin
        ContosoCustomerVendor.InsertCustomerDiscountGroup(LargeAcc(), LargeAccountLbl);
        ContosoCustomerVendor.InsertCustomerDiscountGroup(Retail(), RetailLbl);
    end;

    procedure LargeAcc(): Code[20]
    begin
        exit(LargeAccTok);
    end;

    procedure Retail(): Code[20]
    begin
        exit(RetailTok);
    end;

    var
        LargeAccTok: Label 'LARGE ACC', MaxLength = 20;
        RetailTok: Label 'RETAIL', MaxLength = 20;
        LargeAccountLbl: Label 'Large account', MaxLength = 100;
        RetailLbl: Label 'Retail', MaxLength = 100;
}