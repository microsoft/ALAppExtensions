// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

page 18691 "TDS Entries"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "TDS Entry";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
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
                    ToolTip = 'Specifies the type of the account of the TDS entry.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the vendor account of the TDS entry.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entries posting date.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document that the TDS entry is.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number on the TDS entry.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account number of the vendor account on the TDS entry.';
                }
                field("T.A.N. No."; Rec."T.A.N. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TAN number on the TDS entry.';
                }
                field(Section; Rec.Section)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'TDS Section Code';
                    ToolTip = 'Specifies the section of TDS entry.';
                }
                field("Assessee Code"; Rec."Assessee Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the assessee code of the Vendor on the TDS entry.';
                }
                field("Non Resident Payments"; Rec."Non Resident Payments")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the section belongs to Non Resident payments.';
                }
                field("Nature of Remittance"; Rec."Nature of Remittance")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the type of Remittance deductee deals with on the TDS entry.';
                }
                field("Act Applicable"; Rec."Act Applicable")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the tax rates prescribed under the IT Act or DTAA on the TDS entry.';
                }
                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Country Code';
                }
                field("TDS Base Amount"; Rec."TDS Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount that is used as base to calculate TDS on the TDS entry.';
                }
                field("TDS Paid"; Rec."TDS Paid")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the deducted TDS has been paid to government for the TDS entry.';
                }
                field("TDS %"; Rec."TDS %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Species the TDS % on the TDS entry.';
                }
                field("TDS Amount"; Rec."TDS Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TDS amount on the TDS entry.';
                }
                field("Surcharge %"; Rec."Surcharge %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the surcharge % on the TDS entry.';
                }
                field("Surcharge Amount"; Rec."Surcharge Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the surcharge % on the TDS entry.';
                }
                field("TDS Amount Including Surcharge"; Rec."TDS Amount Including Surcharge")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Toal TDS amount Including Surcharge on the TDS entry.';
                }
                field("eCess %"; Rec."eCess %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the eCess % on the TDS entry.';
                }
                field("eCess Amount"; Rec."eCess Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the eCess amount on the TDS entry.';
                }
                field("SHE Cess %"; Rec."SHE Cess %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SHE Cess % on the TDS entry.';
                }
                field("SHE Cess Amount"; Rec."SHE Cess Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SHE Cess amount on the TDS entry.';
                }
                field("Total TDS Including SHE CESS"; Rec."Total TDS Including SHE CESS")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Total TDS Including SHE Cess amount on the TDS entry.';
                }
                field("Invoice Amount"; Rec."Invoice Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the invoice amount that the TCS entry is linked to.';
                }
                field("Concessional Code"; Rec."Concessional Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the concessional code on the TDS entry.';
                }
                field("Concessional Form No."; Rec."Concessional Form No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the applied concessional code on the TDS entry.';
                }
                field("Deductee PAN No."; Rec."Deductee PAN No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Species the PAN number of deductee on the TDS entry.';
                }
                field("Per Contract"; Rec."Per Contract")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Per Contract on the TDS Entry';
                }
            }
        }
    }
}
