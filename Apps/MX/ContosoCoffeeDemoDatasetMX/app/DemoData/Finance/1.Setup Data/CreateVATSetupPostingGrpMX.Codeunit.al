codeunit 14111 "Create VATSetupPostingGrp. MX"
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
    end;

    local procedure CreateVatSetupPostingGrp()
    var
        VATSetupPostingGroups: Record "VAT Setup Posting Groups";
        CreateVatPostingGroupMX: Codeunit "Create VAT Posting Groups MX";
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
        CreateMXGLAccounts: Codeunit "Create MX GL Accounts";
    begin
        ContosoVATStatement.SetOverwriteData(true);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroupMX.NOVAT(), true, 0, CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), true, VATSetupPostingGroups."Application Type"::Items, StrSubstNo(VATDescriptionLbl, CreateVatPostingGroupMX.NOVAT()));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroupMX.VAT16(), true, 16, CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), true, VATSetupPostingGroups."Application Type"::Items, StrSubstNo(VATDescriptionLbl, CreateVatPostingGroupMX.VAT16()));
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroupMX.VAT8(), true, 8, CreateMXGLAccounts.SalesVat8Perc(), CreateMXGLAccounts.PurchaseVat8Perc(), true, VATSetupPostingGroups."Application Type"::Items, StrSubstNo(VATDescriptionLbl, CreateVatPostingGroupMX.VAT8()));
        ContosoVATStatement.SetOverwriteData(false);
    end;

    var
        VATDescriptionLbl: Label 'Setup for EXPORT / %1', Comment = '%1 is Vat posting group', MaxLength = 100;
}