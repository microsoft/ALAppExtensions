// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

page 10857 "View/Edit Payment Line FR"
{
    Caption = 'View/Edit Payment Lines';
    Editable = false;
    PageType = List;
    SourceTable = "Payment Status FR";
    SourceTableView = where(Look = const(true));
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Payment Class"; Rec."Payment Class")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the payment class.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies text to describe the payment status.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Payment Lines List")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payment Lines List';
                Image = ListPage;
                RunObject = Page "Payment Lines List FR";
                RunPageLink = "Payment Class" = field("Payment Class"),
                              "Status No." = field(Line),
                              "Copied To No." = filter('');
                ToolTip = 'View line information for payments and collections.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Payment Lines List_Promoted"; "Payment Lines List")
                {
                }
            }
        }
    }
}

