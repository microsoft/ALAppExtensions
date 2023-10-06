// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

pageextension 13654 "OIOUBL-Sales Order" extends "Sales Order"
{
    layout
    {
        modify("Sell-to Customer Name")
        {
            trigger OnAfterValidate();
            begin
                CurrPage.UPDATE();
            end;
        }

        addafter("Sell-to Contact No.")
        {
            field("OIOUBL-Sell-to Contact Phone No."; "OIOUBL-Sell-to Contact Phone No.")
            {
                Caption = 'Contact Phone No.';
                Tooltip = 'Specifies the telephone number of the contact person at the customer. This is used in the exported electronic document.';
                ApplicationArea = Basic, Suite;
            }
            field("OIOUBL-Sell-to Contact Fax No."; "OIOUBL-Sell-to Contact Fax No.")
            {
                Caption = 'Contact Fax No.';
                Tooltip = 'Specifies the fax number of the contact person at the customer. This is used in the exported electronic document.';
                ApplicationArea = Basic, Suite;
            }
            field("OIOUBL-Sell-to Contact E-Mail"; "OIOUBL-Sell-to Contact E-Mail")
            {
                Caption = 'Contact E-Mail';
                Tooltip = 'Specifies the email address of the contact person at the customer. This is used in the exported electronic document.';
                ApplicationArea = Basic, Suite;
            }
            field("OIOUBL-Sell-to Contact Role"; "OIOUBL-Sell-to Contact Role")
            {
                Caption = 'Contact Role';
                Tooltip = 'Specifies the role of the contact person at the customer. This is used in the exported electronic document.';
                ApplicationArea = Basic, Suite;
            }
        }

        addafter(BillToOptions)
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
                    CurrPage.SalesLines.PAGE.UpdateForm(True);
                end;
            }
            field("OIOUBL-Profile Code"; "OIOUBL-Profile Code")
            {
                Tooltip = 'Specifies the profile that the customer requires for electronic documents. This is used in the exported electronic document.';
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }
}
