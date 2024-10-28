// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

permissionset 6382 Edit
{
    Access = Internal;
    Assignable = false;
    Caption = 'SignUp E-Doc. Connector - Edit', MaxLength = 30;
    IncludedPermissionSets = Read;

    Permissions = tabledata ConnectionSetup = imd;
}