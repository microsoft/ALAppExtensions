// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

using Microsoft.Finance.TaxBase;

pageextension 18569 "Posted Purch. Inv. Statistics" extends "Purchase Invoice Statistics"
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
    }
    trigger OnAfterGetRecord()
    var
        CalcStatistics: Codeunit "Calculate Statistics";
    begin
        CalcStatistics.GetPostedPurchInvStatisticsAmount(Rec, TotalInclTaxAmount);
    end;

    var
        TotalInclTaxAmount: Decimal;
}
