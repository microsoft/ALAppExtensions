codeunit 4777 "Create Mfg Vendor"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoCustomerVendor: Codeunit "Contoso Customer/Vendor";
        CreateContosoPostingGroup: Codeunit "Create Common Posting Group";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        ContosoCustomerVendor.InsertVendor(SubcontractorVendor(), SubcontractorLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", '', '', '', CreateContosoPostingGroup.Domestic(), CreateContosoPostingGroup.Domestic(), CreateContosoPostingGroup.Domestic(), '', '', false);
    end;

    var
        SubcontractorLbl: Label 'Subcontractor', MaxLength = 30;

    procedure SubcontractorVendor(): Code[20]
    begin
        exit('82000');
    end;
}