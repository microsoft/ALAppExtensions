codeunit 17124 "Create NZ VAT Posting Group"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
        InsertVATBusinessPostingGroups();
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Business Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateGenBusinessPostingGroup(var Rec: Record "VAT Business Posting Group")
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        case Rec.Code of
            CreateVATPostingGroups.Export():
                Rec.Validate(Description, ExportPostingGroupDescriptionLbl);
        end;
    end;

    local procedure InsertVATProductPostingGroup()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertVATProductPostingGroup(NoVAT(), NoVATDescriptionLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT15(), MiscellaneousVAT15VATDescriptionLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT9(), MiscellaneousVAT9VATDescriptionLbl);
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    local procedure InsertVATBusinessPostingGroups()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.SetOverwriteData(true);
        ContosoPostingGroup.InsertVATBusinessPostingGroup(MISC(), MiscPostingGroupDescriptionLbl);
        ContosoPostingGroup.SetOverwriteData(false);
    end;

    procedure UpdateVATPostingSetup()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateNZGLAccounts: Codeunit "Create NZ GL Accounts";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', NoVAT(), CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), NoVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', VAT15(), CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), VAT15(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', VAT9(), CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10EU(), VAT9(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), NoVAT(), CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), NoVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT15(), CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), VAT15(), 15, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Domestic(), VAT9(), CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10EU(), VAT9(), 9, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), NoVAT(), CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), NoVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), VAT15(), CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), VAT15(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreateVATPostingGroups.Export(), VAT9(), CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10EU(), VAT9(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(MISC(), NoVAT(), CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), NoVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(MISC(), VAT15(), CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), VAT15(), 15, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(MISC(), VAT9(), CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10EU(), VAT9(), 9, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    procedure MISC(): Code[20]
    begin
        exit(MiscTok);
    end;

    procedure NoVAT(): Code[20]
    begin
        exit(NoVATTok);
    end;

    procedure VAT15(): Code[20]
    begin
        exit(VAT15Tok);
    end;

    procedure VAT9(): Code[20]
    begin
        exit(VAT9Tok);
    end;

    var
        MiscTok: Label 'MISC', MaxLength = 20;
        NoVATTok: Label 'NO VAT', MaxLength = 20;
        VAT15Tok: Label 'VAT15', MaxLength = 20;
        VAT9Tok: Label 'VAT9', MaxLength = 20;
        MiscPostingGroupDescriptionLbl: Label 'Customers and vendors in MISC', MaxLength = 100;
        ExportPostingGroupDescriptionLbl: Label 'Other customers and vendors (not MISC)', MaxLength = 100;
        NoVATDescriptionLbl: Label 'No VAT', MaxLength = 100;
        MiscellaneousVAT15VATDescriptionLbl: Label 'Miscellaneous VAT15 VAT', MaxLength = 100;
        MiscellaneousVAT9VATDescriptionLbl: Label 'Miscellaneous VAT9 VAT', MaxLength = 100;
}