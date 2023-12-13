// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

codeunit 31415 "Cross Application Handler CZC"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cross Application Mgt. CZL", 'OnGetSuggestedAmountForCustLedgerEntry', '', false, false)]
    local procedure AddCompensationLineCZCOnGetSuggestedAmountForCustLedgerEntry(var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                                                 CustLedgerEntry: Record "Cust. Ledger Entry";
                                                                                 ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    var
        CompensationLineCZC: Record "Compensation Line CZC";
    begin
        CompensationLineCZC.SetRange("Source Type", CompensationLineCZC."Source Type"::Customer);
        CompensationLineCZC.SetRange("Source No.", CustLedgerEntry."Customer No.");
        CompensationLineCZC.SetRange("Source Entry No.", CustLedgerEntry."Entry No.");
        if CompensationLineCZC.FindSet() then
            repeat
                AddLineToBuffer(TempCrossApplicationBufferCZL, CompensationLineCZC, ExcludeTableID, ExcludeDocumentNo, ExcludeLineNo);
            until CompensationLineCZC.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cross Application Mgt. CZL", 'OnGetSuggestedAmountForVendLedgerEntry', '', false, false)]
    local procedure AddCompensationLineCZCOnGetSuggestedAmountForVendLedgerEntry(var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                                                 VendorLedgerEntry: Record "Vendor Ledger Entry";
                                                                                 ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    var
        CompensationLineCZC: Record "Compensation Line CZC";
    begin
        CompensationLineCZC.SetRange("Source Type", CompensationLineCZC."Source Type"::Vendor);
        CompensationLineCZC.SetRange("Source No.", VendorLedgerEntry."Vendor No.");
        CompensationLineCZC.SetRange("Source Entry No.", VendorLedgerEntry."Entry No.");
        if CompensationLineCZC.FindSet() then
            repeat
                AddLineToBuffer(TempCrossApplicationBufferCZL, CompensationLineCZC, ExcludeTableID, ExcludeDocumentNo, ExcludeLineNo);
            until CompensationLineCZC.Next() = 0;
    end;

    local procedure AddLineToBuffer(var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                    CompensationLineCZC: Record "Compensation Line CZC";
                                    ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        if (ExcludeTableID = Database::"Compensation Line CZC") and
           (ExcludeDocumentNo = CompensationLineCZC."Compensation No.") and
           (ExcludeLineNo = CompensationLineCZC."Line No.")
        then
            exit;

        CompensationHeaderCZC.Get(CompensationLineCZC."Compensation No.");
        if CompensationHeaderCZC.Status <> CompensationHeaderCZC.Status::Released then
            exit;

        TempCrossApplicationBufferCZL.Init();
        TempCrossApplicationBufferCZL."Entry No." := TempCrossApplicationBufferCZL.Count() + 1;
        TempCrossApplicationBufferCZL."Table ID" := Database::"Compensation Line CZC";
        TempCrossApplicationBufferCZL."Applied Document No." := CompensationLineCZC."Compensation No.";
        TempCrossApplicationBufferCZL."Applied Document Line No." := CompensationLineCZC."Line No.";
        TempCrossApplicationBufferCZL."Applied Document Date" := CompensationHeaderCZC."Document Date";
        TempCrossApplicationBufferCZL."Amount (LCY)" := CompensationLineCZC."Amount (LCY)";
        TempCrossApplicationBufferCZL.Insert();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Cross Application CZL", 'OnShowCrossApplicationDocument', '', false, false)]
    local procedure ShowCompensationLineCZCOnShowCrossApplicationDocument(TableID: Integer; DocumentNo: Code[20]; LineNo: Integer)
    var
        CompensationLineCZC: Record "Compensation Line CZC";
    begin
        if TableId <> Database::"Compensation Line CZC" then
            exit;

        CompensationLineCZC.FilterGroup(2);
        CompensationLineCZC.SetRange("Compensation No.", DocumentNo);
        CompensationLineCZC.SetRange("Line No.", LineNo);
        CompensationLineCZC.FilterGroup(0);
        Page.Run(Page::"Compensation Lines CZC", CompensationLineCZC);
    end;
}
