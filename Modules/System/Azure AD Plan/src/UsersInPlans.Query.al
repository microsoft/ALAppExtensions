// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Displays a list of the plans assigned to users.
/// </summary>
query 774 "Users in Plans"
{
    Caption = 'Users in Plans';
    Permissions = tabledata Plan = r,
                  tabledata User = r,
                  tabledata "User Plan" = r;

    elements
    {
        dataitem(User_Plan; "User Plan")
        {
            SqlJoinType = InnerJoin;
            column(User_Security_ID; "User Security ID")
            {
            }
            column(User_Name; "User Name")
            {
            }
            column(Plan_ID; "Plan ID")
            {
            }
            column(Plan_Name; "Plan Name")
            {
            }
            dataitem(User; User)
            {
                DataItemLink = "User Security ID" = User_Plan."User Security ID";
                column(User_State; State)
                {
                    Caption = 'User State';
                }
            }
        }
    }
}