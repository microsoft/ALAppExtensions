codeunit 14107 "Create VAT Posting Groups MX"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
    end;

    procedure CreateVATPostingSetup()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateVATPostingGroupsMX: Codeunit "Create VAT Posting Groups MX";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateMXGLAccounts: Codeunit "Create MX GL Accounts";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroupsMX.NOVAT(), CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), CreateVATPostingGroupsMX.NOVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroupsMX.VAT16(), CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), CreateVATPostingGroupsMX.VAT16(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', CreateVATPostingGroupsMX.VAT8(), CreateMXGLAccounts.SalesVat8Perc(), CreateMXGLAccounts.PurchaseVat8Perc(), CreateVATPostingGroupsMX.VAT8(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.NOVAT(), CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), CreateVATPostingGroupsMX.NOVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT16(), CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), CreateVATPostingGroupsMX.VAT16(), 16, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), CreateVATPostingGroupsMX.VAT8(), CreateMXGLAccounts.SalesVat8Perc(), CreateMXGLAccounts.PurchaseVat8Perc(), CreateVATPostingGroupsMX.VAT8(), 8, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroupsMX.NOVAT(), CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), CreateVATPostingGroupsMX.NOVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroupsMX.VAT16(), CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), CreateVATPostingGroupsMX.VAT16(), 16, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateMXGLAccounts.PurchaseVat16PercEu(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.EU(), CreateVATPostingGroupsMX.VAT8(), CreateMXGLAccounts.SalesVat8Perc(), CreateMXGLAccounts.PurchaseVat8Perc(), CreateVATPostingGroupsMX.VAT8(), 8, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateMXGLAccounts.PurchaseVat8PercEu(), '', true);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroupsMX.NOVAT(), CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), CreateVATPostingGroupsMX.NOVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroupsMX.VAT16(), CreateMXGLAccounts.SalesVat16Perc(), CreateMXGLAccounts.PurchaseVat16Perc(), CreateVATPostingGroupsMX.VAT16(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), CreateVATPostingGroupsMX.VAT8(), CreateMXGLAccounts.SalesVat8Perc(), CreateMXGLAccounts.PurchaseVat8Perc(), CreateVATPostingGroupsMX.VAT8(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    local procedure InsertVATProductPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertVATProductPostingGroup(NOVAT(), MiscellaneousNoVATLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT16(), StrSubstNo(MiscellaneousVATLbl, '16'));
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT8(), StrSubstNo(MiscellaneousVATLbl, '8'));
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    procedure NOVAT(): Code[20]
    begin
        exit(NoVATTok);
    end;

    procedure VAT16(): Code[20]
    begin
        exit(VAT16Tok);
    end;

    procedure VAT8(): Code[20]
    begin
        exit(VAT8Tok);
    end;

    var
        NoVATTok: Label 'NO VAT', MaxLength = 20, Locked = true;
        VAT16Tok: Label 'VAT16', MaxLength = 20, Locked = true;
        VAT8Tok: Label 'VAT8', MaxLength = 20, Locked = true;
        MiscellaneousVATLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage';
        MiscellaneousNoVATLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
}