// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

page 6788 "Withholding Tax Entry"
{
    Caption = 'Withholding Tax Entry';
    Editable = false;
    PageType = List;
    SourceTable = "Withholding Tax Entry";

    layout
    {
        area(content)
        {
            repeater(GroupName)
            {
                ShowCaption = false;
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an auto-generated unique key for every transaction in this table.';
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the value is assigned from Gen. Bus. Posting Group in the Sales/Purchase/Journal transaction.';
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value is assigned from Gen. Prod. Posting Group in the Sales/Purchase/Journal transaction.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the original entry was posted.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the original transaction.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value is assigned from Document Type in the Sales/Purchase/Journal transaction.';
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source of the transaction.';
                }
                field(Base; Rec.Base)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the calculated withholding tax base amount.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the calculated withholding tax amount.';
                }
                field("Withholding Tax Calculation Type"; Rec."Withholding Tax Calc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the withholding tax calculation type.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the value of Specifies that this field is assigned from Currency Code in the Sales/Purchase/Journal transaction.';
                }
                field("Bill-to/Pay-to No."; Rec."Bill-to/Pay-to No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the Bill-to Customer or Pay-to Vendor that the entry is linked to.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the user that is associated with the entry.';
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source code that is linked to the Withholding Tax entry.';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reason code for the entry.';
                }
                field("Closed by Entry No."; Rec."Closed by Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry number of the Withholding Tax entry that has been applied to (that has closed) the entry.';
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the entry has been closed for transactions.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country code for the customer or vendor that the Withholding Tax entry is linked to.';
                }
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction number assigned to the entry.';
                }
                field("Unrealized Amount"; Rec."Unrealized Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the withholding tax amount in the original currency that will be realized during payment as calculated during the posting of the document.';
                }
                field("Unrealized Base"; Rec."Unrealized Base")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the base amount in the original currency that the Withholding Tax Amount was calculated from.';
                }
                field("Remaining Unrealized Amount"; Rec."Remaining Unrealized Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the calculated remaining Withholding Tax amount.';
                }
                field("Remaining Unrealized Base"; Rec."Remaining Unrealized Base")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the calculated remaining base amount.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the external document number for this entry.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series that the document number on this entry belongs to.';
                }
                field("Unreal. Wthldg. Tax Entry No."; Rec."Unreal. Wthldg. Tax Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the original Withholding Tax entry with the unrealized Withholding Tax amount.';
                }
                field("Wthldg. Tax Bus. Post. Group"; Rec."Wthldg. Tax Bus. Post. Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Withholding Tax Business Posting group code that was used when the entry was posted.';
                }
                field("Wthldg. Tax Prod. Post. Group"; Rec."Wthldg. Tax Prod. Post. Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Withholding Tax Product Posting group code that was used when the entry was posted.';
                }
                field("Base (LCY)"; Rec."Base (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Base Amount in LCY of the Withholding Tax, which is realized during this transaction.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Withholding Tax Amount in LCY of the Withholding Tax, which is realized during this transaction.';
                }
                field("Unrealized Amount (LCY)"; Rec."Unrealized Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the withholding tax amount that will be realized during payment as calculated during the posting of the document.';
                }
                field("Unrealized Base (LCY)"; Rec."Unrealized Base (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the base amount in your currency that the Withholding Tax Amount was calculated from.';
                }
                field("Withholding Tax %"; Rec."Withholding Tax %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the withholding tax percent used for calculations during this transaction.';
                }
                field("Rem Unrealized Amount (LCY)"; Rec."Rem Unrealized Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Remaining Unrealized Amount in LCY left for a particular transaction is stored.';
                }
                field("Rem Unrealized Base (LCY)"; Rec."Rem Unrealized Base (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Remaining Unrealized Base in LCY left for a particular transaction is stored.';
                }
                field("Withholding Tax Difference"; Rec."Withholding Tax Difference")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the difference between the Unrealized and Realized Withholding Tax.';
                }
                field("Ship-to/Order Address Code"; Rec."Ship-to/Order Address Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address of the entry.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Document Date from the applied Withholding Tax Entry is stored for applying the Withholding Tax Entry table.';
                }
                field("Actual Vendor No."; Rec."Actual Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Actual Vendor No. from which Invoices or Journals is copied.';
                }
                field("Withholding Certificate No."; Rec."Wthldg. Tax Certificate No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an auto-generated no. based on the no. series.';
                }
                field("Void Check"; Rec."Void Check")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that this field is marked internally if the transactions have been reversed due to voiding of checks.';
                }
                field("Original Document No."; Rec."Original Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the original document no. from the Invoice or Journal is assigned to this field.';
                }
                field("Void Payment Entry No."; Rec."Void Payment Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry no. of the Withholding Tax Entry, which has been voided, with this transaction.';
                }
                field("Wthldg. Tax Report Line No"; Rec."Wthldg. Tax Report Line No")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an auto-generated field based on the no. series defined in the Withholding Tax Posting Setup for a particular Withholding Tax Report Type.';
                }
                field("Withholding Tax Report"; Rec."Withholding Tax Report")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that this field is assigned from Withholding Tax Posting Setup based on Withholding Tax Business and Withholding Tax Product Posting Group.';
                }
            }
        }
    }
}