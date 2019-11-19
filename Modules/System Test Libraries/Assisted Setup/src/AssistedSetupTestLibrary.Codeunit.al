// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132585 "Assisted Setup Test Library"
{
    /// <summary>Clears the assisted setup records.</summary>
    procedure DeleteAll()
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        AssistedSetup.DeleteAll();
    end;

    /// <summary>Deletes the given assisted setup.</summary>
    /// <param name="PageID">The page ID that should be opened when the user clicks on the setup.</param>
    procedure Delete(PageID: Integer)
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        if AssistedSetup.Get(PageID) then
            AssistedSetup.Delete(true);
    end;

    /// <summary>Changes the status of an Assisted Setup to be incomplete.</summary>
    /// <param name="PageID">The page ID that should be opened when the user clicks on the setup.</param>
    procedure SetStatusToNotCompleted(PageID: Integer)
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        if not AssistedSetup.Get(PageID) then
            exit;
        if not AssistedSetup.Completed then
            exit;
        AssistedSetup.Validate(Completed, false);
        AssistedSetup.Modify(true);
    end;

    /// <summary>Changes the status of an Assisted Setup to Completed.</summary>
    /// <param name="PageID">The page ID that should be opened when the user clicks on the setup.</param>
    procedure SetStatusToCompleted(PageID: Integer)
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        if not AssistedSetup.Get(PageID) then
            exit;
        if AssistedSetup.Completed then
            exit;
        AssistedSetup.Validate(Completed, true);
        AssistedSetup.Modify(true);
    end;

    /// <summary> Calls the event that asks subscribers to register respective setups.</summary>
    procedure CallOnRegister()
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        AssistedSetup.OnRegister();
    end;

    /// <summary>Has any assisted setup records.</summary>
    procedure HasAny(): Boolean
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        exit(not AssistedSetup.IsEmpty());
    end;

    /// <summary>Checks if a given setup record exists in the system.</summary>
    /// <param name="PageID">The page ID that should be opened when the user clicks on the setup.</param>
    procedure Exists(PageID: Integer): Boolean
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        exit(AssistedSetup.Get(PageID));
    end;

    /// <summary>Gets the page id of the first setup record.</summary>
    procedure FirstPageID(): Integer
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        AssistedSetup.FindFirst();
        exit(AssistedSetup."Page ID");
    end;
}