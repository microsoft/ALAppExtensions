// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.DataAdministration;

using System.DataAdministration;
permissionsetextension 138700 "Reten Pol Admin" extends "Retention Pol. Admin"
{
    // Include Test tables
    Permissions = tabledata "Retention Policy Test Data" = RIMD,
                  tabledata "Retention Policy Test Data 3" = RIMD,
                  tabledata "Retention Policy Test Data 4" = RIMD,
                  tabledata "Retention Policy Test Data Two" = RIMD;
}
