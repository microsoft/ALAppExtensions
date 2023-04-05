// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2504 "Extension Management - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Guided Experience - Objects";

    Permissions = Codeunit "Data Out Of Geo. App" = X,
                  Codeunit "Extension Management" = X,
                  Codeunit "Extension Marketplace" = X,
                  Page "Extension Deployment Status" = X,
                  Page "Extension Details Part" = X,
                  Page "Extension Details" = X,
                  Page "Extension Installation" = X,
                  Page "Extn. Installation Progress" = X,
                  Page "Extension Logo Part" = X,
                  Page "Extension Management" = X,
                  Page "Extension Marketplace" = X,
                  Page "Extension Settings" = X,
                  Page "Extn Deployment Status Detail" = X,
                  Page "Marketplace Extn Deployment" = X,
                  Page "Upload And Deploy Extension" = X,
                  Page "Extension Setup Launcher" = X,
                  Table "Extension Pending Setup" = X;
}
