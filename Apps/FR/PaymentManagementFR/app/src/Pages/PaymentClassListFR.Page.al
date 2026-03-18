// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

page 10835 "Payment Class List FR"
{
    Caption = 'Payment Class List';
    Editable = false;
    PageType = List;
    SourceTable = "Payment Class FR";
    SourceTableView = where(Enable = const(true));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a payment class code.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies text to describe the payment class.';
                }
            }
        }
    }

    actions
    {
    }
}

