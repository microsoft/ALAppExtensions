codeunit 11534 "Create VAT Posting Groups NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateVATPostingSetup()
    end;

    local procedure UpdateVATPostingSetup()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateNLGLAccounts: Codeunit "Create NL GL Accounts";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        ContosoPostingSetup.SetOverwriteData(true);
        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Sales Tax", 'E', '', '', false)
        else begin
            ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroups.Reduced(), CreateNLGLAccounts.SalesVATReduced(), CreateNLGLAccounts.PurchaseVATReduced(), CreateVATPostingGroups.Reduced(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', CreateVATPostingGroups.Reduced(), false);
            ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroups.Standard(), CreateNLGLAccounts.SalesVATNormal(), CreateNLGLAccounts.PurchaseVATNormal(), CreateVATPostingGroups.Standard(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroups.Zero(), CreateNLGLAccounts.MiscVATPayables(), CreateNLGLAccounts.MiscVATReceivables(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', CreateVATPostingGroups.Zero(), false);

            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Reduced(), CreateNLGLAccounts.SalesVATReduced(), CreateNLGLAccounts.PurchaseVATReduced(), CreateVATPostingGroups.Reduced(), 9, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', CreateVATPostingGroups.Reduced(), false);
            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Standard(), CreateNLGLAccounts.SalesVATNormal(), CreateNLGLAccounts.PurchaseVATNormal(), CreateVATPostingGroups.Standard(), 21, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), CreateNLGLAccounts.MiscVATPayables(), CreateNLGLAccounts.MiscVATReceivables(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', CreateVATPostingGroups.Zero(), false);

            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.Reduced(), CreateNLGLAccounts.SalesVATReduced(), CreateNLGLAccounts.PurchaseVATReduced(), CreateVATPostingGroups.Reduced(), 9, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateNLGLAccounts.MiscVATPayables(), CreateVATPostingGroups.Reduced(), true);
            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), CreateNLGLAccounts.SalesVATNormal(), CreateNLGLAccounts.PurchaseVATNormal(), CreateVATPostingGroups.Standard(), 21, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateNLGLAccounts.MiscVATPayables(), '', false);
            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.Zero(), CreateNLGLAccounts.MiscVATPayables(), CreateNLGLAccounts.MiscVATReceivables(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', CreateVATPostingGroups.Zero(), false);

            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroups.Reduced(), CreateNLGLAccounts.SalesVATReduced(), CreateNLGLAccounts.PurchaseVATReduced(), CreateVATPostingGroups.Reduced(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', CreateVATPostingGroups.Reduced(), false);
            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroups.Standard(), CreateNLGLAccounts.SalesVATNormal(), CreateNLGLAccounts.PurchaseVATNormal(), CreateVATPostingGroups.Standard(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroups.Zero(), CreateNLGLAccounts.MiscVATPayables(), CreateNLGLAccounts.MiscVATReceivables(), CreateVATPostingGroups.Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', CreateVATPostingGroups.Zero(), false);
        end;
        ContosoPostingSetup.SetOverwriteData(false);
    end;
}