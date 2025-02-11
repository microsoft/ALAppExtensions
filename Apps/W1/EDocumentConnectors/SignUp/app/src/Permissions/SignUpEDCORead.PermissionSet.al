// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using Microsoft.eServices.EDocument;

permissionset 6381 SignUpEDCORead
{
    Access = Internal;
    Assignable = true;
    Caption = 'SignUp E-Doc. Connector - Read', MaxLength = 30;
    IncludedPermissionSets = SignUpEDCOObjects;
    Permissions = tabledata SignUpConnectionSetup = R,
                  tabledata SignUpMetadataProfile = R,
                  tabledata "E-Document Integration Log" = rim;


}