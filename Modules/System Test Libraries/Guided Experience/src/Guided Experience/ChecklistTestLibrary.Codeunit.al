// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 132608 "Checklist Test Library"
{
    Permissions = tabledata "Checklist Item" = rmd;

    /// <summary>
    /// Deletes all the checklist items in the database.
    /// </summary>
    procedure DeleteAll()
    var
        ChecklistItem: Record "Checklist Item";
    begin
        ChecklistItem.DeleteAll();
    end;

    /// <summary>
    /// Gets the count of entries in the checklist item table.
    /// </summary>
    /// <returns>The count of entries in the checklist item table.</returns>
    procedure GetCount(): Integer
    var
        ChecklistItem: Record "Checklist Item";
    begin
        exit(ChecklistItem.Count);
    end;

    /// <summary>
    /// Checks whether a checklist item exists for the given parameters.
    /// </summary>
    /// <param name="GuidedExperienceType">The type of the guided experience item associated with the checklist item.</param>
    /// <param name="ObjectType">The object type of the guided experience item associated with the checklist item.</param>
    /// <param name="ObjectId">The object ID of the guided experience item associated with the checklist item.</param>
    /// <param name="ForRole">The profile ID that the checklist item is associated with.</param>
    /// <returns>True if the checklist item exists and false otherwise.</returns>
    procedure ChecklistItemExists(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectId: Integer; ForRole: Code[30]): Boolean
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        SpotlightTourType: Enum "Spotlight Tour Type";
    begin
        GuidedExperienceImpl.FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType, ObjectType, ObjectId, '', '', SpotlightTourType::None);

        if ChecklistItemExists(GuidedExperienceItem) then
            exit(ChecklistItemRoleExists(GuidedExperienceItem.Code, ForRole));
    end;

    /// <summary>
    /// Checks whether a checklist item exists for the given parameters.
    /// </summary>
    /// <param name="GuidedExperienceType">The type of the guided experience item associated with the checklist item.</param>
    /// <param name="Link">The link of the guided experience item associated with the checklist item.</param>
    /// <param name="ForRole">The profile ID that the checklist item is associated with.</param>
    /// <returns>True if the checklist item exists and false otherwise.</returns>
    procedure ChecklistItemExists(GuidedExperienceType: Enum "Guided Experience Type"; Link: Text[250]; ForRole: Code[30]): Boolean
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        SpotlightTourType: Enum "Spotlight Tour Type";
    begin
        GuidedExperienceImpl.FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType, ObjectType::MenuSuite, 0, Link, '', SpotlightTourType::None);

        if ChecklistItemExists(GuidedExperienceItem) then
            exit(ChecklistItemRoleExists(GuidedExperienceItem.Code, ForRole));
    end;

    local procedure ChecklistItemExists(var GuidedExperienceItem: Record "Guided Experience Item"): Boolean
    var
        ChecklistItem: Record "Checklist Item";
    begin
        if GuidedExperienceItem.FindFirst() then
            exit(ChecklistItem.Get(GuidedExperienceItem.Code));

        exit(false);
    end;

    local procedure ChecklistItemRoleExists(Code: Code[300]; ProfileId: Code[30]): Boolean
    var
        ChecklistItemRole: Record "Checklist Item Role";
    begin
        exit(ChecklistItemRole.Get(Code, ProfileId));
    end;
}