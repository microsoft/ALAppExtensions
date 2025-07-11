// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

permissionset 4709 "VAT Group Member"
{
    Assignable = true;
    Access = Public;
    Caption = 'VAT Group Member';
    Permissions =
        tabledata "VAT Group Submission Header" = RI,
        tabledata "VAT Group Submission Line" = RI;
}
