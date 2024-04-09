// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Finance.GeneralLedger.Setup;

codeunit 31352 "Banking Document Totals CZB"
{
    var
        TotalAmountLbl: Label 'Total';

    procedure GetTotalCaption(CurrencyCode: Code[10]): Text
    begin
        exit(GetCaptionWithCurrencyCode(TotalAmountLbl, CurrencyCode));
    end;

    local procedure GetCaptionWithCurrencyCode(CaptionWithoutCurrencyCode: Text; CurrencyCode: Code[10]): Text
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencySuffixTok: Label ' (%1)', Comment = '%1 = Currency Code', Locked = true;
    begin
        if CurrencyCode = '' then begin
            GeneralLedgerSetup.Get();
            CurrencyCode := GeneralLedgerSetup.GetCurrencyCode(CurrencyCode);
        end;

        if CurrencyCode <> '' then
            exit(CaptionWithoutCurrencyCode + StrSubstNo(CurrencySuffixTok, CurrencyCode));

        exit(CaptionWithoutCurrencyCode);
    end;

    procedure CalculatePaymentOrderTotals(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB"; PaymentOrderLineCZB: Record "Payment Order Line CZB")
    begin
        if PaymentOrderHeaderCZB.Get(PaymentOrderLineCZB."Payment Order No.") then
            PaymentOrderHeaderCZB.CalcFields("Amount (Pay.Order Curr.)");
    end;
}
