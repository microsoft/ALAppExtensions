// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Verifactu;

permissionset 10777 DocRegESRead
{
    Access = Public;
    Assignable = true;
    Caption = 'Document Registration in Spain - Read';

    Permissions = tabledata "Verifactu Setup" = R,
                  tabledata "Verifactu Document" = R;
}