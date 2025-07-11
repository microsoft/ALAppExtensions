// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

using System.Security.AccessControl;

permissionsetextension 4701 "D365 BASIC - VAT Group Management" extends "D365 BASIC"
{
    Permissions = tabledata "VAT Group Approved Member" = R,
                  tabledata "VAT Group Calculation" = RIMD,
                  tabledata "VAT Group Submission Header" = R,
                  tabledata "VAT Group Submission Line" = R;
}
