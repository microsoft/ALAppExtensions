codeunit 17116 "Create AU No. Series"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: Codeunit "Contoso No Series";
    begin
        ContosoNoSeries.SetOverwriteData(true);
        ContosoNoSeries.InsertNoSeries(BASReports(), BASReportsLbl, 'BASREP-0001', 'BASREP-9999', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(PurchaseJournal(), PurchaseJournalLbl, 'G03001', 'G04000', '', '', 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.SetOverwriteData(false);
    end;

    procedure BASReports(): Code[20]
    begin
        exit(BASReportsTok);
    end;

    procedure PurchaseJournal(): Code[20]
    begin
        exit(PurchaseJournalTok);
    end;

    var
        BASReportsTok: Label 'BASREPORTS', MaxLength = 20;
        PurchaseJournalTok: Label 'GJNL-PURCH', MaxLength = 20;
        BASReportsLbl: Label 'BAS Reports.', MaxLength = 100;
        PurchaseJournalLbl: Label 'Purchase Journal', MaxLength = 100;
}