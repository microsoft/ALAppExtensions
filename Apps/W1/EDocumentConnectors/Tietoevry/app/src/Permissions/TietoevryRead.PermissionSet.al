// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

permissionset 6391 "Tietoevry Read"
{
    Access = Public;
    Assignable = true;
    Caption = 'Tietoevry E-Document Connector - Read';

    Permissions = tabledata "Connection Setup" = r;
}