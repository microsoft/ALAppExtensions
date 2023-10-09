// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Payments;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

pageextension 18246 "GST General Journal Ext" extends "General Journal"
{
    layout
    {
        addafter("Account No.")
        {
            field("Tax Type"; Rec."Tax Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the tax type as selected from the given options';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("GST Component Code"; Rec."GST Component Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST component code for which the entry is being posted.';

                trigger OnLookup(var Text: Text): Boolean
                var
                    GSTSetup: Record "GST Setup";
                    TaxComponent: Record "Tax Component";
                begin
                    if not GSTSetup.Get() then
                        exit;

                    TaxComponent.Reset();
                    TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
                    if Page.RunModal(0, TaxComponent) = Action::LookupOK then
                        Rec.Validate("GST Component Code", TaxComponent.Name);
                end;

                trigger OnValidate()
                var
                    GSTSetup: Record "GST Setup";
                    TaxComponent: Record "Tax Component";
                begin
                    if Rec."GST Component Code" <> '' then begin
                        if not GSTSetup.get() then
                            exit;

                        TaxComponent.Reset();
                        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
                        TaxComponent.SetRange(Name, Rec."GST Component Code");
                        if TaxComponent.IsEmpty() then
                            Rec.FieldError("GST Component Code");
                    end;
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
            field("Without Bill Of Entry"; Rec."Without Bill Of Entry")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the journal line is without the Bill of Entry.';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("Bill of Entry No."; Rec."Bill of Entry No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the bill of entry number. It is a document number which is submitted to custom department';
            }
            field("Bill of Entry Date"; Rec."Bill of Entry Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Bill of Entry Date for the journal line.';
            }
            field("GST Assessable Value"; Rec."GST Assessable Value")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST Assessable Value for the journal line.';

                trigger OnValidate()
                begin
                    CallTaxEngine();
                end;
            }
            field("Custom Duty Amount"; Rec."Custom Duty Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Custom Duty amount for the journal line';

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
            field("Order Address Code"; "Order Address Code")
            {
                ApplicationArea = Basic, Suite;

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
