// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ReceivablesPayables;

#if not CLEAN25
using Microsoft.HumanResources.Payables;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;
#endif
using System.Reflection;

codeunit 31419 "Cross Application Mgt. CZL"
{
#if not CLEAN25
    var
        GlobalCrossApplicationBufferCZL: Record "Cross Application Buffer CZL";

#endif
    procedure CollectSuggestedApplication(CollectedFor: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL"): Boolean
    var
        DummyVariant: Variant;
    begin
        exit(CollectSuggestedApplication(CollectedFor, DummyVariant, CrossApplicationBufferCZL));
    end;

    procedure CollectSuggestedApplication(CollectedFor: Variant; CalledFrom: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL"): Boolean
    var
#if not CLEAN25
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
#endif
        DataTypeManagement: Codeunit "Data Type Management";
        CollectedForRecRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(CollectedFor, CollectedForRecRef) then
            exit(false);

        Clear(CrossApplicationBufferCZL);
        OnCollectSuggestedApplication(CollectedForRecRef.Number, CollectedFor, CalledFrom, CrossApplicationBufferCZL);
#if not CLEAN25
#pragma warning disable AL0432
        case CollectedForRecRef.Number of
            Database::"Cust. Ledger Entry":
                begin
                    CustLedgerEntry := CollectedFor;
                    OnGetSuggestedAmountForCustLedgerEntry(CustLedgerEntry, CrossApplicationBufferCZL, 0, '', 0);
                end;
            Database::"Vendor Ledger Entry":
                begin
                    VendorLedgerEntry := CollectedFor;
                    OnGetSuggestedAmountForVendLedgerEntry(VendorLedgerEntry, CrossApplicationBufferCZL, 0, '', 0);
                end;
            Database::"Employee Ledger Entry":
                begin
                    EmployeeLedgerEntry := CollectedFor;
                    OnGetSuggestedAmountForEmplLedgerEntry(EmployeeLedgerEntry, CrossApplicationBufferCZL, 0, '', 0);
                end;
        end;
#pragma warning restore AL0432
#endif
        CrossApplicationBufferCZL.ExcludeDocument(CalledFrom);
        exit(not CrossApplicationBufferCZL.IsEmpty());
    end;

    procedure CalcSuggestedAmountToApply(CollectedFor: Variant): Decimal
    var
        CrossApplicationBufferCZL: Record "Cross Application Buffer CZL";
    begin
        CollectSuggestedApplication(CollectedFor, CrossApplicationBufferCZL);
        CrossApplicationBufferCZL.CalcSums("Amount (LCY)");
        exit(CrossApplicationBufferCZL."Amount (LCY)");
    end;

    procedure DrillDownSuggestedAmountToApply(CollectedFor: Variant)
    var
        CrossApplicationBufferCZL: Record "Cross Application Buffer CZL";
    begin
        CollectSuggestedApplication(CollectedFor, CrossApplicationBufferCZL);
        Page.Run(Page::"Cross Application CZL", CrossApplicationBufferCZL);
    end;
#if not CLEAN25

    [Obsolete('This function is obsolete and will be removed in a future version. Please use the CollectSuggestedApplication function instead.', '25.0')]
    procedure CalcSuggestedAmountToApplyCustLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry"): Decimal
    begin
        CollectSuggestedApplication(CustLedgerEntry, GlobalCrossApplicationBufferCZL);
        GlobalCrossApplicationBufferCZL.CalcSums("Amount (LCY)");
        exit(GlobalCrossApplicationBufferCZL."Amount (LCY)");
    end;

    [Obsolete('This function is obsolete and will be removed in a future version. Please use the DrillDownSuggestedAmountToApply function instead.', '25.0')]
    procedure DrillDownSuggestedAmountToApplyCustLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CollectSuggestedApplication(CustLedgerEntry, GlobalCrossApplicationBufferCZL);
        Page.Run(Page::"Cross Application CZL", GlobalCrossApplicationBufferCZL);
    end;

    [Obsolete('This function is obsolete and will be removed in a future version. Please use the CollectSuggestedApplication function instead.', '25.0')]
    procedure CalcSuggestedAmountToApplyVendorLedgerEntry(VendorLedgerEntry: Record "Vendor Ledger Entry"): Decimal
    begin
        CollectSuggestedApplication(VendorLedgerEntry, GlobalCrossApplicationBufferCZL);
        GlobalCrossApplicationBufferCZL.CalcSums("Amount (LCY)");
        exit(GlobalCrossApplicationBufferCZL."Amount (LCY)");
    end;

    [Obsolete('This function is obsolete and will be removed in a future version. Please use the DrillDownSuggestedAmountToApply function instead.', '25.0')]
    procedure DrillDownSuggestedAmountToApplyVendorLedgerEntry(VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        CollectSuggestedApplication(VendorLedgerEntry, GlobalCrossApplicationBufferCZL);
        Page.Run(Page::"Cross Application CZL", GlobalCrossApplicationBufferCZL);
    end;

    [Obsolete('This function is obsolete and will be removed in a future version. Please use the CollectSuggestedApplication function instead.', '25.0')]
    procedure CalcSuggestedAmountToApplyEmployeeLedgerEntry(EmployeeLedgerEntry: Record "Employee Ledger Entry"): Decimal
    begin
        CollectSuggestedApplication(EmployeeLedgerEntry, GlobalCrossApplicationBufferCZL);
        GlobalCrossApplicationBufferCZL.CalcSums("Amount (LCY)");
        exit(GlobalCrossApplicationBufferCZL."Amount (LCY)");
    end;

    [Obsolete('This function is obsolete and will be removed in a future version. Please use the DrillDownSuggestedAmountToApply function instead.', '25.0')]
    procedure DrillDownSuggestedAmountToApplyEmployeeLedgerEntry(EmployeeLedgerEntry: Record "Employee Ledger Entry")
    begin
        CollectSuggestedApplication(EmployeeLedgerEntry, GlobalCrossApplicationBufferCZL);
        Page.Run(Page::"Cross Application CZL", GlobalCrossApplicationBufferCZL);
    end;

    [Obsolete('This function is obsolete and will be removed in a future version. Please use the CollectSuggestedApplication function instead.', '25.0')]
    procedure CalcSuggestedAmountToApplyPurchAdvLetterHeader(PurchAdvLetterHeaderNo: Code[20]): Decimal
    begin
        Clear(GlobalCrossApplicationBufferCZL);
#pragma warning disable AL0432
        OnGetSuggestedAmountForPurchAdvLetterHeader(PurchAdvLetterHeaderNo, GlobalCrossApplicationBufferCZL, 0, '', 0);
#pragma warning restore AL0432
        GlobalCrossApplicationBufferCZL.CalcSums("Amount (LCY)");
        exit(-GlobalCrossApplicationBufferCZL."Amount (LCY)");
    end;

    [Obsolete('This function is obsolete and will be removed in a future version. Please use the DrillDownSuggestedAmountToApply function instead.', '25.0')]
    procedure DrillDownSuggestedAmountToApplyPurchAdvLetterHeader(PurchAdvLetterHeaderNo: Code[20])
    begin
        Clear(GlobalCrossApplicationBufferCZL);
#pragma warning disable AL0432
        OnGetSuggestedAmountForPurchAdvLetterHeader(PurchAdvLetterHeaderNo, GlobalCrossApplicationBufferCZL, 0, '', 0);
#pragma warning restore AL0432
        Page.Run(Page::"Cross Application CZL", GlobalCrossApplicationBufferCZL);
    end;
#endif

    procedure SetAppliesToID(AppliesToID: Code[50])
    begin
        OnSetAppliesToID(AppliesToID);
    end;
#if not CLEAN25
    [Obsolete('This event is obsolete and will be removed in a future version. Please use the OnCollectSuggestedApplication event instead.', '25.0')]
    [IntegrationEvent(false, false)]
    procedure OnGetSuggestedAmountForCustLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry";
                                                     var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                     ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    begin
    end;

    [Obsolete('This event is obsolete and will be removed in a future version. Please use the OnCollectSuggestedApplication event instead.', '25.0')]
    [IntegrationEvent(false, false)]
    procedure OnGetSuggestedAmountForVendLedgerEntry(VendorLedgerEntry: Record "Vendor Ledger Entry";
                                                     var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                     ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    begin
    end;

    [Obsolete('This event is obsolete and will be removed in a future version. Please use the OnCollectSuggestedApplication event instead.', '25.0')]
    [IntegrationEvent(false, false)]
    procedure OnGetSuggestedAmountForEmplLedgerEntry(EmployeeLedgerEntry: Record "Employee Ledger Entry";
                                                     var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                     ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    begin
    end;

    [Obsolete('This event is obsolete and will be removed in a future version. Please use the CollectSuggestedApplication event instead.', '25.0')]
    [IntegrationEvent(false, false)]
    procedure OnGetSuggestedAmountForPurchAdvLetterHeader(PurchAdvLetterHeaderNo: Code[20];
                                                          var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
                                                          ExcludeTableID: Integer; ExcludeDocumentNo: Code[20]; ExcludeLineNo: Integer)
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    procedure OnSetAppliesToID(AppliesToID: Code[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCollectSuggestedApplication(CollectedForTableID: Integer; CollectedFor: Variant; CalledFrom: Variant; var CrossApplicationBufferCZL: Record "Cross Application Buffer CZL")
    begin
    end;
}
