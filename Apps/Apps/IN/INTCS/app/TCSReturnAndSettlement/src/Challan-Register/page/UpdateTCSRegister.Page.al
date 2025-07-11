// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSReturnAndSettlement;

using Microsoft.Finance.TCS.TCSBase;

page 18875 "Update TCS Register"
{
    Caption = 'Update TCS Register';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "TCS Entry";
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;
    SourceTableView = where("TCS Paid" = const(true),
                            "TCS Amount Including Surcharge" = filter(<> 0));

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the entry''s posting date.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the type of document that the entry belongs to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the document number for the entry .';
                }
                field("Pay TCS Document No."; Rec."Pay TCS Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the TCS entry to be paid to government.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the description of the TCS entry.';
                }
                field("TCS Base Amount"; Rec."TCS Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the base amount on which TCS is calculated.';
                }
                field("TCS %"; Rec."TCS %")
                {
                    ApplicationArea = Basic, Suite;
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
                field("TCS Amount Including Surcharge"; Rec."TCS Amount Including Surcharge")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the total of TCS amount and surcharge amount on the TCS entry.';
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
                field("Total TCS Including SHE CESS"; Rec."Total TCS Including SHE CESS")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total of TCS amount, surcharge amount, eCess and SHE Cess amount on the TCS entry.';
                }
                field(Adjusted; Rec.Adjusted)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the TCS entry is adjusted.';
                }
                field("Bal. TCS Including SHE CESS"; Rec."Bal. TCS Including SHE CESS")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the balance value of TCS including SHE CESS amount.';
                }
                field("Challan Date"; Rec."Challan Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the challan date for the TCS entry on which TCS amount is paid to government.';
                }
                field("Challan No."; Rec."Challan No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the challan number which is provided by the bank while depositing TCS amount.';
                }
                field("BSR Code"; Rec."BSR Code")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the Basic Statistical Return Code which is provided by the bank while depositing TCS amount.';
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
                field("Bank Name"; Rec."Bank Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the bank where TCS amount has been deposited.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Update Challan Details")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Update Challan Details';
                    Image = RefreshRegister;
                    ToolTip = 'Select this to update the details like Challan No, BSR code, Bank Name, Cheque No. etc. on individual transactions in the Update TCS register.';

                    trigger OnAction()
                    begin
                        UpdateTCSChallanDetails.SetDocumentNo(Rec."Pay TCS Document No.");
                        UpdateTCSChallanDetails.Run();
                    end;
                }
            }
        }
    }
    trigger OnDeleteRecord(): Boolean
    begin
        Error(DeleteTcsEntErr);
    end;

    var
        UpdateTCSChallanDetails: Report "Update TCS Challan Details";
        DeleteTcsEntErr: Label 'You cannot delete TCS entries.';
}
