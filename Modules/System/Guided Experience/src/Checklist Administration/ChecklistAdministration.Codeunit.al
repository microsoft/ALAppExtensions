// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1995 "Checklist Administration"
{
    Access = Internal;
    Permissions = tabledata AllObjWithCaption = r,
                  tabledata "Guided Experience Item" = r,
                  tabledata "Checklist Item" = r,
                  tabledata "Checklist Item Buffer" = rm,
                  tabledata "Checklist Item Role" = rd,
                  tabledata "Checklist Item User" = rm;

    var
        ObjectCaptionLbl: Label '%1 %2', Locked = true;
        ChecklistExistsLbl: Label 'A checklist item already exists for the guided experience item that you selected. Do you want to open and edit the existing checklist item?';
        StatusResetLbl: Label 'Do you want to reset the status for users who have already completed this checklist item?';
        RolesWillBeDeletedLbl: Label 'If you change the completion requirements to "Specific users", then any roles that are assigned to complete this checklist item will be deleted. Are you sure that you want to continue?';
        UsersWillBeDeassignedLbl: Label 'If you change the completion requirements now, then any users that are assigned to complete this checklist item will be deleted. Are you sure that you want to continue?';

    procedure LookupGuidedExperienceItem(var ChecklistItemBuffer: Record "Checklist Item Buffer"; GuidedExperienceType: Enum "Guided Experience Type")
    var
        TempGuidedExperienceItem: Record "Guided Experience Item" temporary;
        ChecklistItem: Record "Checklist Item";
        ChecklistImplementation: Codeunit "Checklist Implementation";
        LookupOK: Boolean;
        HasChecklistItemBufferBeenModified: Boolean;
        ShouldPopulateFields: Boolean;
        ShouldCreateDefaultChecklistItem: Boolean;
    begin
        LookupOK := LookupGuidedExperienceItem(TempGuidedExperienceItem, GuidedExperienceType);

        HasChecklistItemBufferBeenModified := HasChecklistItemBufferChanged(ChecklistItemBuffer);

        if LookupOK then
            if not ChecklistItem.Get(TempGuidedExperienceItem.Code) then begin
                if not HasChecklistItemBufferBeenModified then begin
                    ShouldPopulateFields := true;
                    ShouldCreateDefaultChecklistItem := true;
                end else begin
                    ChecklistImplementation.UpdateCode(ChecklistItemBuffer.Code, TempGuidedExperienceItem.Code);
                    ChecklistItemBuffer.Code := TempGuidedExperienceItem.Code;
                    PopulateGuidedExperienceFields(TempGuidedExperienceItem, ChecklistItemBuffer);

                    UpdateStatusForUsers(ChecklistItemBuffer.Code);
                end;
            end
            else
                if Confirm(ChecklistExistsLbl) then
                    ShouldPopulateFields := true;

        if ShouldPopulateFields then
            PopulateFields(TempGuidedExperienceItem, ChecklistItem, ChecklistItemBuffer);

        if ShouldCreateDefaultChecklistItem then
            ChecklistImplementation.InsertChecklistItem(TempGuidedExperienceItem.Code, ChecklistItem."Completion Requirements"::Anyone, 1);
    end;

    procedure GetObjectCaption(ObjectTypeToRun: Enum "Guided Experience Object Type"; ObjectID: Integer): Text[50]
    var
        AllObjWithCaption: Record AllObjWithCaption;
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        ObjectType: ObjectType;
    begin
        ObjectType := GuidedExperienceImpl.GetObjectType(ObjectTypeToRun);

        if AllObjWithCaption.Get(ObjectType, ObjectID) then
            exit(StrSubstNo(ObjectCaptionLbl, ObjectTypeToRun, AllObjWithCaption."Object Caption"));
    end;

    procedure ConfirmCompletionRequirementsChange(Code: Code[300]; var NewCompletionRequirements: Enum "Checklist Completion Requirements"): Boolean
    var
        ChecklistItem: Record "Checklist Item";
        OldCompletionRequirements: Enum "Checklist Completion Requirements";
    begin
        if not ChecklistItem.Get(Code) then
            exit;

        OldCompletionRequirements := ChecklistItem."Completion Requirements";

        if OldCompletionRequirements = NewCompletionRequirements then
            exit(false);

        if ((OldCompletionRequirements in [OldCompletionRequirements::Anyone, OldCompletionRequirements::Everyone])
            and (NewCompletionRequirements in [NewCompletionRequirements::Anyone, NewCompletionRequirements::Everyone]))
        then
            exit(true);

        if OldCompletionRequirements in [OldCompletionRequirements::Anyone, OldCompletionRequirements::Everyone] then
            if ConfirmDeleteChecklistItemRoles(Code) then
                exit(true);

        if OldCompletionRequirements = OldCompletionRequirements::"Specific users" then
            if ConfirmDeassignChecklistItemUsers(Code) then
                exit(true);

        NewCompletionRequirements := OldCompletionRequirements;
        exit(false);
    end;

    local procedure LookupGuidedExperienceItem(var GuidedExperienceItemTemp: Record "Guided Experience Item" temporary; GuidedExperienceType: Enum "Guided Experience Type"): Boolean
    var
        GuidedExperienceItemListLookup: Page "Guided Experience Item List";
    begin
        GuidedExperienceItemListLookup.SetGuidedExperienceType(GuidedExperienceType);
        GuidedExperienceItemListLookup.LookupMode := true;

        if GuidedExperienceItemListLookup.RunModal() = Action::LookupOK then begin
            GuidedExperienceItemListLookup.GetRecord(GuidedExperienceItemTemp);
            exit(true);
        end;
    end;

    local procedure HasChecklistItemBufferChanged(var ChecklistItemBuffer: Record "Checklist Item Buffer"): Boolean
    var
        ChecklistItemRole: Record "Checklist Item Role";
        ChecklistItemUser: Record "Checklist Item User";
    begin
        if (ChecklistItemBuffer."Completion Requirements" <> ChecklistItemBuffer."Completion Requirements"::Anyone)
            or (ChecklistItemBuffer."Order ID" <> 1)
        then
            exit(true);

        ChecklistItemRole.SetRange(Code, ChecklistItemBuffer.Code);
        if not ChecklistItemRole.IsEmpty() then
            exit(true);

        ChecklistItemUser.SetRange(Code, ChecklistItemBuffer.Code);
        if not ChecklistItemUser.IsEmpty() then
            exit(true);

        exit(false);
    end;

    local procedure PopulateFields(GuidedExperienceItem: Record "Guided Experience Item"; ChecklistItem: Record "Checklist Item"; var ChecklistItemBuffer: Record "Checklist Item Buffer")
    begin
        PopulateGuidedExperienceFields(GuidedExperienceItem, ChecklistItemBuffer);

        if ChecklistItem.Code = GuidedExperienceItem.Code then begin
            ChecklistItemBuffer."Completion Requirements" := ChecklistItem."Completion Requirements";
            ChecklistItemBuffer."Order ID" := ChecklistItem."Order ID";
        end;
    end;

    local procedure PopulateGuidedExperienceFields(GuidedExperienceItem: Record "Guided Experience Item"; var ChecklistItemBuffer: Record "Checklist Item Buffer")
    begin
        ChecklistItemBuffer.Code := GuidedExperienceItem.Code;
        ChecklistItemBuffer.Title := GuidedExperienceItem.Title;
        ChecklistItemBuffer.Description := GuidedExperienceItem.Description;
        ChecklistItemBuffer."Expected Duration" := GuidedExperienceItem."Expected Duration";
        ChecklistItemBuffer."Object Type to Run" := GuidedExperienceItem."Object Type to Run";
        ChecklistItemBuffer."Object ID to Run" := GuidedExperienceItem."Object ID to Run";
        ChecklistItemBuffer.Link := GuidedExperienceItem.Link;
        ChecklistItemBuffer."Spotlight Tour Type" := GuidedExperienceItem."Spotlight Tour Type";
        ChecklistItemBuffer."Video Url" := GuidedExperienceItem."Video Url";
    end;

    local procedure UpdateStatusForUsers(Code: Code[300])
    var
        ChecklistItemUser: Record "Checklist Item User";
    begin
        ChecklistItemUser.SetRange(Code, Code);
        ChecklistItemUser.SetFilter("Checklist Item Status", '<>%1', ChecklistItemUser."Checklist Item Status"::"Not Started");

        if ChecklistItemUser.FindSet() then
            if Confirm(StatusResetLbl) then
                ChecklistItemUser.ModifyAll("Checklist Item Status", ChecklistItemUser."Checklist Item Status"::"Not Started");
    end;

    local procedure ConfirmDeleteChecklistItemRoles(Code: Code[300]): Boolean
    var
        ChecklistItemRole: Record "Checklist Item Role";
    begin
        ChecklistItemRole.SetRange(Code, Code);
        if ChecklistItemRole.IsEmpty() then
            exit(true);

        if Confirm(RolesWillBeDeletedLbl) then begin
            ChecklistItemRole.DeleteAll();
            exit(true);
        end;

        exit(false);
    end;

    local procedure ConfirmDeassignChecklistItemUsers(Code: Code[300]): Boolean
    var
        ChecklistItemUser: Record "Checklist Item User";
    begin
        ChecklistItemUser.SetRange(Code, Code);
        ChecklistItemUser.SetRange("Assigned to User", true);

        if ChecklistItemUser.IsEmpty() then
            exit(true);

        if Confirm(UsersWillBeDeassignedLbl) then begin
            ChecklistItemUser.ModifyAll("Assigned to User", false);
            exit(true);
        end;

        exit(false);
    end;
}