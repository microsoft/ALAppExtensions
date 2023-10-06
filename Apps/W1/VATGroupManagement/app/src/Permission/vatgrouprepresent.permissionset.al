// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

permissionset 4708 "VAT Group Represent."
{
    Assignable = true;
    Access = Public;
    Caption = 'VAT Group Representative';
    Permissions =
        tabledata "VAT Group Approved Member" = RIMD,
        tabledata "VAT Group Calculation" = RIMD,
        tabledata "VAT Group Submission Header" = RMD,
        tabledata "VAT Group Submission Line" = RMD;
}
