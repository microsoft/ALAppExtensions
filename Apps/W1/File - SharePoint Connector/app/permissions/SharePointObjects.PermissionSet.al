// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 80300 "SharePoint - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'SharePoint - Objects';

    Permissions =
        table "SharePoint Account" = X,
        codeunit "SharePoint Connector Impl." = X,
        page "SharePoint Account Wizard" = X,
        page "SharePoint Account" = X;
}
