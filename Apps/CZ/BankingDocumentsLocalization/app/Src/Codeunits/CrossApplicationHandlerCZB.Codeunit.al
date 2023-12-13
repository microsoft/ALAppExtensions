// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Finance.ReceivablesPayables;
using Microsoft.HumanResources.Payables;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

codeunit 31416 "Cross Application Handler CZB"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cross Application Mgt. CZL", 'OnGetSuggestedAmountForCustLedgerEntry', '', false, false)]
    local procedure AddIssPaymentOrderLineCZBOnGetSuggestedAmountForCustLedgerEntry(var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                                                    CustLedgerEntry: Record "Cust. Ledger Entry";
                                                                                    ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
    begin
        IssPaymentOrderLineCZB.SetRange(Type, IssPaymentOrderLineCZB.Type::Customer);
        IssPaymentOrderLineCZB.SetRange("No.", CustLedgerEntry."Customer No.");
        IssPaymentOrderLineCZB.SetRange("Applies-to C/V/E Entry No.", CustLedgerEntry."Entry No.");
        IssPaymentOrderLineCZB.SetFilter(Status, '<>%1', IssPaymentOrderLineCZB.Status::Canceled);
        if IssPaymentOrderLineCZB.FindSet() then
            repeat
                AddLineToBuffer(TempCrossApplicationBufferCZL, IssPaymentOrderLineCZB, ExcludeTableID, ExcludeDocumentNo, ExcludeLineNo);
            until IssPaymentOrderLineCZB.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cross Application Mgt. CZL", 'OnGetSuggestedAmountForVendLedgerEntry', '', false, false)]
    local procedure AddIssPaymentOrderLineCZBOnGetSuggestedAmountForVendLedgerEntry(var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                                                    VendorLedgerEntry: Record "Vendor Ledger Entry";
                                                                                    ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
    begin
        IssPaymentOrderLineCZB.SetRange(Type, IssPaymentOrderLineCZB.Type::Vendor);
        IssPaymentOrderLineCZB.SetRange("No.", VendorLedgerEntry."Vendor No.");
        IssPaymentOrderLineCZB.SetRange("Applies-to C/V/E Entry No.", VendorLedgerEntry."Entry No.");
        IssPaymentOrderLineCZB.SetFilter(Status, '<>%1', IssPaymentOrderLineCZB.Status::Canceled);
        if IssPaymentOrderLineCZB.FindSet() then
            repeat
                AddLineToBuffer(TempCrossApplicationBufferCZL, IssPaymentOrderLineCZB, ExcludeTableID, ExcludeDocumentNo, ExcludeLineNo);
            until IssPaymentOrderLineCZB.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cross Application Mgt. CZL", 'OnGetSuggestedAmountForEmplLedgerEntry', '', false, false)]
    local procedure AddIssPaymentOrderLineCZBOnGetSuggestedAmountForEmplLedgerEntry(var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                                                    EmployeeLedgerEntry: Record "Employee Ledger Entry";
                                                                                    ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
    begin
        IssPaymentOrderLineCZB.SetRange(Type, IssPaymentOrderLineCZB.Type::Employee);
        IssPaymentOrderLineCZB.SetRange("No.", EmployeeLedgerEntry."Employee No.");
        IssPaymentOrderLineCZB.SetRange("Applies-to C/V/E Entry No.", EmployeeLedgerEntry."Entry No.");
        IssPaymentOrderLineCZB.SetFilter(Status, '<>%1', IssPaymentOrderLineCZB.Status::Canceled);
        if IssPaymentOrderLineCZB.FindSet() then
            repeat
                AddLineToBuffer(TempCrossApplicationBufferCZL, IssPaymentOrderLineCZB, ExcludeTableID, ExcludeDocumentNo, ExcludeLineNo);
            until IssPaymentOrderLineCZB.Next() = 0;
    end;

    local procedure AddLineToBuffer(var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                    IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
                                    ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
    begin
        if (ExcludeTableID = Database::"Iss. Payment Order Line CZB") and
           (ExcludeDocumentNo = IssPaymentOrderLineCZB."Payment Order No.") and
           (ExcludeLineNo = IssPaymentOrderLineCZB."Line No.")
        then
            exit;

        IssPaymentOrderHeaderCZB.Get(IssPaymentOrderLineCZB."Payment Order No.");
        TempCrossApplicationBufferCZL.Init();
        TempCrossApplicationBufferCZL."Entry No." := TempCrossApplicationBufferCZL.Count() + 1;
        TempCrossApplicationBufferCZL."Table ID" := Database::"Iss. Payment Order Line CZB";
        TempCrossApplicationBufferCZL."Applied Document No." := IssPaymentOrderLineCZB."Payment Order No.";
        TempCrossApplicationBufferCZL."Applied Document Line No." := IssPaymentOrderLineCZB."Line No.";
        TempCrossApplicationBufferCZL."Applied Document Date" := IssPaymentOrderHeaderCZB."Document Date";
        TempCrossApplicationBufferCZL."Amount (LCY)" := -IssPaymentOrderLineCZB."Amount (LCY)";
        TempCrossApplicationBufferCZL.Insert();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Cross Application CZL", 'OnShowCrossApplicationDocument', '', false, false)]
    local procedure ShowIssPaymentOrderLineCZBOnShowCrossApplicationDocument(TableID: Integer; DocumentNo: Code[20]; LineNo: Integer)
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
    begin
        if TableId <> Database::"Iss. Payment Order Line CZB" then
            exit;

        IssPaymentOrderLineCZB.FilterGroup(2);
        IssPaymentOrderLineCZB.SetRange("Payment Order No.", DocumentNo);
        IssPaymentOrderLineCZB.SetRange("Line No.", LineNo);
        IssPaymentOrderLineCZB.FilterGroup(0);
        Page.Run(Page::"Iss. Payment Order Lines CZB", IssPaymentOrderLineCZB);
    end;
}
