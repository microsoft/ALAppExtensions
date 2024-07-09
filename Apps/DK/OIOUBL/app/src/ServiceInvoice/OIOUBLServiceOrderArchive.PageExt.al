// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Archive;

pageextension 13635 "OIOUBL-Service Order Archive" extends "Service Order Archive"
{
    layout
    {
        moveafter("Post Code"; City)
        moveafter("Phone No."; "Phone No. 2")
        moveafter("Release Status"; "Your Reference")
        addafter("E-Mail")
        {
            field("OIOUBL-Contact Role"; Rec."OIOUBL-Contact Role")
            {
                ToolTip = 'Specifies the role of the contact person at the customer. This is used in the exported electronic document.';
                ApplicationArea = Service;
            }
        }
        addafter("Max. Labor Unit Price")
        {
            field("OIOUBL-GLN"; Rec."OIOUBL-GLN")
            {
                ApplicationArea = Service;
                ToolTip = 'Specifies the GLN location number for the customer. This is used in the exported electronic document.';
            }
            field("OIOUBL-Account Code"; Rec."OIOUBL-Account Code")
            {
                ApplicationArea = Service;
                ToolTip = 'Specifies the account code of the customer. This is used in the exported electronic document.';
            }
            field("OIOUBL-Profile Code"; Rec."OIOUBL-Profile Code")
            {
                ApplicationArea = Service;
                ToolTip = 'Specifies the profile that this customer requires for electronic documents. This is used in the exported electronic document.';
            }
        }
    }
}