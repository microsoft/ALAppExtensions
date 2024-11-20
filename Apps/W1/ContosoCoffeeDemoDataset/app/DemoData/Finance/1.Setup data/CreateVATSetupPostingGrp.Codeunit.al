codeunit 5629 "Create VAT Setup Posting Grp."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        CreateVatSetupPostingGrp();
        CreateVATAssistedSetupGrp();
    end;

    local procedure CreateVatSetupPostingGrp()
    var
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.FullNormal(), true, 0, '', '', true, 1, StrSubstNo(VATOnlyInvoicesDescriptionLbl, '25'));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.FullRed(), true, 0, '', '', true, 1, StrSubstNo(VATOnlyInvoicesDescriptionLbl, '10'));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.Reduced(), true, 10, CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), true, 1, ReducedVatDescriptionLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.ServNormal(), true, 0, '', '', true, 1, StrSubstNo(MiscellaneousVATDescriptionLbl, '25'));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.ServRed(), true, 0, '', '', true, 1, StrSubstNo(MiscellaneousVATDescriptionLbl, '10'));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.Standard(), true, 25, CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), true, 1, NormalVatDescriptionLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.Zero(), true, 0, CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), true, 1, NoVatDescriptionLbl);
    end;

    local procedure CreateVATAssistedSetupGrp()
    begin
        ContosoVATStatement.InsertVATAssistedSetupBusGrp(CreateVatPostingGroup.Domestic(), DomesticPostingGroupDescriptionLbl, true, true);
        ContosoVATStatement.InsertVATAssistedSetupBusGrp(CreateVatPostingGroup.EU(), EUPostingGroupDescriptionLbl, true, true);
        ContosoVATStatement.InsertVATAssistedSetupBusGrp(CreateVatPostingGroup.Export(), ExportPostingGroupDescriptionLbl, true, true);
    end;

    var
        CreateVatPostingGroup: Codeunit "Create VAT Posting Groups";
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
        VATOnlyInvoicesDescriptionLbl: Label 'VAT Only Invoices %1%', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        ReducedVatDescriptionLbl: Label 'Setup for EXPORT / REDUCED', MaxLength = 100;
        MiscellaneousVATDescriptionLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        NormalVatDescriptionLbl: Label 'Setup for EXPORT / STANDARD', MaxLength = 100;
        NoVatDescriptionLbl: Label 'Setup for EXPORT / ZERO', MaxLength = 100;
        DomesticPostingGroupDescriptionLbl: Label 'Domestic customers and vendors', MaxLength = 100;
        EUPostingGroupDescriptionLbl: Label 'Customers and vendors in EU', MaxLength = 100;
        ExportPostingGroupDescriptionLbl: Label 'Other customers and vendors (not EU)', MaxLength = 100;
}