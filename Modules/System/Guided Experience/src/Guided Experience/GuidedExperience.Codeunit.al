// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Manage the guided experience items that users can access.
/// </summary>
codeunit 1990 "Guided Experience"
{
    Access = Public;

    var
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";

    /// <summary>Inserts a manual setup page.</summary>
    /// <param name="Title">The title of the manual setup.</param>
    /// <param name="ShortTitle">A short title used for the checklist.</param>
    /// <param name="Description">The description of the manual setup.</param>
    /// <param name="ExpectedDuration">How many minutes the setup is expected to take.</param>
    /// <param name="ObjectTypeToRun">The type of the object to be run as part of the setup.</param>
    /// <param name="ObjectIDToRun">The ID of the object to be run as part of the setup.</param>
    /// <param name="ManualSetupCategory">The category that this manual setup belongs to.</param>
    /// <param name="Keywords">The keywords related to the manual setup.</param>
    procedure InsertManualSetup(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; ManualSetupCategory: Enum "Manual Setup Category"; Keywords: Text[250])
    var
        CallerModuleInfo: ModuleInfo;
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        SpotlighTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);

        GuidedExperienceImpl.Insert(Title, ShortTitle, Description, ExpectedDuration, CallerModuleInfo.Id, GuidedExperienceType::"Manual Setup",
            ObjectTypeToRun, ObjectIDToRun, '', AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '', ManualSetupCategory,
            Keywords, SpotlighTourType::None, SpotlightTourTexts, true);
    end;

    /// <summary>Inserts an assisted setup page.</summary>
    /// <param name="Title">The title of the assisted setup.</param>
    /// <param name="ShortTitle">A short title used for the checklist.</param>
    /// <param name="Description">The description of the assisted setup.</param>
    /// <param name="ExpectedDuration">How many minutes the setup is expected to take.</param>
    /// <param name="ObjectTypeToRun">The type of the object to be run as part of the setup.</param>
    /// <param name="ObjectIDToRun">The ID of the object to be run as part of the setup.</param>
    /// <param name="AssistedSetupGroup">The assisted setup group enum that this belongs to.</param>
    /// <param name="VideoUrl">The URL of the video that explains the purpose and use of this setup.</param>
    /// <param name="VideoCategory">The category of the video for this setup.</param>
    /// <param name="HelpLink">The help url that explains the purpose and usage of this setup.</param>
    procedure InsertAssistedSetup(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; AssistedSetupGroup: Enum "Assisted Setup Group"; VideoUrl: Text[250]; VideoCategory: Enum "Video Category"; HelpUrl: Text[250])
    var
        CallerModuleInfo: ModuleInfo;
        GuidedExperienceType: Enum "Guided Experience Type";
        ManualSetupCategory: Enum "Manual Setup Category";
        SpotlighTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);

        GuidedExperienceImpl.Insert(Title, ShortTitle, Description, ExpectedDuration, CallerModuleInfo.Id, GuidedExperienceType::"Assisted Setup",
            ObjectTypeToRun, ObjectIDToRun, '', AssistedSetupGroup, VideoUrl, VideoCategory, HelpUrl, ManualSetupCategory::Uncategorized, '',
            SpotlighTourType::None, SpotlightTourTexts, true);
    end;

#if not CLEAN19
    /// <summary>Inserts a learn page.</summary>
    /// <param name="Title">The title of the learn page.</param>
    /// <param name="ShortTitle">A short title used for the checklist.</param>
    /// <param name="Description">The description of the learn page.</param>
    /// <param name="ExpectedDuration">How many minutes the learn page would take to read.</param>
    /// <param name="PageID">The ID of the learn page.</param>
    [Obsolete('Use InsertManualSetup instead.', '19.0')]
    procedure InsertLearnPage(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; PageID: Integer)
    var
        CallerModuleInfo: ModuleInfo;
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        SpotlighTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);

        GuidedExperienceImpl.Insert(Title, ShortTitle, Description, ExpectedDuration, CallerModuleInfo.Id, GuidedExperienceType::Learn,
            ObjectType::Page, PageID, '', AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '',
            ManualSetupCategory::Uncategorized, '', SpotlighTourType::None, SpotlightTourTexts, true);
    end;
#endif

    /// <summary>Inserts a learn link.</summary>
    /// <param name="Title">The title of the learn link.</param>
    /// <param name="ShortTitle">A short title used for the checklist.</param>
    /// <param name="Description">The description of the learn link.</param>
    /// <param name="ExpectedDuration">How many minutes the user should expect to spend using the link.</param>
    /// <param name="Link">The learn link.</param>
    procedure InsertLearnLink(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; Link: Text[250])
    var
        CallerModuleInfo: ModuleInfo;
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        SpotlighTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
        ObjectType: ObjectType;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);

        GuidedExperienceImpl.Insert(Title, ShortTitle, Description, ExpectedDuration, CallerModuleInfo.Id, GuidedExperienceType::Learn,
            ObjectType, 0, Link, AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '', ManualSetupCategory::Uncategorized,
            '', SpotlighTourType::None, SpotlightTourTexts, true);
    end;

    /// <summary>Inserts a tour for a page.</summary>
    /// <param name="Title">The title of the tour.</param>
    /// <param name="ShortTitle">A short title used for the checklist.</param>
    /// <param name="Description">The description of the tour.</param>
    /// <param name="ExpectedDuration">How many minutes the user should expect to spend taking the tour.</param>
    /// <param name="PageID">The ID of the page that the tour is run on.</param>
    procedure InsertTour(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; PageID: Integer)
    var
        CallerModuleInfo: ModuleInfo;
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        SpotlighTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
        ObjectType: ObjectType;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);

        GuidedExperienceImpl.Insert(Title, ShortTitle, Description, ExpectedDuration, CallerModuleInfo.Id,
            GuidedExperienceType::Tour, ObjectType::Page, PageID, '', AssistedSetupGroup::Uncategorized, '',
            VideoCategory::Uncategorized, '', ManualSetupCategory::Uncategorized, '', SpotlighTourType::None, SpotlightTourTexts, true);
    end;

    /// <summary>Inserts a spotlight tour for a page.</summary>
    /// <param name="Title">The title of the manual setup.</param>
    /// <param name="ShortTitle">A short title used for the checklist.</param>
    /// <param name="Description">The description of the manual setup.</param>
    /// <param name="ExpectedDuration">How many minutes the tour is expected to take.</param>
    /// <param name="PageID">The ID of the page that the spotlight tour will be run on.</param>
    /// <param name="SpotlightTourType">The type of spotlight tour.</param>
    /// <param name="SpotlightTourTexts">The texts that will be displayed during the spotlight tour.</param>
    procedure InsertSpotlightTour(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; PageID: Integer; SpotlighTourType: Enum "Spotlight Tour Type"; SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text])
    var
        CallerModuleInfo: ModuleInfo;
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);

        GuidedExperienceImpl.Insert(Title, ShortTitle, Description, ExpectedDuration, CallerModuleInfo.Id, GuidedExperienceType::"Spotlight Tour",
            ObjectType::Page, PageID, '', AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '', ManualSetupCategory::Uncategorized,
            '', SpotlighTourType, SpotlightTourTexts, true);
    end;

    /// <summary>Inserts a guided experience item for an application feature.</summary>
    /// <param name="Title">The title of the application feature.</param>
    /// <param name="ShortTitle">A short title used for the checklist.</param>
    /// <param name="Description">The description of the application feature.</param>
    /// <param name="ExpectedDuration">How many minutes the user should expect to spend .</param>
    /// <param name="ObjectTypeToRun">The object type to run for the application feature.</param>
    /// <param name="ObjectIDToRun">The object ID to run for the application feature.</param>
    procedure InsertApplicationFeature(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer)
    var
        CallerModuleInfo: ModuleInfo;
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        SpotlighTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);

        GuidedExperienceImpl.Insert(Title, ShortTitle, Description, ExpectedDuration, CallerModuleInfo.Id,
            GuidedExperienceType::"Application Feature", ObjectTypeToRun, ObjectIDToRun, '', AssistedSetupGroup::Uncategorized, '',
            VideoCategory::Uncategorized, '', ManualSetupCategory::Uncategorized, '', SpotlighTourType::None, SpotlightTourTexts, true);
    end;

    /// <summary>Inserts a guided experience item for a video.</summary>
    /// <param name="Title">The title of the video.</param>
    /// <param name="ShortTitle">A short title used for the checklist.</param>
    /// <param name="Description">The description of the video.</param>
    /// <param name="ExpectedDuration">The duration of the video in minutes.</param>
    /// <param name="VideoUrl">The URL of the video.</param>
    /// <param name="VideoCategory">The category of the video.</param>
    procedure InsertVideo(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; VideoURL: Text[250]; VideoCategory: Enum "Video Category")
    var
        CallerModuleInfo: ModuleInfo;
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        ManualSetupCategory: Enum "Manual Setup Category";
        SpotlighTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
        ObjectType: ObjectType;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);

        GuidedExperienceImpl.Insert(Title, ShortTitle, Description, ExpectedDuration, CallerModuleInfo.Id, GuidedExperienceType::Video,
            ObjectType, 0, '', AssistedSetupGroup::Uncategorized, VideoURL, VideoCategory, '', ManualSetupCategory::Uncategorized,
            '', SpotlighTourType::None, SpotlightTourTexts, true);
    end;


    /// <summary>Opens the Manual Setup page containing the setup guides.</summary>
    procedure OpenManualSetupPage()
    begin
        GuidedExperienceImpl.OpenManualSetupPage();
    end;

    /// <summary>Opens the Manual Setup page with the setup guides filtered on a selected group of guides.</summary>
    /// <param name="ManualSetupCategory">The group which the view should be filtered to.</param>
    procedure OpenManualSetupPage(ManualSetupCategory: Enum "Manual Setup Category")
    begin
        GuidedExperienceImpl.OpenManualSetupPage(ManualSetupCategory);
    end;

    /// <summary>Adds the translation for the title of the setup object.</summary>
    /// <param name="GuidedExperienceType">The type of setup object.</param>
    /// <param name="ObjectType">The object type that identifies the guided experience item.</param>
    /// <param name="ObjectID">The object ID that identifies the guided experience item.</param>
    /// <param name="LanguageID">The language ID for which the translation is made.</param>
    /// <param name="Translation">The translated text of the title.</param>
    procedure AddTranslationForSetupObjectTitle(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer; LanguageID: Integer; Translation: Text)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
    begin
        GuidedExperienceImpl.AddTranslationForSetupObject(GuidedExperienceType, ObjectType, ObjectID, LanguageID, Translation, GuidedExperienceItem.FieldNo(Title));
    end;

    /// <summary>Adds the translation for the description of the setup object.</summary>
    /// <param name="GuidedExperienceType">The type of setup object.</param>/// 
    /// <param name="ObjectType">The object type that identifies the guided experience item.</param>
    /// <param name="ObjectID">The object ID that identifies the guided experience item.</param>
    /// <param name="LanguageID">The language ID for which the translation is made.</param>
    /// <param name="Translation">The translated text of the description.</param>
    procedure AddTranslationForSetupObjectDescription(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer; LanguageID: Integer; Translation: Text)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
    begin
        GuidedExperienceImpl.AddTranslationForSetupObject(GuidedExperienceType, ObjectType, ObjectID, LanguageID, Translation, GuidedExperienceItem.FieldNo(Description));
    end;

    /// <summary>Checks whether a user has completed the setup corresponding to the object type and ID.</summary>
    /// <param name="ObjectType">The object type that identifies the guided experience item.</param>
    /// <param name="ObjectID">The object ID that identifies the guided experience item.</param>
    /// <returns>Returns true if the given setup guide has been completed by a user, otherwise false.</returns> 
    procedure IsAssistedSetupComplete(ObjectType: ObjectType; ObjectID: Integer): Boolean
    begin
        exit(GuidedExperienceImpl.IsAssistedSetupComplete(ObjectType, ObjectID));
    end;

    /// <summary>Checks whether a guided experience item exists for the given object type and ID.</summary>
    /// <param name="GuidedExperienceType">The type of setup object.</param>/// /// 
    /// <param name="ObjectType">The object type that identifies the guided experience item.</param>
    /// <param name="ObjectID">The object ID that identifies the guided experience item.</param>
    /// <returns>True if a guided experience item exists for the provided object type and ID; false otherwise.</returns>
    procedure Exists(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer): Boolean
    begin
        exit(GuidedExperienceImpl.Exists(GuidedExperienceType, ObjectType, ObjectID));
    end;

    /// <summary>Checks whether a guided experience item exists for the link.</summary>
    /// <param name="GuidedExperienceType">The type of setup object.</param>/// /// 
    /// <param name="Link">The link that identifies the guided experience item.</param>
    /// <returns>True if a guided experience item exists for the provided link; false otherwise.</returns>
    procedure Exists(GuidedExperienceType: Enum "Guided Experience Type"; Link: Text[250]): Boolean
    begin
        exit(GuidedExperienceImpl.Exists(GuidedExperienceType, Link));
    end;

    /// <summary>Checks whether a guided experience item exists but has not been completed for the given object type and ID.</summary>
    /// <param name="ObjectType">The object type that identifies the guided experience item.</param>
    /// <param name="ObjectID">The object ID that identifies the guided experience item.</param>
    /// <returns>True if it exists and is incomplete, false otherwise.</returns>
    procedure AssistedSetupExistsAndIsNotComplete(ObjectType: ObjectType; ObjectID: Integer): Boolean
    begin
        exit(GuidedExperienceImpl.AssistedSetupExistsAndIsNotComplete(ObjectType, ObjectID));
    end;

    /// <summary>Sets the status of the guided experience item to complete.</summary>
    /// <param name="ObjectType">The object type that identifies the guided experience item.</param>
    /// <param name="ObjectID">The object ID that identifies the guided experience item.</param>
    /// <remarks>This is typically called from inside the guided experience item when the setup is finished.</remarks>
    procedure CompleteAssistedSetup(ObjectType: ObjectType; ObjectID: Integer)
    begin
        GuidedExperienceImpl.CompleteAssistedSetup(ObjectType, ObjectID);
    end;

    /// <summary>Resets the status of the guided experience item so that it does not appear to have been completed.</summary>
    /// <param name="ObjectType">The object type that identifies the guided experience item.</param>
    /// <param name="ObjectID">The object ID that identifies the guided experience item.</param>
    procedure ResetAssistedSetup(ObjectType: ObjectType; ObjectID: Integer)
    begin
        GuidedExperienceImpl.ResetAssistedSetup(ObjectType, ObjectID);
    end;

    /// <summary>Issues the call to start the guided experience item.</summary>
    /// <param name="GuidedExperienceType">The type of setup object.</param>/// /// 
    /// <param name="ObjectType">The object type that identifies the guided experience item.</param>
    /// <param name="ObjectID">The object ID that identifies the guided experience item.</param>
    procedure Run(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer)
    begin
        GuidedExperienceImpl.Run(GuidedExperienceType, ObjectType, ObjectID);
    end;

    /// <summary>Opens the Assisted Setup page with the setup guides in it.</summary>
    procedure OpenAssistedSetup()
    begin
        GuidedExperienceImpl.OpenAssistedSetup();
    end;

    /// <summary>Opens the Assisted Setup page with the setup guides filtered on a selected group of guides.</summary>
    /// <param name="AssistedSetupGroup">The group of guides to display on the Assisted Setup page.</param>
    procedure OpenAssistedSetup(AssistedSetupGroup: Enum "Assisted Setup Group")
    begin
        GuidedExperienceImpl.OpenAssistedSetup(AssistedSetupGroup);
    end;

    /// <summary>Removes a guided experience item.</summary>
    /// <param name="GuidedExperienceType">The type of setup object.</param>
    /// <param name="ObjectType">The object type that identifies the guided experience item.</param>
    /// <param name="ObjectID">The object ID that identifies the guided experience item.</param>
    /// <remarks>The OnRegister subscriber which adds this guided experience item needs to be removed first.</remarks>
    procedure Remove(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer)
    begin
        GuidedExperienceImpl.Remove(GuidedExperienceType, ObjectType, ObjectID);
    end;

    /// <summary>Removes a guided experience item.</summary>
    /// <param name="GuidedExperienceType">The type of guided experience item.</param>
    /// <param name="Link">The link that identifies the guided experience item.</param>
    /// <remarks>The OnRegister subscriber which adds this guided experience item needs to be removed first.</remarks>
    procedure Remove(GuidedExperienceType: Enum "Guided Experience Type"; Link: Text[250])
    begin
        GuidedExperienceImpl.Remove(GuidedExperienceType, Link);
    end;

    /// <summary>
    /// Removes a guided experience item.
    /// </summary>
    /// <param name="GuidedExperienceType">The type of guided experience item.</param>
    /// <param name="ObjectType">The object type of the guided experience item.</param>
    /// <param name="ObjectID">The object ID of the guided experience item.</param>
    /// <param name="SpotlightTourType">The type of spotlight tour of the guided experience item.</param>
    procedure Remove(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer; SpotlightTourType: Enum "Spotlight Tour Type")
    begin
        GuidedExperienceImpl.Remove(GuidedExperienceType, ObjectType, ObjectID, SpotlightTourType);
    end;

    /// <summary>Notifies that the list of assisted setups is being gathered, and that new items might be added.</summary>
    [IntegrationEvent(false, false)]
    internal procedure OnRegisterAssistedSetup()
    begin
    end;

    /// <summary>Notifies that an assisted setup that was previously completed is being run again.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the item belongs.</param>
    /// <param name="ObjectType">The object type that identifies the assisted setup.</param>
    /// <param name="ObjectID">The object ID that identifies the assisted setup.</param>
    /// <param name="Handled">The flag which if set, would stop executing the run of the assisted setup.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnReRunOfCompletedAssistedSetup(ExtensionID: Guid; ObjectType: ObjectType; ObjectID: Integer; var Handled: Boolean)
    begin
    end;

    /// <summary>Notifies that the run of the assisted setup has finished.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="ObjectType">The object type that identifies the assisted setup.</param>
    /// <param name="ObjectID">The object ID that identifies the assisted setup.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterRunAssistedSetup(ExtensionID: Guid; ObjectType: ObjectType; ObjectID: Integer)
    begin
    end;

    /// <summary>Notifies that the Open Role Based Setup Experience has been invoked.</summary>
    /// <param name="PageID">The ID of the page being invoked.</param>
    /// <param name="Handled">The flag which if set, would stop executing the OpenRoleBasedSetupExperience of the assisted setup guide.</param>  
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeOpenRoleBasedAssistedSetupExperience(var PageID: Integer; var Handled: Boolean)
    begin
    end;

    /// <summary>
    /// The event that is raised so that subscribers can add the new manual setups that can be displayed in the Manual Setup page.
    /// </summary>
    [IntegrationEvent(true, false)]
    internal procedure OnRegisterManualSetup();
    begin
    end;

    /// <summary>
    /// The event that is raised so that subscribers can add the new guided experience items.
    /// </summary>
    [IntegrationEvent(true, false)]
    internal procedure OnRegisterGuidedExperienceItem();
    begin
    end;
}