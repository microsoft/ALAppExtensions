// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

/// <summary>
/// Provides functionality to customize the Checklist Banner
/// </summary>
codeunit 3728 "Checklist Banner"
{
    Access = Public;
    Description = 'Public events for the Checklist Banner';
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Integration Event to provide the ability to customize Labels on the Checklist Banner
    /// </summary>
    /// <param name="IsHandled"> Whether the labels are handled by the subscriber, set it to false if you want them to be handled by first-party logic </param>
    /// <param name="IsEvaluationCompany"> If the company has type Evaluation </param>
    /// <param name="TitleTxt"> The title text for the checklist banner </param>
    /// <param name="TitleCollapsedTxt"> The title collapse text for the checklist banner </param>
    /// <param name="HeaderTxt"> The header text for the checklist banner </param>
    /// <param name="HeaderCollapsedTxt"> The header collapse text for the checklist banner </param>
    /// <param name="DescriptionTxt"> The description text for the checklist banner </param>
    /// <param name="IsSetupStarted"> If setup has started for the checklist banner </param>
    /// <param name="AreAllItemsSkippedOrCompleted"> If all the checklist items are skipped or completed </param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeUpdateBannerLabels(var IsHandled: Boolean; IsEvaluationCompany: Boolean; var TitleTxt: Text; var TitleCollapsedTxt: Text; var HeaderTxt: Text; var HeaderCollapsedTxt: Text; var DescriptionTxt: Text; IsSetupStarted: Boolean; AreAllItemsSkippedOrCompleted: Boolean)
    begin
    end;

    /// <summary>
    /// Integration Event to provide the ability to skip the welcome state of the checklist banner.
    /// </summary>
    /// <param name="SkipWelcomeState"> Whether to skip the welcome state or not </param>
    /// <param name="IsEvaluationCompany"> If the company has type Evaluation </param>
    [IntegrationEvent(false, false)]
    internal procedure OnOpenChecklistBannerPage(var SkipWelcomeState: Boolean; IsEvaluationCompany: Boolean)
    begin
    end;
}