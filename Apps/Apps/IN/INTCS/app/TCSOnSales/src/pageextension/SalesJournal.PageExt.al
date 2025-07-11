// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.TaxBase;

pageextension 18840 "Sales Journal" extends "Sales Journal"
{
    layout
    {
        addbefore(Amount)
        {
            field("Location Code"; Rec."Location Code")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Location Code';
                ToolTip = 'Specifies the location code for which the journal lines will be posted.';
            }
            field("TCS Nature of Collection"; Rec."TCS Nature of Collection")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the TCS Nature of collection on which the TCS will be calculated for the Sales Journal.';
                trigger OnLookup(var Text: Text): Boolean
                begin
                    Rec.AllowedNOCLookup(Rec, Rec."Account No.");
                    UpdateTaxAmount();
                end;

                trigger OnValidate()
                begin
                    UpdateTaxAmount();
                end;
            }
            field("Excl. GST in TCS Base"; Rec."Excl. GST in TCS Base")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Select this field to exclude GST value in the TCS Base.';

                trigger OnValidate()
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
