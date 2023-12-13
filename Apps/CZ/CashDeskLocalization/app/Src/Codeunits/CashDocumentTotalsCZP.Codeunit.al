// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.GeneralLedger.Setup;

codeunit 11714 "Cash Document Totals CZP"
{
    var
        TotalVATLbl: Label 'Total VAT';
        TotalAmountInclVatLbl: Label 'Total Incl. VAT';
        TotalAmountExclVATLbl: Label 'Total Excl. VAT';

    procedure GetTotalVATCaption(CurrencyCode: Code[10]): Text
    begin
        exit(GetCaptionClassWithCurrencyCode(TotalVATLbl, CurrencyCode));
    end;

    procedure GetTotalInclVATCaption(CurrencyCode: Code[10]): Text
    begin
        exit(GetCaptionClassWithCurrencyCode(TotalAmountInclVatLbl, CurrencyCode));
    end;

    procedure GetTotalExclVATCaption(CurrencyCode: Code[10]): Text
    begin
        exit(GetCaptionClassWithCurrencyCode(TotalAmountExclVATLbl, CurrencyCode));
    end;

    local procedure GetCaptionClassWithCurrencyCode(CaptionWithoutCurrencyCode: Text; CurrencyCode: Code[10]): Text
    begin
        exit('3,' + GetCaptionWithCurrencyCode(CaptionWithoutCurrencyCode, CurrencyCode));
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

    procedure CalculateCashDocumentTotals(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var VATAmount: Decimal; CashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
        if CashDocumentHeaderCZP.Get(CashDocumentLineCZP."Cash Desk No.", CashDocumentLineCZP."Cash Document No.") then begin
            CashDocumentHeaderCZP.CalcFields("VAT Base Amount", "Amount Including VAT");
            VATAmount := CashDocumentHeaderCZP."Amount Including VAT" - CashDocumentHeaderCZP."VAT Base Amount";
        end;
    end;

    procedure CalculatePostedCashDocumentTotals(var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var VATAmount: Decimal; PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP")
    begin
        if PostedCashDocumentHdrCZP.Get(PostedCashDocumentLineCZP."Cash Desk No.", PostedCashDocumentLineCZP."Cash Document No.") then begin
            PostedCashDocumentHdrCZP.CalcFields("VAT Base Amount", "Amount Including VAT");
            VATAmount := PostedCashDocumentHdrCZP."Amount Including VAT" - PostedCashDocumentHdrCZP."VAT Base Amount";
        end;
    end;
}
