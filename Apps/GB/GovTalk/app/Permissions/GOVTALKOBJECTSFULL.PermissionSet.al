// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

permissionset 10504 "GovTalk - Objects Full"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "GovTalk - Objects RM",
                             "GovTalk - Objects X";
    Permissions = tabledata "GovTalk Message" = ID,
                  tabledata "GovTalk Msg. Parts" = ID,
                  tabledata "Gov Talk Setup" = ID;
}