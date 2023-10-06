// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

using System.Security.AccessControl;

permissionsetextension 4707 "INTELLIGENT CLOUD - VAT Group Management" extends "INTELLIGENT CLOUD"
{
    Permissions = tabledata "VAT Group Approved Member" = R,
                  tabledata "VAT Group Calculation" = RIMD,
                  tabledata "VAT Group Submission Header" = R,
                  tabledata "VAT Group Submission Line" = R;
}
