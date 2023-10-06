// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TDS.TDSReturnAndSettlement;

pageextension 18746 "Payment Jnl" extends "Payment Journal"
{
    layout
    {
        addbefore(Amount)
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
                ToolTip = 'Specify the type of Remittance deductee deals with for which the journal line has been created.';

                trigger OnValidate()
                begin
                    Rec.CheckNonResidentsPaymentSelection();
                    UpdateTaxAmount();
                end;
            }
            field("Act Applicable"; Rec."Act Applicable")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specify the tax rates prescribed under the IT Act or DTAA for which the journal line has been created.';

                trigger OnValidate()
                begin
                    Rec.CheckNonResidentsPaymentSelection();
                    UpdateTaxAmount();
                end;
            }
        }
        modify(Amount)
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Amount (LCY)")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Posting Date")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Account No.")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Bal. Account No.")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
    }

    actions
    {
        addafter("&Payments")
        {
            group("Pay TDS")
            {
                action(TDS)
                {
                    Caption = 'TDS';
                    ApplicationArea = Basic, Suite;
                    Image = CollectedTax;
                    ToolTip = 'Select TDS to open Pay TDS page that will show all TDS entries.';

                    trigger OnAction()
                    var
                        TDSPay: Codeunit "TDS Pay";
                    begin
                        TDSPay.PayTDS(Rec);
                    end;
                }
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
