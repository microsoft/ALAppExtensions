// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

using System.Security.AccessControl;

permissionsetextension 4702 "D365 BUS FULL ACCESS - VAT Group Management" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "VAT Group Approved Member" = RIMD,
                  tabledata "VAT Group Calculation" = RIMD,
                  tabledata "VAT Group Submission Header" = RIMD,
                  tabledata "VAT Group Submission Line" = RIMD;
}
