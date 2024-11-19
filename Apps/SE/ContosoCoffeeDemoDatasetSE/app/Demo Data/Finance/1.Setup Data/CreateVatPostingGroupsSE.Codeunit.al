codeunit 11207 "Create Vat Posting Groups SE"
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
    begin
        ContosoPostingGroup.InsertVATProductPostingGroup(NoVat(), NoVatDescriptionLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(Only(), OnlyDescriptionLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT25(), Vat25DescriptionLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT12(), Vat12DescriptionLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT6(), Vat6DescriptionLbl);
    end;

    procedure UpdateVATPostingSetup()
    var
        VatPostingSetup: Record "VAT Posting Setup";
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateSEGLAccounts: Codeunit "Create SE GL Accounts";
    begin
        ContosoPostingSetup.SetOverwriteData(true);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), NoVat(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), NoVat(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), Only(), '', CreateSEGLAccounts.OnlyVAT(), Only(), 0, Enum::"Tax Calculation Type"::"Full VAT", '', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT12(), CreateSEGLAccounts.SalesVAT12(), CreateGLAccount.PurchaseVAT25(), VAT12(), 12, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT25(), CreateGLAccount.SalesVAT25(), CreateSEGLAccounts.PurchaseVAT12EU(), VAT25(), 25, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT6(), '', '', VAT6(), 6, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), NoVat(), CreateGLAccount.SalesVAT25(), CreateSEGLAccounts.PurchaseVAT12EU(), NoVat(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), VAT12(), CreateSEGLAccounts.SalesVAT12(), CreateSEGLAccounts.PurchaseVAT12EU(), VAT12(), 12, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateSEGLAccounts.PurchaseVAT12EU(), '', true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), VAT25(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), VAT25(), 25, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccount.PurchaseVAT25EU(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), VAT6(), '', '', VAT6(), 6, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', '', '', false);

        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), NoVat(), CreateGLAccount.SalesVAT25(), CreateGLAccount.PurchaseVAT25(), NoVat(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), VAT12(), CreateSEGLAccounts.SalesVAT12(), CreateGLAccount.PurchaseVAT25(), NoVat(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), VAT25(), CreateGLAccount.SalesVAT25(), CreateSEGLAccounts.PurchaseVAT12EU(), NoVat(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), VAT6(), '', '', NoVat(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.SetOverwriteData(false);

        VatPostingSetup.Get(CreateVATPostingGroups.Domestic(), Only());
        VatPostingSetup.Validate(Description, '');
        VatPostingSetup.Modify(true);
    end;

    procedure NoVat(): Code[20]
    begin
        exit(NoVatTok);
    end;

    procedure Only(): Code[20]
    begin
        exit(OnlyTok);
    end;

    procedure VAT25(): Code[20]
    begin
        exit(VAT25Tok);
    end;

    procedure VAT12(): Code[20]
    begin
        exit(VAT12Tok);
    end;

    procedure VAT6(): Code[20]
    begin
        exit(VAT6Tok);
    end;

    var
        NoVatTok: Label 'NO VAT', Locked = true;
        NoVatDescriptionLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
        OnlyTok: Label 'ONLY', Locked = true;
        OnlyDescriptionLbl: Label 'Manually posted VAT', MaxLength = 100;
        VAT12Tok: Label 'VAT12', Locked = true;
        Vat12DescriptionLbl: Label 'Miscellaneous 12 VAT', MaxLength = 100;
        VAT25Tok: Label 'VAT25', Locked = true;
        Vat25DescriptionLbl: Label 'Miscellaneous 25 VAT', MaxLength = 100;
        VAT6Tok: Label 'VAT6', Locked = true;
        Vat6DescriptionLbl: Label 'Miscellaneous 6 VAT', MaxLength = 100;

}