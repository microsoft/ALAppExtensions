#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Environment.Configuration;

codeunit 10544 "VAT Audit GB"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        FeatureKeyIdTok: Label 'PrintVATAuditReports', Locked = true;

    procedure IsEnabled() Result: Boolean
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
        Result := FeatureManagementFacade.IsEnabled(FeatureKeyIdTok);
        OnAfterCheckFeatureEnabled(Result);
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