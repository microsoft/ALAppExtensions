codeunit 1875 "Manual Setup"
{
    /// <summary>
    /// The manual setup aggregates all cases where the functionality is setup manually. Typically this is accomplished 
    /// by registering the setup page ID of the extension that contains the functionality.
    /// </summary>

    Access = Public;

    var
        TempManualSetup: Record "Manual Setup" temporary;
        ManualSetupImpl: Codeunit "Manual Setup Impl.";

    /// <summary>Insert a manual setup page requiring a shared icon.</summary>
    /// <param name="Name">The name of the setup.</param>
    /// <param name="Description">The description of the setup.</param>
    /// <param name="Keywords">The keywords related to the setup.</param>
    /// <param name="RunPage">The page id of the setup page to be run.</param>
    /// <param name="IconName">The icon file name of the setup that is part of the shared media repository.</param>
    [Scope('OnPrem')]
    procedure InsertWithIconSharedInMedia(Name: Text[50]; Description: Text[250]; Keywords: Text[250]; RunPage: Integer; IconName: Text[50])
    begin
        ManualSetupImpl.Insert(TempManualSetup, Name, Description, Keywords, RunPage, IconName);
    end;

    /// <summary>Insert a manual setup page./summary>
    /// <param name="Name">The name of the setup.</param>
    /// <param name="Description">The description of the setup.</param>
    /// <param name="Keywords">The keywords related to the setup.</param>
    /// <param name="RunPage">The page id of the setup page to be run<./param>
    /// <param name="ExtensionID">The ID of the extension that the caller is in. This is used to fetch the icon for
    /// the setup.</param>
    procedure Insert(Name: Text[50]; Description: Text[250]; Keywords: Text[250]; RunPage: Integer; ExtensionID: GUID)
    begin
        ManualSetupImpl.InsertExtension(TempManualSetup, Name, Description, Keywords, RunPage, ExtensionID);
    end;

    /// <summary>Clears all icons to be used for manual setups.</summary>
    /// <remarks>This is called when initializing the icons and typically followed by calls to add icons.</remarks>
    procedure ClearAllIcons()
    begin
        ManualSetupImpl.ClearAllIcons();
    end;

    /// <summary>Add an icon to be used for one or more manual setups.</summary>
    /// <param name="Name">The name of the icon.</param>
    /// <param name="MediaRef">The media reference for the icon.</param>
    procedure AddIcon(Name: Text[50]; MediaRef: Code[50])
    begin
        ManualSetupImpl.AddIcon(Name, MediaRef);
    end;

    /// <summary>Copies the internally used temporary record to a passed variable.</summary>
    /// <param name="TemporaryManualSetup">The temporary variable to copy the record to.</param>
    [Scope('OnPrem')]
    procedure GetTemporaryRecord(var TemporaryManualSetup: Record "Manual Setup" temporary);
    begin
        TemporaryManualSetup.Copy(TempManualSetup, true);
    end;

    /// <summary>The event that is raised so that subscribers can add the new manual setups that can be displayed in the
    /// Manual Setup page.</summary>
    /// <remarks>The subscriber should call the methods Insert or InsertWithIconSharedInMedia on the Sender object.</remarks>
    [IntegrationEvent(true, false)]
    procedure OnRegisterManualSetup();
    begin
    end;

}