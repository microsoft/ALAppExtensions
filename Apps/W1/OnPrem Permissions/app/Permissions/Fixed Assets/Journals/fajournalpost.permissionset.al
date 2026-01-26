// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 2019 "FA-JOURNAL, POST"
{
    Access = Public;
    Assignable = true;
    Caption = 'Post FA journals';
    
    IncludedPermissionSets = "Insurance Journals - Post";
}
