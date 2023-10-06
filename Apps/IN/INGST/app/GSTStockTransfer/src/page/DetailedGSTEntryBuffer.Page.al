// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

using Microsoft.Finance.GST.Base;

page 18390 "Detailed GST Entry Buffer"
{
    Caption = 'Detailed GST Entry Buffer';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Detailed GST Entry Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type that the GST entry belongs to.';
                }

                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the transaction that created the entry.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the ledger entry.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the type is G/L Account, Item, Resource, Fixed Asset or Charge (Item).';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Item No., G/L Account No. etc.';
                }
                field("Product Type"; Rec."Product Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies product type only when Type is Items. It displays whether the Item is a normal item or capital good.';
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the transaction is a sale or purchase.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Source Type as customer for sales transaction,. For purchase transaction, Source Type is vendor. For Bank Charges Transaction, Source Type is Bank account.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor number, if Source Type is vendor. If Source Type is customer, then the customer number is displayed. If Source Type is Bank Account, the Bank Account No. is displayed.';
                }
                field("GST Component Code"; Rec."GST Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST component code. For an intrastate transaction, it can be either CGST or SGST. For an interstate transaction, it is IGST.';
                }
                field("GST %"; Rec."GST %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST % on the GST ledger entry.';
                }
                field("GST Base Amount"; Rec."GST Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Displays the base amount on which GST percentage is applied.';
                }
                field("GST Amount"; Rec."GST Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Displays the tax amount computed by applying GST percentage on GST base.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity.';
                }
                field(UOM; Rec.UOM)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Unit of Measure for the ledger entry.';
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Displays the GST Group code of the transaction.';
                }
                field("HSN/SAC Code"; Rec."HSN/SAC Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the HSN for Items & Fixed Assets. SAC for Services & Resources. For charges, it can be either SAC or HSN. ';
                }
                field("Amount Loaded on Item"; Rec."Amount Loaded on Item")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the charges or tax amount loaded on the line item.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code for which the entry was posted.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line number of the assigned entry.';
                }
                field("Item Charge Assgn. Line No."; Rec."Item Charge Assgn. Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line number of the assigned entry.';
                }
                field("Item Charge Assgn. Doc. Type"; Rec."Item Charge Assgn. Doc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type of the assigned entry.';
                }
                field("Item Charge Assgn Doc. No."; Rec."Item Charge Assgn Doc. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the assigned entry.';
                }
                field("Component Calc. Type"; Rec."Component Calc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Component Calc. Type for the ledger Entry.';
                }
                field("Cess Amount Per Unit Factor"; Rec."Cess Amount Per Unit Factor")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Cess Amount per Unit Factor for the ledger entry.';
                }
                field("Cess UOM"; Rec."Cess UOM")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Cess Unit of Measure for the ledger entry.';
                }
                field("Cess Factor Quantity"; Rec."Cess Factor Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Cess Factor Quantity for the ledger entry.';
                }
                field("Custom Duty Amount"; Rec."Custom Duty Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Custom duty amount on the GST ledger entry.';
                }
                field("GST Assessable Value"; Rec."GST Assessable Value")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST assessable value on transaction.';
                }
                field("Non-Availment"; Rec."Non-Availment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the input credit is to be availed or not.';
                }
                field("FA Journal Entry"; Rec."FA Journal Entry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the transaction is posted from FA Journal. ';
                }
                field("Without Bill Of Entry"; Rec."Without Bill Of Entry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the ledger entry is created with or without Bill of entry.';
                }
                field("Finance Charge Memo"; Rec."Finance Charge Memo")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Finance charge memo on the ledger entry.';
                }
                field("POS Out Of India"; Rec."POS Out Of India")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the POS out of India on the GST ledger entry.';
                }
            }
        }
    }
}

