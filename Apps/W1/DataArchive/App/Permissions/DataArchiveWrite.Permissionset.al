// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 630 "Data Archive - Write"
{
    Access=Internal;
    Assignable=false;
    Permissions = tabledata "Data Archive" = rimd,
                  tabledata "Data Archive Table" = rimd,
                  tabledata "Data Archive Media Field" = rimd;
}
