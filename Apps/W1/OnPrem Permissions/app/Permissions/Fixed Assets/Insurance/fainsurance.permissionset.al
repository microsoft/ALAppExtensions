// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 6896 "FA-INSURANCE"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read insurances and entries';

    IncludedPermissionSets = "Insurance - Read";
}
