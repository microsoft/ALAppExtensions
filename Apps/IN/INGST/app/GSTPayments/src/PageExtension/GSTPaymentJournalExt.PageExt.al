// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.GST.Payments;
using Microsoft.Finance.TaxBase;

pageextension 18250 "GST Payment Journal Ext" extends "Payment Journal"
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
            field("Amount Excl. GST"; Rec."Amount Excl. GST")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Amount Excluding GST for the journal line.';

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
            }
            field("GST Group Code"; Rec."GST Group Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST Group code for the calculation of GST on journal line.';

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
            field("GST Credit"; Rec."GST Credit")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the GST Credit has to be availed or not.';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("Location State Code"; Rec."Location State Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the sate code mentioned in location used in the transaction.';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("GST Group Type"; Rec."GST Group Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the GST Group is of goods or service category for the journal line.';
            }
            field("Vendor GST Reg. No."; Rec."Vendor GST Reg. No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST registration number of the Vendor specified on the journal line.';
            }
            field("Location GST Reg. No."; Rec."Location GST Reg. No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST registration number of the Location specified on the journal line.';
            }
            field("GST Vendor Type"; Rec."GST Vendor Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST Vendor type for the vendor specified in account number field on journal line.';
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
        modify("Location Code")
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
