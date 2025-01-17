// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Archive;

pageextension 13673 "OIOUBL-Sales Order Archive" extends "Sales Order Archive"
{
    layout
    {
        addafter("Sell-to Contact")
        {
            field("OIOUBL-Sell-to Contact Phone No."; "OIOUBL-Sell-to Contact Phone No.")
            {
                ApplicationArea = Advanced;
                Tooltip = 'Specifies the telephone number of the contact person at the customer. This is used in the exported electronic document.';
            }
            field("OIOUBL-Sell-to Contact Fax No."; "OIOUBL-Sell-to Contact Fax No.")
            {
                ApplicationArea = Advanced;
                Tooltip = 'Specifies the fax number of the contact person at the customer. This is used in the exported electronic document.';
            }
            field("OIOUBL-Sell-to Contact E-Mail"; "OIOUBL-Sell-to Contact E-Mail")
            {
                ApplicationArea = Advanced;
                Tooltip = 'Specifies the email address of the contact person at the customer. This is used in the exported electronic document.';
            }
            field("OIOUBL-Sell-to Contact Role"; "OIOUBL-Sell-to Contact Role")
            {
                ApplicationArea = Advanced;
                Tooltip = 'Specifies the role of the contact person at the customer. This is used in the exported electronic document.';
            }
        }
    }
}
