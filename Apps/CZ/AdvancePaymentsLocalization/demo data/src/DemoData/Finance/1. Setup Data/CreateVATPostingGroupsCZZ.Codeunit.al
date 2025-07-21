#pragma warning disable AA0247
codeunit 31472 "Create Vat Posting Groups CZZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateVATPostingSetup();
    end;

    procedure UpdateVATPostingSetup()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoAdvancePaymentsCZZ: Codeunit "Contoso Advance Payments CZZ";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateVATPostingGroupsCZ: Codeunit "Create VAT Posting Groups CZ";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        ContosoAdvancePaymentsCZZ.UpdateVATPostingSetup('', CreateVATPostingGroupsCZ.VAT12I(), CreateGLAccountCZ.AdvancesVAT12(), CreateGLAccountCZ.SalesAdvancesDomestic(), CreateGLAccountCZ.AdvancesVAT12(), CreateGLAccountCZ.PurchaseAdvancesDomestic());
        ContosoAdvancePaymentsCZZ.UpdateVATPostingSetup('', CreateVATPostingGroupsCZ.VAT12S(), CreateGLAccountCZ.AdvancesVAT12(), CreateGLAccountCZ.SalesAdvancesDomestic(), CreateGLAccountCZ.AdvancesVAT12(), CreateGLAccountCZ.PurchaseAdvancesDomestic());
        ContosoAdvancePaymentsCZZ.UpdateVATPostingSetup('', CreateVATPostingGroupsCZ.VAT21I(), CreateGLAccountCZ.AdvancesVAT21(), CreateGLAccountCZ.SalesAdvancesDomestic(), CreateGLAccountCZ.AdvancesVAT21(), CreateGLAccountCZ.PurchaseAdvancesDomestic());
        ContosoAdvancePaymentsCZZ.UpdateVATPostingSetup('', CreateVATPostingGroupsCZ.VAT21S(), CreateGLAccountCZ.AdvancesVAT21(), CreateGLAccountCZ.SalesAdvancesDomestic(), CreateGLAccountCZ.AdvancesVAT21(), CreateGLAccountCZ.PurchaseAdvancesDomestic());
        ContosoAdvancePaymentsCZZ.UpdateVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT12I(), CreateGLAccountCZ.AdvancesVAT12(), CreateGLAccountCZ.SalesAdvancesDomestic(), CreateGLAccountCZ.AdvancesVAT12(), CreateGLAccountCZ.PurchaseAdvancesDomestic());
        ContosoAdvancePaymentsCZZ.UpdateVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT12S(), CreateGLAccountCZ.AdvancesVAT12(), CreateGLAccountCZ.SalesAdvancesDomestic(), CreateGLAccountCZ.AdvancesVAT12(), CreateGLAccountCZ.PurchaseAdvancesDomestic());
        ContosoAdvancePaymentsCZZ.UpdateVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21I(), CreateGLAccountCZ.AdvancesVAT21(), CreateGLAccountCZ.SalesAdvancesDomestic(), CreateGLAccountCZ.AdvancesVAT21(), CreateGLAccountCZ.PurchaseAdvancesDomestic());
        ContosoAdvancePaymentsCZZ.UpdateVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsCZ.VAT21S(), CreateGLAccountCZ.AdvancesVAT21(), CreateGLAccountCZ.SalesAdvancesDomestic(), CreateGLAccountCZ.AdvancesVAT21(), CreateGLAccountCZ.PurchaseAdvancesDomestic());
        ContosoAdvancePaymentsCZZ.UpdateVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroupsCZ.VAT12I(), CreateGLAccountCZ.AdvancesVAT12(), CreateGLAccountCZ.SalesAdvancesEU(), CreateGLAccountCZ.AdvancesVAT12(), CreateGLAccountCZ.PurchaseAdvancesEU());
        ContosoAdvancePaymentsCZZ.UpdateVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroupsCZ.VAT12S(), CreateGLAccountCZ.AdvancesVAT12(), CreateGLAccountCZ.SalesAdvancesEU(), CreateGLAccountCZ.AdvancesVAT12(), CreateGLAccountCZ.PurchaseAdvancesEU());
        ContosoAdvancePaymentsCZZ.UpdateVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroupsCZ.VAT21I(), CreateGLAccountCZ.AdvancesVAT21(), CreateGLAccountCZ.SalesAdvancesEU(), CreateGLAccountCZ.AdvancesVAT21(), CreateGLAccountCZ.PurchaseAdvancesEU());
        ContosoAdvancePaymentsCZZ.UpdateVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroupsCZ.VAT21S(), CreateGLAccountCZ.AdvancesVAT21(), CreateGLAccountCZ.SalesAdvancesEU(), CreateGLAccountCZ.AdvancesVAT21(), CreateGLAccountCZ.PurchaseAdvancesEU());
    end;
}
