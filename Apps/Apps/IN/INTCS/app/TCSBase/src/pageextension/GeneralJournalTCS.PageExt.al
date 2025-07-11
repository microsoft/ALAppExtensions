// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.TaxBase;

pageextension 18809 "General Journal TCS" extends "General Journal"
{
    layout
    {
        addafter("Account No.")
        {
            field("TCS Nature of Collection"; Rec."TCS Nature of Collection")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Nature of Collection for the journal line.';

                trigger OnLookup(var Text: Text): Boolean
                begin
                    Rec.AllowedNocLookup(Rec, Rec."Account No.");
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
        modify("Account No.")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
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
