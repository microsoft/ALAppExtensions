// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup.ChargeGroupBase;

page 18509 "Charge Group SubPage"
{
    AutoSplitKey = true;
    PageType = ListPart;
    SourceTable = "Charge Group Line";
    Caption = 'Charge Group SubPage';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the charges for Charge(item) and G/L Account.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the charges for Charge(item) and G/L Account.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the Charge(item) and G/L Account that you are setting up.';
                }
                field(Assignment; Rec.Assignment)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a assignment of the Charge(item) and G/L Account that you are setting up.';
                }
                field("Third Party Invoice"; Rec."Third Party Invoice")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a third party invoice required or not.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a vendor No. if required third party Invoice.';
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account no.  the involved entry or record, according to the specified.';
                }
                field("Computation Method"; Rec."Computation Method")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the method the involved entry or record, according to the specified.';
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value for computation method.';
                }
            }
        }
    }
}
