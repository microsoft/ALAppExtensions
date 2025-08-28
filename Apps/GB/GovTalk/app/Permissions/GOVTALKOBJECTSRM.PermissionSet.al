// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

permissionset 10525 "GovTalk - Objects RM"
{
    Access = Internal;
    Assignable = false;
    Permissions = tabledata "GovTalk Message" = RM,
                  tabledata "GovTalk Msg. Parts" = RM,
                  tabledata "Gov Talk Setup" = RM;
}