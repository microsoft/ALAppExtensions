#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.SalesPurch.Setup;

using System.Environment.Configuration;

codeunit 10504 "Posting Date Check"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        FeatureKeyIdTok: Label 'PostingDateCheck', Locked = true;

    procedure IsEnabled() Enabled: Boolean
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
        Enabled := FeatureManagementFacade.IsEnabled(FeatureKeyIdTok);
        OnAfterCheckFeatureEnabled(Enabled);
    end;

    procedure GetFeatureKeyId(): Text
    begin
        exit(FeatureKeyIdTok);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
    end;
}
#endif