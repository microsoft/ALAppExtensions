codeunit 148002 "Library - Cash Document CZP"
{
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        LibraryCashDeskCZP: Codeunit "Library - Cash Desk CZP";

    procedure GetNewGLAccountNo(WithVATPostingSetup: Boolean): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        CreateGLAccount(GLAccount, WithVATPostingSetup);
        exit(GLAccount."No.");
    end;

    procedure GetExistGLAccountNo(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        FindGLAccount(GLAccount);
        exit(GLAccount."No.");
    end;

    local procedure FindGLAccount(var GLAccount: Record "G/L Account")
    begin
        LibraryERM.FindGLAccount(GLAccount);
    end;

    procedure CreateGLAccount(var GLAccount: Record "G/L Account"; WithVATPostingSetup: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        GLAccountNo: Code[20];
    begin
        if not WithVATPostingSetup then
            LibraryERM.CreateGLAccount(GLAccount)
        else begin
            LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
            GLAccountNo := LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, GLAccount."Gen. Posting Type"::Purchase);
            GLAccount.Get(GLAccountNo);
        end;
    end;

    local procedure CreateFixedAsset(var FixedAsset: Record "Fixed Asset")
    var
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
    begin
        LibraryFixedAsset.CreateFixedAsset(FixedAsset);
        CreateDepreciationBook(DepreciationBook);
        CreateFAPostingGroup(FAPostingGroup);
        LibraryFixedAsset.CreateFADepreciationBook(FADepreciationBook, FixedAsset."No.", DepreciationBook.Code);
        FADepreciationBook.Validate("FA Posting Group", FAPostingGroup.Code);
        FADepreciationBook.Validate("Default FA Depreciation Book", true);
        FADepreciationBook.Modify(true);
    end;

    local procedure CreateFAPostingGroup(var FAPostingGroup: Record "FA Posting Group")
    begin
        LibraryFixedAsset.CreateFAPostingGroup(FAPostingGroup);
        FAPostingGroup."Acquisition Cost Account" := GetExistGLAccountNo();
        FAPostingGroup."Accum. Depreciation Account" := GetExistGLAccountNo();
        FAPostingGroup."Acq. Cost Acc. on Disposal" := GetExistGLAccountNo();
        FAPostingGroup."Accum. Depr. Acc. on Disposal" := GetExistGLAccountNo();
        FAPostingGroup."Gains Acc. on Disposal" := GetExistGLAccountNo();
        FAPostingGroup."Losses Acc. on Disposal" := GetExistGLAccountNo();
        FAPostingGroup."Maintenance Expense Account" := GetExistGLAccountNo();
        FAPostingGroup."Depreciation Expense Acc." := GetExistGLAccountNo();
        FAPostingGroup.Modify(true);
    end;

    local procedure CreateDepreciationBook(var DepreciationBook: Record "Depreciation Book")
    begin
        LibraryFixedAsset.CreateDepreciationBook(DepreciationBook);
        DepreciationBook.Validate("G/L Integration - Acq. Cost", true);
        DepreciationBook.Modify(true);
    end;

    procedure GetNewFixedAssetNo(): Code[20]
    var
        FixedAsset: Record "Fixed Asset";
    begin
        CreateFixedAsset(FixedAsset);
        exit(FixedAsset."No.");
    end;

    procedure CreatePaymentMethod(var PaymentMethod: Record "Payment Method"; CashDeskCode: Code[20]; CashDocumentActionCZP: Enum "Cash Document Action CZP")
    begin
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        PaymentMethod."Cash Desk Code CZP" := CashDeskCode;
        PaymentMethod."Cash Document Action CZP" := CashDocumentActionCZP;
        PaymentMethod.Modify();
    end;

    procedure CreateCashDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP";
                                        CashDocType: Enum "Cash Document Type CZP"; CashDeskNo: Code[20])
    var
        AccountType: Enum "Cash Document Account Type CZP";
    begin
        CreateCashDocumentHeaderCZP(CashDocumentHeaderCZP, CashDocType, CashDeskNo);
        CreateCashDocumentLineCZP(CashDocumentLineCZP, CashDocumentHeaderCZP, AccountType::"G/L Account", GetNewGLAccountNo(true), 0);
        CashDocumentLineCZP.Validate(Amount, GetLineAmount(CashDocType, CashDocumentLineCZP));
        CashDocumentLineCZP.Modify();
    end;

    procedure CreateCashDocumentWithEvent(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP";
                                            CashDocType: Enum "Cash Document Type CZP"; CashDeskNo: Code[20])
    var
        CashDeskEventCZP: Record "Cash Desk Event CZP";
    begin
        CreateCashDocumentHeaderCZP(CashDocumentHeaderCZP, CashDocType, CashDeskNo);
        LibraryCashDeskCZP.CreateCashDeskEventCZP(CashDeskEventCZP, CashDeskNo, CashDocType, CashDeskEventCZP."Account Type"::"G/L Account", GetNewGLAccountNo(false));
        CreateCashDocumentLineCZPWithCashDeskEvent(CashDocumentLineCZP, CashDocumentHeaderCZP, CashDeskEventCZP.Code, 0);
        CashDocumentLineCZP.Validate(Amount, GetLineAmount(CashDocType, CashDocumentLineCZP));
        CashDocumentLineCZP.Modify();
    end;

    procedure CreateCashDocumentWithFixedAsset(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP";
                                                        CashDocType: Enum "Cash Document Type CZP"; CashDeskNo: Code[20])
    begin
        CreateCashDocumentHeaderCZP(CashDocumentHeaderCZP, CashDocType, CashDeskNo);
        CreateCashDocumentLineCZP(CashDocumentLineCZP, CashDocumentHeaderCZP, CashDocumentLineCZP."Account Type"::"Fixed Asset", GetNewFixedAssetNo(), 0);
        CashDocumentLineCZP.Validate(Amount, GetLineAmount(CashDocType, CashDocumentLineCZP));
        CashDocumentLineCZP.Validate("FA Posting Type", CashDocumentLineCZP."FA Posting Type"::"Acquisition Cost");
        CashDocumentLineCZP.Modify(true);
    end;

    local procedure GetLineAmount(CashDocType: Enum "Cash Document Type CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP"): Decimal
    var
        CashDeskCZP: Record "Cash Desk CZP";
        CashLimit: Decimal;
    begin
        CashDeskCZP.Get(CashDocumentLineCZP."Cash Desk No.");
        case CashDocType of
            CashDocType::Receipt:
                CashLimit := CashDeskCZP."Cash Receipt Limit";
            CashDocType::Withdrawal:
                CashLimit := CashDeskCZP."Cash Withdrawal Limit";
        end;
        exit(Round(CashLimit * (100 - CashDocumentLineCZP."VAT %") / 100, 1, '<'));
    end;

    procedure CreateCashDocumentHeaderCZP(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; CashDocType: Enum "Cash Document Type CZP"; CashDeskNo: Code[20])
    begin
        Clear(CashDocumentHeaderCZP);
        CashDocumentHeaderCZP.Validate("Cash Desk No.", CashDeskNo);
        CashDocumentHeaderCZP.Validate("Document Type", CashDocType);
        CashDocumentHeaderCZP.Insert(true);
        CashDocumentHeaderCZP."Payment Purpose" := CashDocumentHeaderCZP."No.";
        CashDocumentHeaderCZP.Modify(true);
    end;

    procedure CreateCashDocumentLineCZP(var CashDocumentLineCZP: Record "Cash Document Line CZP"; CashDocumentHeaderCZP: Record "Cash Document Header CZP";
                                        AccountType: Enum "Cash Document Account Type CZP"; AccountNo: Code[20]; LineAmount: Decimal)
    begin
        InsertCashDocumentLineCZP(CashDocumentLineCZP, CashDocumentHeaderCZP);
        CashDocumentLineCZP.Validate("Account Type", AccountType);
        CashDocumentLineCZP.Validate("Account No.", AccountNo);
        if LineAmount <> 0 then
            CashDocumentLineCZP.Validate(Amount, LineAmount);
        CashDocumentLineCZP.Modify(true);
    end;

    procedure CreateCashDocumentLineCZPWithCashDeskEvent(var CashDocumentLineCZP: Record "Cash Document Line CZP"; CashDocumentHeaderCZP: Record "Cash Document Header CZP";
                                                        CashDeskEventCode: Code[10]; LineAmount: Decimal)
    var
        CashDocumentCZP: TestPage "Cash Document CZP";
    begin
        CashDocumentCZP.OpenEdit(); // created through the TestPage for validation Cash Desk Event
        CashDocumentCZP.Filter.SetFilter("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
        CashDocumentCZP.Filter.SetFilter("No.", CashDocumentHeaderCZP."No.");
        CashDocumentCZP.CashDocLines.Last();
        CashDocumentCZP.CashDocLines.Next();
        CashDocumentCZP.CashDocLines."Cash Desk Event".SetValue(CashDeskEventCode);
        if LineAmount <> 0 then
            CashDocumentCZP.CashDocLines.Amount.SetValue(LineAmount);
        CashDocumentCZP.OK().Invoke();
        CashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
        CashDocumentLineCZP.FindLast();
        CashDocumentLineCZP.Reset();
    end;

    local procedure InsertCashDocumentLineCZP(var CashDocumentLineCZP: Record "Cash Document Line CZP"; CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        RecordRef: RecordRef;
    begin
        Clear(CashDocumentLineCZP);
        CashDocumentLineCZP.Validate("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
        CashDocumentLineCZP.Validate("Cash Document No.", CashDocumentHeaderCZP."No.");
        RecordRef.GetTable(CashDocumentLineCZP);
        CashDocumentLineCZP.Validate("Line No.", LibraryUtility.GetNewLineNo(RecordRef, CashDocumentLineCZP.FieldNo("Line No.")));
        CashDocumentLineCZP.Insert(true);
    end;

    procedure ReleaseCashDocumentCZP(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        Codeunit.Run(Codeunit::"Cash Document-Release CZP", CashDocumentHeaderCZP);
    end;

    procedure PostCashDocumentCZP(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        Codeunit.Run(Codeunit::"Cash Document-Post(Yes/No) CZP", CashDocumentHeaderCZP);
    end;

    procedure PrintCashDocumentCZP(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; ShowRequestPage: Boolean)
    var
        PrintedCashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        PrintedCashDocumentHeaderCZP := CashDocumentHeaderCZP;
        PrintedCashDocumentHeaderCZP.SetRecFilter();
        PrintedCashDocumentHeaderCZP.PrintRecords(ShowRequestPage);
    end;

    procedure PrintPostedCashDocumentCZP(var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; ShowRequestPage: Boolean)
    var
        PrintedPostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
    begin
        PrintedPostedCashDocumentHdrCZP := PostedCashDocumentHdrCZP;
        PrintedPostedCashDocumentHdrCZP.SetRecFilter();
        PrintedPostedCashDocumentHdrCZP.PrintRecords(ShowRequestPage);
    end;
}
