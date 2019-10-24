// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>Manage setup wizards by allowing adding to the list and updating the status of each.</summary>
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
        AssistedSetupImpl.Add(ExtensionID, PageID, AssistantName, GroupName, '', "Video Category"::Uncategorized, '');
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
        AssistedSetupImpl.Add(ExtensionID, PageID, AssistantName, GroupName, VideoLink, "Video Category"::Uncategorized, HelpLink);
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
        AssistedSetupImpl.Add(ExtensionID, PageID, AssistantName, GroupName, VideoLink, VideoCategory, HelpLink);
    end;

    /// <summary>Adds the translation for the name of the setup.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <param name="LanguageID">The language ID for which the translation is made.</param>
    /// <param name="TranslatedName">The translated text of the name.</param>
    procedure AddTranslation(ExtensionID: Guid; PageID: Integer; LanguageID: Integer; TranslatedName: Text)
    begin
        AssistedSetupImpl.AddSetupAssistantTranslation(ExtensionID, PageID, LanguageID, TranslatedName);
    end;

    /// <summary>Checks whether a user has already completed the setup.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <returns>Returns true if the given setup guide has been completed by the user, otherwise false.</returns> 
    procedure IsComplete(ExtensionID: Guid; PageID: Integer): Boolean
    begin
        exit(AssistedSetupImpl.IsComplete(ExtensionID, PageID));
    end;

    /// <summary>Checks whether an assisted setup guide exists.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <returns>True if an assisted setup guide for provided extension and page IDs exists; false otherwise.</returns>
    procedure Exists(ExtensionID: Guid; PageID: Integer): Boolean
    begin
        exit(AssistedSetupImpl.Exists(ExtensionID, PageID));
    end;

    /// <summary>Checks whether as assisted setup guide exists but has not been completed.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <returns>True if it exists and is incomplete, false otherwise.</returns>
    procedure ExistsAndIsNotComplete(ExtensionID: Guid; PageID: Integer): Boolean
    begin
        exit(AssistedSetupImpl.ExistsAndIsNotComplete(ExtensionID, PageID));
    end;

    /// <summary>Sets the status of the assisted setup to Complete.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    /// <remarks>This is typically called from inside the assisted setup guide when the setup is finished.</remarks>
    procedure Complete(ExtensionID: Guid; PageID: Integer)
    begin
        AssistedSetupImpl.Complete(ExtensionID, PageID);
    end;

    /// <summary>Sets the status of the assisted setup to incomplete.</summary>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    procedure Reset(PageID: Integer)
    begin
        AssistedSetupImpl.Reset(PageID);
    end;

    /// <summary>Issues the call to execute the setup.</summary>
    /// <param name="ExtensionID">The app ID of the extension to which the setup belongs.</param>
    /// <param name="PageID">The ID of the page to open when the user clicks the setup.</param>
    procedure Run(ExtensionID: Guid; PageID: Integer)
    begin
        AssistedSetupImpl.Run(ExtensionID, PageID);
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

    var
        AssistedSetupImpl: Codeunit "Assisted Setup Impl.";

}