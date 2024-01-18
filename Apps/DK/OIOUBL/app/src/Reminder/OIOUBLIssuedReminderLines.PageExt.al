// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Reminder;

pageextension 13659 "OIOUBL-Issued Reminder Lines" extends "Issued Reminder Lines"
{
    layout
    {
        addafter("Applies-To Document No.")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Tooltip = 'Specifies the account code of the customer. This is used in the exported electronic document.';
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
