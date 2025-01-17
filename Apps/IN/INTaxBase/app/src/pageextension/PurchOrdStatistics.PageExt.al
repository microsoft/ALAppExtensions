// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.TaxBase;

pageextension 18567 "Purch. Ord. Statistics" extends "Purchase Order Statistics"
{
    layout
    {
        addlast(General)
        {
            field("Total Amount"; TotalInclTaxAmount)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the amount, including Tax amount. On the General fast tab, this is the amount posted to the vendor account for all the lines in the purchase order if you post the purchase order as invoiced.';
                Caption = 'Net Total';
            }
        }
        addlast(Invoicing)
        {
            field("Partial Inv. Amount"; PartialInclInvTaxAmount)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the amount, including Tax amount. On the Invoicing fast tab, this is the amount posted to the vendor account for all the lines in the purchase order if you post the purchase order as invoiced.';
                Caption = 'Net Total';
            }
        }
        addlast(Shipping)
        {
            field("Partial Ship. Amount"; PartialInclRcptTaxAmount)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the amount, including Tax amount. On the Shipping fast tab, this is the amount posted to the vendor account for all the lines in the purchase order if you post the purchase order as Shipped.';
                Caption = 'Net Total';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    local procedure GetTotalInclTaxAmount()
    var
        CalcStatistics: Codeunit "Calculate Statistics";
    begin
        CalcStatistics.GetPurchaseStatisticsAmount(Rec, TotalInclTaxAmount);
        CalcStatistics.GetPartialPurchaseInvStatisticsAmount(Rec, PartialInclInvTaxAmount);
        CalcStatistics.GetPartialPurchaseRcptStatisticsAmount(Rec, PartialInclRcptTaxAmount);
        Calculated := true;
    end;

    local procedure FormatLine()
    begin
        if not Calculated then
            GetTotalInclTaxAmount();
    end;

    var
        TotalInclTaxAmount: Decimal;
        PartialInclRcptTaxAmount: Decimal;
        PartialInclInvTaxAmount: Decimal;
        Calculated: Boolean;
}
