// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 4580 "Ext. SharePoint - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'SharePoint - Objects';

    Permissions =
        table "Ext. SharePoint Account" = X,
        codeunit "Ext. SharePoint Connector Impl" = X,
        page "Ext. SharePoint Account Wizard" = X,
        page "Ext. SharePoint Account" = X;
}
