// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Implements functionality to get page summary provider settings.
/// </summary>
codeunit 2720 "Page Summary Settings Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetPageSummaryProviderSettings(var PageSummarySettings: Record "Page Summary Settings"): Boolean
    var
        Company: Record "Company";
        NullGuid: Guid;
    begin
        Company.Get(CompanyName());

        if not PageSummarySettings.Get(Company.Id) then
            if not PageSummarySettings.Get(NullGuid) then
                exit(false);

        exit(true);
    end;

    procedure IsShowRecordSummaryEnabled(): Boolean
    var
        PageSummarySettings: Record "Page Summary Settings";
    begin
        if not GetPageSummaryProviderSettings(PageSummarySettings) then
            exit(true); // no settings, return default value

        exit(PageSummarySettings."Show Record summary");
    end;

}