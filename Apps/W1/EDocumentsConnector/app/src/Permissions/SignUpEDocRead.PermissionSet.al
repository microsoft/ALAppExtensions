// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

permissionset 6381 SignUpEDocRead
{
    Access = Internal;
    Assignable = false;
    IncludedPermissionSets = SignUpEDocObjects;

    Permissions = tabledata SignUpConnectionSetup = R,
                  tabledata SignUpConnectionAuth = R;
}