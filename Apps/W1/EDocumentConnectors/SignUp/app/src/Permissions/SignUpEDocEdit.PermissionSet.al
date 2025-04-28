// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

permissionset 6442 "SignUp E-Doc Edit"
{
    Access = Internal;
    Assignable = true;
    Caption = 'SignUp E-Doc. Connector - Edit', MaxLength = 30;
    IncludedPermissionSets = "SignUp E-Doc Read";
    Permissions = tabledata "SignUp Connection Setup" = IMD,
                  tabledata "SignUp Metadata Profile" = IMD;

}