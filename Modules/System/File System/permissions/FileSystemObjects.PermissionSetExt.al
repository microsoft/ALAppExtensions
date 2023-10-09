// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

permissionset 70001 "File System - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions =
        table "File Account" = X,
        table "File System Connector" = X,
        table "File System Connector Logo" = X,
        table "File Account Scenario" = X,
        table "File Scenario" = X,
        table "File Account Content" = X,
        codeunit "File Account" = X,
        codeunit "File Account Impl." = X,
        codeunit "File Scenario" = X,
        codeunit "File Pagination Data" = X,
        codeunit "File System Impl." = X,
        codeunit "File System" = X,
        codeunit "File Scenario Impl." = X,
        page "File Accounts" = X,
        page "File Account Wizard" = X,
        page "Folder Name Input" = X,
        page "File Scenarios FactBox" = X,
        page "File Scenarios for Account" = X,
        page "File Scenario Setup" = X,
        page "File Account Browser" = X;
}
