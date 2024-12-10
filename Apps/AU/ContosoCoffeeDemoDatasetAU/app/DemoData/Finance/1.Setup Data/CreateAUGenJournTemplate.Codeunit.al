codeunit 17160 "Create AU Gen. Journ. Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoGeneralLedger: Codeunit "Contoso General Ledger";
        CreateAUNoSeries: Codeunit "Create AU No. Series";
    begin
        ContosoGeneralLedger.InsertGeneralJournalTemplate(Purchase(), PurchasesLbl, Enum::"Gen. Journal Template Type"::Purchases, Page::"Purchase Journal", CreateAUNoSeries.PurchaseJournal(), false);
    end;

    procedure Purchase(): Code[10]
    begin
        exit(PurchaseTok);
    end;

    var
        PurchasesLbl: Label 'Purchases', MaxLength = 80;
        PurchaseTok: Label 'PURCH', MaxLength = 10;
}