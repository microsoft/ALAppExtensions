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
#if not CLEAN23 
        codeunit "Inv. Post. Buff. Subscribers" = X,
#endif 
        page "Automatic Account Header" = X,
        page "Automatic Account Line" = X,
        page "Automatic Account List" = X,
#if not CLEAN22
        codeunit "Auto. Acc. Codes Feature Mgt." = X,
        tabledata "Auto. Acc. Page Setup" = RIMD,
        table "Auto. Acc. Page Setup" = X,
        codeunit "Auto. Acc. Codes Page Mgt." = X,
        codeunit "Feature Auto. Acc. Codes" = X,
#endif
        codeunit "AA Codes Posting Helper" = X;
}