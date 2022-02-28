// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1999 "Guided Experience Upgrade"
{
    Subtype = Upgrade;
    Permissions = tabledata "Guided Experience Item" = rimd,
                    tabledata "Checklist Item" = rimd,
                    tabledata "Checklist Item Role" = rimd,
                    tabledata "Checklist Item User" = rimd;

    var
        CodeFormatLbl: Label '%1_%2', Locked = true;

    trigger OnUpgradePerCompany()
    begin
        InsertSpotlightTour();

        UpdateTranslations();
    end;

    local procedure InsertSpotlightTour()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        GuidedExperienceUpgradeTag: Codeunit "Guided Experience Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GuidedExperienceUpgradeTag.GetGuidedExperienceItemAddSpotlightTourTypeTag(), '') then
            exit;

        if UpgradeTag.HasUpgradeTag(GuidedExperienceUpgradeTag.GetGuidedExperienceItemAddSpotlightTourTypeTag()) then
            exit;

        InsertSpotlightTourInGuidedExperienceItem();

        UpgradeTag.SetUpgradeTag(GuidedExperienceUpgradeTag.GetGuidedExperienceItemAddSpotlightTourTypeTag());
    end;

    local procedure InsertSpotlightTourInGuidedExperienceItem()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        NewGuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        NewCode: Code[300];
    begin
        GuidedExperienceItem.SetRange(SystemCreatedAt, 0DT, CurrentDateTime());
        if GuidedExperienceItem.FindSet() then
            repeat
                NewCode := GetCodeThatAccountsForSpotlightTourType(GuidedExperienceItem.Code);

                InsertRecordCopyWithModifiedCode(GuidedExperienceItem,
                    GuidedExperienceItem.FieldNo(Code), NewCode);

                if NewGuidedExperienceItem.Get(NewCode, GuidedExperienceItem.Version) then
                    GuidedExperienceImpl.InsertTranslations(NewGuidedExperienceItem,
                        GuidedExperienceItem.Title, GuidedExperienceItem."Short Title",
                        GuidedExperienceItem.Description, GuidedExperienceItem.Keywords);

                UpdateChecklistItems(GuidedExperienceItem.Code, NewCode);
            until GuidedExperienceItem.Next() = 0;

        GuidedExperienceItem.DeleteAll();
    end;

    local procedure UpdateChecklistItems(OldCode: Code[300]; NewCode: Code[300])
    var
        ChecklistItem: Record "Checklist Item";
    begin
        if ChecklistItem.Get(OldCode) then begin
            InsertRecordCopyWithModifiedCode(ChecklistItem, ChecklistItem.FieldNo(Code), NewCode);

            UpdateChecklistItemRoles(ChecklistItem.Code, NewCode);
            UpdateChecklistItemUsers(ChecklistItem.Code, NewCode);

            ChecklistItem.Delete();
        end;
    end;

    local procedure UpdateChecklistItemRoles(OldCode: Code[300]; NewCode: Code[300])
    var
        ChecklistItemRole: Record "Checklist Item Role";
    begin
        ChecklistItemRole.SetRange(Code, OldCode);
        if ChecklistItemRole.FindSet() then
            repeat
                InsertRecordCopyWithModifiedCode(ChecklistItemRole,
                    ChecklistItemRole.FieldNo(Code), NewCode);
            until ChecklistItemRole.Next() = 0;

        ChecklistItemRole.DeleteAll();
    end;

    local procedure UpdateChecklistItemUsers(OldCode: Code[300]; NewCode: Code[300])
    var
        ChecklistItemUser: Record "Checklist Item User";
    begin
        ChecklistItemUser.SetRange(Code, OldCode);
        if ChecklistItemUser.FindSet() then
            repeat
                InsertRecordCopyWithModifiedCode(ChecklistItemUser,
                    ChecklistItemUser.FieldNo(Code), NewCode);
            until ChecklistItemUser.Next() = 0;

        ChecklistItemUser.DeleteAll();
    end;

    local procedure InsertRecordCopyWithModifiedCode(RecVariant: Variant; FieldNo: Integer; Code: Code[300])
    var
        RecordRef: RecordRef;
        RecordRef2: RecordRef;
    begin
        RecordRef.GetTable(RecVariant);

        RecordRef2.Open(RecordRef.Number);

        RecordRef2.Copy(RecordRef);
        RecordRef2.Field(FieldNo).Value(Code);
        if RecordRef2.Insert() then;
    end;

    local procedure GetCodeThatAccountsForSpotlightTourType(Code: Code[300]): Code[300]
    var
        SpotlightTourType: Enum "Spotlight Tour Type";
    begin
        exit(StrSubstNo(CodeFormatLbl, Code, SpotlightTourType::None.AsInteger()));
    end;

    local procedure UpdateTranslations()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        GuidedExperienceUpgradeTag: Codeunit "Guided Experience Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GuidedExperienceUpgradeTag.GetGuidedExperienceTranslationUpdateTag(), '') then
            exit;

        if UpgradeTag.HasUpgradeTag(GuidedExperienceUpgradeTag.GetGuidedExperienceTranslationUpdateTag()) then
            exit;

        DeleteTranslationsForGuidedExperienceItemsAndSpotlightTours();

        UpgradeTag.SetUpgradeTag(GuidedExperienceUpgradeTag.GetGuidedExperienceTranslationUpdateTag());
    end;

    local procedure DeleteTranslationsForGuidedExperienceItemsAndSpotlightTours()
    var
        Translation: Codeunit Translation;
    begin
        Translation.Delete(Database::"Guided Experience Item");
        Translation.Delete(Database::"Spotlight Tour Text");
    end;
}