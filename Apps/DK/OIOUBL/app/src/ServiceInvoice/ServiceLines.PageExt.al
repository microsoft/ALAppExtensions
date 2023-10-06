// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Document;

pageextension 13675 "OIOUBL-Service Lines" extends "Service Lines"
{
    layout
    {
        addafter("Symptom Code")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Visible = false;
                ApplicationArea = Service;
                ToolTip = 'Specifies the account code of the customer. This is used in the exported electronic document.';
            }
        }
    }
}
