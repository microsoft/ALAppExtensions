#if not CLEAN18
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The manual setup aggregates all cases where the functionality is setup manually. Typically this is accomplished 
/// by registering the setup page ID of the extension that contains the functionality.
/// </summary>
codeunit 1875 "Manual Setup"
{
    Access = Public;
    ObsoleteState = Pending;
    ObsoleteReason = 'The functions from this codeunit have been consolidated in the Guided Experience codeunit.';
    ObsoleteTag = '18.0';

    var
        GuidedExperience: Codeunit "Guided Experience";

    /// <summary>Insert a manual setup page for an extension.</summary>
    /// <param name="Name">The name of the setup.</param>
    /// <param name="Description">The description of the setup.</param>
    /// <param name="Keywords">The keywords related to the setup.</param>
    /// <param name="RunPage">The page ID of the setup page to be run.</param>
    /// <param name="ExtensionId">The ID of the extension that the caller is in. This is used to fetch the icon for the setup.</param>
    /// <param name="Category">The category that this manual setup belongs to.</param>
    [Obsolete('Replaced by Insert in the Guided Experience codeunit. See below how to invoke the new function.', '18.0')]
    procedure Insert(Name: Text[50]; Description: Text[250]; Keywords: Text[250]; RunPage: Integer; ExtensionId: Guid; Category: Enum "Manual Setup Category")
    var
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        SpotlightTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
    begin
        GuidedExperienceImpl.Insert(Name, CopyStr(Name, 1, 50), Description, 0, ExtensionId, GuidedExperienceType::"Manual Setup",
            ObjectType::Page, RunPage, '', AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '', Category,
            Keywords, SpotlightTourType::None, SpotlightTourTexts, true);
    end;

    /// <summary>Opens the Manual Setup page with the setup guides in it.</summary>
    [Obsolete('Replaced by OpenManualSetup() in the Guided Experience codeunit.', '18.0')]
    procedure Open()
    begin
        GuidedExperience.OpenManualSetupPage();
    end;

    /// <summary>Opens the Manual Setup page with the setup guides filtered on a selected group of guides.</summary>
    /// <param name="ManualSetupCategory">The group which the view should be filtered to.</param>
    [Obsolete('Replaced by OpenManualSetup(ManualSetupCategory) in the Guided Experience codeunit.', '18.0')]
    procedure Open(ManualSetupCategory: Enum "Manual Setup Category")
    begin
        GuidedExperience.OpenManualSetupPage(ManualSetupCategory);
    end;

    /// <summary>Register the manual setups and get the list of page IDs that have been registered.</summary>
    /// <param name="PageIDs">The reference to the list of page IDs for manual setups.</param>
    [Obsolete('The manual setups are now persisted in the Guided Experience Item table.', '18.0')]
    procedure GetPageIDs(var PageIDs: List of [Integer])
    var
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
    begin
        GuidedExperienceImpl.GetManualSetupPageIDs(PageIDs);
    end;

    /// <summary>
    /// The event that is raised so that subscribers can add the new manual setups that can be displayed in the Manual Setup page.
    /// </summary>
    /// <remarks>
    /// The subscriber should call <see cref="Insert"/> on the Sender object.
    /// </remarks>
    [Obsolete('Replaced by OnRegisterManualSetup in the Guided Experience codeunit.', '18.0')]
    [IntegrationEvent(true, false)]
    internal procedure OnRegisterManualSetup();
    begin
    end;
}
#endif