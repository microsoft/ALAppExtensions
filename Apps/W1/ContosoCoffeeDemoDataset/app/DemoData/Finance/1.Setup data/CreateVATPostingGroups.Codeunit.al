codeunit 5473 "Create VAT Posting Groups"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
        InsertVATBusinessPostingGroups();

        InsertVATClause();
        InsertVATPostingSetupWithoutGLAccounts();
    end;

    procedure UpdateVATPostingSetup()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        ContosoPostingSetup.SetOverwriteData(true);
        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Sales Tax", 'E', '', '', false)
        else begin
            ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup('', Reduced(), CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), Reduced(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', Reduced(), false);
            ContosoPostingSetup.InsertVATPostingSetup('', Standard(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Standard(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup('', Zero(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', zero(), false);
            ContosoPostingSetup.InsertVATPostingSetup(Domestic(), Reduced(), CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), Reduced(), 10, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', Reduced(), false);
            ContosoPostingSetup.InsertVATPostingSetup(Domestic(), Standard(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Standard(), 25, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup(Domestic(), Zero(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', zero(), false);
            ContosoPostingSetup.InsertVATPostingSetup(EU(), Reduced(), CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), Reduced(), 10, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccount.PurchaseVAT10EU(), Reduced(), true);
            ContosoPostingSetup.InsertVATPostingSetup(EU(), Standard(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Standard(), 25, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccount.PurchaseVAT25EU(), '', false);
            ContosoPostingSetup.InsertVATPostingSetup(EU(), Zero(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', zero(), false);
            ContosoPostingSetup.InsertVATPostingSetup(Export(), Reduced(), CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10(), Reduced(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', Reduced(), false);
            ContosoPostingSetup.InsertVATPostingSetup(Export(), Standard(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Standard(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup(Export(), Zero(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', zero(), false);
        end;
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    local procedure InsertVATPostingSetupWithoutGLAccounts()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Sales Tax", 'E', '', '', false)
        else begin
            ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup('', Reduced(), '', '', Reduced(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', Reduced(), false);
            ContosoPostingSetup.InsertVATPostingSetup('', Standard(), '', '', Standard(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup('', Zero(), '', '', Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', zero(), false);
            ContosoPostingSetup.InsertVATPostingSetup(Domestic(), Reduced(), '', '', Reduced(), 10, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', Reduced(), false);
            ContosoPostingSetup.InsertVATPostingSetup(Domestic(), Standard(), '', '', Standard(), 25, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup(Domestic(), Zero(), '', '', Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', zero(), false);
            ContosoPostingSetup.InsertVATPostingSetup(EU(), Reduced(), '', '', Reduced(), 10, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', '', Reduced(), true);
            ContosoPostingSetup.InsertVATPostingSetup(EU(), Standard(), '', '', Standard(), 25, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup(EU(), Zero(), '', '', Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', zero(), false);
            ContosoPostingSetup.InsertVATPostingSetup(Export(), Reduced(), '', '', Reduced(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', Reduced(), false);
            ContosoPostingSetup.InsertVATPostingSetup(Export(), Standard(), '', '', Standard(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
            ContosoPostingSetup.InsertVATPostingSetup(Export(), Zero(), '', '', Zero(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', zero(), false);
        end;
    end;

    local procedure InsertVATClause()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        ContosoPostingSetup.InsertVATClause(Reduced(), ReducedVATClauseDescriptionLbl);
        ContosoPostingSetup.InsertVATClause(Zero(), ZeroVATClauseDescriptionLbl);
    end;

    local procedure InsertVATProductPostingGroup()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        ContosoPostingGroup.InsertVATProductPostingGroup(FullNormal(), StrSubstNo(VATOnlyInvoicesDescriptionLbl, '25'));
        ContosoPostingGroup.InsertVATProductPostingGroup(FullRed(), StrSubstNo(VATOnlyInvoicesDescriptionLbl, '10'));
        ContosoPostingGroup.InsertVATProductPostingGroup(Reduced(), StrSubstNo(ReducedVatDescriptionLbl, '10'));
        ContosoPostingGroup.InsertVATProductPostingGroup(ServNormal(), StrSubstNo(MiscellaneousVATDescriptionLbl, '25'));
        ContosoPostingGroup.InsertVATProductPostingGroup(ServRed(), StrSubstNo(MiscellaneousVATDescriptionLbl, '10'));
        ContosoPostingGroup.InsertVATProductPostingGroup(Standard(), StrSubstNo(NormalVatDescriptionLbl, '25'));
        ContosoPostingGroup.InsertVATProductPostingGroup(Zero(), NoVatDescriptionLbl);
    end;

    local procedure InsertVATBusinessPostingGroups()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        ContosoPostingGroup.InsertVATBusinessPostingGroup(Domestic(), DomesticPostingGroupDescriptionLbl);
        ContosoPostingGroup.InsertVATBusinessPostingGroup(EU(), EUPostingGroupDescriptionLbl);
        ContosoPostingGroup.InsertVATBusinessPostingGroup(Export(), ExportPostingGroupDescriptionLbl);
    end;

    procedure Domestic(): Code[20]
    begin
        exit(DomesticTok);
    end;

    procedure EU(): Code[20]
    begin
        exit(EUTok);
    end;

    procedure Export(): Code[20]
    begin
        exit(ExportTok);
    end;

    procedure Zero(): Code[20]
    begin
        exit(ZeroTok);
    end;

    procedure Standard(): Code[20]
    begin
        exit(StandardTok);
    end;

    procedure Reduced(): Code[20]
    begin
        exit(ReducedTok);
    end;

    procedure ServRed(): Code[20]
    begin
        exit(ServRedTok);
    end;

    procedure ServNormal(): Code[20]
    begin
        exit(ServNormTok);
    end;

    procedure FullRed(): Code[20]
    begin
        exit(FullRedTok);
    end;

    procedure FullNormal(): Code[20]
    begin
        exit(FullNormalTok);
    end;

    var
        DomesticTok: Label 'DOMESTIC', MaxLength = 20;
        EUTok: Label 'EU', MaxLength = 20;
        ExportTok: Label 'EXPORT', MaxLength = 20;
        ZeroTok: Label 'ZERO', MaxLength = 20;
        StandardTok: Label 'STANDARD', MaxLength = 20;
        ReducedTok: Label 'REDUCED', MaxLength = 20;
        ServRedTok: Label 'SERV RED', MaxLength = 20;
        ServNormTok: Label 'SERV NORM', MaxLength = 20;
        FullRedTok: Label 'FULL RED', MaxLength = 20;
        FullNormalTok: Label 'FULL NORM', MaxLength = 20;
        ReducedVATClauseDescriptionLbl: Label 'Reduced VAT Rate is used due to VAT Act regulation 1 article II', MaxLength = 250;
        ZeroVATClauseDescriptionLbl: Label 'Zero VAT Rate is used due to VAT Act regulation 2 article III', MaxLength = 250;
        MiscellaneousVATDescriptionLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        VATOnlyInvoicesDescriptionLbl: Label 'VAT Only Invoices %1%', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        NormalVatDescriptionLbl: Label 'Standard VAT (%1%)', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        ReducedVatDescriptionLbl: Label 'Reduced VAT (%1%)', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        NoVatDescriptionLbl: Label 'No VAT', MaxLength = 100;
        DomesticPostingGroupDescriptionLbl: Label 'Domestic customers and vendors', MaxLength = 100;
        EUPostingGroupDescriptionLbl: Label 'Customers and vendors in EU', MaxLength = 100;
        ExportPostingGroupDescriptionLbl: Label 'Other customers and vendors (not EU)', MaxLength = 100;
}