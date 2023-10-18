// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

/// <summary>
/// Displays a list of the Role Center Ids assigned to users through plans.
/// </summary>
query 777 "Role Center from Plans"
{
    Caption = 'RoleCenter from Plans';
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata Plan = r,
                  tabledata "User Plan" = r;

    elements
    {
        dataitem(User_Plan; "User Plan")
        {
            filter(User_Security_ID; "User Security ID") { }
            dataitem(Plan; Plan)
            {
                SqlJoinType = InnerJoin;
                DataItemLink = "Plan ID" = User_Plan."Plan ID";
                column(Role_Center_ID; "Role Center ID")
                {
                    Caption = 'Role Center ID';
                }
            }
        }
    }
}