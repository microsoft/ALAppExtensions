// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

permissionset 10519 "GovTalk - Objects Read"
{
    Access = Internal;
    Assignable = false;
    Permissions = tabledata "GovTalk Message" = R,
                  tabledata "GovTalk Msg. Parts" = R,
                  tabledata "Gov Talk Setup" = R;
}