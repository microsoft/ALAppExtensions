codeunit 11365 "Create VAT Posting Group BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertVATProductPostingGroup();
        InsertVATBusinessPostingGroups();
    end;

    procedure CreateVATPostingSetup()
    var
        ContosoPostingSetup: codeunit "Contoso Posting Setup";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateBEGLAccount: Codeunit "Create GL Account BE";
        CreatePostingGroup: codeunit "Create Posting Groups";
        CreateGLAccountBE: Codeunit "Create GL Account BE";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup(CC(), S0(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S0(), 0, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CC(), S1(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S1(), 6, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CC(), S3(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S3(), 21, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);

        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), G0(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G0(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), G1(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G1(), 6, Enum::"Tax Calculation Type"::"Normal VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), G2(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G2(), 12, Enum::"Tax Calculation Type"::"Normal VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), G3(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G3(), 21, Enum::"Tax Calculation Type"::"Normal VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), I0(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), I0(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), I3(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), I3(), 21, Enum::"Tax Calculation Type"::"Normal VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), S0(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S0(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), S1(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S1(), 6, Enum::"Tax Calculation Type"::"Normal VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), S3(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S3(), 21, Enum::"Tax Calculation Type"::"Normal VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.DomesticPostingGroup(), VAT(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), VAT(), 0, Enum::"Tax Calculation Type"::"Full VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);

        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), G0(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G0(), 0, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), G1(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G1(), 6, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), G2(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G2(), 12, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), G3(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G3(), 21, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), I0(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), I0(), 0, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), I3(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), I3(), 21, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), S0(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S0(), 0, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), S1(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S1(), 6, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.EUPostingGroup(), S3(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S3(), 21, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);

        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), G0(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G0(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), G1(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G1(), 10, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), G2(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G2(), 20, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), G3(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G3(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), I0(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), I0(), 10, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), I3(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), I3(), 20, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), S0(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S0(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), S1(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S1(), 10, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(CreatePostingGroup.ExportPostingGroup(), S3(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S3(), 20, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);

        ContosoPostingSetup.InsertVATPostingSetup(IMPREV(), G0(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G0(), 0, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(IMPREV(), G1(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G1(), 6, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(IMPREV(), G2(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G2(), 12, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(IMPREV(), G3(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G3(), 21, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(IMPREV(), I0(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), I0(), 0, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(IMPREV(), I3(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), I3(), 21, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(IMPREV(), S0(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S0(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(IMPREV(), S1(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S1(), 6, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(IMPREV(), S3(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S3(), 21, Enum::"Tax Calculation Type"::"Reverse Charge VAT", 'S', CreateGLAccountBE.VatRecoverable(), '', false);

        ContosoPostingSetup.InsertVATPostingSetup(IMPEXP(), G0(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G0(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(IMPEXP(), G1(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G1(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(IMPEXP(), G2(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G2(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(IMPEXP(), G3(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), G3(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(IMPEXP(), I0(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), I0(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(IMPEXP(), I3(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), I3(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(IMPEXP(), S0(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S0(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(IMPEXP(), S1(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S1(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.InsertVATPostingSetup(IMPEXP(), S3(), CreateGLAccount.VATPayable(), CreateBEGLAccount.VatRecoverable(), S3(), 0, Enum::"Tax Calculation Type"::"Normal VAT", 'E', CreateGLAccountBE.VatRecoverable(), '', false);
        ContosoPostingSetup.SetOverwriteData(false);

        UpdateReverseChrgVATAcc();
    end;

    local procedure InsertVATProductPostingGroup()
    var
        ContosoPostingGroup: codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertVATProductPostingGroup(G0(), StrSubstNo(GoodsVATLbl, 'No'));
        ContosoPostingGroup.InsertVATProductPostingGroup(G1(), StrSubstNo(GoodsVATLbl, '6%'));
        ContosoPostingGroup.InsertVATProductPostingGroup(G2(), StrSubstNo(GoodsVATLbl, '12%'));
        ContosoPostingGroup.InsertVATProductPostingGroup(G3(), StrSubstNo(GoodsVATLbl, '21%'));
        ContosoPostingGroup.InsertVATProductPostingGroup(I0(), StrSubstNo(InvestmentVATLbl, '0%'));
        ContosoPostingGroup.InsertVATProductPostingGroup(I3(), StrSubstNo(InvestmentVATLbl, '21%'));
        ContosoPostingGroup.InsertVATProductPostingGroup(S0(), ServicesNoVATLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(S1(), StrSubstNo(ServicesVATLbl, '6%'));
        ContosoPostingGroup.InsertVATProductPostingGroup(S3(), StrSubstNo(ServicesVATLbl, '21%'));
        ContosoPostingGroup.InsertVATProductPostingGroup(NoVAT(), MiscellaneousNoVATLbl);
        ContosoPostingGroup.InsertVATProductPostingGroup(VAT(), VATDescLbl);
    end;

    local procedure InsertVATBusinessPostingGroups()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
    begin
        ContosoPostingGroup.InsertVATBusinessPostingGroup(CC(), CocontractorLbl);
        ContosoPostingGroup.InsertVATBusinessPostingGroup(IMPREV(), ImportReverseChargeLbl);
        ContosoPostingGroup.InsertVATBusinessPostingGroup(IMPEXP(), ImportExportLbl);
    end;

    local procedure UpdateReverseChrgVATAcc()
    var
        VatPostingSetup: Record "VAT Posting Setup";
        CreateGLAccountBE: Codeunit "Create GL Account BE";
    begin
        if VatPostingSetup.FindSet() then
            repeat
                VatPostingSetup.Validate("Reverse Chrg. VAT Acc.", CreateGLAccountBE.VatRecoverable());
                VatPostingSetup.Modify(true);
            until VatPostingSetup.Next() = 0;
    end;

    procedure NOVAT(): Code[20]
    begin
        exit(NoVATTok);
    end;

    procedure G0(): Code[20]
    begin
        exit(G0Tok);
    end;

    procedure G1(): Code[20]
    begin
        exit(G1Tok);
    end;

    procedure G2(): Code[20]
    begin
        exit(G2Tok);
    end;

    procedure G3(): Code[20]
    begin
        exit(G3Tok);
    end;

    procedure I0(): Code[20]
    begin
        exit(I0Tok);
    end;

    procedure I3(): Code[20]
    begin
        exit(I3Tok);
    end;

    procedure S0(): Code[20]
    begin
        exit(S0Tok);
    end;

    procedure S1(): Code[20]
    begin
        exit(S1Tok);
    end;

    procedure S3(): Code[20]
    begin
        exit(S3Tok);
    end;

    procedure VAT(): Code[20]
    begin
        exit(VATTok);
    end;

    procedure CC(): Code[20]
    begin
        exit(CCTok);
    end;

    procedure IMPREV(): Code[20]
    begin
        exit(IMPREVTok);
    end;

    procedure IMPEXP(): Code[20]
    begin
        exit(IMPEXPTok);
    end;

    var
        NoVATTok: Label 'NO VAT', MaxLength = 20, Locked = true;
        G0Tok: Label 'G0', MaxLength = 20, Locked = true;
        G1Tok: Label 'G1', MaxLength = 20, Locked = true;
        G2Tok: Label 'G2', MaxLength = 20, Locked = true;
        G3Tok: Label 'G3', MaxLength = 20, Locked = true;
        I0Tok: Label 'I0', MaxLength = 20, Locked = true;
        I3Tok: Label 'I3', MaxLength = 20, Locked = true;
        S0Tok: Label 'S0', MaxLength = 20, Locked = true;
        S1Tok: Label 'S1', MaxLength = 20, Locked = true;
        S3Tok: Label 'S3', MaxLength = 20, Locked = true;
        VATTok: Label 'VAT', MaxLength = 20, Locked = true;
        CCTok: Label 'CC', MaxLength = 20, Locked = true;
        IMPREVTok: Label 'IMPREV', MaxLength = 20, Locked = true;
        IMPEXPTok: Label 'IMPEXP', MaxLength = 20, Locked = true;
        InvestmentVATLbl: Label 'Investments %1 VAT', Comment = '%1=a number specifying the VAT percentage';
        GoodsVATLbl: Label 'Goods %1 VAT', Comment = '%1=a number specifying the VAT percentage';
        ServicesVATLbl: Label 'Services %1 VAT', Comment = '%1=a number specifying the VAT percentage';
        ServicesNoVATLbl: Label 'Services No VAT', MaxLength = 100;
        VATDescLbl: Label 'Only VAT', MaxLength = 100;
        CocontractorLbl: Label 'Cocontractor', MaxLength = 100;
        ImportReverseChargeLbl: Label 'Import Reverse Charge VAT', MaxLength = 100;
        ImportExportLbl: Label 'Other customers and vendors (not EU)', MaxLength = 100;
        MiscellaneousNoVATLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
}