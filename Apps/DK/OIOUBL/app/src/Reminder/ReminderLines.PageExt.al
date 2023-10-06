// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Reminder;

pageextension 13657 "OIOUBL-ReminderLines" extends "Reminder Lines"
{
    layout
    {
        addafter("Applies-to Document No.")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                ApplicationArea = Basic, Suite;
                Tooltip = 'Specifies the account code of the customer. This is used in the exported electronic document.';
                Visible = false;
            }
        }
    }

    procedure UpdateLines(SetSaveRecord: Boolean);
    begin
        CurrPage.Update(SetSaveRecord);
    end;
}
