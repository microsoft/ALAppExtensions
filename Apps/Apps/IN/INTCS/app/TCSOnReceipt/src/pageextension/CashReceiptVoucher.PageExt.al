// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

pageextension 18903 "Cash Receipt Voucher" extends "Cash Receipt Voucher"
{
    layout
    {
        addbefore(Amount)
        {
            field("TCS Nature of Collection"; Rec."TCS Nature of Collection")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the TCS Nature of collection on which the TCS will be calculated for the journal line.';
                trigger OnLookup(var Text: Text): Boolean
                begin
                    Rec.AllowedNOCLookup(Rec, Rec."Account No.");
                    UpdateTaxAmount();
                end;

                trigger OnValidate()
                var
                begin
                    UpdateTaxAmount();
                end;
            }
            field("T.C.A.N. No."; Rec."T.C.A.N. No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the T.C.A.N. number of the person who is responsible for collecting tax.';
                trigger OnValidate()
                begin
                    UpdateTaxAmount();
                end;
            }
            field("TCS On Recpt. Of Pmt. Amount"; Rec."TCS On Recpt. Of Pmt. Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Select this field for calculating TCS on receipt of payment amount. TCS Base amount will be considered from this field instead of transaction amount.';

                trigger OnValidate()
                begin
                    UpdateTaxAmount();
                end;
            }
        }
        modify(Amount)
        {
            trigger OnAfterValidate()
            begin
                Rec.CheckTCSOnRecptOfPmtAmount();
                UpdateTaxAmount();
            end;
        }
        modify("Credit Amount")
        {
            trigger OnAfterValidate()
            begin
                Rec.CheckTCSOnRecptOfPmtAmount();
                UpdateTaxAmount();
            end;
        }
        modify("Debit Amount")
        {
            trigger OnAfterValidate()
            begin
                Rec.CheckTCSOnRecptOfPmtAmount();
                UpdateTaxAmount();
            end;
        }
        modify("Amount (LCY)")
        {
            trigger OnAfterValidate()
            begin
                Rec.CheckTCSOnRecptOfPmtAmount();
                UpdateTaxAmount();
            end;
        }
        modify("Currency Code")
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
        modify("Document Type")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
    }
    actions
    {
        addafter("Insert Conv. LCY Rndg. Lines")
        {
            action("Get Open Posted Lines For TCS On Payment Calculation")
            {
                Caption = 'Get Open Posted Lines For TCS On Payment Calculation';
                ApplicationArea = Basic, Suite;
                Image = CarryOutActionMessage;
                ToolTip = 'Use this function to select posted sales lines for updating amount in TCS on Recpt. Of Pmt. Amount on payment line.';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.GetOpenPostedLinesForTCSOnPaymentCalculation(Rec);
                    CurrPage.Update(true);
                    UpdateTaxAmount();
                end;
            }
        }
    }

    procedure UpdateTaxAmount()
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CurrPage.SaveRecord();
        CalculateTax.CallTaxEngineOnGenJnlLine(Rec, xRec);
    end;
}
