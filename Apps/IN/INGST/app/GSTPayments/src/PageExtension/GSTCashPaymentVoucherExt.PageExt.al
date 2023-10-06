// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;


pageextension 18245 "GST Cash Payment Voucher Ext" extends "Cash Payment Voucher"
{
    layout
    {
        addafter("Account No.")
        {
            field("GST on Advance Payment"; Rec."GST on Advance Payment")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if GST is required to be calculated on Advance Payment.';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("GST Group Code"; Rec."GST Group Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST group code for the calculation of GST on journal line.';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("HSN/SAC Code"; Rec."HSN/SAC Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the HSN/SAC code for the calculation of GST on journal line.';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("GST TDS/GST TCS"; Rec."GST TDS/GST TCS")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if GST TCS or GST TDS is calculated on the journal line.';
                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("GST TCS State Code"; Rec."GST TCS State Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the state code for which GST TCS is applicable on the journal line.';
                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("GST TDS/TCS Base Amount"; Rec."GST TDS/TCS Base Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST TDS/TCS Base amount for the journal line.';
                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
        }
        modify(Amount)
        {
            trigger OnAfterValidate()
            begin
                CallTaxEngine();
            end;
        }
        modify("Account No.")
        {
            trigger OnAfterValidate()
            begin
                CallTaxEngine();
            end;
        }
        modify("Bal. Account No.")
        {
            trigger OnAfterValidate()
            begin
                CallTaxEngine();
            end;
        }
        modify("Document Type")
        {
            trigger OnAfterValidate()
            begin
                CallTaxEngine();
            end;
        }
        modify("Posting Date")
        {
            trigger OnAfterValidate()
            begin
                CallTaxEngine();
            end;
        }
        modify("Currency Code")
        {
            trigger OnAfterValidate()
            begin
                CallTaxEngine();
            end;
        }
    }
    local procedure CallTaxEngine()
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CurrPage.SaveRecord();
        CalculateTax.CallTaxEngineOnGenJnlLine(Rec, xRec);
    end;
}
