// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Tooling;

permissionset 149001 "BC Perf. Toolkit - Obj"
{
    Assignable = false;
    Access = Public;

    Permissions = table "BCPT Header" = X,
        table "BCPT Line" = X,
        table "BCPT Log Entry" = X,
        table "BCPT Parameter Line" = X,
        codeunit "BCPT Header" = X,
        codeunit "BCPT Install" = X,
        codeunit "BCPT Line" = X,
        codeunit "BCPT Role Wrapper" = X,
        codeunit "BCPT Start Tests" = X,
        codeunit "BCPT Test Context" = X,
        codeunit "BCPT Test Suite" = X,
        xmlport "BCPT Import/Export" = X,
        xmlport "BCPT Log Entries" = X,
        page "BCPT CommandLine Card" = X,
        page "BCPT Lines" = X,
        page "BCPT Log Entries" = X,
        page "BCPT Log Entry API" = X,
        page "BCPT Lookup Codeunits" = X,
        page "BCPT Parameters" = X,
        page "BCPT Setup Card" = X,
        page "BCPT Setup List" = X,
        page "BCPT Suite API" = X,
        page "BCPT Suite Line API" = X;
}