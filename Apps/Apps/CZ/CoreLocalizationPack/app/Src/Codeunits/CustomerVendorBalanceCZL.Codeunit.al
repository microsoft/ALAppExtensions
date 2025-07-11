// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ReceivablesPayables;

using Microsoft.Finance.Currency;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

codeunit 31058 "Customer Vendor Balance CZL"
{
    procedure FillCustomerVendorBuffer(var TempCurrency: Record Currency temporary; var TempCVLedgerEntryBuffer: Record "CV Ledger Entry Buffer" temporary; CustomerNo: Code[20]; VendorNo: Code[20]; AtDate: Date; AmountsInCurrency: Boolean)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        NextEntryNo: Integer;
    begin
        TempCurrency.Reset();
        TempCurrency.DeleteAll();
        TempCVLedgerEntryBuffer.Reset();
        TempCVLedgerEntryBuffer.DeleteAll();

        if not AmountsInCurrency then begin
            TempCurrency.Code := '';
            TempCurrency.Insert();
        end;

        CustLedgerEntry.SetCurrentKey(CustLedgerEntry."Customer No.", CustLedgerEntry."Posting Date", CustLedgerEntry."Currency Code");
        CustLedgerEntry.SetRange(CustLedgerEntry."Customer No.", CustomerNo);
        CustLedgerEntry.SetFilter(CustLedgerEntry."Posting Date", '..%1', AtDate);
        if CustLedgerEntry.FindSet() then
            repeat
                CustLedgerEntry.SetFilter(CustLedgerEntry."Date Filter", '..%1', AtDate);
                CustLedgerEntry.CalcFields(CustLedgerEntry."Remaining Amount");
                if CustLedgerEntry."Remaining Amount" <> 0 then begin
                    NextEntryNo += 1;
                    TempCVLedgerEntryBuffer."Entry No." := NextEntryNo;
                    TempCVLedgerEntryBuffer."Document Date" := CustLedgerEntry."Document Date";
                    TempCVLedgerEntryBuffer."Document Type" := CustLedgerEntry."Document Type";
                    TempCVLedgerEntryBuffer."Document No." := CustLedgerEntry."Document No.";
                    TempCVLedgerEntryBuffer."External Document No." := CustLedgerEntry."External Document No.";
                    TempCVLedgerEntryBuffer."Currency Code" := CustLedgerEntry."Currency Code";
                    TempCVLedgerEntryBuffer."Due Date" := CustLedgerEntry."Due Date";
                    CustLedgerEntry.CalcFields(CustLedgerEntry.Amount, CustLedgerEntry."Remaining Amount", CustLedgerEntry."Remaining Amt. (LCY)");
                    TempCVLedgerEntryBuffer.Amount := CustLedgerEntry.Amount;
                    TempCVLedgerEntryBuffer."Remaining Amount" := CustLedgerEntry."Remaining Amount";
                    TempCVLedgerEntryBuffer."Remaining Amt. (LCY)" := CustLedgerEntry."Remaining Amt. (LCY)";
                    OnFillCustomerVendorBufferOnBeforeInsertCustLedgerEntry(TempCVLedgerEntryBuffer, CustLedgerEntry);
                    TempCVLedgerEntryBuffer.Insert();
                    if AmountsInCurrency then
                        if not TempCurrency.Get(CustLedgerEntry."Currency Code") then begin
                            TempCurrency.Code := CustLedgerEntry."Currency Code";
                            TempCurrency.Insert();
                        end;
                end;
            until CustLedgerEntry.Next() = 0;

        VendorLedgerEntry.SetCurrentKey(VendorLedgerEntry."Vendor No.", VendorLedgerEntry."Posting Date", VendorLedgerEntry."Currency Code");
        VendorLedgerEntry.SetRange(VendorLedgerEntry."Vendor No.", VendorNo);
        VendorLedgerEntry.SetFilter(VendorLedgerEntry."Posting Date", '..%1', AtDate);
        if VendorLedgerEntry.FindSet() then
            repeat
                VendorLedgerEntry.SetFilter(VendorLedgerEntry."Date Filter", '..%1', AtDate);
                VendorLedgerEntry.CalcFields(VendorLedgerEntry."Remaining Amount");
                if VendorLedgerEntry."Remaining Amount" <> 0 then begin
                    NextEntryNo += 1;
                    TempCVLedgerEntryBuffer."Entry No." := NextEntryNo;
                    TempCVLedgerEntryBuffer."Document Date" := VendorLedgerEntry."Document Date";
                    TempCVLedgerEntryBuffer."Document Type" := VendorLedgerEntry."Document Type";
                    TempCVLedgerEntryBuffer."Document No." := VendorLedgerEntry."Document No.";
                    TempCVLedgerEntryBuffer."External Document No." := VendorLedgerEntry."External Document No.";
                    TempCVLedgerEntryBuffer."Currency Code" := VendorLedgerEntry."Currency Code";
                    TempCVLedgerEntryBuffer."Due Date" := VendorLedgerEntry."Due Date";
                    VendorLedgerEntry.CalcFields(VendorLedgerEntry.Amount, VendorLedgerEntry."Remaining Amount", VendorLedgerEntry."Remaining Amt. (LCY)");
                    TempCVLedgerEntryBuffer.Amount := VendorLedgerEntry.Amount;
                    TempCVLedgerEntryBuffer."Remaining Amount" := VendorLedgerEntry."Remaining Amount";
                    TempCVLedgerEntryBuffer."Remaining Amt. (LCY)" := VendorLedgerEntry."Remaining Amt. (LCY)";
                    OnFillCustomerVendorBufferOnBeforeInsertVendorLedgerEntry(TempCVLedgerEntryBuffer, VendorLedgerEntry);
                    TempCVLedgerEntryBuffer.Insert();
                    if AmountsInCurrency then
                        if not TempCurrency.Get(VendorLedgerEntry."Currency Code") then begin
                            TempCurrency.Code := VendorLedgerEntry."Currency Code";
                            TempCurrency.Insert();
                        end;
                end;
            until VendorLedgerEntry.Next() = 0;
    end;

    procedure CalcCustomerVendorBalance(CustomerNo: Code[20]; VendorNo: Code[20]; CurrencyCode: Code[10]; Date: Date; InLCY: Boolean) BalanceAmount: Decimal
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        if CustomerNo <> '' then begin
            Customer.Get(CustomerNo);
            Customer.SetFilter("Date Filter", '..%1', Date);
            if InLCY then
                Customer.CalcFields("Net Change (LCY)")
            else begin
                Customer.SetFilter("Currency Filter", '%1', CurrencyCode);
                Customer.CalcFields("Net Change");
            end;
        end;
        if VendorNo <> '' then begin
            Vendor.Get(VendorNo);
            Vendor.SetFilter("Date Filter", '..%1', Date);
            if InLCY then
                Vendor.CalcFields("Net Change (LCY)")
            else begin
                Vendor.SetFilter("Currency Filter", '%1', CurrencyCode);
                Vendor.CalcFields("Net Change");
            end;
        end;
        if InLCY then
            BalanceAmount := Customer."Net Change (LCY)" - Vendor."Net Change (LCY)"
        else
            BalanceAmount := Customer."Net Change" - Vendor."Net Change";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFillCustomerVendorBufferOnBeforeInsertCustLedgerEntry(var TempCVLedgerEntryBuffer: Record "CV Ledger Entry Buffer" temporary; CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFillCustomerVendorBufferOnBeforeInsertVendorLedgerEntry(var TempCVLedgerEntryBuffer: Record "CV Ledger Entry Buffer" temporary; VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
    end;
}
