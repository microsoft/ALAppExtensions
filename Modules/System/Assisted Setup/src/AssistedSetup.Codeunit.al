// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>Manage assisted setup guides by allowing the addition of new guides to the list, and updating whether a guide has been completed.</summary>
codeunit 3725 "Assisted Setup"
{
    Access = Public;

    /// <summary>Adds an assisted setup record from a given extension so that it can be shown in the list.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <param name="AssistantName">The name as shown for the setup.</param>
    /// <param name="GroupName">The assisted setup group enum that this belongs to.</param>
    procedure Add(ExtensionID: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group")
    begin
        AssistedSetupImpl.Add(ExtensionID, PageID, AssistantName, GroupName, '', "Video Category"::Uncategorized, '', '');
    end;

    /// <summary>Adds an assisted setup record from a given extension so that it can be shown in the list.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <param name="AssistantName">The name as shown for the setup.</param>
    /// <param name="GroupName">The assisted setup group enum that this belongs to.</param>
    /// <param name="VideoLink">The URL of the video that explains the purpose and use of this setup.</param>
    /// <param name="HelpLink">The help url that explains the purpose and usage of this setup.</param>
    procedure Add(ExtensionID: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group"; VideoLink: Text[250]; HelpLink: Text[250])
    begin
        AssistedSetupImpl.Add(ExtensionID, PageID, AssistantName, GroupName, VideoLink, "Video Category"::Uncategorized, HelpLink, '');
    end;

    /// <summary>Adds an assisted setup record from a given extension so that it can be shown in the list.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <param name="AssistantName">The name as shown for the setup.</param>
    /// <param name="GroupName">The assisted setup group enum that this belongs to.</param>
    /// <param name="VideoLink">The URL of the video that explains the purpose and use of this setup.</param>
    /// <param name="VideoCategory">The category of the video for this setup.</param>
    /// <param name="HelpLink">The help url that explains the purpose and usage of this setup.</param>
    procedure Add(ExtensionID: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group"; VideoLink: Text[250]; VideoCategory: Enum "Video Category"; HelpLink: Text[250])
    begin
        AssistedSetupImpl.Add(ExtensionID, PageID, AssistantName, GroupName, VideoLink, VideoCategory, HelpLink, '');
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
    procedure Add(ExtensionID: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group"; VideoLink: Text[250]; VideoCategory: Enum "Video Category"; HelpLink: Text[250]; Description: Text[1024])
    begin
        AssistedSetupImpl.Add(ExtensionID, PageID, AssistantName, GroupName, VideoLink, VideoCategory, HelpLink, Description);
    end;

    /// <summary>Adds the translation for the name of the setup.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <param name="LanguageID">The language ID for which the translation is made.</param>
    /// <param name="TranslatedName">The translated text of the name.</param>
    [Obsolete('ExtensionID is not required. Please use the function with the same name without this parameter.', '16.0')]
    procedure AddTranslation(ExtensionID: Guid; PageID: Integer; LanguageID: Integer; TranslatedName: Text)
    begin
        AddTranslation(PageID, LanguageID, TranslatedName);
    end;

    /// <summary>Adds the translation for the name of the setup.</summary>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <param name="LanguageID">The language ID for which the translation is made.</param>
    /// <param name="TranslatedName">The translated text of the name.</param>
    procedure AddTranslation(PageID: Integer; LanguageID: Integer; TranslatedName: Text)
    begin
        AssistedSetupImpl.AddSetupAssistantTranslation(PageID, LanguageID, TranslatedName);
    end;

    /// <summary>Checks whether a user has already completed the setup.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <returns>Returns true if the given setup guide has been completed by the user, otherwise false.</returns> 
    [Obsolete('ExtensionID is not required. Please use the function with the same name without this parameter.', '16.0')]
    procedure IsComplete(ExtensionID: Guid; PageID: Integer): Boolean
    begin
        exit(IsComplete(PageID));
    end;

    /// <summary>Checks whether a user has already completed the setup.</summary>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <returns>Returns true if the given setup guide has been completed by the user, otherwise false.</returns> 
    procedure IsComplete(PageID: Integer): Boolean
    begin
        exit(AssistedSetupImpl.IsComplete(PageID));
    end;

    /// <summary>Checks whether an assisted setup guide exists.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <returns>True if an assisted setup guide for provided extension and page IDs exists; false otherwise.</returns>
    [Obsolete('ExtensionID is not required. Please use the function with the same name without this parameter.', '16.0')]
    procedure Exists(ExtensionID: Guid; PageID: Integer): Boolean
    begin
        exit(Exists(PageID));
    end;

    /// <summary>Checks whether an assisted setup guide exists.</summary>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <returns>True if an assisted setup guide for provided extension and page IDs exists; false otherwise.</returns>
    procedure Exists(PageID: Integer): Boolean
    begin
        exit(AssistedSetupImpl.Exists(PageID));
    end;

    /// <summary>Checks whether as assisted setup guide exists but has not been completed.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <returns>True if it exists and is incomplete, false otherwise.</returns>
    [Obsolete('ExtensionID is not required. Please use the function with the same name without this parameter.', '16.0')]
    procedure ExistsAndIsNotComplete(ExtensionID: Guid; PageID: Integer): Boolean
    begin
        exit(ExistsAndIsNotComplete(PageID));
    end;

    /// <summary>Checks whether as assisted setup guide exists but has not been completed.</summary>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <returns>True if it exists and is incomplete, false otherwise.</returns>
    procedure ExistsAndIsNotComplete(PageID: Integer): Boolean
    begin
        exit(AssistedSetupImpl.ExistsAndIsNotComplete(PageID));
    end;

    /// <summary>Sets the status of the assisted setup to Complete.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <remarks>This is typically called from inside the assisted setup guide when the setup is finished.</remarks>
    [Obsolete('ExtensionID is not required. Please use the function with the same name without this parameter.', '16.0')]
    procedure Complete(ExtensionID: Guid; PageID: Integer)
    begin
        Complete(PageID);
    end;

    /// <summary>Sets the status of the assisted setup to Complete.</summary>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <remarks>This is typically called from inside the assisted setup guide when the setup is finished.</remarks>
    procedure Complete(PageID: Integer)
    begin
        AssistedSetupImpl.Complete(PageID);
    end;

    /// <summary>Resets the status of the assisted setup guide so that it does not appear to have been completed.</summary>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    procedure Reset(PageID: Integer)
    begin
        AssistedSetupImpl.Reset(PageID);
    end;

    /// <summary>Issues the call to execute the setup.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    [Obsolete('ExtensionID is not required. Please use the function with the same name without this parameter.', '16.0')]
    procedure Run(ExtensionID: Guid; PageID: Integer)
    begin
        Run(PageID);
    end;

    /// <summary>Issues the call to start the setup.</summary>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <remarks>If the page does not exist the user can choose whether to delete the page record.</remarks>
    procedure Run(PageID: Integer)
    begin
        AssistedSetupImpl.Run(PageID);
    end;

    /// <summary>Opens the Assisted Setup page with the setup guides in it.</summary>
    procedure Open()
    begin
        AssistedSetupImpl.Open();
    end;

    /// <summary>Opens the Assisted Setup page with the setup guides filtered on a selected group of guides.</summary>
    /// <param name="AssistedSetupGroup">The group of guides to display on the Assisted Setup page.</param>
    procedure Open(AssistedSetupGroup: Enum "Assisted Setup Group")
    begin
        AssistedSetupImpl.Open(AssistedSetupGroup);
    end;

    /// <summary>Removes an Assisted Setup so it will no longer be shown in the list.</summary>
    /// <param name="PageID">The ID of the page to be removed.</param>
    /// <remarks>The OnRegister subscriber which adds this PageID needs to be removed first.</remarks>
    procedure Remove(PageID: Integer)
    begin
        AssistedSetupImpl.Remove(PageID);
    end;

    /// <summary>Notifies the user that the list of assisted setup guides is being gathered, and that new guides might be added.</summary>
    [IntegrationEvent(false, false)]
    internal procedure OnRegister()
    begin
    end;

    /// <summary>Notifies the user that a setup that was previously completed is being run again.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <param name="Handled">The flag which if set, would stop executing the run of the assisted setup guide.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnReRunOfCompletedSetup(ExtensionID: Guid; PageID: Integer; var Handled: Boolean)
    begin
    end;

    /// <summary>Notifies that the run of the assisted setup has finished.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterRun(ExtensionID: Guid; PageID: Integer)
    begin
    end;

    /// <summary>Notifies that the Open Role Based Setup Experience has been invoked.</summary>
    /// <param name="PageID">The Page ID of the page been invoked.</param>
    /// <param name="Handled">The flag which if set, would stop executing the OpenRoleBasedSetupExperience of the assisted setup guide.</param>  
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeOpenRoleBasedSetupExperience(var PageID: Integer; var Handled: Boolean)
    begin
    end;

    var
        AssistedSetupImpl: Codeunit "Assisted Setup Impl.";

}