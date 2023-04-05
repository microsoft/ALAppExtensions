codeunit 4777 "Create Mfg Vendor"
{
    Permissions = tabledata "Vendor" = ri,
        tabledata "Vendor Posting Group" = ri,
        tabledata "Tax Area" = r;

    trigger OnRun()
    begin
        ManufacturingDemoDataSetup.Get();

        InsertData('81000', XRawMaterialSupplierLbl, ManufacturingDemoDataSetup."Domestic Code", '', '');
        InsertData('82000', XSubcontractorLbl, ManufacturingDemoDataSetup."Domestic Code", '', '');
    end;

    var
        ManufacturingDemoDataSetup: record "Manufacturing Demo Data Setup";
        XSubcontractorLbl: Label 'Subcontractor', MaxLength = 30;
        XRawMaterialSupplierLbl: Label 'Raw material supplier', MaxLength = 30;

    local procedure InsertData("No.": Code[20]; Name: Text[30]; VendorPostingGroupCode: Code[20]; Address: Text[30]; CountryCode: Code[10])
    var
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
        TaxArea: Record "Tax Area";
    begin
        Vendor.Init();

        Vendor.Validate("No.", "No.");
        Vendor.Validate(Name, Name);
        Vendor.Validate(Address, Address);
        Vendor.Validate("Country/Region Code", CountryCode);

        if ManufacturingDemoDataSetup."Company Type" = ManufacturingDemoDataSetup."Company Type"::"Sales Tax" then
            if TaxArea.FindFirst() then
                Vendor.Validate("Tax Area Code", TaxArea.Code);

        OnBeforeVendorInsert(Vendor);

        if Vendor."Vendor Posting Group" = '' then begin
            if not VendorPostingGroup.Get(VendorPostingGroupCode) then
                CreateVendorPostingGroup(VendorPostingGroupCode);
            Vendor.Validate("Vendor Posting Group", VendorPostingGroupCode);
        end;
        if Vendor."Gen. Bus. Posting Group" = '' then
            Vendor.Validate("Gen. Bus. Posting Group", VendorPostingGroupCode);

        Vendor.Insert(true);
    end;

    local procedure CreateVendorPostingGroup(VendorPostingGroupCode: Code[20])
    var
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        VendorPostingGroup.Init();
        VendorPostingGroup.Code := VendorPostingGroupCode;
        VendorPostingGroup.Insert();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVendorInsert(var Vendor: Record Vendor)
    begin
    end;
}