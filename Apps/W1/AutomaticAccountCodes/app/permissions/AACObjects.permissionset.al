// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

permissionset 4850 "AAC - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'AutomaticAccountCodes - Objects';

    Permissions = table "Automatic Account Header" = X,
        table "Automatic Account Line" = X,
        page "Automatic Account Header" = X,
        page "Automatic Account Line" = X,
        page "Automatic Account List" = X,
        codeunit "AA Codes Posting Helper" = X;
}