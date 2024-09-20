// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

permissionset 6381 "SignUpEDoc. - Read"
{
    Access = Internal;
    Assignable = false;
    IncludedPermissionSets = "SignUpEDoc. - Objects";

    Permissions = tabledata ConnectionSetup = R,
                  tabledata ConnectionAuth = R;
}