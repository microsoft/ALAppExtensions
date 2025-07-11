// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSReturnAndSettlement;

page 18752 "TDS Challan Register"
{
    Caption = 'TDS Challan Register';
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "TDS Challan Register";
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
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the challan number provided by the bank while depositing the TDS amount.';
                }
                field("Challan Date"; Rec."Challan Date")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the challan date on which TDS is paid to government.';
                }
                field("BSR Code"; Rec."BSR Code")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Basic Statistical Return Code provided by the bank while depositing the TDS amount.';
                }
                field("Minor Head Code"; Rec."Minor Head Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the minor head used in the payment.';
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
                field("TDS Interest Amount"; Rec."TDS Interest Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of interest payable.';
                }
                field("TDS Others"; Rec."TDS Others")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of other charges payable.';
                }
                field("TDS Fee"; Rec."TDS Fee")
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
            action("Update Challan Register")
            {
                Caption = 'Update Challan Register';
                Image = UpdateDescription;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Select this to update the details like Interest Amount, Others and Paid by Book entry in TDS challan register during the financial year.';

                trigger OnAction()
                var
                    UpdateChallanRegister: Report "Update Challan Register";
                begin
                    UpdateChallanRegister.UpdateChallan(Rec."TDS Interest Amount", Rec."TDS Others", Rec."TDS Fee", Rec."Entry No.");
                    UpdateChallanRegister.Run();
                end;
            }
        }
    }
}
