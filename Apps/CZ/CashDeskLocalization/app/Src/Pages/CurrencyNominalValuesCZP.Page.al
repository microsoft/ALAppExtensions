// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

page 31159 "Currency Nominal Values CZP"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Currency Nominal Values';
    DelayedInsert = true;
    PageType = Worksheet;
    SourceTable = "Currency Nominal Value CZP";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code for nominal value.';
                }
                field("Nominal Value"; Rec."Nominal Value")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies usable nominal value for currency.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }
}
