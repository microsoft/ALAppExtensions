#pragma warning disable AA0247
codeunit 31340 "Contoso Cash Desk CZP"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Cash Desk CZP" = rim,
        tabledata "Cash Desk Event CZP" = rim,
        tabledata "Cash Document Header CZP" = rim,
        tabledata "Cash Document Line CZP" = rim,
        tabledata "Currency Nominal Value CZP" = rim,
        tabledata "Rounding Method" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertCashDesk(No: Code[20]; Name: Text[100]; BankAccPostingGroup: Code[20]; RoundingMethodCode: Code[10]; DebitRoundingAccount: Code[20]; CreditRoudingAccount: Code[20]; MaxBalance: Decimal; CashReceiptLimit: Decimal; CashWithdrawalLimit: Decimal; CashDocumentReceiptNos: Code[20]; CashDocumentWithdrawalNos: Code[20])
    var
        CashDeskCZP: Record "Cash Desk CZP";
        Exists: Boolean;
    begin
        if CashDeskCZP.Get(No) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CashDeskCZP.Validate("No.", No);
        CashDeskCZP.Validate(Name, Name);
        CashDeskCZP.Validate("Bank Acc. Posting Group", BankAccPostingGroup);
        CashDeskCZP.Validate("Rounding Method Code", RoundingMethodCode);
        CashDeskCZP.Validate("Debit Rounding Account", DebitRoundingAccount);
        CashDeskCZP.Validate("Credit Rounding Account", CreditRoudingAccount);
        CashDeskCZP.Validate("Max. Balance", MaxBalance);
        CashDeskCZP.Validate("Cash Receipt Limit", CashReceiptLimit);
        CashDeskCZP.Validate("Cash Withdrawal Limit", CashWithdrawalLimit);
        CashDeskCZP.Validate("Cash Document Receipt Nos.", CashDocumentReceiptNos);
        CashDeskCZP.Validate("Cash Document Withdrawal Nos.", CashDocumentWithdrawalNos);

        if Exists then
            CashDeskCZP.Modify(true)
        else
            CashDeskCZP.Insert(true);
    end;

    procedure InsertCashDeskEvent(Code: Code[10]; Description: Text[50]; CashDocumentType: Enum "Cash Document Type CZP"; AccountType: Enum "Cash Document Account Type CZP"; AccountNo: Code[20]; GenPostingType: Option; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; GenDocumentType: Enum "Cash Document Gen.Doc.Type CZP"; EETTransaction: Boolean)
    var
        CashDeskEventCZP: Record "Cash Desk Event CZP";
        Exists: Boolean;
    begin
        if CashDeskEventCZP.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CashDeskEventCZP.Validate(Code, Code);
        CashDeskEventCZP.Validate(Description, Description);
        CashDeskEventCZP.Validate("Document Type", CashDocumentType);
        CashDeskEventCZP.Validate("Account Type", AccountType);
        CashDeskEventCZP.Validate("Account No.", AccountNo);
        CashDeskEventCZP.Validate("Gen. Posting Type", GenPostingType);
        CashDeskEventCZP.Validate("Gen. Document Type", GenDocumentType);
        CashDeskEventCZP.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        CashDeskEventCZP.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        CashDeskEventCZP.Validate("EET Transaction", EETTransaction);

        if Exists then
            CashDeskEventCZP.Modify(true)
        else
            CashDeskEventCZP.Insert(true);
    end;

    procedure InsertCashDocumentHeader(CashDeskNo: Code[20]; CashDocumentType: Enum "Cash Document Type CZP"; PostingDate: Date; PaymentPurpose: Text[100]): Record "Cash Document Header CZP"
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        CashDocumentHeaderCZP.Validate("Document Type", CashDocumentType);
        CashDocumentHeaderCZP.Validate("Cash Desk No.", CashDeskNo);
        CashDocumentHeaderCZP.Validate("No.", '');
        CashDocumentHeaderCZP.Insert(true);

        CashDocumentHeaderCZP.Validate("Posting Date", PostingDate);
        CashDocumentHeaderCZP.Validate("Payment Purpose", PaymentPurpose);
        CashDocumentHeaderCZP.Modify(true);

        exit(CashDocumentHeaderCZP);
    end;

    procedure InsertCashDocumentLine(CashDocumentHeaderCZP: Record "Cash Document Header CZP"; CashDeskEvent: Code[10]; Amount: Decimal; Description: Text[100])
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        CashDocumentLineCZP.Validate("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
        CashDocumentLineCZP.Validate("Cash Document No.", CashDocumentHeaderCZP."No.");
        CashDocumentLineCZP.Validate("Line No.", GetNextCashDocumentLineNo(CashDocumentHeaderCZP));
        CashDocumentLineCZP.Insert(true);

        CashDocumentLineCZP.Validate("Cash Desk Event", CashDeskEvent);
        CashDocumentLineCZP.Validate(Description, Description);
        CashDocumentLineCZP.Validate(Amount, Amount);
        CashDocumentLineCZP.Modify(true);
    end;

    procedure InsertRoundingMethod(Code: Code[10]; MinimumAmount: Decimal; Precision: Decimal; Type: Option)
    var
        RoundingMethod: Record "Rounding Method";
        Exists: Boolean;
    begin
        if RoundingMethod.Get(Code, MinimumAmount) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        RoundingMethod.Validate(Code, Code);
        RoundingMethod.Validate("Minimum Amount", MinimumAmount);
        RoundingMethod.Validate(Precision, Precision);
        RoundingMethod.Validate(Type, Type);

        if Exists then
            RoundingMethod.Modify(true)
        else
            RoundingMethod.Insert(true);
    end;

    procedure InsertCurrencyNominalValue(CurrencyCode: Code[10]; NominalValue: Decimal)
    var
        CurrencyNominalValueCZP: Record "Currency Nominal Value CZP";
        Exists: Boolean;
    begin
        if CurrencyNominalValueCZP.Get(CurrencyCode, NominalValue) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CurrencyNominalValueCZP.Validate("Currency Code", CurrencyCode);
        CurrencyNominalValueCZP.Validate("Nominal Value", NominalValue);

        if Exists then
            CurrencyNominalValueCZP.Modify(true)
        else
            CurrencyNominalValueCZP.Insert(true);
    end;

    local procedure GetNextCashDocumentLineNo(CashDocumentHeaderCZP: Record "Cash Document Header CZP"): Integer
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        CashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
        CashDocumentLineCZP.SetCurrentKey("Line No.");

        if CashDocumentLineCZP.FindLast() then
            exit(CashDocumentLineCZP."Line No." + 10000)
        else
            exit(10000);
    end;
}
