// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1807 "Assisted Setup Upgrade"
{
    Subtype = Upgrade;
    Permissions = tabledata "Guided Experience Item" = r;

    trigger OnUpgradePerCompany()
    begin
        DeleteAssistedSetup();
        UpgradeToGuidedExperienceItem();
    end;

    procedure DeleteAssistedSetup()
    var
        AssistedSetup: Record "Assisted Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        AssistedSetupUpgradeTag: Codeunit "Assisted Setup Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(AssistedSetupUpgradeTag.GetDeleteAssistedSetupTag(), '') then
            exit;

        if UpgradeTag.HasUpgradeTag(AssistedSetupUpgradeTag.GetDeleteAssistedSetupTag()) then
            exit;

        AssistedSetup.DeleteAll();

        UpgradeTag.SetUpgradeTag(AssistedSetupUpgradeTag.GetDeleteAssistedSetupTag());
    end;

    procedure UpgradeToGuidedExperienceItem()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        AssistedSetup: Record "Assisted Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        AssistedSetupUpgradeTag: Codeunit "Assisted Setup Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(AssistedSetupUpgradeTag.GetAssistedSetupToGuidedExperienceItemUpgradeTag(), '') then
            exit;

        if UpgradeTag.HasUpgradeTag(AssistedSetupUpgradeTag.GetAssistedSetupToGuidedExperienceItemUpgradeTag()) then
            exit;

        if AssistedSetup.FindSet() then
            repeat
                InsertAndGetGuidedExperienceItem(GuidedExperienceItem, AssistedSetup);
                InsertTranslations(GuidedExperienceItem, AssistedSetup);
            until AssistedSetup.Next() = 0;

        UpgradeTag.SetUpgradeTag(AssistedSetupUpgradeTag.GetAssistedSetupToGuidedExperienceItemUpgradeTag());
    end;

    local procedure InsertAndGetGuidedExperienceItem(var GuidedExperienceItem: Record "Guided Experience Item"; AssistedSetup: Record "Assisted Setup")
    var
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        GuidedExperienceType: Enum "Guided Experience Type";
        ManualSetupCategory: Enum "Manual Setup Category";
        SpotlightTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
    begin
        GuidedExperienceImpl.Insert(AssistedSetup.Name, CopyStr(AssistedSetup.Name, 1, 50), AssistedSetup.Description,
            0, AssistedSetup."App ID", GuidedExperienceType::"Assisted Setup", ObjectType::Page, AssistedSetup."Page ID",
            '', AssistedSetup."Group Name", AssistedSetup."Video Url", AssistedSetup."Video Category",
            AssistedSetup."Help Url", ManualSetupCategory::Uncategorized, '', SpotlightTourType::None, SpotlightTourTexts, false);

        GuidedExperienceItem.SetRange("Guided Experience Type", GuidedExperienceItem."Guided Experience Type"::"Assisted Setup");
        GuidedExperienceItem.SetRange("Object Type to Run", GuidedExperienceItem."Object Type to Run"::Page);
        GuidedExperienceItem.SetRange("Object ID to Run", AssistedSetup."Page ID");
        GuidedExperienceItem.SetRange(Link, '');
        if GuidedExperienceItem.FindLast() then;
    end;

    local procedure InsertTranslations(GuidedExperienceItem: Record "Guided Experience Item"; AssistedSetup: Record "Assisted Setup")
    var
        Translation: Codeunit Translation;
    begin
        Translation.Copy(AssistedSetup, AssistedSetup.FieldNo(Name), GuidedExperienceItem, GuidedExperienceItem.FieldNo(Title));
    end;
}