codeunit 4794 "Create Whse Cust/Vend"
{
    Permissions = tabledata Customer = ri,
        tabledata "Tax Area" = ri,
        tabledata Vendor = ri;

    trigger OnRun()
    begin
        WhseDemoDataSetup.Get();

        InsertVendorData(WhseDemoDataSetup."Vendor No.", BeansSupplierLbl, WhseDemoDataSetup."Vendor Posting Group", WhseDemoDataSetup."Vend. Gen. Bus. Posting Group");
        OnAfterCreatedVendors();
        InsertCustomerData(WhseDemoDataSetup."Customer No.", CustomerLbl, WhseDemoDataSetup."Cust. Posting Group", WhseDemoDataSetup."Cust. Gen. Bus. Posting Group");
        OnAfterCreatedCustomers();
    end;

    var
        WhseDemoDataSetup: Record "Whse Demo Data Setup";
        BeansSupplierLbl: Label 'Fabrikam, Inc.', MaxLength = 30;
        CustomerLbl: Label 'Adatum Corporation', MaxLength = 30;

    local procedure InsertVendorData("No.": Code[20]; Name: Text[30]; VendorPostingGroup: Code[20]; BusPostingGroup: Code[20])
    var
        Vendor: Record Vendor;
        TaxArea: Record "Tax Area";
    begin
        if Vendor.Get("No.") then
            exit;

        Vendor.Init();

        Vendor.Validate("No.", "No.");
        Vendor.Validate(Name, Name);

        if WhseDemoDataSetup."Company Type" = WhseDemoDataSetup."Company Type"::"Sales Tax" then
            if TaxArea.FindFirst() then
                Vendor.Validate("Tax Area Code", TaxArea.Code);

        if Vendor."Vendor Posting Group" = '' then
            Vendor.Validate("Vendor Posting Group", VendorPostingGroup);
        if Vendor."Gen. Bus. Posting Group" = '' then
            Vendor.Validate("Gen. Bus. Posting Group", BusPostingGroup);

        OnBeforeVendorInsert(Vendor);
        Vendor.Insert(true);
    end;

    local procedure InsertCustomerData("No.": Code[20]; Name: Text[30]; CustomerPostingGroup: Code[20]; BusPostingGroup: Code[20])
    var
        Customer: Record Customer;
        TaxArea: Record "Tax Area";
    begin
        if Customer.Get("No.") then
            exit;

        Customer.Init();

        Customer.Validate("No.", "No.");
        Customer.Validate(Name, Name);

        if WhseDemoDataSetup."Company Type" = WhseDemoDataSetup."Company Type"::"Sales Tax" then
            if TaxArea.FindFirst() then
                Customer.Validate("Tax Area Code", TaxArea.Code);

        if Customer."Customer Posting Group" = '' then
            Customer.Validate("Customer Posting Group", CustomerPostingGroup);
        if Customer."Gen. Bus. Posting Group" = '' then
            Customer.Validate("Gen. Bus. Posting Group", BusPostingGroup);

        OnBeforeCustomerInsert(Customer);
        Customer.Insert(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVendorInsert(var Vendor: Record Vendor)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCustomerInsert(var Customer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatedVendors()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatedCustomers()
    begin
    end;
}
