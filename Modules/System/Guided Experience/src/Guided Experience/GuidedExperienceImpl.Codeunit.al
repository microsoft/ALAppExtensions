// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1991 "Guided Experience Impl."
{
    Access = Internal;
    Permissions = tabledata AllObj = r,
                  tabledata "Guided Experience Item" = rimd,
                  tabledata "Spotlight Tour Text" = rimd;

    var
        TempBlob: Codeunit "Temp Blob";
        ObjectAndLinkToRunErr: Label 'You cannot insert a guided experience item with both an object to run and a link.';
        InvalidObjectTypeErr: Label 'The object type to run is not valid';
        ObjectDoesNotExistErr: Label 'The object %1 %2 does not exist', Comment = '%1 = Object type, %2 = The object ID';
        RunSetupAgainQst: Label 'You have already completed the %1 assisted setup guide. Do you want to run it again?', Comment = '%1 = Assisted Setup Name';
        CodeFormatLbl: Label '%1_%2_%3_%4_%5', Locked = true;
        GuidedExperienceItemInsertedLbl: Label 'Guided Experience Item inserted.', Locked = true;
        GuidedExperienceItemDeletedLbl: Label 'Guided Experience Item deleted.', Locked = true;
        TitleDimensionLbl: Label '%1ItemTitle', Locked = true;
        ShortTitleDimensionLbl: Label '%1ItemShortTitle', Locked = true;
        DescriptionDimensionLbl: Label '%1ItemDescription', Locked = true;
        ExtensionIdDimensionLbl: Label '%1ItemExtensionId', Locked = true;
        ExtensionNameDimensionLbl: Label '%1ItemExtensionName', Locked = true;
        ObjectTypeToRunLbl: Label 'ObjectTypeToRun', Locked = true;
        ObjectIdToRunLbl: Label 'ObjectIdToRun', Locked = true;
        LinkToRunLbl: Label 'LinkToRun', Locked = true;
        SpotlightTourTypeLbl: Label 'SpotlightTourType', Locked = true;
        VideoUrlLbl: Label 'VideoUrl', Locked = true;
        GuidedExperienceTypeLbl: Label 'GuidedExperienceType', Locked = true;

    procedure Insert(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; ExtensionId: Guid; GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; Link: Text[250]; AssistedSetupGroup: Enum "Assisted Setup Group"; VideoUrl: Text[250]; VideoCategory: Enum "Video Category"; HelpUrl: Text[250]; ManualSetupCategory: Enum "Manual Setup Category"; Keywords: Text[250]; SpotlighTourType: Enum "Spotlight Tour Type"; SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text]; CheckObjectValidity: Boolean)
    var
        PrevGuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistImplementation: Codeunit "Checklist Implementation";
        Video: Codeunit Video;
        GuidedExperienceObjectType: Enum "Guided Experience Object Type";
        Version: Integer;
        Code: Code[300];
    begin
        if not GuidedExperienceItem.WritePermission() then
            exit;

        ValidateGuidedExperienceItem(ObjectTypeToRun, ObjectIDToRun, Link, VideoUrl, CheckObjectValidity);

        GetObjectTypeToRun(GuidedExperienceObjectType, ObjectTypeToRun);
        Code := GetCode(GuidedExperienceType, GuidedExperienceObjectType, ObjectIDToRun, Link, VideoUrl, SpotlighTourType);

        Version := GetVersion(PrevGuidedExperienceItem, Code, Title, ShortTitle, Description, ExpectedDuration, ExtensionId,
            GuidedExperienceType, GuidedExperienceObjectType, ObjectIDToRun, Link, AssistedSetupGroup, VideoUrl, VideoCategory,
            HelpUrl, ManualSetupCategory, Keywords, SpotlighTourType, SpotlightTourTexts);

        if Version = -1 then begin
            // This means that the record hasn't changed, so we shouldn't insert a new version of the object.
            // However, we might have to insert a new translation for the already existing version of the object.
            InsertTranslations(PrevGuidedExperienceItem, Title, ShortTitle, Description, Keywords);

            InsertTranslationsForSpotlightTours(SpotlightTourTexts, PrevGuidedExperienceItem.Code, PrevGuidedExperienceItem.Version, false);

            exit;
        end;

        if Version <> 0 then
            ChecklistImplementation.UpdateVersionForSkippedChecklistItems(Code, Version);

        InsertGuidedExperienceItem(GuidedExperienceItem, Code, Version, Title, ShortTitle, Description, ExpectedDuration, ExtensionId,
            PrevGuidedExperienceItem.Completed, GuidedExperienceType, GuidedExperienceObjectType, ObjectIDToRun, Link, AssistedSetupGroup,
            VideoUrl, VideoCategory, HelpUrl, ManualSetupCategory, Keywords, SpotlighTourType);

        InsertSpotlightTourTexts(Code, Version, SpotlightTourTexts);
        InsertTranslationsForSpotlightTours(SpotlightTourTexts, GuidedExperienceItem.Code, GuidedExperienceItem.Version, true);

        InsertTranslations(GuidedExperienceItem, PrevGuidedExperienceItem);

        if VideoUrl <> '' then
            Video.Register(GuidedExperienceItem."Extension ID", CopyStr(GuidedExperienceItem.Title, 1, 250), VideoUrl, VideoCategory,
                Database::"Guided Experience Item", GuidedExperienceItem.SystemId);

        LogMessageOnDatabaseEvent(GuidedExperienceItem, '0000EIM', GuidedExperienceItemInsertedLbl);
    end;

    procedure OpenManualSetupPage()
    begin
        Page.RunModal(Page::"Manual Setup");
    end;

    procedure OpenManualSetupPage(ManualSetupCategory: Enum "Manual Setup Category")
    var
        ManualSetup: Page "Manual Setup";
    begin
        ManualSetup.SetCategoryToDisplay(ManualSetupCategory);
        ManualSetup.RunModal();
    end;

    procedure GetManualSetupPageIDs(var PageIDs: List of [Integer])
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        PrevGuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
#if not CLEAN18
#pragma warning disable AL0432
        ManualSetup: Codeunit "Manual Setup";
#pragma warning restore
#endif
    begin
        Clear(PageIDs);

        GuidedExperience.OnRegisterManualSetup();
#if not CLEAN18
#pragma warning disable AL0432
        ManualSetup.OnRegisterManualSetup();
#pragma warning restore
#endif

        GuidedExperienceItem.SetCurrentKey("Guided Experience Type", "Object Type to Run", "Object ID to Run", Link, Version);
        GuidedExperienceItem.SetRange("Guided Experience Type", GuidedExperienceItem."Guided Experience Type"::"Manual Setup");
        GuidedExperienceItem.SetRange("Object Type to Run", GuidedExperienceItem."Object Type to Run"::Page);
        if GuidedExperienceItem.FindSet() then
            repeat
                if PrevGuidedExperienceItem.Code <> GuidedExperienceItem.Code then
                    PageIDs.Add(GuidedExperienceItem."Object ID to Run");
                PrevGuidedExperienceItem := GuidedExperienceItem;
            until GuidedExperienceItem.Next() = 0;
    end;

    procedure AddTranslationForSetupObject(GuidedExperienceObjectType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer; LanguageID: Integer; TranslatedName: Text; FieldNo: Integer)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        Translation: Codeunit Translation;
        SpotlightTourType: Enum "Spotlight Tour Type";
    begin
        FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceObjectType, ObjectType, ObjectID, '', '', SpotlightTourType::None);
        if not GuidedExperienceItem.FindLast() then
            exit;

        Translation.Set(GuidedExperienceItem, FieldNo, LanguageID, CopyStr(TranslatedName, 1, 2048));
    end;

    procedure IsAssistedSetupComplete(ObjectTypeToRun: Enum "Guided Experience Object Type"; ObjectID: Integer): Boolean
    var
        ObjectType: ObjectType;
    begin
        ObjectType := GetObjectType(ObjectTypeToRun);
        exit(IsAssistedSetupComplete(ObjectType, ObjectID));
    end;

    procedure IsAssistedSetupComplete(ObjectType: ObjectType; ObjectID: Integer): Boolean
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ObjectTypeToRun: Enum "Guided Experience Object Type";
    begin
        if not GuidedExperienceItem.ReadPermission() then
            exit;

        GetObjectTypeToRun(ObjectTypeToRun, ObjectType);

        GuidedExperienceItem.SetRange("Guided Experience Type", GuidedExperienceItem."Guided Experience Type"::"Assisted Setup");
        GuidedExperienceItem.SetRange("Object Type to Run", ObjectTypeToRun);
        GuidedExperienceItem.SetRange("Object ID to Run", ObjectID);
        GuidedExperienceItem.SetRange(Completed, true);

        exit(not GuidedExperienceItem.IsEmpty());
    end;

    procedure Exists(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer): Boolean
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperienceObjectType: Enum "Guided Experience Object Type";
    begin
        if not GuidedExperienceItem.ReadPermission() then
            exit;

        GetObjectTypeToRun(GuidedExperienceObjectType, ObjectType);

        GuidedExperienceItem.SetRange("Guided Experience Type", GuidedExperienceType);
        GuidedExperienceItem.SetRange("Object Type to Run", GuidedExperienceObjectType);
        GuidedExperienceItem.SetRange("Object ID to Run", ObjectID);

        exit(not GuidedExperienceItem.IsEmpty());
    end;

    procedure Exists(GuidedExperienceType: Enum "Guided Experience Type"; Link: Text[250]): Boolean
    var
        GuidedExperienceItem: Record "Guided Experience Item";
    begin
        if not GuidedExperienceItem.ReadPermission() then
            exit;

        GuidedExperienceItem.SetRange("Guided Experience Type", GuidedExperienceType);
        GuidedExperienceItem.SetRange(Link, Link);
        exit(not GuidedExperienceItem.IsEmpty());
    end;

    procedure AssistedSetupExistsAndIsNotComplete(ObjectType: ObjectType; ObjectID: Integer): Boolean
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperienceObjectType: Enum "Guided Experience Object Type";
    begin
        if not GuidedExperienceItem.ReadPermission() then
            exit;

        GetObjectTypeToRun(GuidedExperienceObjectType, ObjectType);

        GuidedExperienceItem.SetRange("Guided Experience Type", GuidedExperienceItem."Guided Experience Type"::"Assisted Setup");
        GuidedExperienceItem.SetRange("Object Type to Run", GuidedExperienceObjectType);
        GuidedExperienceItem.SetRange("Object ID to Run", ObjectID);

        if GuidedExperienceItem.IsEmpty() then
            exit(false);

        GuidedExperienceItem.SetRange(Completed, true);
        exit(GuidedExperienceItem.IsEmpty());
    end;

    procedure CompleteAssistedSetup(ObjectType: ObjectType; ObjectID: Integer)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperienceObjectType: Enum "Guided Experience Object Type";
    begin
        if not GuidedExperienceItem.WritePermission() then
            exit;

        GetObjectTypeToRun(GuidedExperienceObjectType, ObjectType);

        GuidedExperienceItem.SetRange("Guided Experience Type", GuidedExperienceItem."Guided Experience Type"::"Assisted Setup");
        GuidedExperienceItem.SetRange("Object Type to Run", GuidedExperienceObjectType);
        GuidedExperienceItem.SetRange("Object ID to Run", ObjectID);

        Complete(GuidedExperienceItem);
    end;

    procedure ResetAssistedSetup(ObjectType: ObjectType; ObjectID: Integer)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperienceObjectType: Enum "Guided Experience Object Type";
    begin
        if not GuidedExperienceItem.WritePermission() then
            exit;

        GetObjectTypeToRun(GuidedExperienceObjectType, ObjectType);

        GuidedExperienceItem.SetRange("Guided Experience Type", GuidedExperienceItem."Guided Experience Type"::"Assisted Setup");
        GuidedExperienceItem.SetRange("Object Type to Run", GuidedExperienceObjectType);
        GuidedExperienceItem.SetRange("Object ID to Run", ObjectID);

        Reset(GuidedExperienceItem);
    end;

    procedure Run(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperienceObjectType: Enum "Guided Experience Object Type";
    begin
        if not GuidedExperienceItem.ReadPermission() then
            exit;

        GetObjectTypeToRun(GuidedExperienceObjectType, ObjectType);

        GuidedExperienceItem.SetRange("Guided Experience Type", GuidedExperienceType);
        GuidedExperienceItem.SetRange("Object Type to Run", GuidedExperienceObjectType);
        GuidedExperienceItem.SetRange("Object ID to Run", ObjectID);
        if not GuidedExperienceItem.FindLast() then
            exit;

        Run(GuidedExperienceItem);
    end;

    procedure RunAndRefreshAssistedSetup(var GuidedExperienceItemToRefresh: Record "Guided Experience Item")
    begin
        Run(GuidedExperienceItemToRefresh);
        RefreshAssistedSetup(GuidedExperienceItemToRefresh);
    end;

    procedure OpenAssistedSetup()
    begin
        Page.RunModal(Page::"Assisted Setup");
    end;

    procedure OpenAssistedSetup(AssistedSetupGroup: Enum "Assisted Setup Group")
    var
        AssistedSetup: Page "Assisted Setup";
    begin
        AssistedSetup.SetGroupToDisplay(AssistedSetupGroup);
        AssistedSetup.RunModal();
    end;

    procedure Remove(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperienceObjectType: Enum "Guided Experience Object Type";
        SpotlightTourType: Enum "Spotlight Tour Type";
    begin
        if not GuidedExperienceItem.WritePermission() then
            exit;

        GetObjectTypeToRun(GuidedExperienceObjectType, ObjectType);

        FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType, GuidedExperienceObjectType, ObjectID, '', '', SpotlightTourType::None);

        Delete(GuidedExperienceItem);
    end;

    procedure Remove(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer; SpotlightTourType: Enum "Spotlight Tour Type")
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperienceObjectType: Enum "Guided Experience Object Type";
    begin
        if not GuidedExperienceItem.WritePermission() then
            exit;

        GetObjectTypeToRun(GuidedExperienceObjectType, ObjectType);

        FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType, GuidedExperienceObjectType, ObjectID, '', '', SpotlightTourType);
        Delete(GuidedExperienceItem);
    end;

    procedure Remove(GuidedExperienceType: Enum "Guided Experience Type"; Link: Text[250])
    var
        GuidedExperienceItem: Record "Guided Experience Item";
    begin
        if not GuidedExperienceItem.WritePermission() then
            exit;

        GuidedExperienceItem.SetRange("Guided Experience Type", GuidedExperienceType);
        case GuidedExperienceType of
            GuidedExperienceType::Learn:
                GuidedExperienceItem.SetRange(Link, Link);
            GuidedExperienceType::Video:
                GuidedExperienceItem.SetRange("Video Url", Link);
        end;

        Delete(GuidedExperienceItem);
    end;

    procedure NavigateToAssistedSetupHelpPage(GuidedExperienceItem: Record "Guided Experience Item")
    begin
        if GuidedExperienceItem."Help Url" = '' then
            exit;

        Hyperlink(GuidedExperienceItem."Help Url");
    end;

    procedure IsAssistedSetupSetupRecord(GuidedExperienceItem: Record "Guided Experience Item"): Boolean
    begin
        exit(GuidedExperienceItem."Object ID to Run" > 0);
    end;

    procedure GetTranslationForField(GuidedExperienceItem: Record "Guided Experience Item"; FieldNo: Integer): Text
    begin
        exit(GetTranslationForField(GuidedExperienceItem."Guided Experience Type", GuidedExperienceItem."Object Type to Run",
            GuidedExperienceItem."Object ID to Run", GuidedExperienceItem.Link, GuidedExperienceItem."Video Url", GuidedExperienceItem."Spotlight Tour Type", FieldNo));
    end;

    procedure GetTranslationForField(GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: Enum "Guided Experience Object Type"; ObjectIDToRun: Integer; Link: Text[250]; VideoUrl: Text[250]; SpotlightTourType: Enum "Spotlight Tour Type"; FieldNo: Integer): Text
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        Translation: Codeunit Translation;
    begin
        FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType, ObjectTypeToRun, ObjectIDToRun, Link, VideoUrl, SpotlightTourType);
        if GuidedExperienceItem.FindLast() then
            exit(Translation.Get(GuidedExperienceItem, FieldNo, GlobalLanguage));
    end;

    procedure IsObjectToRunValid(GuidedExperienceObjectType: Enum "Guided Experience Object Type"; ObjectID: Integer): Boolean
    var
        ObjectType: ObjectType;
    begin
        ObjectType := GetObjectType(GuidedExperienceObjectType);
        exit(IsObjectToRunValid(ObjectType, ObjectID));
    end;

    procedure IsObjectToRunValid(ObjectType: ObjectType; ObjectID: Integer): Boolean
    var
        AllObj: Record AllObj;
    begin
        if AllObj.Get(ObjectType, ObjectID) then
            exit(true);

        exit(false);
    end;

    procedure GetContentForAssistedSetup(var GuidedExperienceItemTemp: Record "Guided Experience Item" temporary)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GroupValue: Enum "Assisted Setup Group";
        GroupId: Integer;
        i: Integer;
    begin
        GuidedExperienceItem.SetCurrentKey("Guided Experience Type", "Object Type to Run", "Object ID to Run", Link, Version);
        GuidedExperienceItem.SetRange("Guided Experience Type", GuidedExperienceItem."Guided Experience Type"::"Assisted Setup");
        GuidedExperienceItem.SetAscending(Version, false);

        GroupId := -1;
        foreach i in "Assisted Setup Group".Ordinals() do begin
            GroupValue := "Assisted Setup Group".FromInteger(i);
            GuidedExperienceItem.SetRange("Assisted Setup Group", GroupValue);

            if GuidedExperienceItem.FindSet() then begin
                // this part is necessary to include the assisted setup group as a header on the page
                GuidedExperienceItemTemp.Init();
                GuidedExperienceItemTemp.Code := Format(GroupId);
                GuidedExperienceItemTemp."Object ID to Run" := GroupId;
                GuidedExperienceItemTemp.Title := Format(GroupValue);
                GuidedExperienceItemTemp."Assisted Setup Group" := GroupValue;
                GuidedExperienceItemTemp.Insert();

                GroupId -= 1;

                InsertGuidedExperienceItemsInTempVar(GuidedExperienceItem, GuidedExperienceItemTemp);
            end;
        end;
    end;

    procedure GetContentForSetupPage(var GuidedExperienceItemTemp: Record "Guided Experience Item" temporary; GuidedExperienceType: Enum "Guided Experience Type")
    var
        GuidedExperienceItem: Record "Guided Experience Item";
    begin
        GuidedExperienceItem.SetCurrentKey("Guided Experience Type", "Object Type to Run", "Object ID to Run", Link, Version);
        GuidedExperienceItem.SetAscending(Version, false);

        GuidedExperienceItem.SetRange("Guided Experience Type", GuidedExperienceType);
        if GuidedExperienceItem.FindSet() then
            InsertGuidedExperienceItemsInTempVar(GuidedExperienceItem, GuidedExperienceItemTemp);
    end;

    local procedure InsertGuidedExperienceItemsInTempVar(var GuidedExperienceItem: Record "Guided Experience Item"; var GuidedExperienceItemTemp: Record "Guided Experience Item" temporary)
    var
        PrevGuidedExperienceItem: Record "Guided Experience Item";
    begin
        repeat
            if (GuidedExperienceItem."Object Type to Run" <> PrevGuidedExperienceItem."Object Type to Run")
                or (GuidedExperienceItem."Object ID to Run" <> PrevGuidedExperienceItem."Object ID to Run")
                or (GuidedExperienceItem.Link <> PrevGuidedExperienceItem.Link)
                or (GuidedExperienceItem."Guided Experience Type" <> PrevGuidedExperienceItem."Guided Experience Type")
                or (GuidedExperienceItem."Spotlight Tour Type" <> PrevGuidedExperienceItem."Spotlight Tour Type")
            then
                InsertGuidedExperienceItemIfValid(GuidedExperienceItemTemp, GuidedExperienceItem);

            PrevGuidedExperienceItem := GuidedExperienceItem;
        until GuidedExperienceItem.Next() = 0;
    end;

    local procedure ValidateGuidedExperienceItem(ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; Link: Text[250]; VideoUrl: Text[250]; CheckObjectValidity: Boolean)
    begin
        if (ObjectIDToRun <> 0) and (Link <> '') and (VideoUrl <> '') then
            Error(ObjectAndLinkToRunErr);

        if (Link = '') and (VideoUrl = '') then begin
            if not (ObjectTypeToRun in [ObjectType::Page, ObjectType::Codeunit, ObjectType::Report, ObjectType::XmlPort]) then
                Error(InvalidObjectTypeErr);

            if CheckObjectValidity then
                if not IsObjectToRunValid(ObjectTypeToRun, ObjectIDToRun) then
                    Error(ObjectDoesNotExistErr, ObjectTypeToRun, ObjectIDToRun);
        end;
    end;

    local procedure GetCode(Type: Enum "Guided Experience Type"; ObjectType: Enum "Guided Experience Object Type"; ObjectID: Integer; Link: Text[250]; VideoUrl: Text[250]; SpotlightTourType: Enum "Spotlight Tour Type"): Code[300]
    var
        Url: Text[250];
    begin
        if Type = Type::Video then
            Url := VideoUrl
        else
            Url := Link;

        exit(StrSubstNo(CodeFormatLbl, Type, ObjectType, ObjectID, Url, SpotlightTourType.AsInteger()));
    end;

    local procedure GetVersion(var GuidedExperienceItem: Record "Guided Experience Item"; Code: Code[300]; Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; ExtensionId: Guid; GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: Enum "Guided Experience Object Type"; ObjectIDToRun: Integer; Link: Text[250]; AssistedSetupGroup: Enum "Assisted Setup Group"; VideoUrl: Text[250]; VideoCategory: Enum "Video Category"; HelpUrl: Text[250]; ManualSetupCategory: Enum "Manual Setup Category"; Keywords: Text[250]; SpotlightTourType: Enum "Spotlight Tour Type"; SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text]): Integer
    begin
        GuidedExperienceItem.SetRange(Code, Code);
        if not GuidedExperienceItem.FindLast() then
            exit(0);

        if HasTheRecordChanged(GuidedExperienceItem, Title, ShortTitle, Description, ExpectedDuration, ExtensionId, GuidedExperienceType, ObjectTypeToRun,
            ObjectIDToRun, Link, AssistedSetupGroup, VideoUrl, VideoCategory, HelpUrl, ManualSetupCategory, Keywords, SpotlightTourType, SpotlightTourTexts)
        then
            exit(GuidedExperienceItem.Version + 1);

        exit(-1);
    end;

    local procedure HasTheRecordChanged(GuidedExperienceItem: Record "Guided Experience Item"; Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; ExtensionId: Guid; GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: Enum "Guided Experience Object Type"; ObjectIDToRun: Integer; Link: Text[250]; AssistedSetupGroup: Enum "Assisted Setup Group"; VideoUrl: Text[250]; VideoCategory: Enum "Video Category"; HelpUrl: Text[250]; ManualSetupCategory: Enum "Manual Setup Category"; Keywords: Text[250]; SpotlightTourType: Enum "Spotlight Tour Type"; SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text]): Boolean
    begin
        if (GuidedExperienceItem."Expected Duration" <> ExpectedDuration)
            or (GuidedExperienceItem."Extension ID" <> ExtensionId)
            or (GuidedExperienceItem."Guided Experience Type" <> GuidedExperienceType)
            or (GuidedExperienceItem."Object Type to Run" <> ObjectTypeToRun)
            or (GuidedExperienceItem."Object ID to Run" <> ObjectIDToRun)
            or (GuidedExperienceItem.Link <> Link)
            or (GuidedExperienceItem."Assisted Setup Group" <> AssistedSetupGroup)
            or (GuidedExperienceItem."Video Url" <> VideoUrl)
            or (GuidedExperienceItem."Video Category" <> VideoCategory)
            or (GuidedExperienceItem."Help Url" <> HelpUrl)
            or (GuidedExperienceItem."Manual Setup Category" <> ManualSetupCategory)
            or (GuidedExperienceItem."Spotlight Tour Type" <> SpotlightTourType)
        then
            exit(true);

        if HasTheSpotlightTourDictionaryChanged(GuidedExperienceItem.Code, GuidedExperienceItem.Version, SpotlightTourTexts) then
            exit(true);

        if GuidedExperienceItem.Title <> Title then
            if IsTranslationDifferentFromFieldValue(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Title), Title) then
                exit(true);

        if GuidedExperienceItem."Short Title" <> ShortTitle then
            if IsTranslationDifferentFromFieldValue(GuidedExperienceItem, GuidedExperienceItem.FieldNo("Short Title"), ShortTitle) then
                exit(true);

        if GuidedExperienceItem.Description <> Description then
            if IsTranslationDifferentFromFieldValue(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Description), Description) then
                exit(true);

        if GuidedExperienceItem.Keywords <> Keywords then
            if IsTranslationDifferentFromFieldValue(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Keywords), Keywords) then
                exit(true);

        exit(false);
    end;

    local procedure HasTheSpotlightTourDictionaryChanged(Code: Code[300]; Version: Integer; Dictionary: Dictionary of [Enum "Spotlight Tour Text", Text]): Boolean
    var
        SpotlightTourText: Record "Spotlight Tour Text";
        DictionaryKeys: List of [Enum "Spotlight Tour Text"];
        DictionaryValue: Text;
    begin
        DictionaryKeys := Dictionary.Keys();

        SpotlightTourText.SetRange("Guided Experience Item Code", Code);
        SpotlightTourText.SetRange("Guided Experience Item Version", Version);

        if SpotlightTourText.FindSet() then
            repeat
                if not DictionaryKeys.Contains(SpotlightTourText."Spotlight Tour Step") then
                    exit(true)
                else begin
                    DictionaryValue := Dictionary.Get(SpotlightTourText."Spotlight Tour Step");

                    if DictionaryValue <> SpotlightTourText."Spotlight Tour Text" then
                        if IsTranslationDifferentFromFieldValue(SpotlightTourText, SpotlightTourText.FieldNo("Spotlight Tour Text"), DictionaryValue) then
                            exit(true);

                    DictionaryKeys.Remove(SpotlightTourText."Spotlight Tour Step");
                end;
            until SpotlightTourText.Next() = 0;

        if DictionaryKeys.Count <> 0 then
            exit(true);

        exit(false);
    end;

    local procedure IsTranslationDifferentFromFieldValue(SpotlightTourText: Record "Spotlight Tour Text"; FieldNo: Integer; FieldValue: Text): Boolean
    var
        Translation: Codeunit Translation;
        TranslatedString: Text;
    begin
        TranslatedString := Translation.Get(SpotlightTourText, FieldNo, GlobalLanguage);

        exit(IsTranslationDifferentFromFieldValue(TranslatedString, FieldValue));
    end;

    local procedure IsTranslationDifferentFromFieldValue(GuidedExperienceItem: Record "Guided Experience Item"; FieldNo: Integer; FieldValue: Text): Boolean
    var
        Translation: Codeunit Translation;
        TranslatedString: Text;
    begin
        TranslatedString := Translation.Get(GuidedExperienceItem, FieldNo, GlobalLanguage);

        exit(IsTranslationDifferentFromFieldValue(TranslatedString, FieldValue));
    end;

    local procedure IsTranslationDifferentFromFieldValue(TranslatedString: Text; FieldValue: Text): Boolean
    begin
        if TranslatedString = '' then
            exit(false);

        if TranslatedString <> FieldValue then
            exit(true);

        exit(false);
    end;

    local procedure InsertGuidedExperienceItem(var GuidedExperienceItem: Record "Guided Experience Item"; Code: Code[300]; Version: Integer; Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; ExtensionId: Guid; Completed: Boolean; GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: Enum "Guided Experience Object Type"; ObjectIDToRun: Integer; Link: Text[250]; AssistedSetupGroup: Enum "Assisted Setup Group"; VideoUrl: Text[250]; VideoCategory: Enum "Video Category"; HelpUrl: Text[250]; ManualSetupCategory: Enum "Manual Setup Category"; Keywords: Text[250]; SpotlightTourType: Enum "Spotlight Tour Type")
    var
        IconInStream: InStream;
    begin
        GuidedExperienceItem.Code := Code;
        GuidedExperienceItem.Version := Version;
        GuidedExperienceItem.Title := Title;
        GuidedExperienceItem."Short Title" := ShortTitle;
        GuidedExperienceItem.Description := Description;
        GuidedExperienceItem."Expected Duration" := ExpectedDuration;
        GuidedExperienceItem."Extension ID" := ExtensionId;
        GuidedExperienceItem.Completed := Completed;
        GuidedExperienceItem."Guided Experience Type" := GuidedExperienceType;
        GuidedExperienceItem."Object Type to Run" := ObjectTypeToRun;
        GuidedExperienceItem."Object ID to Run" := ObjectIDToRun;
        GuidedExperienceItem.Link := Link;
        GuidedExperienceItem."Assisted Setup Group" := AssistedSetupGroup;
        GuidedExperienceItem."Video Url" := VideoUrl;
        GuidedExperienceItem."Video Category" := VideoCategory;
        GuidedExperienceItem."Help Url" := HelpUrl;
        GuidedExperienceItem."Manual Setup Category" := ManualSetupCategory;
        GuidedExperienceItem.Keywords := Keywords;
        GuidedExperienceItem."Spotlight Tour Type" := SpotlightTourType;

        if GetIconInStream(IconInStream, ExtensionId) then
            GuidedExperienceItem.Icon.ImportStream(IconInStream, ExtensionId);

        GuidedExperienceItem.Insert();
    end;

    local procedure InsertSpotlightTourTexts(Code: Code[300]; Version: Integer; SpotlightTourTextsDictionary: Dictionary of [Enum "Spotlight Tour Text", Text])
    var
        SpotlightTourText: Record "Spotlight Tour Text";
        SpotlightTourKey: Enum "Spotlight Tour Text";
        SpotlightTourKeys: List of [Enum "Spotlight Tour Text"];
    begin
        SpotlightTourKeys := SpotlightTourTextsDictionary.Keys();

        foreach SpotlightTourKey in SpotlightTourKeys do begin
            SpotlightTourText."Guided Experience Item Code" := Code;
            SpotlightTourText."Guided Experience Item Version" := Version;
            SpotlightTourText."Spotlight Tour Step" := SpotlightTourKey;
            SpotlightTourText."Spotlight Tour Text" := CopyStr(SpotlightTourTextsDictionary.Get(SpotlightTourKey),
                1, MaxStrLen(SpotlightTourText."Spotlight Tour Text"));
            if SpotlightTourText.Insert() then;
        end;
    end;

    local procedure InsertTranslationsForSpotlightTours(SpotlightTourTextsDictionary: Dictionary of [Enum "Spotlight Tour Text", Text]; Code: Code[300]; Version: Integer; CopyTranslationsFromPreviousVersions: Boolean)
    var
        SpotlightTourText: Record "Spotlight Tour Text";
        SpotlightTourKey: Enum "Spotlight Tour Text";
        SpotlightTourKeys: List of [Enum "Spotlight Tour Text"];
        SpotlightTourTextValue: Text[250];
    begin
        SpotlightTourKeys := SpotlightTourTextsDictionary.Keys();

        foreach SpotlightTourKey in SpotlightTourKeys do
            if SpotlightTourText.Get(Code, Version, SpotlightTourKey) then begin
                SpotlightTourTextValue := CopyStr(SpotlightTourTextsDictionary.Get(SpotlightTourKey),
                    1, MaxStrLen(SpotlightTourText."Spotlight Tour Text"));

                InsertTranslation(SpotlightTourText, SpotlightTourTextValue);

                if CopyTranslationsFromPreviousVersions then
                    InsertExistingTranslationsForSpotlightTour(SpotlightTourText);
            end;
    end;

    local procedure InsertTranslation(SpotlightTourText: Record "Spotlight Tour Text"; TranslationText: Text[250])
    var
        Translation: Codeunit Translation;
    begin
        Translation.Set(SpotlightTourText, SpotlightTourText.FieldNo("Spotlight Tour Text"), TranslationText);
    end;

    local procedure InsertExistingTranslationsForSpotlightTour(SpotlightTourText: Record "Spotlight Tour Text")
    var
        PrevSpotlightTourText: Record "Spotlight Tour Text";
        Translation: Codeunit Translation;
    begin
        if SpotlightTourText."Guided Experience Item Version" = 0 then
            exit; // the record doesn't have any previous versions and thus no existing translations

        if not PrevSpotlightTourText.Get(SpotlightTourText."Guided Experience Item Code",
            SpotlightTourText."Guided Experience Item Version" - 1,
            SpotlightTourText."Spotlight Tour Step")
        then
            exit;

        if SpotlightTourText."Spotlight Tour Text" = PrevSpotlightTourText."Spotlight Tour Text" then
            if Translation.Get(SpotlightTourText, SpotlightTourText.FieldNo("Spotlight Tour Text")) = '' then
                Translation.Copy(PrevSpotlightTourText, SpotlightTourText, SpotlightTourText.FieldNo("Spotlight Tour Text"));
    end;

    procedure InsertTranslations(GuidedExperienceItem: Record "Guided Experience Item"; Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; Keywords: Text[250])
    var
        Translation: Codeunit Translation;
    begin
        Translation.Set(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Title), Title);
        Translation.Set(GuidedExperienceItem, GuidedExperienceItem.FieldNo("Short Title"), ShortTitle);
        Translation.Set(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Description), Description);
        Translation.Set(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Keywords), Keywords);
    end;

    local procedure InsertTranslations(GuidedExperienceItem: Record "Guided Experience Item"; PrevVersionGuidedExperienceItem: Record "Guided Experience Item")
    var
        Translation: Codeunit Translation;
    begin
        InsertTranslations(GuidedExperienceItem, GuidedExperienceItem.Title, GuidedExperienceItem."Short Title",
            GuidedExperienceItem.Description, GuidedExperienceItem.Keywords);

        // if this isn't the first version of the record, copy all the existing translations for the 
        // record if the fields haven't changed and if the translations don't already exist
        if GuidedExperienceItem.Version > 0 then begin
            if PrevVersionGuidedExperienceItem.Title = GuidedExperienceItem.Title then
                if Translation.Get(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Title)) = '' then
                    Translation.Copy(PrevVersionGuidedExperienceItem, GuidedExperienceItem, GuidedExperienceItem.FieldNo(Title));

            if PrevVersionGuidedExperienceItem."Short Title" = GuidedExperienceItem."Short Title" then
                if Translation.Get(GuidedExperienceItem, GuidedExperienceItem.FieldNo("Short Title")) = '' then
                    Translation.Copy(PrevVersionGuidedExperienceItem, GuidedExperienceItem, GuidedExperienceItem.FieldNo("Short Title"));

            if PrevVersionGuidedExperienceItem.Description = GuidedExperienceItem.Description then
                if Translation.Get(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Description)) = '' then
                    Translation.Copy(PrevVersionGuidedExperienceItem, GuidedExperienceItem, GuidedExperienceItem.FieldNo(Description));
        end;
    end;

    procedure GetObjectTypeToRun(var GuidedExperienceObjectType: Enum "Guided Experience Object Type"; ObjectType: ObjectType)
    begin
        case ObjectType of
            ObjectType::Page:
                GuidedExperienceObjectType := GuidedExperienceObjectType::Page;
            ObjectType::Codeunit:
                GuidedExperienceObjectType := GuidedExperienceObjectType::Codeunit;
            ObjectType::Report:
                GuidedExperienceObjectType := GuidedExperienceObjectType::Report;
            ObjectType::XmlPort:
                GuidedExperienceObjectType := GuidedExperienceObjectType::XmlPort;
            else
                GuidedExperienceObjectType := GuidedExperienceObjectType::Uninitialized;
        end
    end;

    procedure FilterGuidedExperienceItem(var GuidedExperienceItem: Record "Guided Experience Item"; GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer; Link: Text[250]; VideoUrl: Text[250]; SpotlightTourType: Enum "Spotlight Tour Type")
    var
        ObjectTypeToRun: Enum "Guided Experience Object Type";
    begin
        GetObjectTypeToRun(ObjectTypeToRun, ObjectType);

        FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType, ObjectTypeToRun, ObjectID, Link, VideoUrl, SpotlightTourType);
    end;

    procedure FilterGuidedExperienceItem(var GuidedExperienceItem: Record "Guided Experience Item"; GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: Enum "Guided Experience Object Type"; ObjectID: Integer; Link: Text[250]; VideoUrl: Text[250]; SpotlightTourType: Enum "Spotlight Tour Type")
    begin
        GuidedExperienceItem.SetCurrentKey("Guided Experience Type", "Object Type to Run", "Object ID to Run", Link, Version);
        GuidedExperienceItem.SetRange("Guided Experience Type", GuidedExperienceType);
        GuidedExperienceItem.SetRange("Object Type to Run", ObjectType);
        GuidedExperienceItem.SetRange("Object ID to Run", ObjectID);
        GuidedExperienceItem.SetRange(Link, Link);
        GuidedExperienceItem.SetRange("Spotlight Tour Type", SpotlightTourType);

        if GuidedExperienceType = GuidedExperienceType::Video then
            GuidedExperienceItem.SetRange("Video Url", VideoUrl);
    end;

    local procedure Complete(var GuidedExperienceItem: Record "Guided Experience Item")
    begin
        if GuidedExperienceItem.FindSet() then
            GuidedExperienceItem.ModifyAll(Completed, true);
    end;

    local procedure Reset(GuidedExperienceItem: Record "Guided Experience Item")
    begin
        if GuidedExperienceItem.FindSet() then
            repeat
                GuidedExperienceItem.Completed := false;
                GuidedExperienceItem.Modify();
            until GuidedExperienceItem.Next() = 0;
    end;

    local procedure Run(var GuidedExperienceItem: Record "Guided Experience Item")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        GuidedExperience: Codeunit "Guided Experience";
#if not CLEAN18
#pragma warning disable AL0432
        AssistedSetup: Codeunit "Assisted Setup";
        HandledAssistedSetup: Boolean;
#pragma warning restore
#endif
        Handled: Boolean;
        ObjectType: ObjectType;
    begin
        ObjectType := GetObjectType(GuidedExperienceItem."Object Type to Run");

        if GuidedExperienceItem.Completed and (GuidedExperienceItem."Guided Experience Type" = GuidedExperienceItem."Guided Experience Type"::"Assisted Setup") then begin
            GuidedExperience.OnReRunOfCompletedAssistedSetup(GuidedExperienceItem."Extension ID", ObjectType,
                GuidedExperienceItem."Object ID to Run", Handled);

#if CLEAN18
            if Handled then
                exit;           
#else
#pragma warning disable AL0432
            AssistedSetup.OnReRunOfCompletedSetup(GuidedExperienceItem."Extension ID", GuidedExperienceItem."Object ID to Run", HandledAssistedSetup);
            if Handled or HandledAssistedSetup then
                exit;
#pragma warning restore
#endif

            if not ConfirmManagement.GetResponse(StrSubstNo(RunSetupAgainQst, GuidedExperienceItem.Title), false) then
                exit;
        end;

        RunObject(GuidedExperienceItem);

#if not CLEAN18
#pragma warning disable AL0432
        if GuidedExperienceItem."Guided Experience Type" = GuidedExperienceItem."Guided Experience Type"::"Assisted Setup" then
            AssistedSetup.OnAfterRun(GuidedExperienceItem."Extension ID", GuidedExperienceItem."Object ID to Run");
#pragma warning restore
#endif
        if GuidedExperienceItem."Guided Experience Type" = GuidedExperienceItem."Guided Experience Type"::"Assisted Setup" then
            GuidedExperience.OnAfterRunAssistedSetup(GuidedExperienceItem."Extension ID", ObjectType, GuidedExperienceItem."Object ID to Run");
    end;

    procedure GetObjectType(GuidedExperienceObjectType: Enum "Guided Experience Object Type"): ObjectType
    begin
        case GuidedExperienceObjectType of
            GuidedExperienceObjectType::Uninitialized:
                exit;
            GuidedExperienceObjectType::Page:
                exit(ObjectType::Page);
            GuidedExperienceObjectType::Codeunit:
                exit(ObjectType::Codeunit);
            GuidedExperienceObjectType::Report:
                exit(ObjectType::Report);
            GuidedExperienceObjectType::XmlPort:
                exit(ObjectType::XmlPort);
        end;
    end;

    procedure RefreshAssistedSetup(var GuidedExperienceItemToRefresh: Record "Guided Experience Item")
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        SpotlightTourType: Enum "Spotlight Tour Type";
    begin
        FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceItem."Guided Experience Type"::"Assisted Setup",
            GuidedExperienceItemToRefresh."Object Type to Run", GuidedExperienceItemToRefresh."Object ID to Run", '', '', SpotlightTourType::None);

        if not GuidedExperienceItem.FindLast() then
            exit;

        GuidedExperienceItemToRefresh := GuidedExperienceItem;
        GuidedExperienceItemToRefresh.Modify();
    end;

    local procedure Delete(var GuidedExperienceItem: Record "Guided Experience Item")
    var
        ChecklistImplementation: Codeunit "Checklist Implementation";
    begin
        if GuidedExperienceItem.IsEmpty() then
            exit;

        if GuidedExperienceItem.FindFirst() then begin
            ChecklistImplementation.Delete(GuidedExperienceItem.Code);
            DeleteSpotlightTourTexts(GuidedExperienceItem.Code);
        end;

        GuidedExperienceItem.DeleteAll();
    end;

    local procedure DeleteSpotlightTourTexts(Code: Code[300])
    var
        SpotlightTourText: Record "Spotlight Tour Text";
    begin
        SpotlightTourText.SetRange("Guided Experience Item Code", Code);
        if not SpotlightTourText.IsEmpty() then
            SpotlightTourText.DeleteAll();
    end;

    local procedure InsertGuidedExperienceItemIfValid(var GuidedExperienceItemTemp: Record "Guided Experience Item" temporary; GuidedExperienceItem: Record "Guided Experience Item")
    var
        Translation: Text;
    begin
        if not (GuidedExperienceItem."Guided Experience Type" in
            ["Guided Experience Type"::Learn, "Guided Experience Type"::Video])
        then
            if not IsObjectToRunValid(
                GetObjectType(GuidedExperienceItem."Object Type to Run"),
                GuidedExperienceItem."Object ID to Run")
            then
                exit;

        GuidedExperienceItemTemp.TransferFields(GuidedExperienceItem);

        Translation := GetTranslationForField(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Title));
        if Translation <> '' then
            GuidedExperienceItemTemp.Title := CopyStr(Translation, 1, MaxStrLen(GuidedExperienceItemTemp.Title));

        Translation := GetTranslationForField(GuidedExperienceItem, GuidedExperienceItem.FieldNo("Short Title"));
        if Translation <> '' then
            GuidedExperienceItemTemp."Short Title" := CopyStr(Translation, 1, MaxStrLen(GuidedExperienceItemTemp."Short Title"));

        Translation := GetTranslationForField(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Description));
        if Translation <> '' then
            GuidedExperienceItemTemp.Description := CopyStr(Translation, 1, MaxStrLen(GuidedExperienceItemTemp.Description));

        GuidedExperienceItemTemp.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Video, 'OnRegisterVideo', '', false, false)]
    local procedure OnRegisterVideo(Sender: Codeunit Video)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        PrevGuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.OnRegisterAssistedSetup();

        GuidedExperienceItem.SetCurrentKey("Object Type to Run", "Object ID to Run", Link, Version);
        GuidedExperienceItem.SetFilter("Video Url", '<>%1', '');
        if GuidedExperienceItem.FindSet() then begin
            repeat
                if (PrevGuidedExperienceItem."Object ID to Run" <> 0) and
                    ((GuidedExperienceItem."Object Type to Run" <> PrevGuidedExperienceItem."Object Type to Run") or (GuidedExperienceItem."Object Type to Run" <> PrevGuidedExperienceItem."Object Type to Run")) then
                    Sender.Register(PrevGuidedExperienceItem."Extension ID", CopyStr(PrevGuidedExperienceItem.Title, 1, 250), PrevGuidedExperienceItem."Video Url",
                        PrevGuidedExperienceItem."Video Category", Database::"Guided Experience Item", PrevGuidedExperienceItem.SystemId);

                PrevGuidedExperienceItem := GuidedExperienceItem;
            until GuidedExperienceItem.Next() = 0;

            Sender.Register(GuidedExperienceItem."Extension ID", CopyStr(GuidedExperienceItem.Title, 1, 250), GuidedExperienceItem."Video Url",
                GuidedExperienceItem."Video Category", Database::"Guided Experience Item", GuidedExperienceItem.SystemId);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Navigation Bar Subscribers", 'OnBeforeDefaultOpenRoleBasedSetupExperience', '', false, false)] // Assisted setup module
    local procedure OpenRoleBasedSetupExperience(var Handled: Boolean)
    var
        GuidedExperience: Codeunit "Guided Experience";
#if not CLEAN18
#pragma warning disable AL0432
        AssistedSetup: Codeunit "Assisted Setup";
        HandledAssistedSetup: Boolean;
#pragma warning restore
#endif
        RoleBasedSetupExperienceID: Integer;
    begin
        RoleBasedSetupExperienceID := Page::"Assisted Setup";

        GuidedExperience.OnBeforeOpenRoleBasedAssistedSetupExperience(RoleBasedSetupExperienceID, Handled);
#if not CLEAN18
#pragma warning disable AL0432
        AssistedSetup.OnBeforeOpenRoleBasedSetupExperience(RoleBasedSetupExperienceID, HandledAssistedSetup);
        if not (HandledAssistedSetup or Handled) then
#pragma warning restore
#else
        if not Handled then
#endif
            Page.Run(RoleBasedSetupExperienceID);

        Handled := true;
    end;

    local procedure GetIconInStream(var IconInStream: InStream; ExtensionId: Guid): Boolean
    var
        ExtensionManagement: Codeunit "Extension Management";
    begin
        ExtensionManagement.GetExtensionLogo(ExtensionId, TempBlob);

        if not TempBlob.HasValue() then
            exit(false);

        TempBlob.CreateInStream(IconInStream);
        exit(true);
    end;

    local procedure RunObject(GuidedExperienceItem: Record "Guided Experience Item")
    begin
        case GuidedExperienceItem."Object Type to Run" of
            "Guided Experience Object Type"::Page:
                Page.RunModal(GuidedExperienceItem."Object ID to Run");
            "Guided Experience Object Type"::Codeunit:
                Codeunit.Run(GuidedExperienceItem."Object ID to Run");
            "Guided Experience Object Type"::Report:
                Report.RunModal(GuidedExperienceItem."Object ID to Run");
            "Guided Experience Object Type"::XmlPort:
                Xmlport.Run(GuidedExperienceItem."Object ID to Run");
        end
    end;

    procedure AddGuidedExperienceItemDimensions(var Dimensions: Dictionary of [Text, Text]; GuidedExperienceItem: Record "Guided Experience Item"; DimensionName: Text)
    var
        Translation: Codeunit Translation;
        Language: Codeunit Language;
        DefaultLanguage: Integer;
        CurrentLanguage: Integer;
    begin
        DefaultLanguage := Language.GetDefaultApplicationLanguageId();
        CurrentLanguage := GlobalLanguage();
        GlobalLanguage(DefaultLanguage);

        Dimensions.Add(StrSubstNo(TitleDimensionLbl, DimensionName), Translation.Get(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Title), DefaultLanguage));
        Dimensions.Add(StrSubstNo(ShortTitleDimensionLbl, DimensionName), Translation.Get(GuidedExperienceItem, GuidedExperienceItem.FieldNo("Short Title"), DefaultLanguage));
        Dimensions.Add(StrSubstNo(DescriptionDimensionLbl, DimensionName), Translation.Get(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Description), DefaultLanguage));
        Dimensions.Add(StrSubstNo(ExtensionIdDimensionLbl, DimensionName), GuidedExperienceItem."Extension ID");

        GuidedExperienceItem.CalcFields("Extension Name");
        Dimensions.Add(StrSubstNo(ExtensionNameDimensionLbl, DimensionName), GuidedExperienceItem."Extension Name");

        Dimensions.Add(GuidedExperienceTypeLbl, Format(GuidedExperienceItem."Guided Experience Type"));
        Dimensions.Add(ObjectTypeToRunLbl, Format(GuidedExperienceItem."Object Type to Run"));
        Dimensions.Add(ObjectIdToRunLbl, Format(GuidedExperienceItem."Object ID to Run"));
        Dimensions.Add(LinkToRunLbl, Format(GuidedExperienceItem.Link));
        Dimensions.Add(SpotlightTourTypeLbl, Format(GuidedExperienceItem."Spotlight Tour Type"));
        Dimensions.Add(VideoUrlLbl, Format(GuidedExperienceItem."Video Url"));

        GlobalLanguage(CurrentLanguage);
    end;

    procedure AddCompanyNameDimension(var Dimensions: Dictionary of [Text, Text])
    begin
        Dimensions.Add('CompanyName', CompanyName);
    end;

    procedure AddRoleDimension(var Dimensions: Dictionary of [Text, Text]; var UserPersonalization: Record "User Personalization")
    var
        Language: Codeunit Language;
        CurrentLanguage: Integer;
    begin
        if not (UserPersonalization.Scope = UserPersonalization.Scope::System) then
            exit;
        CurrentLanguage := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());

        Dimensions.Add('Role', UserPersonalization."Profile ID");
        Dimensions.Add('RoleExtension', UserPersonalization."App ID");
        Dimensions.Add('RoleScope', Format(UserPersonalization.Scope));

        GlobalLanguage(CurrentLanguage);
    end;

    local procedure LogMessageOnDatabaseEvent(var Rec: Record "Guided Experience Item"; Tag: Text; Message: Text)
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        AddGuidedExperienceItemDimensions(Dimensions, Rec, 'GuidedExperience');
        AddCompanyNameDimension(Dimensions);

        Session.LogMessage(Tag, Message, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation,
            TelemetryScope::ExtensionPublisher, Dimensions);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Guided Experience Item", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterGuidedExperienceItemDelete(var Rec: Record "Guided Experience Item")
    begin
        if Rec.IsTemporary() then
            exit;

        LogMessageOnDatabaseEvent(Rec, '0000EIN', GuidedExperienceItemDeletedLbl);
    end;
}