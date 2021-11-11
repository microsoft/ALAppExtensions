codeunit 20111 "AMC Bank Exp. CT Feedback"
{
    Permissions = TableData "Payment Export Data" = rimd;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        CreditTransferRegister: Record "Credit Transfer Register";
        GenJournalLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
    begin
        GenJournalLine.SetRange("Data Exch. Entry No.", "Entry No.");
        GenJournalLine.FindFirst();
        CreditTransferRegister.SetRange("Data Exch. Entry No.", "Entry No.");
        CreditTransferRegister.FindLast();
        SetFileOnCreditTransferRegister(Rec, CreditTransferRegister);
        SetExportFlagOnGenJnlLine(GenJournalLine);

        PaymentExportData.SetRange("Data Exch Entry No.", "Entry No.");
        PaymentExportData.DeleteAll(true);
    end;

    local procedure SetFileOnCreditTransferRegister(DataExch: Record "Data Exch."; var CreditTransferRegister: Record "Credit Transfer Register")
    begin
        CreditTransferRegister.SetStatus(CreditTransferRegister.Status::"File Created");
        CreditTransferRegister.SetFileContent(DataExch);
    end;

    procedure SetExportFlagOnGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        CopyGenJournalLine: Record "Gen. Journal Line";
    begin
        CopyGenJournalLine.CopyFilters(GenJournalLine);
        if CopyGenJournalLine.FindSet() then
            repeat
                case CopyGenJournalLine."Account Type" of
                    CopyGenJournalLine."Account Type"::Vendor:
                        SetExportFlagOnAppliedVendorLedgerEntry(CopyGenJournalLine);
                    CopyGenJournalLine."Account Type"::Customer:
                        SetExportFlagOnAppliedCustLedgerEntry(CopyGenJournalLine);
                end;
                CopyGenJournalLine.Validate("Check Exported", true);
                CopyGenJournalLine.Validate("Exported to Payment File", true);
                CopyGenJournalLine.Modify(true);
            until CopyGenJournalLine.Next() = 0;
    end;

    local procedure SetExportFlagOnAppliedVendorLedgerEntry(GenJournalLine: Record "Gen. Journal Line")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if GenJournalLine.IsApplied() then begin
            VendorLedgerEntry.SetRange("Vendor No.", GenJournalLine."Account No.");

            if GenJournalLine."Applies-to Doc. No." <> '' then begin
                VendorLedgerEntry.SetRange("Document Type", GenJournalLine."Applies-to Doc. Type");
                VendorLedgerEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
            end;

            if GenJournalLine."Applies-to ID" <> '' then
                VendorLedgerEntry.SetRange("Applies-to ID", GenJournalLine."Applies-to ID");

            if VendorLedgerEntry.FindSet() then
                repeat
                    VendorLedgerEntry.Validate("Exported to Payment File", true);
                    CODEUNIT.Run(CODEUNIT::"Vend. Entry-Edit", VendorLedgerEntry);
                until VendorLedgerEntry.Next() = 0;
        end;

        VendorLedgerEntry.Reset();
        VendorLedgerEntry.SetRange("Vendor No.", GenJournalLine."Account No.");
        VendorLedgerEntry.SetRange("Applies-to Doc. Type", GenJournalLine."Document Type");
        VendorLedgerEntry.SetRange("Applies-to Doc. No.", GenJournalLine."Document No.");
        if VendorLedgerEntry.FindSet() then
            repeat
                VendorLedgerEntry.Validate("Exported to Payment File", true);
                CODEUNIT.Run(CODEUNIT::"Vend. Entry-Edit", VendorLedgerEntry);
            until VendorLedgerEntry.Next() = 0;
    end;

    local procedure SetExportFlagOnAppliedCustLedgerEntry(GenJournalLine: Record "Gen. Journal Line")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if GenJournalLine.IsApplied() then begin
            CustLedgerEntry.SetRange("Customer No.", GenJournalLine."Account No.");

            if GenJournalLine."Applies-to Doc. No." <> '' then begin
                CustLedgerEntry.SetRange("Document Type", GenJournalLine."Applies-to Doc. Type");
                CustLedgerEntry.SetRange("Document No.", GenJournalLine."Applies-to Doc. No.");
            end;

            if GenJournalLine."Applies-to ID" <> '' then
                CustLedgerEntry.SetRange("Applies-to ID", GenJournalLine."Applies-to ID");

            if CustLedgerEntry.FindSet() then
                repeat
                    CustLedgerEntry.Validate("Exported to Payment File", true);
                    CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", CustLedgerEntry);
                until CustLedgerEntry.Next() = 0;
        end;

        CustLedgerEntry.Reset();
        CustLedgerEntry.SetRange("Customer No.", GenJournalLine."Account No.");
        CustLedgerEntry.SetRange("Applies-to Doc. Type", GenJournalLine."Document Type");
        CustLedgerEntry.SetRange("Applies-to Doc. No.", GenJournalLine."Document No.");

        if CustLedgerEntry.FindSet() then
            repeat
                CustLedgerEntry.Validate("Exported to Payment File", true);
                CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", CustLedgerEntry);
            until CustLedgerEntry.Next() = 0;
    end;
}

