// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

page 18323 "Detailed Cr. Adjstmnt. Entries"
{
    Caption = 'Detailed Cr. Adjstmnt. Entries';
    Editable = false;
    PageType = List;
    SourceTable = "Detailed Cr. Adjstmnt. Entry";
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entrys posting date.';
                }
                field("Credit Adjustment Type"; Rec."Credit Adjustment Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the document type is Credit Reveresal, Credit Re-availment, Permanent Reversal,Credit Availment and Reversal of Availment.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entrys document number.';
                }
                field("Adjusted Doc. Entry No."; Rec."Adjusted Doc. Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry number of the adjusted document.';
                }
                field("Adjusted Doc. Entry Type"; Rec."Adjusted Doc. Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry type of the adjusted document.';
                }
                field("Adjusted Doc. Transaction Type"; Rec."Adjusted Doc. Transaction Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction type of the adjusted document.';
                }
                field("Adjusted Doc. Type"; Rec."Adjusted Doc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the adjusted document.';
                }
                field("Adjusted Doc. No."; Rec."Adjusted Doc. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the adjusted document.';
                }
                field("Adjusted Doc. Line No."; Rec."Adjusted Doc. Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line number of the adjusted document.';
                }
                field("Adjusted Doc. Posting Date"; Rec."Adjusted Doc. Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of adjusted document number.';
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
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies  if the Source Type of the Entry is Customer,Vendor,Bank or G/L Account.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source number as per defined type in source type.';
                }
                field("HSN/SAC Code"; Rec."HSN/SAC Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an unique identifier for the type of HSN or SAC that is used to calculate and post GST.';
                }
                field("GST Component Code"; Rec."GST Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies GST component code.';
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies GST group code.';
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
                field("GST %"; Rec."GST %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST rate used in GST calculation in entry.';
                }
                field("GST Amount"; Rec."GST Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the calculated GST amount calculated for the particular combination of GST group and state.';
                }
                field("Adjustment %"; Rec."Adjustment %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the adjustment rate. Do not enter percent sign, only the number. For example, if the adjustment rate is 10%, enter 10 into this field.';
                }
                field("Adjustment Amount"; Rec."Adjustment Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the adjustment amount.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the Customers or Vendors numbering system.';
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'This displays the general ledger account of tax component.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the user who created the document.';
                }
                field(Positive; Rec.Positive)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the amount in the line is positive or not.';
                }
                field("Location State Code"; Rec."Location State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sate code mentioned in location used in the transaction.';
                }
                field("Buyer/Seller State Code"; Rec."Buyer/Seller State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Customer/Vendor state code that the entry is posted to.';
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
                    ToolTip = 'Specifies if that the GST group is assigned for goods or service.';
                }
                field("GST Credit"; Rec."GST Credit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the transaction is related GST credit availement or non-availement';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code for the posted entry.';
                }
                field("Currency Factor"; Rec."Currency Factor")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currecny factor with respect to local currency for the posted entry.';
                }
                field("GST Rounding Precision"; Rec."GST Rounding Precision")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Invoice rounding precision used in posted entry.';
                }
                field("GST Rounding Type"; Rec."GST Rounding Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Invoice rounding type used in posted entry.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code for which the entry was posted.';
                }
                field("GST Vendor Type"; Rec."GST Vendor Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Vendor type for the vendor specified in account number field on journal line.';
                }
                field("Credit Availed"; Rec."Credit Availed")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the credit amount that has been availed for the component code.';
                }
                field(Paid; Rec.Paid)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether GST has been paid to the government through GST settlement.';
                }
                field(Cess; Rec.Cess)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether cess is applicable for this transaction or not.';
                }
                field("Input Service Distribution"; Rec."Input Service Distribution")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the entry is related to input service distribution or not.';
                }
                field("Liable to Pay"; Rec."Liable to Pay")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the payment liability occurs  for the transaction or not.';
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Update Remaining Credit Adjust")
            {
                Caption = '&Update Remaining Credit Adjust';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Update Remaining Credit Adjust';
                Image = AdjustEntries;
                trigger OnAction()
                var
                    GSTSettlement: Codeunit "GST Settlement";
                begin
                    GSTSettlement.UpdateAdjRemAmt();
                end;
            }
        }
    }
}
