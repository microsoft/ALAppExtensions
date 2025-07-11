// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.Finance.TaxBase;

pageextension 18572 "Sales Inv. Statistics" extends "Sales Statistics"
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
    }

    trigger OnAfterGetRecord()
    var
        CalcStatistics: Codeunit "Calculate Statistics";
    begin
        CalcStatistics.GetSalesStatisticsAmount(Rec, TotalInclTaxAmount);
    end;

    var
        TotalInclTaxAmount: Decimal;
}
