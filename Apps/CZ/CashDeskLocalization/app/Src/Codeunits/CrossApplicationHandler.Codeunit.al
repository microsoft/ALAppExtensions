// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.ReceivablesPayables;
using Microsoft.HumanResources.Payables;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

codeunit 31417 "Cross Application Handler CZP"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cross Application Mgt. CZL", 'OnGetSuggestedAmountForCustLedgerEntry', '', false, false)]
    local procedure AddCashDocumentLineCZPOnGetSuggestedAmountForCustLedgerEntry(var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                                                 CustLedgerEntry: Record "Cust. Ledger Entry";
                                                                                 ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        CashDocumentLineCZP.SetRange("Account Type", CashDocumentLineCZP."Account Type"::Customer);
        CashDocumentLineCZP.SetRange("Account No.", CustLedgerEntry."Customer No.");
        CashDocumentLineCZP.SetRange("Applies-to Doc. Type", CustLedgerEntry."Document Type");
        CashDocumentLineCZP.SetRange("Applies-to Doc. No.", CustLedgerEntry."Document No.");
        if CashDocumentLineCZP.FindSet() then
            repeat
                AddLineToBuffer(TempCrossApplicationBufferCZL, CashDocumentLineCZP, ExcludeTableID, ExcludeDocumentNo, ExcludeLineNo);
            until CashDocumentLineCZP.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cross Application Mgt. CZL", 'OnGetSuggestedAmountForVendLedgerEntry', '', false, false)]
    local procedure AddCashDocumentLineCZPOnGetSuggestedAmountForVendLedgerEntry(var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                                                 VendorLedgerEntry: Record "Vendor Ledger Entry";
                                                                                 ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        CashDocumentLineCZP.SetRange("Account Type", CashDocumentLineCZP."Account Type"::Vendor);
        CashDocumentLineCZP.SetRange("Account No.", VendorLedgerEntry."Vendor No.");
        CashDocumentLineCZP.SetRange("Applies-to Doc. Type", VendorLedgerEntry."Document Type");
        CashDocumentLineCZP.SetRange("Applies-to Doc. No.", VendorLedgerEntry."Document No.");
        if CashDocumentLineCZP.FindSet() then
            repeat
                AddLineToBuffer(TempCrossApplicationBufferCZL, CashDocumentLineCZP, ExcludeTableID, ExcludeDocumentNo, ExcludeLineNo);
            until CashDocumentLineCZP.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cross Application Mgt. CZL", 'OnGetSuggestedAmountForEmplLedgerEntry', '', false, false)]
    local procedure AddCashDocumentLineCZPOnGetSuggestedAmountForEmplLedgerEntry(var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                                                 EmployeeLedgerEntry: Record "Employee Ledger Entry";
                                                                                 ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        CashDocumentLineCZP.SetRange("Account Type", CashDocumentLineCZP."Account Type"::Employee);
        CashDocumentLineCZP.SetRange("Account No.", EmployeeLedgerEntry."Employee No.");
        CashDocumentLineCZP.SetRange("Applies-to Doc. Type", EmployeeLedgerEntry."Document Type");
        CashDocumentLineCZP.SetRange("Applies-to Doc. No.", EmployeeLedgerEntry."Document No.");
        if CashDocumentLineCZP.FindSet() then
            repeat
                AddLineToBuffer(TempCrossApplicationBufferCZL, CashDocumentLineCZP, ExcludeTableID, ExcludeDocumentNo, ExcludeLineNo);
            until CashDocumentLineCZP.Next() = 0;
    end;

    local procedure AddLineToBuffer(var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                    CashDocumentLineCZP: Record "Cash Document Line CZP";
                                    ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        if (ExcludeTableID = Database::"Cash Document Line CZP") and
           (ExcludeDocumentNo = CashDocumentLineCZP."Cash Document No.") and
           (ExcludeLineNo = CashDocumentLineCZP."Line No.")
        then
            exit;

        CashDocumentHeaderCZP.Get(CashDocumentLineCZP."Cash Desk No.", CashDocumentLineCZP."Cash Document No.");
        if CashDocumentHeaderCZP.Status <> CashDocumentHeaderCZP.Status::Released then
            exit;

        TempCrossApplicationBufferCZL.Init();
        TempCrossApplicationBufferCZL."Entry No." := TempCrossApplicationBufferCZL.Count() + 1;
        TempCrossApplicationBufferCZL."Table ID" := Database::"Cash Document Line CZP";
        TempCrossApplicationBufferCZL."Applied Document No." := CashDocumentLineCZP."Cash Document No.";
        TempCrossApplicationBufferCZL."Applied Document Line No." := CashDocumentLineCZP."Line No.";
        TempCrossApplicationBufferCZL."Applied Document Date" := CashDocumentHeaderCZP."Document Date";
        case CashDocumentHeaderCZP."Document Type" of
            CashDocumentHeaderCZP."Document Type"::Receipt:
                TempCrossApplicationBufferCZL."Amount (LCY)" := CashDocumentLineCZP."Amount Including VAT (LCY)";
            CashDocumentHeaderCZP."Document Type"::Withdrawal:
                TempCrossApplicationBufferCZL."Amount (LCY)" := -CashDocumentLineCZP."Amount Including VAT (LCY)";
        end;
        TempCrossApplicationBufferCZL.Insert();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Cross Application CZL", 'OnShowCrossApplicationDocument', '', false, false)]
    local procedure ShowCashDocumentLineCZPOnShowCrossApplicationDocument(TableID: Integer; DocumentNo: Code[20]; LineNo: Integer)
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        if TableId <> Database::"Cash Document Line CZP" then
            exit;

        CashDocumentLineCZP.FilterGroup(2);
        CashDocumentLineCZP.SetRange("Cash Document No.", DocumentNo);
        CashDocumentLineCZP.SetRange("Line No.", LineNo);
        CashDocumentLineCZP.FilterGroup(0);
        Page.Run(Page::"Cash Document Lines CZP", CashDocumentLineCZP);
    end;
}
