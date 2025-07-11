// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.eServices.EDocument;

permissionset 6441 "SignUp E-Doc Read"
{
    Access = Internal;
    Assignable = true;
    Caption = 'SignUp E-Doc. Connector - Read', MaxLength = 30;
    IncludedPermissionSets = "SignUp E-Doc Objects";
    Permissions = tabledata "SignUp Connection Setup" = R,
                  tabledata "SignUp Metadata Profile" = R,
                  tabledata "E-Document Integration Log" = rim;


}