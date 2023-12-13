// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ReceivablesPayables;

using Microsoft.HumanResources.Payables;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

codeunit 31419 "Cross Application Mgt. CZL"
{
    var
        TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;

    procedure CalcSuggestedAmountToApplyCustLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry"): Decimal
    begin
        Clear(TempCrossApplicationBufferCZL);
        OnGetSuggestedAmountForCustLedgerEntry(CustLedgerEntry, TempCrossApplicationBufferCZL, 0, '', 0);
        TempCrossApplicationBufferCZL.CalcSums("Amount (LCY)");
        exit(TempCrossApplicationBufferCZL."Amount (LCY)");
    end;

    procedure DrillDownSuggestedAmountToApplyCustLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        Clear(TempCrossApplicationBufferCZL);
        OnGetSuggestedAmountForCustLedgerEntry(CustLedgerEntry, TempCrossApplicationBufferCZL, 0, '', 0);
        Page.Run(Page::"Cross Application CZL", TempCrossApplicationBufferCZL);
    end;

    procedure CalcSuggestedAmountToApplyVendorLedgerEntry(VendorLedgerEntry: Record "Vendor Ledger Entry"): Decimal
    begin
        Clear(TempCrossApplicationBufferCZL);
        OnGetSuggestedAmountForVendLedgerEntry(VendorLedgerEntry, TempCrossApplicationBufferCZL, 0, '', 0);
        TempCrossApplicationBufferCZL.CalcSums("Amount (LCY)");
        exit(TempCrossApplicationBufferCZL."Amount (LCY)");
    end;

    procedure DrillDownSuggestedAmountToApplyVendorLedgerEntry(VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        Clear(TempCrossApplicationBufferCZL);
        OnGetSuggestedAmountForVendLedgerEntry(VendorLedgerEntry, TempCrossApplicationBufferCZL, 0, '', 0);
        Page.Run(Page::"Cross Application CZL", TempCrossApplicationBufferCZL);
    end;

    procedure CalcSuggestedAmountToApplyEmployeeLedgerEntry(EmployeeLedgerEntry: Record "Employee Ledger Entry"): Decimal
    begin
        Clear(TempCrossApplicationBufferCZL);
        OnGetSuggestedAmountForEmplLedgerEntry(EmployeeLedgerEntry, TempCrossApplicationBufferCZL, 0, '', 0);
        TempCrossApplicationBufferCZL.CalcSums("Amount (LCY)");
        exit(TempCrossApplicationBufferCZL."Amount (LCY)");
    end;

    procedure DrillDownSuggestedAmountToApplyEmployeeLedgerEntry(EmployeeLedgerEntry: Record "Employee Ledger Entry")
    begin
        Clear(TempCrossApplicationBufferCZL);
        OnGetSuggestedAmountForEmplLedgerEntry(EmployeeLedgerEntry, TempCrossApplicationBufferCZL, 0, '', 0);
        Page.Run(Page::"Cross Application CZL", TempCrossApplicationBufferCZL);
    end;

    procedure CalcSuggestedAmountToApplyPurchAdvLetterHeader(PurchAdvLetterHeaderNo: Code[20]): Decimal
    begin
        Clear(TempCrossApplicationBufferCZL);
        OnGetSuggestedAmountForPurchAdvLetterHeader(PurchAdvLetterHeaderNo, TempCrossApplicationBufferCZL, 0, '', 0);
        TempCrossApplicationBufferCZL.CalcSums("Amount (LCY)");
        exit(-TempCrossApplicationBufferCZL."Amount (LCY)");
    end;

    procedure DrillDownSuggestedAmountToApplyPurchAdvLetterHeader(PurchAdvLetterHeaderNo: Code[20])
    begin
        Clear(TempCrossApplicationBufferCZL);
        OnGetSuggestedAmountForPurchAdvLetterHeader(PurchAdvLetterHeaderNo, TempCrossApplicationBufferCZL, 0, '', 0);
        Page.Run(Page::"Cross Application CZL", TempCrossApplicationBufferCZL);
    end;

    procedure SetAppliesToID(AppliesToID: Code[50])
    begin
        OnSetAppliesToID(AppliesToID);
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetSuggestedAmountForCustLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry";
                                                     var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                     ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetSuggestedAmountForVendLedgerEntry(VendorLedgerEntry: Record "Vendor Ledger Entry";
                                                     var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                     ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetSuggestedAmountForEmplLedgerEntry(EmployeeLedgerEntry: Record "Employee Ledger Entry";
                                                     var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                     ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetSuggestedAmountForPurchAdvLetterHeader(PurchAdvLetterHeaderNo: Code[20];
                                                          var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                          ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetAppliesToID(AppliesToID: Code[50])
    begin
    end;
}
