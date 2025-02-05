codeunit 11379 "Create DE VAT Posting Groups"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
        CreateVATPostingSetup();
    end;

    local procedure CreateVATPostingSetup()
    var
        ContosoPostingSetup: codeunit "Contoso Posting Setup";
        CreateDEGLAccount: Codeunit "Create DE GL Acc.";
        CreatePostingGroup: codeunit "Create Posting Groups";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', NOVAT(), CreateDEGLAccount.MiscVATPayables(), CreateDEGLAccount.MiscVATReceivables(), NOVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', VAT19(), CreateDEGLAccount.SalesVATNormal(), CreateDEGLAccount.PurchaseVATNormal(), VAT19(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup('', VAT7(), CreateDEGLAccount.SalesVATReduced(), CreateDEGLAccount.PurchaseVATReduced(), VAT7(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), EUPostingGroupST(), '', '', EUPostingGroupST(), 100, Enum::"Tax Calculation Type"::"Full VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), NOVAT(), CreateDEGLAccount.MiscVATPayables(), CreateDEGLAccount.MiscVATReceivables(), NOVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), VAT19(), CreateDEGLAccount.SalesVATNormal(), CreateDEGLAccount.PurchaseVATNormal(), VAT19(), 19, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), VAT7(), CreateDEGLAccount.SalesVATReduced(), CreateDEGLAccount.PurchaseVATReduced(), VAT7(), 7, Enum::"Tax Calculation Type"::"Normal VAT", 'S', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), NOVAT(), CreateDEGLAccount.MiscVATPayables(), CreateDEGLAccount.MiscVATReceivables(), NOVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), VAT19(), CreateDEGLAccount.SalesVATNormal(), CreateDEGLAccount.PurchaseVATNormal(), VAT19(), 19, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateDEGLAccount.MiscVATPayables(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), VAT7(), CreateDEGLAccount.SalesVATReduced(), CreateDEGLAccount.PurchaseVATReduced(), VAT7(), 7, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateDEGLAccount.MiscVATPayables(), '', true);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), NOVAT(), CreateDEGLAccount.MiscVATPayables(), CreateDEGLAccount.MiscVATReceivables(), NOVAT(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), VAT19(), CreateDEGLAccount.SalesVATNormal(), CreateDEGLAccount.PurchaseVATNormal(), VAT19(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), VAT7(), CreateDEGLAccount.SalesVATReduced(), CreateDEGLAccount.PurchaseVATReduced(), VAT7(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', '', '', false);
        ContosoPostingSetup.SetOverwriteData(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVATPostingSetup(var Rec: Record "VAT Posting Setup")
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        UpdateAdjustforPaymentDiscountOnGeneralLedgerSetup();

        case Rec."VAT Bus. Posting Group" of
            CreateVATPostingGroups.Domestic(),
            CreateVATPostingGroups.EU(),
            CreateVATPostingGroups.Export(),
            '':
                Rec.Validate("Adjust for Payment Discount", false);
        end;
    end;

    local procedure UpdateAdjustforPaymentDiscountOnGeneralLedgerSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        GeneralLedgerSetup.Get();

        if not GeneralLedgerSetup."Adjust for Payment Disc." then
            exit;

        if VATPostingSetup.Get('', '') then begin
            VATPostingSetup.Validate("Adjust for Payment Discount", false);
            VATPostingSetup.Modify(true);

            GeneralLedgerSetup.Validate("Adjust for Payment Disc.", false);
            GeneralLedgerSetup.Modify(true);
        end;
    end;

    procedure InsertVATProductPostingGroup()
    var
        CreateDEPostingGroups: Codeunit "Create DE Posting Groups";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateDEGLAcc: Codeunit "Create DE GL Acc.";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoPostingGroup.InsertVATProductPostingGroup(EUPostingGroupST(), EUPostingGroupSTLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(Min19(), StrSubstNo(MinderungDescriptionLbl, '19%'));
        ContosoPostingGroup.InsertVATProductPostingGroup(Min7(), StrSubstNo(MinderungDescriptionLbl, '7%'));
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT7(), StrSubstNo(MiscellaneousVATLbl, '7'));
        ContosoPostingGroup.InsertVATProductPostingGroup(NoVAT(), MiscellaneousNoVATLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT19(), StrSubstNo(MiscellaneousVATLbl, '19'));

        CreateDEPostingGroups.UpdateVATProdPostingGroup(CreatePostingGroups.FreightPostingGroup(), VAT19());
        CreateDEPostingGroups.UpdateVATProdPostingGroup(CreatePostingGroups.RawMatPostingGroup(), VAT19());
        CreateDEPostingGroups.UpdateVATProdPostingGroup(CreatePostingGroups.MiscPostingGroup(), VAT19());
        CreateDEPostingGroups.UpdateVATProdPostingGroup(CreatePostingGroups.ServicesPostingGroup(), VAT7());
        CreateDEPostingGroups.UpdateVATProdPostingGroup(CreatePostingGroups.RetailPostingGroup(), VAT19());
        CreateDEPostingGroups.UpdateVATProdPostingGroup(CreateDEPostingGroups.NoVATPostingGroup(), NOVAT());

        UpdateVATProductPostingGroupOnGLAccount(CreateDEGLAcc.MiscVATPayables(), VAT19());
        UpdateVATProductPostingGroupOnGLAccount(CreateDEGLAcc.Incomefromsecurities(), VAT19());
        UpdateVATProductPostingGroupOnGLAccount(CreateGLAccount.InterestIncome(), VAT19());
        UpdateVATProductPostingGroupOnGLAccount(CreateDEGLAcc.SaleofFinishedGoods(), VAT19());
        UpdateVATProductPostingGroupOnGLAccount(CreateDEGLAcc.SaleofRawMaterials(), VAT19());
        UpdateVATProductPostingGroupOnGLAccount(CreateDEGLAcc.ResaleofGoods(), VAT19());
        UpdateVATProductPostingGroupOnGLAccount(CreateDEGLAcc.SaleofResources(), VAT7());
        UpdateVATProductPostingGroupOnGLAccount(CreateDEGLAcc.SaleofSubcontracting(), VAT7());
        UpdateVATProductPostingGroupOnGLAccount(CreateDEGLAcc.SalesofServiceContracts(), VAT7());
        UpdateVATProductPostingGroupOnGLAccount(CreateDEGLAcc.PayableInvoiceRounding(), VAT19());

    end;

    local procedure UpdateVATProductPostingGroupOnGLAccount(GLAccountNo: Code[20]; VATProductPostingGroup: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        if not GLAccount.Get(GLAccountNo) then
            exit;

        GLAccount.Validate("VAT Prod. Posting Group", VATProductPostingGroup);
        GLAccount.Modify(true);
    end;

    procedure NOVAT(): Code[20]
    begin
        exit(NoVATTok);
    end;

    procedure VAT19(): Code[20]
    begin
        exit(VAT19Tok);
    end;

    procedure VAT7(): Code[20]
    begin
        exit(VAT7Tok);
    end;

    procedure Zero(): Code[20]
    begin
        exit(ZeroTok);
    end;

    procedure EUPostingGroupST(): Code[20]
    begin
        exit(EUSTTok);
    end;

    procedure Min19(): Code[20]
    begin
        exit(Min19Tok);
    end;

    procedure Min7(): Code[20]
    begin
        exit(Min7Tok);
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

    procedure FullNormal(): Code[20]
    begin
        exit(FullNormalTok);
    end;

    var
        NoVATTok: Label 'NO VAT', MaxLength = 20, Locked = true;
        VAT19Tok: Label 'VAT19', MaxLength = 20, Locked = true;
        VAT7Tok: Label 'VAT7', MaxLength = 20, Locked = true;
        ZeroTok: Label 'ZERO', MaxLength = 20, Locked = true;
        EUSTTok: Label 'EUST', MaxLength = 20, Locked = true;
        Min19Tok: Label 'MIN19', MaxLength = 20, Locked = true;
        Min7Tok: Label 'MIN7', MaxLength = 20, Locked = true;
        ReducedTok: Label 'REDUCED', MaxLength = 20, Locked = true;
        ServRedTok: Label 'SERV RED', MaxLength = 20, Locked = true;
        ServNormTok: Label 'SERV NORM', MaxLength = 20, Locked = true;
        FullNormalTok: Label 'FULL NORMAL', MaxLength = 20, Locked = true;
        MiscellaneousVATLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage';
        EUPostingGroupSTLbl: Label 'Einfuhrumsatzsteuer', MaxLength = 100;
        MiscellaneousNoVATLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
        MinderungDescriptionLbl: Label 'Minderung %1', Comment = '%1= a number specifying the VAT Percentage';
}