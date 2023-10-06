// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSReturnAndSettlement;

page 18874 "TCS Challan Register"
{
    Caption = 'TCS Challan Register';
    PageType = List;
    SourceTable = "TCS Challan Register";
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Quarter; Rec.Quarter)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quarter this accounting period belongs to.';
                }
                field("Financial Year"; Rec."Financial Year")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the accounting period.';
                }
                field("Challan No."; Rec."Challan No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the challan number provided by the bank while depositing the TCS amount.';
                }
                field("Challan Date"; Rec."Challan Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the challan date on which TCS has been paid to government.';
                }
                field("BSR Code"; Rec."BSR Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the Basic Statistical Return Code provided by the bank while depositing the TDS amount.';
                }
                field("Bank Name"; Rec."Bank Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the bank where TCS amount has been deposited.';
                }
                field("Paid By Book Entry"; Rec."Paid By Book Entry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Select this field to specify that challan has been paid by book entry.';
                }
                field("Transfer Voucher No."; Rec."Transfer Voucher No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transfer voucher reference.';
                }
                field("TCS Interest Amount"; Rec."TCS Interest Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the value of interest payable.';
                }
                field("TCS Others"; Rec."TCS Others")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the value of other charges payable.';
                }
                field("TCS Fee"; Rec."TCS Fee")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of fees payable.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Register")
            {
                Caption = '&Register';
                Image = Register;

                action("Update Challan Register")
                {
                    Caption = 'Update Challan Register';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Select this to update the details like Interest Amount, Others and Paid by Book entry in TCS challan register during the financial year.';
                    Image = UpdateShipment;
                    trigger OnAction()
                    var
                        UpdateTCSChallanRegister: Report "Update TCS Challan Register";
                    begin
                        UpdateTCSChallanRegister.UpdateChallan(Rec."TCS Interest Amount", Rec."TCS Others", Rec."TCS Fee", Rec."Entry No.");
                        UpdateTCSChallanRegister.Run();
                    end;
                }
            }
        }
    }
}
