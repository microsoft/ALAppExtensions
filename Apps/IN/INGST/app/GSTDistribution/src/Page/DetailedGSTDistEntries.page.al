// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

page 18213 "Detailed GST Dist. Entries"
{
    Caption = 'Detailed GST Dist. Entries';
    Editable = false;
    PageType = List;
    SourceTable = "Detailed GST Dist. Entry";
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
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                }
                field("Detailed GST Ledger Entry No."; Rec."Detailed GST Ledger Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                }
                field("Dist. Location Code"; Rec."Dist. Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the distributing location code.';
                }
                field("Dist. Location State Code"; Rec."Dist. Location State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the distributing location state code.';
                }
                field("Dist. GST Regn. No."; Rec."Dist. GST Regn. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST registration number of the distributing location.';
                }
                field("Dist. GST Credit"; Rec."Dist. GST Credit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the transaction is related GST credit availment or non-availment.';
                }
                field("ISD Document Type"; Rec."ISD Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type that the GST entry related to input service distribution belongs to.';
                }
                field("ISD Document No."; Rec."ISD Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the transaction that created the input service distribution entry.';
                }
                field("ISD Posting Date"; Rec."ISD Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the GST distribution ledger entry.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor code.';
                }
                field("Supplier GST Reg. No."; Rec."Supplier GST Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST registration number of the vendor.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the vendor.';
                }
                field("Vendor Address"; Rec."Vendor Address")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the address of the vendor.';
                }
                field("Vendor State Code"; Rec."Vendor State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the state code of the vendor.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document that the entry belongs to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entrys document number.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entrys posting date.';
                }
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the Vendors numbering system.';
                }
                field("Vendor Document Date"; Rec."Vendor Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document date of the vendor invoice number.';
                }
                field("GST Base Amount"; Rec."GST Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount that used for GST calculation base in the posted entry.';
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an unique identifier for the GST group code used to calculate and post GST.';
                }
                field("GST %"; Rec."GST %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the relevant GST rate for the particular combination of GST group, state. Do not enter percent sign, only the number. For example, if the GST rate is 10%, enter 10 into this field.';
                }
                field("GST Amount"; Rec."GST Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the calculated GST amount calculated for the particular combination of GST group and state.';
                }
                field("Rcpt. Location Code"; Rec."Rcpt. Location Code")
                {
                    ToolTip = 'Specifies the receiving location code.';
                    ApplicationArea = Basic, Suite;
                }
                field("Rcpt. GST Reg. No."; Rec."Rcpt. GST Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST registration number of the receiving location.';
                }
                field("Rcpt. Location State Code"; Rec."Rcpt. Location State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the receiving location state code.';
                }
                field("Rcpt. GST Credit"; Rec."Rcpt. GST Credit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the received input credit to be availed or not.';
                }
                field("Distribution Jurisdiction"; Rec."Distribution Jurisdiction")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the jurisdiction depending on the state code defined in from and to location.';
                }
                field("Location Distribution %"; Rec."Location Distribution %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the relevant Distribution rate which need to be transferred. Do not enter percent sign, only the number. For example if the Distribution rate is 10%, enter 10 into this field.';
                }
                field("Distributed Component Code"; Rec."Distributed Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies distribution component code for input service distribution.';
                }
                field("Rcpt. Component Code"; Rec."Rcpt. Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies recipients component code for input service distribution.';
                }
                field("Distribution Amount"; Rec."Distribution Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount field as calculated from the defined distribution percent.';
                }
                field("Pre Dist. Invoice No."; Rec."Pre Dist. Invoice No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the pre distribution invoice number.';
                }
                field(Reversal; Rec.Reversal)
                {
                    ToolTip = 'Specifies if the document is for reversal purpose.';
                    ApplicationArea = Basic, Suite;
                }
                field("Reversal Date"; Rec."Reversal Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reversal date of the document.';
                }
                field("Original Dist. Invoice No."; Rec."Original Dist. Invoice No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Original invoice number on the GST distribution ledger entry.';
                }
                field("Original Dist. Invoice Date"; Rec."Original Dist. Invoice Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Original invoice date of the GST distribution ledger entry.';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line number of an entry of a document.';
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'This displays the general ledger account of tax component.';
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
                field(Cess; Rec.Cess)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether Cess is applicable for this transaction or not.';
                }
                field(Paid; Rec.Paid)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether GST has been paid to the government through GST settlement.';
                }
                field("Credit Availed"; Rec."Credit Availed")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the credit amount that has been availed for the component code.';
                }
                field("Payment Document No."; Rec."Payment Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the settlement document number  when GST is paid through GST settlement.';
                }
                field("Payment Document Date"; Rec."Payment Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the settlement posting date when GST is paid through GST settlement.';
                }
                field("Invoice Type"; Rec."Invoice Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Invoice type as per GST law.';
                }
            }
        }
    }
}
