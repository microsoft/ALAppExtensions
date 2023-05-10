// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 135536 "Rec. Selection Read"
{
    Assignable = true;

    // Include Test Objects
    Permissions = tabledata "Page Data Personalization" = R,
                  tabledata "Record Selection Test Table" = RIMD,
                  table "Record Selection Test Table" = X,
                  page "Record Selection Test Page" = X;
}