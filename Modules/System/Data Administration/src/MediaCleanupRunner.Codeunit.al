// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.DataAdministration;

codeunit 1929 "Media Cleanup Runner"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        MediaCleanup: Codeunit "Media Cleanup";
    begin
        MediaCleanup.DeleteDetachedTenantMediaSet();
        MediaCleanup.DeleteDetachedTenantMedia();
    end;
}