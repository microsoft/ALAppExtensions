namespace Microsoft.Purchases.History;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using System.Utilities;
using Microsoft.Finance.Currency;

reportextension 11705 "Purchase Credit Memo CZL" extends "Purchase - Credit Memo"
{
    dataset
    {
        modify("Purch. Cr. Memo Hdr.")
        {
            trigger OnAfterAfterGetRecord()
            var
                PurchCrMemoLine: Record "Purch. Cr. Memo Line";
            begin
                if UseFunctionalCurrency then begin
                    AdditionalTempVATAmountLine.DeleteAll();
                    PurchCrMemoLine.CalcVATAmountLines("Purch. Cr. Memo Hdr.", AdditionalTempVATAmountLine);
                    AdditionalTempVATAmountLine.UpdateVATEntryLCYAmountsCZL("Purch. Cr. Memo Hdr.");
                end;
            end;
        }
        addafter(VATCounterLCY)
        {
            dataitem(VATCounterCZL; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(VALExchRateCZL; VALExchRateCZL)
                {
                }
                column(VALSpecHeaderCZL; VALSpecHeaderCZL)
                {
                }
                column(VALVATAmountCZL; VALVATAmountCZL)
                {
                    AutoFormatType = 1;
                }
                column(VALVATBaseCZL; VALVATBaseCZL)
                {
                    AutoFormatType = 1;
                }
                column(VATAmountLineVAT_VATCounterCZL; AdditionalTempVATAmountLine."VAT %")
                {
                    DecimalPlaces = 0 : 5;
                }
                column(VATAmtLineVATIdentifier_VATCounterCZL; AdditionalTempVATAmountLine."VAT Identifier")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if not UseFunctionalCurrency then begin
                        AdditionalTempVATAmountLine.GetLine(Number);
                        VALVATBaseCZL :=
                          AdditionalTempVATAmountLine.GetBaseLCY(
                            "Purch. Cr. Memo Hdr."."Posting Date", "Purch. Cr. Memo Hdr."."Currency Code",
                            "Purch. Cr. Memo Hdr."."Currency Factor");
                        VALVATAmountCZL :=
                          AdditionalTempVATAmountLine.GetAmountLCY(
                            "Purch. Cr. Memo Hdr."."Posting Date", "Purch. Cr. Memo Hdr."."Currency Code",
                            "Purch. Cr. Memo Hdr."."Currency Factor");
                    end else begin
                        AdditionalTempVATAmountLine.GetLine(Number);
                        VALVATBaseCZL := AdditionalTempVATAmountLine."Additional-Currency Base CZL";
                        VALVATAmountCZL := AdditionalTempVATAmountLine."Additional-Currency Amount CZL";
                    end;
                end;

                trigger OnPreDataItem()
                var
                    CurrencyExchangeRate: Record "Currency Exchange Rate";
                    CalculatedExchRate: Decimal;
                begin
                    if UseFunctionalCurrency then
                        if "Purch. Cr. Memo Hdr."."Currency Code" = GeneralLedgerSetup."Additional Reporting Currency" then
                            CurrReport.Break();

                    if ((not GeneralLedgerSetup."Print VAT specification in LCY") or
                       ("Purch. Cr. Memo Hdr."."Currency Code" = '')) and not UseFunctionalCurrency
                    then
                        CurrReport.Break();

                    if UseFunctionalCurrency and not (("Purch. Cr. Memo Hdr."."Additional Currency Factor CZL" <> 0) and ("Purch. Cr. Memo Hdr."."Additional Currency Factor CZL" <> 1)) then
                        CurrReport.Break();

                    SetRange(Number, 1, AdditionalTempVATAmountLine.Count);
                    Clear(VALVATBaseCZL);
                    Clear(VALVATAmountCZL);

                    if GeneralLedgerSetup."LCY Code" = '' then
                        VALSpecHeaderCZL := VATAmountSpecificationTxt + LocalCurrencyTxt
                    else
                        VALSpecHeaderCZL := VATAmountSpecificationTxt + Format(GeneralLedgerSetup."LCY Code");

                    if not UseFunctionalCurrency then begin
                        CurrencyExchangeRate.FindCurrency("Purch. Cr. Memo Hdr."."Posting Date", "Purch. Cr. Memo Hdr."."Currency Code", 1);
                        CalculatedExchRate := Round(1 / "Purch. Cr. Memo Hdr."."Currency Factor" * CurrencyExchangeRate."Exchange Rate Amount", 0.000001);
                        VALExchRateCZL := StrSubstNo(ExchangeRateTxt, CalculatedExchRate, CurrencyExchangeRate."Exchange Rate Amount");
                    end else
                        if ("Purch. Cr. Memo Hdr."."Additional Currency Factor CZL" <> 0) and ("Purch. Cr. Memo Hdr."."Additional Currency Factor CZL" <> 1) then begin
                            VALSpecHeaderCZL := VATAmountSpecificationTxt + Format(GeneralLedgerSetup."Additional Reporting Currency");
                            CurrencyExchangeRate.FindCurrency("Purch. Cr. Memo Hdr."."Posting Date", GeneralLedgerSetup."Additional Reporting Currency", 1);
                            CalculatedExchRate := Round(1 / "Purch. Cr. Memo Hdr."."Additional Currency Factor CZL" * CurrencyExchangeRate."Exchange Rate Amount", 0.00001);
                            VALExchRateCZL := StrSubstNo(ExchangeRateTxt, CalculatedExchRate, CurrencyExchangeRate."Exchange Rate Amount");
                        end;
                end;
            }
        }
    }

    rendering
    {
        layout(FunctioanlCurrency)
        {
            Type = RDLC;
            LayoutFile = './Src/ReportExtensions/PurchaseCreditMemoCZL.rdl';
            Caption = 'Purchase Credit Memo Functional Currency (rdl)';
            Summary = 'The Purchase Credit Memo Functional Currency (rdl) provides a detailed layout.';
        }
    }

    trigger OnPreReport()
    begin
        GeneralLedgerSetup.Get();
        UseFunctionalCurrency := GeneralLedgerSetup."Functional Currency CZL";
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        AdditionalTempVATAmountLine: Record "VAT Amount Line" temporary;
        UseFunctionalCurrency: Boolean;
        VALVATBaseCZL: Decimal;
        VALVATAmountCZL: Decimal;
        VALSpecHeaderCZL: Text[80];
        VALExchRateCZL: Text[50];
        VATAmountSpecificationTxt: Label 'VAT Amount Specification in ';
        LocalCurrencyTxt: Label 'Local Currency';
        ExchangeRateTxt: Label 'Exchange rate: %1/%2', Comment = '%1 = Calculated Exchange Rate, %2 = Exchnage Rate Amount';
}
