codeunit 14627 "Create Vat Posting Groups IS"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
    end;

    local procedure InsertVATProductPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.FullNormal(), StrSubstNo(VATOnlyInvoicesDescriptionLbl, '24'));
        ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.ServNormal(), StrSubstNo(MiscellaneousVATDescriptionLbl, '24'));
        ContosoPostingGroup.InsertVATProductPostingGroup(CreateVATPostingGroups.Standard(), StrSubstNo(NormalVatDescriptionLbl, '24'));
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    procedure UpdateVATPostingSetup()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroups.Standard(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), CreateVATPostingGroups.Standard(), 24, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccount.PurchaseVAT25EU(), '', false);
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    var
        VATOnlyInvoicesDescriptionLbl: Label 'VAT Only Invoices %1%', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        MiscellaneousVATDescriptionLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        NormalVatDescriptionLbl: Label 'Standard VAT (%1%)', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
}