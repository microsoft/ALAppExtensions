#if not CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Environment.Configuration;

codeunit 11720 "Replace VAT Period Mgt. CZL"
{
    Access = Internal;

    var
        ReplaceVATPeriodFeatureIdTok: Label 'ReplaceVATPeriod', Locked = true, MaxLength = 50;
        ReplaceVATPeriodNotEnabledErr: Label 'The replacing VAT Period CZ table with VAT Return Period is not enabled.\Please enable it by using Feature Management before use.';
        ReplaceVATPeriodEnabledErr: Label 'The replacing VAT Period CZ table with VAT Return Period is already enabled.\Please use the new VAT Return Period feature instead.';

    procedure IsEnabled() FeatureEnabled: Boolean
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
        FeatureEnabled := FeatureManagementFacade.IsEnabled(GetFeatureKey());
#pragma warning disable AL0432
        OnAfterIsEnabled(FeatureEnabled);
#pragma warning restore AL0432
    end;

    procedure TestIsEnabled()
    begin
        if not IsEnabled() then
            Error(ReplaceVATPeriodNotEnabledErr);
    end;

    procedure TestIsNotEnabled()
    begin
        if IsEnabled() then
            Error(ReplaceVATPeriodEnabledErr);
    end;

    procedure GetFeatureKey(): Text[50]
    begin
        exit(ReplaceVATPeriodFeatureIdTok);
    end;

    [Obsolete('The VAT Period CZL will be replaced by VAT Return Period by default.', '28.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterIsEnabled(var FeatureEnabled: Boolean)
    begin
    end;
}
#endif
