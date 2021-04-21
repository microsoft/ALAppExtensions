// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Displays a list of plans.
/// </summary>
query 775 Plan
{
    Caption = 'Plan';
    Permissions = tabledata Plan = r,
                  tabledata User = r;

    elements
    {
        dataitem(Plan; Plan)
        {
            column(Plan_ID; "Plan ID")
            {
            }
            column(Plan_Name; "Name")
            {
            }
            column(Role_Center_ID; "Role Center ID")
            {
            }
        }
    }
}