// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.CashFlow.Forecast;
using Microsoft.CashFlow.Setup;

pageextension 31196 "CF Forecast Stat. FactBox CZZ" extends "CF Forecast Statistics FactBox"
{
    layout
    {
        addafter(Tax)
        {
            field(SalesAdvancesCZZ; Rec.CalcSourceTypeAmount(Enum::"Cash Flow Source Type"::"Sales Advance Letters CZZ"))
            {
                Caption = 'Sales Advances';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies an amount of sales advances.';

                trigger OnDrillDown()
                begin
                    Rec.DrillDownSourceTypeEntries(Enum::"Cash Flow Source Type"::"Sales Advance Letters CZZ");
                end;
            }
            field(PurchaseAdvancesCZZ; Rec.CalcSourceTypeAmount(Enum::"Cash Flow Source Type"::"Purchase Advance Letters CZZ"))
            {
                Caption = 'Purchase Advances';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies an amount of purchase advances.';

                trigger OnDrillDown()
                begin
                    Rec.DrillDownSourceTypeEntries(Enum::"Cash Flow Source Type"::"Purchase Advance Letters CZZ");
                end;
            }
        }
    }
}
