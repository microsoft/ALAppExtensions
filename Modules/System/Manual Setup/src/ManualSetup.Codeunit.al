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

    var
        TempManualSetup: Record "Manual Setup" temporary;
        ManualSetupImpl: Codeunit "Manual Setup Impl.";

    /// <summary>Insert a manual setup page for an extension./summary>
    /// <param name="Name">The name of the setup.</param>
    /// <param name="Description">The description of the setup.</param>
    /// <param name="Keywords">The keywords related to the setup.</param>
    /// <param name="RunPage">The page ID of the setup page to be run<./param>
    /// <param name="ExtensionId">The ID of the extension that the caller is in. This is used to fetch the icon for the setup.</param>
    /// <param name="Category">The category that this manual setup belongs to.</param>
    procedure Insert(Name: Text[50]; Description: Text[250]; Keywords: Text[250]; RunPage: Integer; ExtensionId: GUID; Category: Enum "Manual Setup Category")
    begin
        ManualSetupImpl.Insert(TempManualSetup, Name, Description, Keywords, RunPage, ExtensionId, Category);
    end;

    /// <summary>
    /// Copies the internally used temporary record to a passed variable.
    /// </summary>
    /// <param name="TemporaryManualSetup">The temporary variable to copy the record to.</param>
    [Scope('OnPrem')]
    procedure GetTemporaryRecord(var TemporaryManualSetup: Record "Manual Setup" temporary);
    begin
        TemporaryManualSetup.Copy(TempManualSetup, true);
    end;

    /// <summary>
    /// The event that is raised so that subscribers can add the new manual setups that can be displayed in the Manual Setup page.
    /// </summary>
    /// <remarks>
    /// The subscriber should call the methods <see cref="Insert"/> or <see cref="InsertForExtension"/> on the Sender object.
    /// </remarks>
    [IntegrationEvent(true, false)]
    internal procedure OnRegisterManualSetup();
    begin
    end;

}