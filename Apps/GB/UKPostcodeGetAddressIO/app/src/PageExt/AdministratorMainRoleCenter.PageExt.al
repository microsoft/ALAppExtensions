// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if CLEAN28
namespace app.app;

using Microsoft.Foundation.Address;
using Microsoft.RoleCenters;

pageextension 50011 "Administrator Main Role Center" extends "Administrator Main Role Center"
{
    actions
    {
        addafter("Acc. Sched. KPI Web Service")
        {
            action("UK Postcode Address Autocomplete GB")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'UK Postcode Address Autocomplete';
                RunObject = page "Postcode Configuration Page GB";
            }
        }
    }
}
#endif