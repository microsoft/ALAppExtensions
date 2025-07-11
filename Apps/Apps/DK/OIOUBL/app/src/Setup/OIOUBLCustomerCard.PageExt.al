// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

pageextension 13652 "OIOUBL-Customer Card" extends "Customer Card"
{
    layout
    {
        addafter("Copy Sell-to Addr. to Qte From")
        {
            field("OIOUBL-Account Code"; "OIOUBL-Account Code")
            {
                Tooltip = 'Specifies the account code for the customer.';
                ApplicationArea = Basic, Suite;
            }
            field("OIOUBL-Profile Code"; "OIOUBL-Profile Code")
            {
                Tooltip = 'Specifies the profile that this customer requires for electronic documents.';
                ApplicationArea = Basic, Suite;
            }
            field("OIOUBL-Profile Code Required"; "OIOUBL-Profile Code Required")
            {
                Tooltip = 'Specifies if this customer requires a profile code for electronic documents.';
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
