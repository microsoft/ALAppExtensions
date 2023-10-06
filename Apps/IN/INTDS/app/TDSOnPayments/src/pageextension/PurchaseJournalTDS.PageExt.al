// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TDS.TDSOnPayments;

pageextension 18768 "Purchase Journal TDS" extends "Purchase Journal"
{
    layout
    {
        addafter("Account No.")
        {
            field("Provisional Entry"; Rec."Provisional Entry")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Provisional Entry';
                ToolTip = 'Specifies whether this is a provisional entry or not.';

                trigger OnValidate()
                begin
                    UpdateTaxAmount();
                end;
            }
            field("Applied Provisional Entry"; Rec."Applied Provisional Entry")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Applied Provisional Entry';
                ToolTip = 'Specifies the applied provisional entry number.';
            }
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
            field("Include GST in TDS Base"; Rec."Include GST in TDS Base")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Select this field to include GST value in the TDS Base.';

                trigger OnValidate()
                begin
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
    }

    actions
    {
        addafter("F&unctions")
        {
            action("Apply Provisional Entry")
            {
                ApplicationArea = Basic, Suite;
                Image = Apply;
                ToolTip = 'Select this option to apply provisional entry against purchase invoice (actual entry).';

                trigger OnAction()
                var
                    ProvisionalEntry: Record "Provisional Entry";
                    ApplyProvisionalEntries: Page "Apply Provisional Entries";
                    AmtNegErr: Label 'Amount must be Negative.';
                begin
                    Rec.TestField("Account Type", Rec."Account Type"::Vendor);
                    Rec.TestField("Account No.");
                    Rec.TestField("Bal. Account Type", Rec."Bal. Account Type"::"G/L Account");
                    Rec.TestField("Document Type", Rec."Document Type"::Invoice);
                    Rec.TestField("Work Tax Nature Of Deduction", '');
                    Rec.TestField("TDS Section Code", '');
                    if Rec.Amount > 0 then
                        Error(AmtNegErr);

                    ProvisionalEntry.SetRange("Party Type", ProvisionalEntry."Party Type"::Vendor);
                    ProvisionalEntry.SetRange("Party Code", Rec."Account No.");
                    ProvisionalEntry.SetRange(Open, true);
                    ProvisionalEntry.SetRange(Reversed, false);
                    ProvisionalEntry.SetRange("Reversed After TDS Paid", false);
                    ApplyProvisionalEntries.SetGenJnlLine(Rec);
                    ApplyProvisionalEntries.SetTableView(ProvisionalEntry);
                    ApplyProvisionalEntries.LookupMode(true);
                    ProvisionalEntry.Update := ApplyProvisionalEntries.RunModal() = Action::LookupOK;
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
