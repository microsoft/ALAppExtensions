// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality that manages page summary settings.
/// </summary>
codeunit 2719 "Page Summary Settings"
{
    /// <summary>
    /// Gets the page summary settings.
    /// </summary>
    /// <param name="PageSummarySettings">The record to get the page summary settings.</param>
    /// <returns></returns>
    procedure GetPageSummaryProviderSettings(var PageSummarySettings: Record "Page Summary Settings"): Boolean
    var
        PageSummarySettingsImpl: Codeunit "Page Summary Settings Impl.";
    begin
        exit(PageSummarySettingsImpl.GetPageSummaryProviderSettings(PageSummarySettings));
    end;

    /// <summary>
    /// Determines if Show Record Summary settings is enabled.
    /// </summary>
    /// <returns></returns>
    procedure IsShowRecordSummaryEnabled(): Boolean
    var
        PageSummarySettingsImpl: Codeunit "Page Summary Settings Impl.";
    begin
        exit(PageSummarySettingsImpl.IsShowRecordSummaryEnabled());
    end;

}