codeunit 5132 "Contoso Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "VAT Product Posting Group" = rim,
        tabledata "VAT Business Posting Group" = rim,
        tabledata "Gen. Product Posting Group" = rim,
        tabledata "Gen. Business Posting Group" = rim,
        tabledata "Customer Posting Group" = rim,
        tabledata "Vendor Posting Group" = rim,
        tabledata "Inventory Posting Group" = rim,
        tabledata "Tax Group" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertTaxGroup(TaxGroupCode: Code[20]; Description: Text[100])
    var
        TaxGroup: Record "Tax Group";
        Exists: Boolean;
    begin
        if TaxGroup.Get(TaxGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TaxGroup.Validate(Code, TaxGroupCode);
        TaxGroup.Validate(Description, Description);

        if Exists then
            TaxGroup.Modify(true)
        else
            TaxGroup.Insert(true);
    end;

    procedure InsertVATProductPostingGroup(ProductGroupCode: Code[20]; Description: Text[100])
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
        Exists: Boolean;
    begin
        if VATProductPostingGroup.Get(ProductGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATProductPostingGroup.Validate(Code, ProductGroupCode);
        VATProductPostingGroup.Validate(Description, Description);

        if Exists then
            VATProductPostingGroup.Modify(true)
        else
            VATProductPostingGroup.Insert(true);
    end;

    procedure InsertVATBusinessPostingGroup(BusinessGroupCode: Code[20]; Description: Text[100])
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        Exists: Boolean;
    begin
        if VATBusinessPostingGroup.Get(BusinessGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATBusinessPostingGroup.Validate(Code, BusinessGroupCode);
        VATBusinessPostingGroup.Validate(Description, Description);

        if Exists then
            VATBusinessPostingGroup.Modify(true)
        else
            VATBusinessPostingGroup.Insert(true);
    end;

    procedure InsertGenProductPostingGroup(ProductGroupCode: Code[20]; Description: Text[100]; DefaultVATProdPostingGroup: Code[20])
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        Exists: Boolean;
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if GenProductPostingGroup.Get(ProductGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GenProductPostingGroup.Validate(Code, ProductGroupCode);
        GenProductPostingGroup.Validate(Description, Description);

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::VAT then
            GenProductPostingGroup.Validate("Def. VAT Prod. Posting Group", DefaultVATProdPostingGroup);

        if Exists then
            GenProductPostingGroup.Modify(true)
        else
            GenProductPostingGroup.Insert(true);
    end;

    procedure InsertGenBusinessPostingGroup(BusinessGroupCode: Code[20]; Description: Text[100]; DefaultVATBusPostingGroup: Code[20])
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        Exists: Boolean;
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if GenBusinessPostingGroup.Get(BusinessGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GenBusinessPostingGroup.Validate(Code, BusinessGroupCode);
        GenBusinessPostingGroup.Validate(Description, Description);

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::VAT then begin
            GenBusinessPostingGroup.Validate("Def. VAT Bus. Posting Group", DefaultVATBusPostingGroup);
            GenBusinessPostingGroup.Validate("Auto Insert Default", true);
        end;

        if Exists then
            GenBusinessPostingGroup.Modify(true)
        else
            GenBusinessPostingGroup.Insert(true);
    end;

    procedure InsertCustomerPostingGroup(CustomerGroupCode: Code[20]; Description: Text[100]; ReceivablesAccountNo: Code[20])
    var
        CustomerPostingGroup: Record "Customer Posting Group";
        Exists: Boolean;
    begin
        if CustomerPostingGroup.Get(CustomerGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CustomerPostingGroup.Validate(Code, CustomerGroupCode);
        CustomerPostingGroup.Validate(Description, Description);
        CustomerPostingGroup.Validate("Receivables Account", ReceivablesAccountNo);

        if Exists then
            CustomerPostingGroup.Modify(true)
        else
            CustomerPostingGroup.Insert(true);
    end;

    procedure InsertVendorPostingGroup(VendorGroupCode: Code[20]; Description: Text[100]; PayablesAccountNo: Code[20])
    var
        VendorPostingGroup: Record "Vendor Posting Group";
        Exists: Boolean;
    begin
        if VendorPostingGroup.Get(VendorGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VendorPostingGroup.Validate(Code, VendorGroupCode);
        VendorPostingGroup.Validate(Description, Description);
        VendorPostingGroup.Validate("Payables Account", PayablesAccountNo);

        if Exists then
            VendorPostingGroup.Modify(true)
        else
            VendorPostingGroup.Insert(true);
    end;

    procedure InsertInventoryPostingGroup(Code: Code[20]; Description: Text[100])
    var
        InventoryPostingGroup: Record "Inventory Posting Group";
        Exists: Boolean;
    begin
        if InventoryPostingGroup.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        InventoryPostingGroup.Validate("Code", Code);
        InventoryPostingGroup.Validate("Description", Description);

        if Exists then
            InventoryPostingGroup.Modify(true)
        else
            InventoryPostingGroup.Insert(true);
    end;
}