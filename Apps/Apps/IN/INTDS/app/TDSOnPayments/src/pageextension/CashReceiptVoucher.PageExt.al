// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

pageextension 18769 "Cash Receipt Voucher" extends "Cash Receipt Voucher"
{
    layout
    {
        addafter("Account No.")
        {
            field("TDS Section Code"; Rec."TDS Section Code")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'TDS Section Code';
                ToolTip = 'Specifies the Section Codes as per the Income Tax Act 1961 for e tds returns';

                trigger OnValidate()
                begin
                    UpdateTaxAmount();
                end;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    Rec.TDSSectionCodeLookupGenLine(Rec, Rec."Account No.", true);
                    UpdateTaxAmount();
                end;
            }
            field("Nature of Remittance"; Rec."Nature of Remittance")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Nature of Remittance';
                ToolTip = 'Specify the type of Remittance deductee deals with for which the journal line has been created.';

                trigger OnValidate()
                begin
                    UpdateTaxAmount();
                end;
            }
            field("Act Applicable"; Rec."Act Applicable")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Act Applicable';
                ToolTip = 'Specify the tax rates prescribed under the IT Act or DTAA for which the journal line has been created.';

                trigger OnValidate()
                begin
                    UpdateTaxAmount();
                end;
            }
            field("T.A.N. No."; Rec."T.A.N. No.")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'T.A.N. No.';
                ToolTip = 'Specifies the T.A.N. Number.';

                trigger OnValidate()
                begin
                    UpdateTaxAmount();
                end;
            }
            field("TDS Certificate Receivable"; Rec."TDS Certificate Receivable")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'TDS Certificate Receivable';
                ToolTip = 'Selected to allow calculating TDS for the customer.';
            }
        }
    }

    local procedure UpdateTaxAmount()
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CurrPage.SaveRecord();
        CalculateTax.CallTaxEngineOnGenJnlLine(Rec, xRec);
    end;
}
