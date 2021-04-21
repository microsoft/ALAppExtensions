// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Manage the checklist presented to users by inserting and deleting checklist items and controling the visibility of the checklist.
/// </summary>
codeunit 1992 "Checklist"
{
    Access = Public;

    var
        ChecklistImplementation: Codeunit "Checklist Implementation";

    /// <summary>
    /// Inserts a new checklist item. 
    /// </summary>
    /// <param name="GuidedExperienceType">The type of guided experience item that the checklist item references.</param>
    /// <param name="ObjectTypeToRun">The object type run by the guided experience item that the checklist item references.</param>
    /// <param name="ObjectIDToRun">The object ID run by the guided experience item that the checklist item references.</param>
    /// <param name="OrderID">The index at which this checklist item should appear in the list. Please be aware that if other extensions also insert checklist items, then this ID might not match the index in the list.</param>
    /// <param name="TempAllProfile">The roles that this checklist item should be displayed for.</param>
    /// <param name="ShouldEveryoneComplete">Boolean value that controls whether everyone should complete this checklist item. If false, the checklist item will be marked as completed for everyone, even if only one person completes it.</param>
    procedure Insert(GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; OrderID: Integer; var TempAllProfile: Record "All Profile" temporary; ShouldEveryoneComplete: Boolean)
    var
        TempUser: Record User temporary;
    begin
        ChecklistImplementation.Insert(GuidedExperienceType, ObjectTypeToRun, ObjectIDToRun, '', ShouldEveryoneComplete, OrderID, TempAllProfile, TempUser);
    end;

    /// <summary>
    /// Inserts a new checklist item.
    /// </summary>
    /// <param name="GuidedExperienceType">The type of guided experience item that the checklist item references.</param>
    /// <param name="ObjectTypeToRun">The object type run by the guided experience item that the checklist item references.</param>
    /// <param name="ObjectIDToRun">The object ID run by the guided experience item that the checklist item references.</param>
    /// <param name="OrderID">The index at which this checklist item should appear in the list. Please be aware that if other extensions also insert checklist items, then this ID might not match the index in the list.</param>
    /// <param name="TempUser">The users that this checklist item should be displayed for.</param>
    procedure Insert(GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; OrderID: Integer; var TempUser: Record User temporary)
    var
        TempAllProfile: Record "All Profile" temporary;
        CompletionRequirements: Enum "Checklist Completion Requirements";
    begin
        ChecklistImplementation.Insert(GuidedExperienceType, ObjectTypeToRun, ObjectIDToRun, '', CompletionRequirements::"Specific users", OrderID, TempAllProfile, TempUser);
    end;

    /// <summary>
    /// Inserts a new checklist item.
    /// </summary>
    /// <param name="GuidedExperienceType">The type of guided experience item that the checklist item references.</param>
    /// <param name="Link">The URL that is open by the guided experience item that the checklist item references.</param>
    /// <param name="OrderID">The index at which this checklist item should appear in the list. Please be aware that if other extensions also insert checklist items, then this ID might not match the index in the list.</param>
    /// <param name="TempAllProfile">The roles that this checklist item should be displayed for.</param>
    /// <param name="ShouldEveryoneComplete">Boolean value that controls whether everyone should complete this checklist item. If false, the checklist item will be marked as completed for everyone, even if only one person completes it.</param>
    procedure Insert(GuidedExperienceType: Enum "Guided Experience Type"; Link: Text[250]; OrderID: Integer; var TempAllProfile: Record "All Profile" temporary; ShouldEveryoneComplete: Boolean)
    var
        TempUser: Record User temporary;
    begin
        ChecklistImplementation.Insert(GuidedExperienceType, ObjectType::MenuSuite, 0, Link, ShouldEveryoneComplete, OrderID, TempAllProfile, TempUser);
    end;

    /// <summary>
    /// Inserts a new checklist item.
    /// </summary>
    /// <param name="GuidedExperienceType">The type of guided experience item that the checklist item references.</param>
    /// <param name="Link">The URL that is open by the guided experience item that the checklist item references.</param>
    /// <param name="OrderID">The index at which this checklist item should appear in the list. Please be aware that if other extensions also insert checklist items, then this ID might not match the index in the list.</param>
    /// <param name="TempUser">The users that this checklist item should be displayed for.</param>
    procedure Insert(GuidedExperienceType: Enum "Guided Experience Type"; Link: Text[250]; OrderID: Integer; var TempUser: Record User temporary)
    var
        TempAllProfile: Record "All Profile" temporary;
        CompletionRequirements: Enum "Checklist Completion Requirements";
    begin
        ChecklistImplementation.Insert(GuidedExperienceType, ObjectType::MenuSuite, 0, Link, CompletionRequirements::"Specific users", OrderID, TempAllProfile, TempUser);
    end;

    /// <summary>
    /// Deletes a checklist item.
    /// </summary>
    /// <param name="GuidedExperienceType">The type of guided experience item that the checklist item references.</param>
    /// <param name="ObjectTypeToRun">The object type run by the guided experience item that the checklist item references.</param>
    /// <param name="ObjectIDToRun">The object ID run by the guided experience item that the checklist item references.</param>
    procedure Delete(GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: ObjectType; ObjectID: Integer)
    begin
        ChecklistImplementation.Delete(GuidedExperienceType, ObjectTypeToRun, ObjectID, '');
    end;

    /// <summary>
    /// Deletes a checklist item.
    /// </summary>
    /// <param name="GuidedExperienceType">The type of guided experience item that the checklist item references.</param>
    /// <param name="Link">The URL that is open by the guided experience item that the checklist item references.</param>
    procedure Delete(GuidedExperienceType: Enum "Guided Experience Type"; Link: Text[250])
    begin
        ChecklistImplementation.Delete(GuidedExperienceType, ObjectType::MenuSuite, 0, Link);
    end;

    /// <summary>
    /// Checks whether the checklist should be initialized
    /// </summary>
    /// <returns>True if the checklist should be initialized and false otherwise.</returns>
    procedure ShouldInitializeChecklist(): Boolean
    begin
        exit(ChecklistImplementation.ShouldInitializeChecklist());
    end;

    /// <summary>
    /// Marks the checklist setup as done.
    /// </summary>
    procedure MarkChecklistSetupAsDone()
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);

        ChecklistImplementation.MarkChecklistSetupAsDone(CallerModuleInfo);
    end;

    /// <summary>
    /// Initializes the guided experience items.
    /// </summary>
    procedure InitializeGuidedExperienceItems()
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);

        ChecklistImplementation.InitializeGuidedExperienceItems(CallerModuleInfo);
    end;

    /// <summary>
    /// Updates the user name for checklist records that have it as a primary key.
    /// </summary>
    /// <param name="RecRef">The recordref that poins to the record that is to be modified.</param>
    /// <param name="Company">The company in which the table is to be modified.</param>
    /// <param name="UserName">The new user name.</param>
    /// <param name="TableID">The table for which the user name is to be modified.</param>
    procedure UpdateUserName(var RecRef: RecordRef; Company: Text[30]; UserName: Text[50]; TableID: Integer)
    begin
        ChecklistImplementation.UpdateUserName(RecRef, Company, UserName, TableID);
    end;
}