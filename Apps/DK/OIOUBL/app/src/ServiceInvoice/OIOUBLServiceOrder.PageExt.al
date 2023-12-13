// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Document;

pageextension 13674 "OIOUBL-Service Order" extends "Service Order"
{
    layout
    {
        moveafter("Post Code"; City)
        moveafter("Phone No."; "Phone No. 2")
        moveafter("Release Status"; "Your Reference")

        addafter("E-Mail")
        {
            field("OIOUBL-Contact Role"; "OIOUBL-Contact Role")
            {
                ToolTip = 'Specifies the role of the contact person at the customer. This is used in the exported electronic document.';
                ApplicationArea = Service;
            }
        }

        addafter("Max. Labor Unit Price")
        {
            field("OIOUBL-GLN"; "OIOUBL-GLN")
            {
                ApplicationArea = Service;
                ToolTip = 'Specifies the GLN location number for the customer. This is used in the exported electronic document.';
            }

            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                ApplicationArea = Service;
                ToolTip = 'Specifies the account code of the customer. This is used in the exported electronic document.';
            }

            field("OIOUBL-Profile Code"; "OIOUBL-Profile Code")
            {
                ApplicationArea = Service;
                ToolTip = 'Specifies the profile that this customer requires for electronic documents. This is used in the exported electronic document.';
            }
        }
    }
}
