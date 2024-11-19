codeunit 11535 "Create VAT Setup PostingGrp NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
        CreateVatPostingGroup: Codeunit "Create VAT Posting Groups";
        CreateNLGLAccounts: Codeunit "Create NL GL Accounts";
    begin
        ContosoVATStatement.SetOverwriteData(true);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.FullNormal(), true, 0, '', '', true, 1, StrSubstNo(VATOnlyInvoicesDescriptionLbl, '21'));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.FullRed(), true, 0, '', '', true, 1, StrSubstNo(VATOnlyInvoicesDescriptionLbl, '9'));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.Reduced(), true, 9, CreateNLGLAccounts.SalesVATReduced(), CreateNLGLAccounts.PurchaseVATReduced(), true, 1, ReducedVatDescriptionLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.ServNormal(), true, 0, '', '', true, 1, StrSubstNo(MiscellaneousVATDescriptionLbl, '21'));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.ServRed(), true, 0, '', '', true, 1, StrSubstNo(MiscellaneousVATDescriptionLbl, '9'));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.Standard(), true, 21, CreateNLGLAccounts.SalesVATNormal(), CreateNLGLAccounts.PurchaseVATNormal(), true, 1, NormalVatDescriptionLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.Zero(), true, 0, CreateNLGLAccounts.MiscVATPayables(), CreateNLGLAccounts.MiscVATReceivables(), true, 1, NoVatDescriptionLbl);
        ContosoVATStatement.SetOverwriteData(false);
    end;

    var
        VATOnlyInvoicesDescriptionLbl: Label 'VAT Only Invoices %1%', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        MiscellaneousVATDescriptionLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        ReducedVatDescriptionLbl: Label 'Setup for EXPORT / REDUCED', MaxLength = 100;
        NormalVatDescriptionLbl: Label 'Setup for EXPORT / STANDARD', MaxLength = 100;
        NoVatDescriptionLbl: Label 'Setup for EXPORT / ZERO', MaxLength = 100;
}