// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Reminder;

pageextension 13656 "OIOUBL-Reminder" extends Reminder
{
    layout
    {
        addafter(Contact)
        {
            field("OIOUBL-Contact Phone No."; "OIOUBL-Contact Phone No.")
            {
                Tooltip = 'Specifies the telephone number of the contact person at the customer. This is used in the exported electronic document.';
                ApplicationArea = Basic, Suite;
            }
            field("OIOUBL-Contact Fax No."; "OIOUBL-Contact Fax No.")
            {
                Tooltip = 'Specifies the fax number of the contact person at the customer. This is used in the exported electronic document.';
                ApplicationArea = Basic, Suite;
            }
            field("OIOUBL-Contact E-Mail"; "OIOUBL-Contact E-Mail")
            {
                Tooltip = 'Specifies the email address of the contact person at the customer. This is used in the exported electronic document.';
                ApplicationArea = Basic, Suite;
            }
            field("OIOUBL-Contact Role"; "OIOUBL-Contact Role")
            {
                Tooltip = 'Specifies the role of the contact person at the customer. This is used in the exported electronic document.';
                ApplicationArea = Basic, Suite;
            }
        }

        addafter("Currency Code")
        {
            field("OIOUBL-GLN"; "OIOUBL-GLN")
            {
                Tooltip = 'Specifies the GLN location number for the customer. This is used in the exported electronic document.';
                ApplicationArea = Basic, Suite;
            }
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Tooltip = 'Specifies the account code of the customer. This is used in the exported electronic document.';
                ApplicationArea = Basic, Suite;

                trigger OnValidate();
                begin
                    CurrPage.ReminderLines.PAGE.UpdateLines(TRUE);
                end;
            }
        }
    }
}
