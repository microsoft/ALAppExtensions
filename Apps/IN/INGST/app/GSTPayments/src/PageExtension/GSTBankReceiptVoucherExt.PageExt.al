// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

using Microsoft.Finance.GST.Payments;

pageextension 18244 "GST Bank Receipt Voucher Ext" extends "Bank Receipt Voucher"
{
    layout
    {
        addafter("Account No.")
        {
            field("Location Code"; Rec."Location Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the location code for which the journal lines will be posted.';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("GST on Advance Payment"; Rec."GST on Advance Payment")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if GST is required to be calculated on Advance Payment.';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("Amount Excl. GST"; Rec."Amount Excl. GST")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the amount excluding GST for the journal line.';

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
                ToolTip = 'Specifies the state code for which GST TCS is applicable.';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("GST TDS/TCS Base Amount"; Rec."GST TDS/TCS Base Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST TDS/TCS base amount for the journal line.';

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
            field("Location State Code"; Rec."Location State Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the sate code mentioned in location used in the transaction.';
            }
            field("GST Group Type"; Rec."GST Group Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the GST Group is of goods or services category for the journal line.';
            }
            field("Customer GST Reg. No."; Rec."Customer GST Reg. No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST Registration number of the Customer specified on the journal line.';
            }
            field("Location GST Reg. No."; Rec."Location GST Reg. No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST Registration number of the Location specified on the journal line.';
            }
            field("GST Vendor Type"; Rec."GST Vendor Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of GST registration or the vendor. For example, Registered/Un-registered/Import/Composite/Exempted/SEZ.';
            }
            field("Bank Charge"; Rec."Bank Charge")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the entry is related to bank charges or not.';
            }
            field("Ship-to Code"; Rec."Ship-to Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies this Ship-to-Code for the customer related transactions';
            }
            field("GST Place of Supply"; Rec."GST Place of Supply")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the state based on customer of Ship-to-Code';
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
    actions
    {
        addafter("&Line")
        {
            action("Bank Charges")
            {
                ApplicationArea = All;
                Caption = 'Bank Charges';
                Image = BankContact;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'View or change Bank Charges of Bank Payment Voucher';
                RunObject = Page "Journal Bank Charges";
                RunPageView = SORTING("Journal Template Name", "Journal Batch Name", "Line No.", "Bank Charge");
                RunPageLink = "Journal Template Name" = FIELD("Journal Template Name"), "Journal Batch Name" = FIELD("Journal Batch Name"), "Line No." = FIELD("Line No.");
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
