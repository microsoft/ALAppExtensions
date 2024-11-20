codeunit 11351 "Create No. Series BE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(PurchaseCreditMemoJnl(), PurchCreditMemoJournalLbl, 'G03501', 'G04500', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(PurchaseJournal(), PurchaseJournalLbl, 'G03001', 'G04000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(SalesCreditMemoJnl(), SalesCreditMemoJournalLbl, 'G01501', 'G02500', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(SalesJournal(), SalesJournalLbl, 'G01001', 'G02000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
    end;

    procedure PurchaseCreditMemoJnl(): Code[20]
    begin
        exit('GJNL-P-CR');
    end;

    procedure PurchaseJournal(): Code[20]
    begin
        exit('GJNL-PURCH');
    end;

    procedure SalesJournal(): Code[20]
    begin
        exit('GJNL-SALES');
    end;

    procedure SalesCreditMemoJnl(): Code[20]
    begin
        exit('GJNL-S-CR');
    end;

    var
        PurchCreditMemoJournalLbl: Label 'Purch. Credit Memo Journal', MaxLength = 100;
        PurchaseJournalLbl: Label 'Purchase Journal', MaxLength = 100;
        SalesJournalLbl: Label 'Sales Journal', MaxLength = 100;
        SalesCreditMemoJournalLbl: Label 'Sales Credit Memo Journal', MaxLength = 100;
}