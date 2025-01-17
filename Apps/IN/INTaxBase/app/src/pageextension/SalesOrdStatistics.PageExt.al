// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Finance.TaxBase;

pageextension 18571 "sales Ord. Statistics" extends "Sales Order Statistics"
{
    layout
    {
        addlast(General)
        {
            field("Total Amount"; TotalInclTaxAmount)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the amount, including Tax amount. On the General fast tab, this is the amount posted to the customer account for all the lines in the sales order if you post the sales order as invoiced.';
                Caption = 'Net Total';
            }
        }
        addlast(Invoicing)
        {
            field("Partial Inv. Amount"; PartailInclInvTaxAmount)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the amount, including Tax amount. On the Invoicing fast tab, this is the amount posted to the customer account for all the lines in the sales order if you post the sales order as invoiced.';
                Caption = 'Net Total';
            }
        }
        addlast(Shipping)
        {
            field("Partial Ship. Amount"; PartialInclShptTaxAmount)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the amount, including Tax amount. On the General fast tab, this is the amount posted to the customer account for all the lines in the sales order if you post the sales order as Shipped.';
                Caption = 'Net Total';
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        CalcStatistics: Codeunit "Calculate Statistics";
    begin
        CalcStatistics.GetSalesStatisticsAmount(Rec, TotalInclTaxAmount);
        CalcStatistics.GetPartialSalesInvStatisticsAmount(Rec, PartailInclInvTaxAmount);
        CalcStatistics.GetPartialSalesShptStatisticsAmount(Rec, PartialInclShptTaxAmount);
    end;

    var
        TotalInclTaxAmount: Decimal;
        PartailInclInvTaxAmount: Decimal;
        PartialInclShptTaxAmount: Decimal;
}
