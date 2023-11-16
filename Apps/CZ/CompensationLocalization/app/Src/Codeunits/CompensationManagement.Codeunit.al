// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

codeunit 31279 "Compensation Management CZC"
{
    Permissions = tabledata "Cust. Ledger Entry" = rm,
                  tabledata "Vendor Ledger Entry" = rm;

    var
        ApplyDocManuallyMsg: Label 'Document was not applied with 0 remaining amount, you have to apply it manually.';

    procedure SuggestCompensationLines(var CompensationHeaderCZC: Record "Compensation Header CZC")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CompensationLineCZC: Record "Compensation Line CZC";
        CompensationProposalCZC: Page "Compensation Proposal CZC";
        LineNo: Integer;
    begin
        CompensationHeaderCZC.TestField(Status, CompensationHeaderCZC.Status::Open);
        CompensationHeaderCZC.TestField("Posting Date");
        CompensationProposalCZC.SetCompensationHeader(CompensationHeaderCZC);
        CompensationProposalCZC.ApplyFilters();
        if CompensationProposalCZC.RunModal() = Action::LookupOK then begin
            CompensationProposalCZC.GetLedgEntries(CustLedgerEntry, VendorLedgerEntry);

            Clear(CompensationLineCZC);
            CompensationLineCZC.SetRange("Compensation No.", CompensationHeaderCZC."No.");
            LineNo := 10000;
            if CompensationLineCZC.FindLast() then
                LineNo += CompensationLineCZC."Line No.";

            if CustLedgerEntry.FindSet() then
                repeat
                    Clear(CompensationLineCZC);
                    CompensationLineCZC.Init();
                    CompensationLineCZC.Validate("Compensation No.", CompensationHeaderCZC."No.");
                    CompensationLineCZC."Line No." := LineNo;
                    CompensationLineCZC.Validate("Source Type", CompensationLineCZC."Source Type"::Customer);
                    CompensationLineCZC.Validate("Source Entry No.", CustLedgerEntry."Entry No.");
                    CompensationLineCZC.Insert();
                    LineNo += 10000;
                until CustLedgerEntry.Next() = 0;
            if VendorLedgerEntry.FindSet() then
                repeat
                    Clear(CompensationLineCZC);
                    CompensationLineCZC.Init();
                    CompensationLineCZC.Validate("Compensation No.", CompensationHeaderCZC."No.");
                    CompensationLineCZC."Line No." := LineNo;
                    CompensationLineCZC.Validate("Source Type", CompensationLineCZC."Source Type"::Vendor);
                    CompensationLineCZC.Validate("Source Entry No.", VendorLedgerEntry."Entry No.");
                    CompensationLineCZC.Insert();
                    LineNo += 10000;
                until VendorLedgerEntry.Next() = 0;
        end;
    end;

    procedure SetAppliesToID(CompensationLineCZC: Record "Compensation Line CZC"; AppliesToID: Code[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        case CompensationLineCZC."Source Type" of
            CompensationLineCZC."Source Type"::Customer:
                begin
                    CustLedgerEntry.Get(CompensationLineCZC."Source Entry No.");
                    CustLedgerEntry.TestField(Prepayment, false);
                    if AppliesToID <> '' then begin
                        CustLedgerEntry.Validate("Applies-to ID", AppliesToID);
                        CustLedgerEntry."Amount to Apply" := CompensationLineCZC.Amount;
                    end else begin
                        CustLedgerEntry."Applies-to ID" := AppliesToID;
                        CustLedgerEntry."Amount to Apply" := 0;
                    end;
                    CustLedgerEntry.Modify();
                end;
            CompensationLineCZC."Source Type"::Vendor:
                begin
                    VendorLedgerEntry.Get(CompensationLineCZC."Source Entry No.");
                    VendorLedgerEntry.TestField(Prepayment, false);
                    if AppliesToID <> '' then begin
                        VendorLedgerEntry.Validate("Applies-to ID", AppliesToID);
                        VendorLedgerEntry."Amount to Apply" := CompensationLineCZC.Amount;
                    end else begin
                        VendorLedgerEntry."Applies-to ID" := AppliesToID;
                        VendorLedgerEntry."Amount to Apply" := 0;
                    end;
                    VendorLedgerEntry.Modify();
                end;
        end;
    end;

    procedure BalanceCompensations(CompensationHeaderCZC: Record "Compensation Header CZC")
    var
        CompensationLineCZC: Record "Compensation Line CZC";
        Amt: Decimal;
    begin
        CompensationHeaderCZC.TestField(Status, CompensationHeaderCZC.Status::Open);
        CompensationLineCZC.SetCurrentKey("Compensation No.", "Source Type", "Source Entry No.");
        CompensationLineCZC.Ascending(false);
        CompensationLineCZC.SetRange("Compensation No.", CompensationHeaderCZC."No.");
        CompensationLineCZC.CalcSums("Amount (LCY)");
        if CompensationLineCZC."Amount (LCY)" = 0 then
            exit;

        Amt := CompensationLineCZC."Amount (LCY)";
        if Amt > 0 then
            CompensationLineCZC.SetFilter("Amount (LCY)", '>0')
        else
            CompensationLineCZC.SetFilter("Amount (LCY)", '<0');
        CompensationLineCZC.SetRange("Manual Change Only", false);

        if CompensationLineCZC.FindSet() then
            repeat
                if Abs(Amt) >= Abs(CompensationLineCZC."Amount (LCY)") then begin
                    Amt -= CompensationLineCZC."Amount (LCY)";
                    CompensationLineCZC.Amount := 0;
                    CompensationLineCZC."Remaining Amount" := CompensationLineCZC."Ledg. Entry Remaining Amount";
                    CompensationLineCZC.ConvertLCYAmounts();
                end else begin
                    CompensationLineCZC.Validate("Amount (LCY)", CompensationLineCZC."Amount (LCY)" - Amt);
                    Amt := 0;
                end;
                CompensationLineCZC.Modify(true);
            until (CompensationLineCZC.Next() = 0) or (Amt = 0);

        if Amt <> 0 then
            Message(ApplyDocManuallyMsg);
    end;
}
