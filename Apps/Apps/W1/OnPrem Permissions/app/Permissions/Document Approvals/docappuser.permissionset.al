// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 7112 "DOC-APP-USER"
{
    Access = Public;
    Assignable = true;
    Caption = 'Document Approval';

    IncludedPermissionSets = "Document Approvals - Edit";
}
