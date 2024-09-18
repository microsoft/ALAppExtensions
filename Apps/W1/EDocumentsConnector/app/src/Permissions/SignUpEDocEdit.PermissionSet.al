// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

permissionset 6382 SignUpEDocEdit
{
    Access = Internal;
    Assignable = false;
    IncludedPermissionSets = SignUpEDocRead;

    Permissions = tabledata SignUpConnectionSetup = IM,
                tabledata SignUpConnectionAuth = IM;
}