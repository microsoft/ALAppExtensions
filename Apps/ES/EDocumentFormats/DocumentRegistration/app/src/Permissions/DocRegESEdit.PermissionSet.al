// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Verifactu;

permissionset 10776 DocRegESEdit
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = DocRegESRead;
    Caption = 'Document Registration in Spain - Edit';

    Permissions = tabledata "Verifactu Setup" = IMD,
                  tabledata "Verifactu Document" = IMD;
}