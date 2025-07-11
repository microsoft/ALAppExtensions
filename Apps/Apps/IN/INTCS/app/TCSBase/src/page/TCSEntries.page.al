// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

page 18810 "TCS Entries"
{
    Caption = 'TCS Entries';
    Editable = false;
    PageType = List;
    SourceTable = "TCS Entry";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies type of the account on TCS entry.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the customer account on the TCS entry.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the TCS entry.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document that the TCS entry is linked to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number on the TCS entry.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the TCS entry.';
                }
                field("TCS Base Amount"; Rec."TCS Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the base amount on which TCS is calculated.';
                }
                field("TCS Amount Including Surcharge"; Rec."TCS Amount Including Surcharge")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total of TCS amount and surcharge amount on the TCS entry.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account number of the customer account on the TCS entry.';
                }
                field("Assessee Code"; Rec."Assessee Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the assessee code of the customer account on TCS entry.';
                }
                field("TCS Nature of Collection"; Rec."TCS Nature of Collection")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Nature of Collection of TCS entry.';
                }
                field("TCS %"; Rec."TCS %")
                {
                    ApplicationArea = Basic, Suite;
                    DecimalPlaces = 2 : 3;
                    ToolTip = 'Specifies the TCS % on the TCS entry.';
                }
                field("TCS Amount"; Rec."TCS Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TCS amount on the TCS entry.';
                }
                field("Surcharge %"; Rec."Surcharge %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the surcharge % on the TCS entry.';
                }
                field("Surcharge Amount"; Rec."Surcharge Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the surcharge amount on the TCS entry.';
                }
                field("eCESS %"; Rec."eCESS %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the eCess % on TCS entry.';
                }
                field("eCESS Amount"; Rec."eCESS Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the eCess amount on TCS entry.';
                }
                field("SHE Cess %"; Rec."SHE Cess %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SHE Cess % on TCS entry.';
                }
                field("SHE Cess Amount"; Rec."SHE Cess Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SHE Cess amount on TCS entry.';
                }
                field("Concessional Code"; Rec."Concessional Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the applied concessional code on the TCS entry.';
                }
                field("T.C.A.N. No."; Rec."T.C.A.N. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the T.C.A.N. number on the TCS entry.';
                }
                field("Customer Account No."; Rec."Customer Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies account number of the customer on the TCS entry.';
                }
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction number that the TCS entry belongs to.';
                }
                field("Customer P.A.N. No."; Rec."Customer P.A.N. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies PAN number of the customer on the TCS entry.';
                }
                field("Total TCS Including SHE CESS"; Rec."Total TCS Including SHE CESS")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total of TCS amount, surcharge amount, eCess and SHE Cess amount on the TCS entry.';
                }
                field("Pay TCS Document No."; Rec."Pay TCS Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the TCS entry to be paid to government.';
                }
                field("TCS Paid"; Rec."TCS Paid")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the amount on TCS entry is fully paid.';
                }
                field("Challan Date"; Rec."Challan Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'This field will be updated once TCS is paid to government and relevant details to be updated in TCS register.';
                }
                field("Challan No."; Rec."Challan No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'This field will be updated once TCS is paid to government and relevant details to be updated in TCS register.';
                }
                field("Bank Name"; Rec."Bank Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'This field will be updated once TCS made to government and relevant details to be updated in TCS register.';
                }
                field(Adjusted; Rec.Adjusted)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'This field will be updated if any transaction is adjusted using TCS adjustment Journal.';
                }
                field("Adjusted TCS %"; Rec."Adjusted TCS %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the % on which transaction is adjusted using TCS adjustment Journal.';
                }
                field("Bal. TCS Including SHE CESS"; Rec."Bal. TCS Including SHE CESS")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the balance TDS/TCS including SHE Cess on the adjustment journal line.';
                }
                field("Invoice Amount"; Rec."Invoice Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Displays the amount of the transaction document.';
                }
                field(Applied; Rec.Applied)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Displays if transaction is applied to any transaction.';
                }
                field("Adjusted Surcharge %"; Rec."Adjusted Surcharge %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'This field will be updated if any transaction is adjusted using TCS adjustment Journal.';
                }
                field("Surcharge Base Amount"; Rec."Surcharge Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the base amount on which surcharge is being calculated.';
                }
                field("Adjusted eCESS %"; Rec."Adjusted eCESS %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'This field will be updated if any transaction is adjusted using TCS adjustment Journal.';
                }
                field("Adjusted SHE CESS %"; Rec."Adjusted SHE CESS %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'This field will be updated if any transaction is adjusted using TCS adjustment Journal.';
                }
                field(Reversed; Rec.Reversed)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the TCS entry is reversed.';
                }
                field("Reversed by Entry No."; Rec."Reversed by Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies reversal entry number.';
                }
                field("Reversed Entry No."; Rec."Reversed Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies reversed entry number.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the user ID of the user who has posted the transaction.';
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source code. Source code can be PURCHASES, SALES, GENJNL, BANKPYMT etc.';
                }
                field("Check/DD No."; Rec."Check/DD No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'This field will be updated once TCS is paid to government and relevant details has to be updated in TCS register.';
                }
                field("Check Date"; Rec."Check Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'This field will be updated once TCS is paid to government and relevant details to be updated in TCS register.';
                }
                field("TCS Payment Date"; Rec."TCS Payment Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which TCS is paid to government.';
                }
                field("Challan Register Entry No."; Rec."Challan Register Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry number of challan details of the transactions.';
                }
                field("Concessional Form No."; Rec."Concessional Form No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the applied concessional form no. on the TCS entry.';
                }
                field("TCS on Recpt. Of Pmt."; Rec."TCS on Recpt. Of Pmt.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies TCS is calclated on payment receipt only.';
                }
            }
        }
    }
}
