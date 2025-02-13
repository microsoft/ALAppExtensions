codeunit 11247 "Create VAT Setup PostingGrp SE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
        CreateVatPostingGroup: Codeunit "Create VAT Posting Groups SE";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateSEGLAccounts: Codeunit "Create SE GL Accounts";
    begin
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.NoVat(), true, 0, CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), true, 1, StrSubstNo(SetupforExportDescLbl, CreateVatPostingGroup.NoVat()));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.Only(), true, 0, '', '', true, 1, OnlyVatDescriptionLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.VAT12(), true, 12, CreateSEGLAccounts.SalesVAT12(), CreateGLAccount.PurchaseVAT25(), true, 1, StrSubstNo(SetupforExportDescLbl, CreateVatPostingGroup.VAT12()));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.VAT25(), true, 25, CreateGLAccount.SalesVAT25(), CreateSEGLAccounts.PurchaseVAT12EU(), true, 1, StrSubstNo(SetupforExportDescLbl, CreateVatPostingGroup.VAT25()));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroup.VAT6(), true, 6, '', '', true, 1, StrSubstNo(SetupforExportDescLbl, CreateVatPostingGroup.VAT6()));
    end;

    var
        SetupforExportDescLbl: Label 'Setup for EXPORT / %1', Comment = '%1 is Vat Prod. Posting Grp Desc', MaxLength = 100;
        OnlyVatDescriptionLbl: Label 'Manually posted VAT', MaxLength = 100;
}