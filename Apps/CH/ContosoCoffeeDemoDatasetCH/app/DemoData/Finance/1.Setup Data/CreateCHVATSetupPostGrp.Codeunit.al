codeunit 11623 "Create CH VAT Setup Post. Grp."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateCHGLAccounts: Codeunit "Create CH GL Accounts";
        CreateCHVatPostingGroups: Codeunit "Create CH VAT Posting Groups";
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
    begin
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateCHVatPostingGroups.HalfNormal(), true, 3.66089, CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatInvOperatingExp(), true, 1, '');
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateCHVatPostingGroups.Hotel(), true, 3.6, CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), true, 1, '');
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateCHVatPostingGroups.Import(), true, 100, ' ', CreateCHGLAccounts.PurchVatOnImports100Percent(), true, 1, '');
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateCHVatPostingGroups.NOVAT(), true, 0, CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), true, 1, '');
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateCHVatPostingGroups.Normal(), true, 8, CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), true, 1, '');
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateCHVatPostingGroups.OperatingExpense(), true, 8, CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatInvOperatingExp(), true, 1, '');
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateCHVatPostingGroups.Reduced(), true, 2.4, CreateCHGLAccounts.VatOwed(), CreateCHGLAccounts.PurchVatMatDl(), true, 1, '');
    end;
}