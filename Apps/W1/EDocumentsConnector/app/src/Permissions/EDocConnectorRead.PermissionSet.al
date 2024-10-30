// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.EServices.EDocumentConnector.Logiq;

permissionset 6362 "EDocConnector - Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "EDoc. Connector Objects";

    Permissions = tabledata "E-Doc. Ext. Connection Setup" = R
                  tabledata "Logiq Connection Setup" = R,
                  tabledata "Logiq Connection User Setup" = R;
}