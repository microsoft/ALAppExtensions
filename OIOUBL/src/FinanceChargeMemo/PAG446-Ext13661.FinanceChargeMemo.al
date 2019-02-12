// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13661 "OIOUBL-Finance Charge Memo" extends "Finance Charge Memo"
{
    layout
    {
        addafter("Contact")
        {
            field("OIOUBL-Contact Phone No."; "OIOUBL-Contact Phone No.")
            {
                Tooltip = 'Specifies the telephone number of the contact person at the customer.';
                ApplicationArea = Basic, Suite;
            }
            field("OIOUBL-Contact Fax No."; "OIOUBL-Contact Fax No.")
            {
                Tooltip = 'Specifies the fax number of the contact person at the customer.';
                ApplicationArea = Basic, Suite;
            }
            field("OIOUBL-Contact E-Mail"; "OIOUBL-Contact E-Mail")
            {
                Tooltip = 'Specifies the email address of the contact person at the customer.';
                ApplicationArea = Basic, Suite;
            }
            field("OIOUBL-Contact Role"; "OIOUBL-Contact Role")
            {
                Tooltip = 'Specifies the role of the contact person at the customer.';
                ApplicationArea = Basic, Suite;
            }
        }

        addafter("Currency Code")
        {
            field("OIOUBL-GLN"; "OIOUBL-GLN")
            {
                Tooltip = 'Specifies the GLN location number for the customer, based on the GLN field in the original sales order.';
                ApplicationArea = Basic, Suite;
            }
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Tooltip = 'Specifies the account code of the customer who you will send the invoice to.';
                ApplicationArea = Basic, Suite;

                trigger OnValidate();
                begin
                    CurrPage.FinChrgMemoLines.PAGE.UpdateLines(TRUE);
                end;
            }
        }
    }
}