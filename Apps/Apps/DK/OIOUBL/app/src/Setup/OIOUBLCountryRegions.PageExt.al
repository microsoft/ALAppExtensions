// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

pageextension 13645 "OIOUBL-Country/Regions" extends "Countries/Regions"
{
    layout
    {
        addafter("Intrastat Code")
        {
            field("OIOUBL-Country/Region Code"; "OIOUBL-Country/Region Code")
            {
                ApplicationArea = Basic, Suite;
                Tooltip = 'Specifies the ISO 3166-1 code for the country/region that you are doing business with.';
                Visible = False;
            }
        }
    }
}
