// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.HumanResources.Setup;

pageextension 31278 "Human Resources Setup CZP" extends "Human Resources Setup"
{
    layout
    {
        modify("Allow Multiple Posting Groups")
        {
            ToolTip = 'Specifies if to enable checking on assignment an alternative posting group from employee posting group setup for the employee assigned in the general journal and cash document.';
        }
    }
}