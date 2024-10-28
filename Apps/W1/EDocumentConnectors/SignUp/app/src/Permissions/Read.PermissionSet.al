// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

permissionset 6381 Read
{
    Access = Internal;
    Assignable = false;
    Caption = 'SignUp E-Doc. Connector - Read', MaxLength = 30;
    IncludedPermissionSets = Objects;

    Permissions = tabledata ConnectionSetup = r;
}