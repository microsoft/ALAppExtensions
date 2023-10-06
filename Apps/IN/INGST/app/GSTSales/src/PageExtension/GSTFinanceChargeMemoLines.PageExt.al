// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.FinanceCharge;

using Microsoft.Finance.TaxBase;

pageextension 18162 "GST Finance Charge Memo Lines" extends "Finance Charge Memo Lines"
{
    layout
    {
        addlast(Control1)
        {
            field("GST Place of Supply"; Rec."GST Place of Supply")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the location state code which system should consider for GST calculation.';
            }
            field("GST Group Code"; Rec."GST Group Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies an identifier for the GST group used to calculate and post GST.';

                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CalculateTax.CallTaxEngineOnFinanceChargeMemoLine(Rec, xRec);
                end;
            }
            field("HSN/SAC Code"; Rec."HSN/SAC Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies an unique identifier for the type of HSN or SAC that is used to calculate and post GST.';

                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CalculateTax.CallTaxEngineOnFinanceChargeMemoLine(Rec, xRec);
                end;
            }
            field("GST Group Type"; Rec."GST Group Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the GST group is assigned for goods or service.';
            }
            field("GST Jurisdiction Type"; Rec."GST Jurisdiction Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type related to GST jurisdiction. For example, interstate/intrastate.';
            }
            field(Exempted; Rec.Exempted)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the shipment line is exempted of GST.';

                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CalculateTax.CallTaxEngineOnFinanceChargeMemoLine(Rec, xRec);
                end;
            }
            field("Non-GST Line"; Rec."Non-GST Line")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether this is a non GST line or not.';

                trigger OnValidate()
                var
                    CalculateTax: Codeunit "Calculate Tax";
                begin
                    CalculateTax.CallTaxEngineOnFinanceChargeMemoLine(Rec, xRec);
                end;
            }
        }
    }
}
