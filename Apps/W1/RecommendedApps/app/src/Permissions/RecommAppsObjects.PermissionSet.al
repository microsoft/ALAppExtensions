// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Environment.Configuration;

permissionset 4752 "RecommApps - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'RecommendedApps - Objects';

    Permissions = codeunit "Recommended Apps" = X,
                     codeunit "Recommended Apps Impl." = X,
                     page "Recommended App Card" = X,
                     page "Recommended Apps List" = X,
                     table "Recommended Apps" = X;
}
