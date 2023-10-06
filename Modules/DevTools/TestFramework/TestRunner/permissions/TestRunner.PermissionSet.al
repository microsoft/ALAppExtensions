// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestTools.TestRunner;

permissionset 130451 TestRunner
{
    Assignable = true;
    Caption = 'TestRunner Permissions';

    IncludedPermissionSets = "Test Runner - Exec";

    Permissions = tabledata "AL Test Suite" = RIMD,
        tabledata "Test Method Line" = RIMD;
}