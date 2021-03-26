// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132585 "Assisted Setup Test Library"
{
    Permissions = tabledata "Guided Experience Item" = rmd;

    /// <summary>Clears the assisted setup records.</summary>
    procedure DeleteAll()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
    begin
        GuidedExperienceItem.DeleteAll();
    end;

    /// <summary>Deletes the given assisted setup.</summary>
    /// <param name="PageID">The page ID that should be opened when the user clicks on the setup.</param>
    procedure Delete(PageID: Integer)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
    begin
        if GuidedExperienceItem.Get(PageID) then
            GuidedExperienceItem.Delete(true);
    end;

    /// <summary>Changes the status of an Assisted Setup to be incomplete.</summary>
    /// <param name="PageID">The page ID that should be opened when the user clicks on the setup.</param>
    procedure SetStatusToNotCompleted(PageID: Integer)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
    begin
        if not GuidedExperienceItem.Get(PageID) then
            exit;
        if not GuidedExperienceItem.Completed then
            exit;
        GuidedExperienceItem.Validate(Completed, false);
        GuidedExperienceItem.Modify(true);
    end;

    /// <summary>Changes the status of an Assisted Setup to Completed.</summary>
    /// <param name="PageID">The page ID that should be opened when the user clicks on the setup.</param>
    procedure SetStatusToCompleted(PageID: Integer)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
    begin
        if not GuidedExperienceItem.Get(PageID) then
            exit;
        if GuidedExperienceItem.Completed then
            exit;
        GuidedExperienceItem.Validate(Completed, true);
        GuidedExperienceItem.Modify(true);
    end;

    /// <summary> Calls the event that asks subscribers to register respective setups.</summary>
    procedure CallOnRegister()
    var
        GuidedExperienceItem: Codeunit "Guided Experience";
#if not CLEAN18
        AssistedSetup: Codeunit "Assisted Setup";
#endif
    begin
        GuidedExperienceItem.OnRegisterAssistedSetup();
#if not CLEAN18
        AssistedSetup.OnRegister();
#endif
    end;

    /// <summary>Has any assisted setup records.</summary>
    procedure HasAny(): Boolean
    var
        GuidedExperienceItem: Record "Guided Experience Item";
    begin
        exit(not GuidedExperienceItem.IsEmpty());
    end;

    /// <summary>Checks if a given setup record exists in the system.</summary>
    /// <param name="PageID">The page ID that should be opened when the user clicks on the setup.</param>
    procedure Exists(PageID: Integer): Boolean
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
    begin
        exit(GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, PageID));
    end;

    /// <summary>Gets the page id of the first setup record.</summary>
    procedure FirstPageID(): Integer
    var
        GuidedExperienceItem: Record "Guided Experience Item";
    begin
        GuidedExperienceItem.FindFirst();
        exit(GuidedExperienceItem."Object ID to Run");
    end;
}