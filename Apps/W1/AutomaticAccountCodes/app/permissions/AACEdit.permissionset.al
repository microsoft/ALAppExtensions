// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

permissionset 4852 "AAC - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'AutomaticAccountCodes - Edit';

    IncludedPermissionSets = "AAC - Read";

    Permissions = tabledata "Automatic Account Header" = IMD,
#if not CLEAN22
     tabledata "Auto. Acc. Page Setup" = IMD,
#endif
     tabledata "Automatic Account Line" = IMD;
}