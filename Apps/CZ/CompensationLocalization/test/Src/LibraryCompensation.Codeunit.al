#pragma warning disable AL0432
codeunit 148004 "Library - Compensation CZC"
{
    var
        LibraryUtility: Codeunit "Library - Utility";
        CompensationManagementCZC: Codeunit "Compensation Management CZC";
        ReleaseCompensDocumentCZC: Codeunit "Release Compens. Document CZC";

    procedure CreateCompensationHeader(var CompensationHeaderCZC: Record "Compensation Header CZC"; SourceType: Enum "Compensation Source Type CZC"; CompanyNo: Code[20])
    begin
        CompensationHeaderCZC.Init();
        CompensationHeaderCZC.Insert(true);

        UpdateCompensationHeader(CompensationHeaderCZC, SourceType, CompanyNo, WorkDate());
    end;

    procedure CreateCompensationLine(var CompensationLineCZC: Record "Compensation Line CZC"; CompensationHeaderCZC: Record "Compensation Header CZC";
                                     SourceType: Enum "Compensation Source Type CZC"; SourceEntryNo: Integer)
    var
        RecordRef: RecordRef;
    begin
        CompensationLineCZC.Init();
        CompensationLineCZC.Validate("Compensation No.", CompensationHeaderCZC."No.");
        RecordRef.GetTable(CompensationLineCZC);
        CompensationLineCZC.Validate("Line No.", LibraryUtility.GetNewLineNo(RecordRef, CompensationLineCZC.FieldNo("Line No.")));
        CompensationLineCZC.Validate("Source Type", SourceType);
        CompensationLineCZC.Validate("Source Entry No.", SourceEntryNo);
        CompensationLineCZC.Insert(true);
    end;

    procedure FindCustomerLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalDocumentType: Enum "Gen. Journal Document Type")
    begin
        CustLedgerEntry.Reset();
        CustLedgerEntry.SetRange("Document Type", GenJournalDocumentType);
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange("Compensation Amount (LCY) CZC", 0);
        CustLedgerEntry.FindFirst();
    end;

    procedure FindVendorLedgerEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalDocumentType: Enum "Gen. Journal Document Type")
    begin
        VendorLedgerEntry.Reset();
        VendorLedgerEntry.SetRange("Document Type", GenJournalDocumentType);
        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.SetRange("Compensation Amount (LCY) CZC", 0);
        VendorLedgerEntry.FindFirst();
    end;

    procedure RunPostCompensation(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        Codeunit.Run(Codeunit::"Compensation - Post CZC", CompensationHeaderCZC);
    end;

    procedure RunPrintCompensation(var CompensationHeaderCZC: Record "Compensation Header CZC"; ShowRequestPage: Boolean)
    var
        PrintedCompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        PrintedCompensationHeaderCZC.Get(CompensationHeaderCZC."No.");
        PrintedCompensationHeaderCZC.SetRecFilter();
        PrintedCompensationHeaderCZC.PrintRecords(ShowRequestPage);
    end;

    procedure RunPrintPostedCompensation(var PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC"; ShowRequestPage: Boolean)
    var
        PrintedPostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
    begin
        PrintedPostedCompensationHeaderCZC.Get(PostedCompensationHeaderCZC."No.");
        PrintedPostedCompensationHeaderCZC.SetRecFilter();
        PrintedPostedCompensationHeaderCZC.PrintRecords(ShowRequestPage);
    end;

    procedure GetCompensationReport(): Integer
    var
        CompensReportSelectionsCZC: Record "Compens. Report Selections CZC";
    begin
        CompensReportSelectionsCZC.SetRange(Usage, CompensReportSelectionsCZC.Usage::Compensation);
        CompensReportSelectionsCZC.SetFilter("Report ID", '<>0');
        CompensReportSelectionsCZC.FindFirst();
        exit(CompensReportSelectionsCZC."Report ID");
    end;

    procedure GetPostedCompensationReport(): Integer
    var
        CompensReportSelectionsCZC: Record "Compens. Report Selections CZC";
    begin
        CompensReportSelectionsCZC.SetRange(Usage, CompensReportSelectionsCZC.Usage::"Posted Compensation");
        CompensReportSelectionsCZC.SetFilter("Report ID", '<>0');
        CompensReportSelectionsCZC.FindFirst();
        exit(CompensReportSelectionsCZC."Report ID");
    end;

    procedure RunReleaseCompensation(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        Codeunit.Run(Codeunit::"Release Compens. Document CZC", CompensationHeaderCZC);
    end;

    procedure RunReopenCompensation(var CompensationHeader: Record "Compensation Header CZC")
    begin
        ReleaseCompensDocumentCZC.Reopen(CompensationHeader);
    end;

    procedure RunSuggestCompensationLines(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        CompensationManagementCZC.SuggestCompensationLines(CompensationHeaderCZC);
    end;

    procedure UpdateCompensationHeader(var CompensationHeaderCZC: Record "Compensation Header CZC"; CompanyType: Enum "Compensation Source Type CZC"; CompanyNo: Code[20]; DocumentDate: Date)
    begin
        case CompanyType of
            CompanyType::Customer:
                CompensationHeaderCZC.Validate("Company Type", CompensationHeaderCZC."Company Type"::Customer);
            CompanyType::Vendor:
                CompensationHeaderCZC.Validate("Company Type", CompensationHeaderCZC."Company Type"::Vendor);
        end;
        CompensationHeaderCZC.Validate("Company No.", CompanyNo);
        CompensationHeaderCZC.Validate("Document Date", DocumentDate);
        CompensationHeaderCZC.Modify(true);
    end;

    procedure UpdateCompensationLine(var CompensationLineCZC: Record "Compensation Line CZC"; Amount: Decimal)
    begin
        CompensationLineCZC.Validate("Amount (LCY)", Amount);
        CompensationLineCZC.Modify(true);
    end;
}