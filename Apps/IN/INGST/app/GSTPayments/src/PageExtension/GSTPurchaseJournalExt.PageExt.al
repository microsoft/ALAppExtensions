// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.TaxBase;

pageextension 18248 "GST Purchase Journal Ext" extends "Purchase Journal"
{
    layout
    {
        addafter("Account No.")
        {
            field("Party Type"; Rec."Party Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of party that the entry on the journal line will be posted to.';
            }
            field("Party Code"; Rec."Party Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the party number that the entry on the journal line will be posted to.';
            }
            field("Without Bill Of Entry"; Rec."Without Bill Of Entry")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if purchase document is without bill of entry.';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("Bill of Entry No."; Rec."Bill of Entry No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the bill of entry number. It is a document number which is submitted to custom department .';
            }
            field("Bill of Entry Date"; Rec."Bill of Entry Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the entry date defined in bill of entry document.';
            }
            field("GST Assessable Value"; Rec."GST Assessable Value")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST assessable value on the Journal line';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("Custom Duty Amount"; Rec."Custom Duty Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the custom duty amount  on the Journal line.';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("GST Customer Type"; Rec."GST Customer Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of GST registration or the vendor, for example Registered-registered, Export, Deemed Export etc.';
            }
            field("GST Vendor Type"; Rec."GST Vendor Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of GST registration for the vendor. For example, Registered/Un-registered/Import/composite/Exempted etc.';
            }
            field("GST Group Code"; Rec."GST Group Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies an unique identifier for the GST group code used to calculate and post GST.';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("HSN/SAC Code"; Rec."HSN/SAC Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies an unique identifier for the type of HSN or SAC that is used to calculate and post GST.';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("Exempted"; Rec."Exempted")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the service is exempted from GST';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("GST Credit"; Rec."GST Credit")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the GST credit has to be availed or not.';
                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("POS Out of India"; Rec."POS Out of India")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the place of supply of invoice is out of India.';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("POS as Vendor State"; Rec."POS as Vendor State")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the vendor state code';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("Order Address Code"; "Order Address Code")
            {
                ApplicationArea = Basic, Suite;

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("GST Input Service Distribution"; Rec."GST Input Service Distribution")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the location is a GST input service distributor.';
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
        modify("Location Code")
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

    actions
    {
        addafter(IncomingDocument)
        {
            action("Update Reference Invoice No.")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                Image = ApplyEntries;
                ToolTip = 'Specifies the function through which reference number can be updated in the document.';

                trigger OnAction()
                var
                    i: Integer;
                begin
                    i := 0;
                    //blank OnAction created as we have a subscriber of this action in "Reference Invoice No. Mgt." codeunit;
                end;
            }
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
