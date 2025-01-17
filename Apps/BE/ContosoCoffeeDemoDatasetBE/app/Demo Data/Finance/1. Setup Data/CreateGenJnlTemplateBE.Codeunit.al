codeunit 11362 "Create Gen. Jnl Template BE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoGeneralLedger: Codeunit "Contoso General Ledger";
        CreateNoSeriesBE: Codeunit "Create No. Series BE";
        CreateNoSeries: Codeunit "Create No. Series";
    begin
        ContosoGeneralLedger.InsertGeneralJournalTemplate(NBL(), NBLLbl, Enum::"Gen. Journal Template Type"::Financial, Page::"Financial Journal", '', false);
        ContosoGeneralLedger.InsertGeneralJournalTemplate(Purchase(), PurchaseLbl, Enum::"Gen. Journal Template Type"::Purchases, Page::"Purchase Journal", CreateNoSeriesBE.PurchaseJournal(), false);
        ContosoGeneralLedger.InsertGeneralJournalTemplate(PurchCreditMemo(), PurchCreditMemoLbl, Enum::"Gen. Journal Template Type"::Purchases, Page::"Purchase Journal", CreateNoSeriesBE.PurchaseCreditMemoJnl(), false);
        ContosoGeneralLedger.InsertGeneralJournalTemplate(Sales(), SalesLbl, Enum::"Gen. Journal Template Type"::Sales, Page::"Sales Journal", CreateNoSeriesBE.SalesJournal(), false);
        ContosoGeneralLedger.InsertGeneralJournalTemplate(SalesCreditMemo(), SalesCreditMemoLbl, Enum::"Gen. Journal Template Type"::Sales, Page::"Sales Journal", CreateNoSeriesBE.SalesCreditMemoJnl(), false);

        UpdateGeneralJournalTemplate(Purchase(), CreateNoSeries.PostedPurchaseInvoice());
        UpdateGeneralJournalTemplate(PurchCreditMemo(), CreateNoSeries.PostedPurchaseCreditMemo());
        UpdateGeneralJournalTemplate(Sales(), CreateNoSeries.PostedSalesInvoice());
        UpdateGeneralJournalTemplate(SalesCreditMemo(), CreateNoSeries.PostedSalesCreditMemo());
    end;

    procedure UpdateGenJnlTemplate()
    var
        CreateBankAccountBE: Codeunit "Create Bank Account BE";
    begin
        ValidateGenJnlTemplate(NBL(), Enum::"Gen. Journal Account Type"::"Bank Account", CreateBankAccountBE.NBLBank());
    end;

    local procedure ValidateGenJnlTemplate(TemplateName: Code[10]; BalAccountType: Enum "Gen. Journal Account Type"; BankAccountNo: Code[20])
    var
        GenJnlTemplate: Record "Gen. Journal Template";
    begin
        if GenJnlTemplate.Get(TemplateName) then begin
            GenJnlTemplate.Validate("Bal. Account Type", BalAccountType);
            GenJnlTemplate.Validate("Bal. Account No.", BankAccountNo);
            GenJnlTemplate.Modify(true);
        end;
    end;

    local procedure UpdateGeneralJournalTemplate(TemplateName: Code[10]; PostingNoSeries: Code[20])
    var
        GenJnlTemplate: Record "Gen. Journal Template";
    begin
        if not GenJnlTemplate.Get(TemplateName) then
            exit;

        GenJnlTemplate.Validate("Posting No. Series", PostingNoSeries);
        GenJnlTemplate.Modify(true);
    end;

    procedure NBL(): Code[10]
    begin
        exit(NBLTok);
    end;

    procedure Purchase(): Code[10]
    begin
        exit(PURCHTok);
    end;

    procedure PurchCreditMemo(): Code[10]
    begin
        exit(PurchCreditMemoTok);
    end;

    procedure Sales(): Code[10]
    begin
        exit(SalesTok);
    end;

    procedure SalesCreditMemo(): Code[10]
    begin
        exit(SalesCreditMemoTok);
    end;

    var
        NBLTok: Label 'NBL', MaxLength = 10, Locked = true;
        PURCHTok: Label 'PURCH', MaxLength = 10, Locked = true;
        PurchCreditMemoTok: Label 'PURCH-CR', MaxLength = 10, Locked = true;
        SalesTok: Label 'SALES', MaxLength = 10, Locked = true;
        SalesCreditMemoTok: Label 'SALES-CR', MaxLength = 10, Locked = true;
        NBLLbl: Label 'NBL', MaxLength = 80;
        PurchaseLbl: Label 'Purchases', MaxLength = 80;
        PurchCreditMemoLbl: Label 'Purch. Credit Memo', MaxLength = 80;
        SalesLbl: Label 'Sales', MaxLength = 80;
        SalesCreditMemoLbl: Label 'Sales Credit Memo', MaxLength = 80;
}