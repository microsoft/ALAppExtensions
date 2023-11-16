// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.CashFlow.Forecast;
using Microsoft.CashFlow.Setup;
using Microsoft.Finance.Analysis;

pageextension 31197 "Cash Flow Avail. Lines CZZ" extends "Cash Flow Availability Lines"
{
    layout
    {
        addafter(Tax)
        {
            field(SalesAdvancesCZZ; Rec."Sales Advances CZZ")
            {
                ApplicationArea = Basic, Suite;
                AutoFormatExpression = FormatExpression();
                AutoFormatType = 11;
                Caption = 'Sales Advances';
                ToolTip = 'Specifies an amount of sales advances';

                trigger OnDrillDown()
                begin
                    CashFlowForecast.DrillDownSourceTypeEntries(Enum::"Cash Flow Source Type"::"Sales Advance Letters CZZ");
                end;
            }
            field(PurchaseAdvancesCZZ; Rec."Purchase Advances CZZ")
            {
                ApplicationArea = Basic, Suite;
                AutoFormatExpression = FormatExpression();
                AutoFormatType = 11;
                Caption = 'Purchase Advances';
                ToolTip = 'Specifies an amount of purchase advances';

                trigger OnDrillDown()
                begin
                    CashFlowForecast.DrillDownSourceTypeEntries(Enum::"Cash Flow Source Type"::"Purchase Advance Letters CZZ");
                end;
            }
        }
    }

    var
        MatrixManagementCZZ: Codeunit "Matrix Management";
        RoundingFactorFormatStringCZZ: Text;

    local procedure FormatExpression(): Text
    begin
        if RoundingFactorFormatStringCZZ <> '' then
            exit(RoundingFactorFormatStringCZZ);

        RoundingFactorFormatStringCZZ := MatrixManagementCZZ.FormatRoundingFactor(RoundingFactor, false);
    end;
}
