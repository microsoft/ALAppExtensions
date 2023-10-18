// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

page 18000 "Detailed GST Ledger Entry"
{
    Caption = 'Detailed GST Ledger Entry';
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Detailed GST Ledger Entry";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the entry is an initial entry or an application entry or an adjustment entry.';
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the transaction is a sale or purchase.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the document type is Payment, Invoice, Credit Memo, Transfer or Refund.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the transaction that created the entry.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the detailed  GST ledger entry.';
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
                    ToolTip = 'Specifies whether the type is G/L Account, Item, Resource, Fixed Asset or Charge (Item).';
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
                field("HSN/SAC Code"; Rec."HSN/SAC Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the HSN for Items & Fixed Assets. SAC for Services & Resources. For charges, it can be either SAC or HSN.';
                }
                field("GST Component Code"; Rec."GST Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST component code with which the entry was posted.';
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Displays the GST Group code of the transaction.';
                }
                field("GST Jurisdiction Type"; Rec."GST Jurisdiction Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type related to GST jurisdiction. For example, interstate/intrastate.';
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
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Displays the external document number entered in the purchase/sales document/journal bank charges Line.';
                }
                field("Amount Loaded on Item"; Rec."Amount Loaded on Item")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the charges or tax amount loaded on the line item.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity.';
                }
                field(Paid; Rec.Paid)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether GST has been paid to the government through GST settlement.';
                }
                field("GST Without Payment of Duty"; Rec."GST Without Payment of Duty")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the transaction is made with or without payment of duty.';
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'This displays the general ledger account of tax component.';
                }
                field("Reversed by Entry No."; Rec."Reversed by Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies reversal entry number. Transactions posted through journals can be reversed.';
                }
                field(Reversed; Rec.Reversed)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the transaction has been reversed or not.';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document line number.';
                }
                field("Item Charge Entry"; Rec."Item Charge Entry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the entry is an Item charge entry.';
                }
                field("Reverse Charge"; Rec."Reverse Charge")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the reverse charge is applicable for this GST group or not.';
                }
                field("GST on Advance Payment"; Rec."GST on Advance Payment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if GST is required to be calculated on Advance Payment.';
                }
                field("Payment Document No."; Rec."Payment Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the settlement document number  when GST is paid through GST settlement.';
                }
                field("GST Exempted Goods"; Rec."GST Exempted Goods")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the goods/services are exempted from GST.';
                }
                field("GST %"; Rec."GST %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST % on the GST ledger entry.';
                }
                field("Location  Reg. No."; Rec."Location  Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GSTIN of location.';
                }
                field("Buyer/Seller Reg. No."; Rec."Buyer/Seller Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the customer/vendor GST Registration number.';
                }
                field("GST Group Type"; Rec."GST Group Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the GST group is assigned for goods or service.';
                }
                field("GST Credit"; Rec."GST Credit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the GST credit has to be availed or not.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code on GST ledger entry.';
                }
                field("GST Rounding Precision"; Rec."GST Rounding Precision")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Rounding precision for the GST Ledger Entry';
                }
                field("GST Rounding Type"; Rec."GST Rounding Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Rounding type for the GST Ledger Entry';
                }
                field("Original Invoice No."; Rec."Original Invoice No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Original invoice number on the GST ledger entry.';
                }
                field("Cr. & Liab. Adjustment Type"; Rec."Cr. & Liab. Adjustment Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the credit and liability adjustment type for the ledger entry.';
                }
                field("GST Customer Type"; Rec."GST Customer Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the customer. For example, Registered, Unregistered, Export etc..';
                }
                field("GST Vendor Type"; Rec."GST Vendor Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the vendor. For example,  Registered, Unregistered, Composite, Import etc..';
                }
                field("Reconciliation Month"; Rec."Reconciliation Month")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the year in which the transaction is Reconciled through GST Reconciliation feature.';
                }
                field("Reconciliation Year"; Rec."Reconciliation Year")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the year in which the transaction is Reconciled through GST Reconciliation feature.';
                }
                field(Reconciled; Rec.Reconciled)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the transaction has been Reconciled.';
                }
                field("Credit Adjustment Type"; Rec."Credit Adjustment Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of credit adjustment. For example, credit reversal, credit re-availment etc.';
                }
                field("Credit Availed"; Rec."Credit Availed")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the GST credit has been availed or not.';
                }
                field("Liable to Pay"; Rec."Liable to Pay")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the payment liability occurs  for the transaction or not.';
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of payment.';
                }
                field("Eligibility for ITC"; Rec."Eligibility for ITC")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Eligibility for ITC on the GST ledger entry.';
                }
                field("GST Assessable Value"; Rec."GST Assessable Value")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST assessable value on the GST ledger entry.';
                }
                field("Custom Duty Amount"; Rec."Custom Duty Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Custom duty amount on the GST ledger entry.';
                }
                field("Journal Entry"; Rec."Journal Entry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the transaction is posted from Journal with document type Invoice or Credit Memo.';
                }
                field("ARN No."; Rec."ARN No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Customer/Vendor ARN number.';
                }
                field("Forex Fluctuation"; Rec."Forex Fluctuation")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Forex fluctuation on the ledger entry.';
                }
                field("CAJ %"; Rec."CAJ %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the CAJ % which is updated from credit adjustment journal line.';
                }
                field("CAJ Amount"; Rec."CAJ Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the CAJ amount which is updated from credit adjustment journal line, displays the adjusted GST amount.';
                }
                field("CAJ % Permanent Reversal"; Rec."CAJ % Permanent Reversal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the CAJ % of payment reversal which is updated from credit adjustment journal line if Adjustment Type is selected as Permanent Reversal. ';
                }
                field("CAJ Amount Permanent Reversal"; Rec."CAJ Amount Permanent Reversal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of permanent reversal which is  updated from credit adjustment journal line, displays the GST amount for Adjustment Type - Permanent Reversal.';
                }
                field("Remaining CAJ Adj. Base Amt"; Rec."Remaining CAJ Adj. Base Amt")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the remaining GST base amount after posting adjustments which is updated on posting credit adjustment journal. ';
                }
                field("Remaining CAJ Adj. Amt"; Rec."Remaining CAJ Adj. Amt")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the remaining GST amount after posting adjustments which is updated on posting credit adjustment journal. ';
                }
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction number that the Detailed GST entry belongs to.';
                }
                field("Currency Factor"; Rec."Currency Factor")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies currency factor for this transactions.';
                }
                field("GST Place of Supply"; Rec."GST Place of Supply")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Place of Supply. For example Bill-to Address, Ship-to Address, Location Address etc.';
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("Show Related Information")
            {
                Image = Info;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Display the additional information of detailed GST ledger entry.';
                RunObject = page "Detailed GST Ledger Entry Info";
                RunPageLink = "Entry No." = field("Entry No.");
            }
            action("Show Related Information By Document No.")
            {
                Image = Info;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Display the additional information of detailed GST ledger entry by document number.';

                trigger OnAction()
                var
                    GSTNavigate: Codeunit "GST Navigate";
                begin
                    GSTNavigate.ShowRelatedDetailedGSTLedgerInfoByDocumentNo(Rec);
                end;
            }
        }
    }
}
