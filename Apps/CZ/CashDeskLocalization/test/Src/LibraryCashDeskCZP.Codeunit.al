codeunit 148001 "Library - Cash Desk CZP"
{
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibraryCashDocumentCZP: Codeunit "Library - Cash Document CZP";

    procedure CreateCashDeskCZP(var CashDeskCZP: Record "Cash Desk CZP")
    begin
        CashDeskCZP.Init();
        CashDeskCZP."No." := '';
        CashDeskCZP.Insert(true);
        CashDeskCZP.Name := CashDeskCZP."No.";
        CashDeskCZP.Modify(true);
    end;

    procedure SetupCashDeskCZP(var CashDeskCZP: Record "Cash Desk CZP"; ConfirmDocumentInserting: Boolean)
    begin
        CashDeskCZP."Confirm Inserting of Document" := ConfirmDocumentInserting;
        CashDeskCZP."Bank Acc. Posting Group" := CreateBankAccPostingGroupCode();
        CashDeskCZP."Debit Rounding Account" := LibraryCashDocumentCZP.GetNewGLAccountNo(false);
        CashDeskCZP."Credit Rounding Account" := LibraryCashDocumentCZP.GetNewGLAccountNo(false);
        CashDeskCZP."Rounding Method Code" := CreateRoundingMethod();
        CashDeskCZP."Cash Receipt Limit" := 100000;
        CashDeskCZP."Cash Withdrawal Limit" := 100000;
        CashDeskCZP."Max. Balance" := 1000000;
        CashDeskCZP."Min. Balance" := 10;
        CashDeskCZP."Cash Document Receipt Nos." := LibraryUtility.GetGlobalNoSeriesCode();
        CashDeskCZP."Cash Document Withdrawal Nos." := LibraryUtility.GetGlobalNoSeriesCode();
        CashDeskCZP.Modify(true);
    end;

    procedure CreateCashDeskEventCZP(var CashDeskEventCZP: Record "Cash Desk Event CZP"; CashDeskNo: Code[20]; CashDocType: Enum "Cash Document Type CZP";
                                        AccountType: Enum "Cash Document Account Type CZP"; AccountNo: Code[20])
    begin
        CashDeskEventCZP.Init();
        CashDeskEventCZP.Validate(Code, LibraryUtility.GenerateRandomCode(CashDeskEventCZP.FieldNo(Code), Database::"Cash Desk Event CZP"));
        CashDeskEventCZP.Insert(true);

        CashDeskEventCZP.Validate("Cash Desk No.", CashDeskNo);
        CashDeskEventCZP.Validate("Document Type", CashDocType);
        CashDeskEventCZP.Validate("Account Type", AccountType);
        CashDeskEventCZP.Validate("Account No.", AccountNo);
        CashDeskEventCZP.Modify(true);
    end;

    procedure CreateCashDeskUserCZP(var CashDeskUserCZP: Record "Cash Desk User CZP"; CashDeskNo: Code[20]; Create: Boolean; Issue: Boolean; Post: Boolean)
    begin
        if not CashDeskUserCZP.Get(CashDeskNo, UserId) then begin
            CashDeskUserCZP.Init();
            CashDeskUserCZP.Validate("Cash Desk No.", CashDeskNo);
            CashDeskUserCZP."User ID" := CopyStr(UserId(), 1, MaxStrLen(CashDeskUserCZP."User ID"));
            CashDeskUserCZP.Insert(true);
        end;
        CashDeskUserCZP.Validate(Create, Create);
        CashDeskUserCZP.Validate(Issue, Issue);
        CashDeskUserCZP.Validate(Post, Post);
        CashDeskUserCZP.Modify(true);
    end;

    local procedure CreateRoundingMethod(): Code[10]
    var
        RoundingMethod: Record "Rounding Method";
    begin
        RoundingMethod.Init();
        RoundingMethod.Code := LibraryUtility.GenerateRandomCode(RoundingMethod.FieldNo(Code), Database::"Rounding Method");
        RoundingMethod.Insert(true);
        RoundingMethod."Minimum Amount" := 0;
        RoundingMethod."Amount Added Before" := 0;
        RoundingMethod.Type := RoundingMethod.Type::Nearest;
        RoundingMethod.Precision := 1;
        RoundingMethod."Amount Added After" := 0;
        RoundingMethod.Modify(true);
        exit(RoundingMethod.Code)
    end;

    local procedure CreateBankAccPostingGroupCode(): Code[20]
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
    begin
        LibraryERM.CreateBankAccountPostingGroup(BankAccountPostingGroup);
        BankAccountPostingGroup."G/L Account No." := LibraryCashDocumentCZP.GetNewGLAccountNo(false);
        BankAccountPostingGroup.Modify(true);
        exit(BankAccountPostingGroup.Code);
    end;

    procedure PrintCashDeskBook(ShowRequestPage: Boolean; var CashDeskCZP: Record "Cash Desk CZP")
    begin
        Report.RunModal(Report::"Cash Desk Book CZP", ShowRequestPage, false, CashDeskCZP);
    end;
}
