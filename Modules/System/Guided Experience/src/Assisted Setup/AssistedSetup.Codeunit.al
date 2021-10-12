#if not CLEAN18
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>Manage assisted setup guides by allowing the addition of new guides to the list, and updating whether a guide has been completed.</summary>
codeunit 3725 "Assisted Setup"
{
    Access = Public;

    ObsoleteState = Pending;
    ObsoleteReason = 'The functions from this codeunit have been consolidated in the Guided Experience codeunit.';
    ObsoleteTag = '18.0';

    /// <summary>Adds an assisted setup record from a given extension so that it can be shown in the list.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <param name="AssistantName">The name as shown for the setup.</param>
    /// <param name="GroupName">The assisted setup group enum that this belongs to.</param>
    [Obsolete('Replaced by Insert in the Guided Experience codeunit.', '18.0')]
    procedure Add(ExtensionID: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group")
    begin
        GuidedExperienceImpl.Insert(CopyStr(AssistantName, 1, 2048), CopyStr(AssistantName, 1, 50), '', 0, ExtensionId, GuidedExperienceType::"Assisted Setup",
            ObjectType::Page, PageID, '', GroupName, '', VideoCategory::Uncategorized, '', ManualSetupCategory::Uncategorized, '',
            SpotlightTourType::None, SpotlightTourTexts, true);
    end;

    /// <summary>Adds an assisted setup record from a given extension so that it can be shown in the list.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <param name="AssistantName">The name as shown for the setup.</param>
    /// <param name="GroupName">The assisted setup group enum that this belongs to.</param>
    /// <param name="VideoLink">The URL of the video that explains the purpose and use of this setup.</param>
    /// <param name="HelpLink">The help url that explains the purpose and usage of this setup.</param>
    [Obsolete('Replaced by Insert in the Guided Experience codeunit.', '18.0')]
    procedure Add(ExtensionID: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group"; VideoLink: Text[250]; HelpLink: Text[250])
    begin
        GuidedExperienceImpl.Insert(CopyStr(AssistantName, 1, 2048), CopyStr(AssistantName, 1, 50), '', 0, ExtensionId, GuidedExperienceType::"Assisted Setup",
            ObjectType::Page, PageID, '', GroupName, VideoLink, VideoCategory::Uncategorized, HelpLink, ManualSetupCategory::Uncategorized, '',
            SpotlightTourType::None, SpotlightTourTexts, true);
    end;

    /// <summary>Adds an assisted setup record from a given extension so that it can be shown in the list.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <param name="AssistantName">The name as shown for the setup.</param>
    /// <param name="GroupName">The assisted setup group enum that this belongs to.</param>
    /// <param name="VideoLink">The URL of the video that explains the purpose and use of this setup.</param>
    /// <param name="VideoCategory">The category of the video for this setup.</param>
    /// <param name="HelpLink">The help url that explains the purpose and usage of this setup.</param>
    [Obsolete('Replaced by Insert in the Guided Experience codeunit.', '18.0')]
    procedure Add(ExtensionID: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group"; VideoLink: Text[250]; VideoCategory: Enum "Video Category"; HelpLink: Text[250])
    begin
        GuidedExperienceImpl.Insert(CopyStr(AssistantName, 1, 2048), CopyStr(AssistantName, 1, 50), '', 0, ExtensionId, GuidedExperienceType::"Assisted Setup",
            ObjectType::Page, PageID, '', GroupName, VideoLink, VideoCategory, HelpLink, ManualSetupCategory::Uncategorized, '',
            SpotlightTourType::None, SpotlightTourTexts, true);
    end;

    /// <summary>Adds an assisted setup record from a given extension so that it can be shown in the list.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <param name="AssistantName">The name as shown for the setup.</param>
    /// <param name="GroupName">The assisted setup group enum that this belongs to.</param>
    /// <param name="VideoLink">The URL of the video that explains the purpose and use of this setup.</param>
    /// <param name="VideoCategory">The category of the video for this setup.</param>
    /// <param name="HelpLink">The help url that explains the purpose and usage of this setup.</param>
    /// <param name="Description">The description of this setup.</param>
    [Obsolete('Replaced by Insert in the Guided Experience codeunit.', '18.0')]
    procedure Add(ExtensionID: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group"; VideoLink: Text[250]; VideoCategory: Enum "Video Category"; HelpLink: Text[250]; Description: Text[1024])
    begin
        GuidedExperienceImpl.Insert(CopyStr(AssistantName, 1, 2048), CopyStr(AssistantName, 1, 50), Description, 0, ExtensionId,
            GuidedExperienceType::"Assisted Setup", ObjectType::Page, PageID, '', GroupName, VideoLink, VideoCategory, HelpLink,
            ManualSetupCategory::Uncategorized, '', SpotlightTourType::None, SpotlightTourTexts, true);
    end;

    /// <summary>Adds the translation for the name of the setup.</summary>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <param name="LanguageID">The language ID for which the translation is made.</param>
    /// <param name="TranslatedName">The translated text of the name.</param>
    [Obsolete('Replaced by AddTranslation(GuidedExperienceType, ObjectType, ObjectID, LanguageID, TranslatedName) in the Guided Experience codeunit.', '18.0')]
    procedure AddTranslation(PageID: Integer; LanguageID: Integer; TranslatedName: Text)
    begin
        GuidedExperience.AddTranslationForSetupObjectTitle(GuidedExperienceType::"Assisted Setup", ObjectType::Page, PageID, LanguageID, TranslatedName);
    end;

    /// <summary>Checks whether a user has already completed the setup.</summary>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <returns>Returns true if the given setup guide has been completed by the user, otherwise false.</returns> 
    [Obsolete('Replaced by IsAssistedSetupComplete(ObjectType, ObjectID) in the Guided Experience codeunit.', '18.0')]
    procedure IsComplete(PageID: Integer): Boolean
    begin
        exit(GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, PageID));
    end;

    /// <summary>Checks whether an assisted setup guide exists.</summary>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <returns>True if an assisted setup guide for provided extension and page IDs exists; false otherwise.</returns>
    [Obsolete('Replaced by Exists(GuidedExperienceType, ObjectType, ObjectID) in the Guided Experience codeunit.', '18.0')]
    procedure Exists(PageID: Integer): Boolean
    begin
        exit(GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, PageID));
    end;

    /// <summary>Checks whether as assisted setup guide exists but has not been completed.</summary>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <returns>True if it exists and is incomplete, false otherwise.</returns>
    [Obsolete('Replaced by AssistedSetupExistsAndIsNotComplete(ObjectType, ObjectID) in the Guided Experience codeunit.', '18.0')]
    procedure ExistsAndIsNotComplete(PageID: Integer): Boolean
    begin
        exit(GuidedExperience.AssistedSetupExistsAndIsNotComplete(ObjectType::Page, PageID));
    end;

    /// <summary>Sets the status of the assisted setup to Complete.</summary>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <remarks>This is typically called from inside the assisted setup guide when the setup is finished.</remarks>
    [Obsolete('Replaced by CompleteAssistedSetup(ObjectType, ObjectID) in the Guided Experience codeunit.', '18.0')]
    procedure Complete(PageID: Integer)
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, PageID);
    end;

    /// <summary>Resets the status of the assisted setup guide so that it does not appear to have been completed.</summary>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    [Obsolete('Replaced by ResetAssistedSetup(ObjectType, ObjectID) in the Guided Experience codeunit.', '18.0')]
    procedure Reset(PageID: Integer)
    begin
        GuidedExperience.ResetAssistedSetup(ObjectType::Page, PageID);
    end;

    /// <summary>Issues the call to start the setup.</summary>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <remarks>If the page does not exist the user can choose whether to delete the page record.</remarks>
    [Obsolete('Replaced by RunAssistedSetup(GuidedExperienceType, ObjectType, ObjectID) in the Guided Experience codeunit.', '18.0')]
    procedure Run(PageID: Integer)
    begin
        GuidedExperience.Run(GuidedExperienceType::"Assisted Setup", ObjectType::Page, PageID);
    end;

    /// <summary>Opens the Assisted Setup page with the setup guides in it.</summary>
    [Obsolete('Replaced by OpenAssistedSetup() in the Guided Experience codeunit.', '18.0')]
    procedure Open()
    begin
        GuidedExperience.OpenAssistedSetup();
    end;

    /// <summary>Opens the Assisted Setup page with the setup guides filtered on a selected group of guides.</summary>
    /// <param name="AssistedSetupGroup">The group of guides to display on the Assisted Setup page.</param>
    [Obsolete('Replaced by OpenAssistedSetup(AssistedSetupGroup) in the Guided Experience codeunit.', '18.0')]
    procedure Open(AssistedSetupGroup: Enum "Assisted Setup Group")
    begin
        GuidedExperience.OpenAssistedSetup(AssistedSetupGroup);
    end;

    /// <summary>Removes an Assisted Setup so it will no longer be shown in the list.</summary>
    /// <param name="PageID">The ID of the page to be removed.</param>
    /// <remarks>The OnRegister subscriber which adds this PageID needs to be removed first.</remarks>
    [Obsolete('Replaced by Remove(GuidedExperienceType, ObjectType, ObjectID) in the Guided Experience codeunit.', '18.0')]
    procedure Remove(PageID: Integer)
    begin
        GuidedExperience.Remove(GuidedExperienceType::"Assisted Setup", ObjectType::Page, PageID);
    end;

    /// <summary>Notifies the user that the list of assisted setup guides is being gathered, and that new guides might be added.</summary>
    [Obsolete('Replaced by OnAssistedSetupRegister() in the Guided Experience codeunit.', '18.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnRegister()
    begin
    end;

    /// <summary>Notifies the user that a setup that was previously completed is being run again.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <param name="Handled">The flag which if set, would stop executing the run of the assisted setup guide.</param>
    [Obsolete('Replaced by OnReRunOfCompletedAssistedSetup(ExtensionID, ObjectType, ObjectID, Handled) in the Guided Experience codeunit.', '18.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnReRunOfCompletedSetup(ExtensionID: Guid; PageID: Integer; var Handled: Boolean)
    begin
    end;

    /// <summary>Notifies that the run of the assisted setup has finished.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    [Obsolete('Replaced by OnAfterRunAssistedSetup(ExtensionID, ObjectType, ObjectID) in the Guided Experience codeunit.', '18.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnAfterRun(ExtensionID: Guid; PageID: Integer)
    begin
    end;

    /// <summary>Notifies that the Open Role Based Setup Experience has been invoked.</summary>
    /// <param name="PageID">The Page ID of the page been invoked.</param>
    /// <param name="Handled">The flag which if set, would stop executing the OpenRoleBasedSetupExperience of the assisted setup guide.</param>  
    [Obsolete('Replaced by OnBeforeOpenRoleBasedAssistedSetupExperience(ObjectType, ObjectID, Handled) in the Guided Experience codeunit.', '18.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeOpenRoleBasedSetupExperience(var PageID: Integer; var Handled: Boolean)
    begin
    end;

    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        GuidedExperienceType: Enum "Guided Experience Type";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        SpotlightTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
}
#endif