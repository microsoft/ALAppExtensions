// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1991 "Guided Experience Impl."
{
    Access = Internal;
    Permissions = tabledata AllObj = r,
                  tabledata "Guided Experience Item" = rimd;

    var
        TempBlob: Codeunit "Temp Blob";
        ObjectAndLinkToRunErr: Label 'You cannot insert a guided experience item with both an object to run and a link.';
        InvalidObjectTypeErr: Label 'The object type to run is not valid';
        ObjectDoesNotExistErr: Label 'The object %1 %2 does not exist', Comment = '%1 = Object type, %2 = The object ID';
        RunSetupAgainQst: Label 'You have already completed the %1 assisted setup guide. Do you want to run it again?', Comment = '%1 = Assisted Setup Name';
        CodeFormatLbl: Label '%1_%2_%3_%4', Locked = true;
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
        GuidedExperienceTypeLbl: Label 'GuidedExperienceType', Locked = true;

    procedure Insert(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; ExtensionId: Guid; GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; Link: Text[250]; AssistedSetupGroup: Enum "Assisted Setup Group"; VideoUrl: Text[250]; VideoCategory: Enum "Video Category"; HelpUrl: Text[250]; ManualSetupCategory: Enum "Manual Setup Category"; Keywords: Text[250]; CheckObjectValidity: Boolean)
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

        ValidateGuidedExperienceItem(ObjectTypeToRun, ObjectIDToRun, Link, CheckObjectValidity);

        GetObjectTypeToRun(GuidedExperienceObjectType, ObjectTypeToRun);
        Code := GetCode(GuidedExperienceType, GuidedExperienceObjectType, ObjectIDToRun, Link);

        Version := GetVersion(PrevGuidedExperienceItem, Code, Title, ShortTitle, Description, ExpectedDuration, ExtensionId, GuidedExperienceType,
            GuidedExperienceObjectType, ObjectIDToRun, Link, AssistedSetupGroup, VideoUrl, VideoCategory, HelpUrl, ManualSetupCategory, Keywords);

        if Version = -1 then begin
            // This means that the record hasn't changed, so we shouldn't insert a new version of the object.
            // However, we might have to insert a new translation for the already existing version of the object.
            InsertTranslations(PrevGuidedExperienceItem, Title, ShortTitle, Description, Keywords);

            exit;
        end;

        if Version <> 0 then
            ChecklistImplementation.UpdateVersionForSkippedChecklistItems(Code, Version);

        InsertGuidedExperienceItem(GuidedExperienceItem, Code, Version, Title, ShortTitle, Description, ExpectedDuration, ExtensionId, PrevGuidedExperienceItem.Completed,
            GuidedExperienceType, GuidedExperienceObjectType, ObjectIDToRun, Link, AssistedSetupGroup, VideoUrl, VideoCategory, HelpUrl, ManualSetupCategory, Keywords);

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
        ManualSetup: Codeunit "Manual Setup";
#endif
    begin
        Clear(PageIDs);

        GuidedExperience.OnRegisterManualSetup();
#if not CLEAN18
        ManualSetup.OnRegisterManualSetup();
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
    begin
        FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceObjectType, ObjectType, ObjectID, '');
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
    begin
        if not GuidedExperienceItem.WritePermission() then
            exit;

        GetObjectTypeToRun(GuidedExperienceObjectType, ObjectType);

        FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType, GuidedExperienceObjectType, ObjectID, '');

        Delete(GuidedExperienceItem);
    end;

    procedure Remove(GuidedExperienceType: Enum "Guided Experience Type"; Link: Text[250])
    var
        GuidedExperienceItem: Record "Guided Experience Item";
    begin
        if not GuidedExperienceItem.WritePermission() then
            exit;

        GuidedExperienceItem.SetRange("Guided Experience Type", GuidedExperienceType);
        GuidedExperienceItem.SetRange(Link, Link);

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
            GuidedExperienceItem."Object ID to Run", GuidedExperienceItem.Link, FieldNo));
    end;

    procedure GetTranslationForField(GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: Enum "Guided Experience Object Type"; ObjectIDToRun: Integer; Link: Text[250]; FieldNo: Integer): Text
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        Translation: Codeunit Translation;
    begin
        FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType, ObjectTypeToRun, ObjectIDToRun, Link);
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

        GroupId := -1;
        foreach i in "Assisted Setup Group".Ordinals() do begin
            GroupValue := "Assisted Setup Group".FromInteger(i);
            GuidedExperienceItem.SetRange("Assisted Setup Group", GroupValue);
            GuidedExperienceItem.SetAscending(Version, false);

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
            then
                InsertGuidedExperienceItemIfValid(GuidedExperienceItemTemp, GuidedExperienceItem);

            PrevGuidedExperienceItem := GuidedExperienceItem;
        until GuidedExperienceItem.Next() = 0;
    end;

    local procedure ValidateGuidedExperienceItem(ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; Link: Text[250]; CheckObjectValidity: Boolean)
    begin
        if (ObjectIDToRun <> 0) and (Link <> '') then
            Error(ObjectAndLinkToRunErr);

        if Link = '' then begin
            if not (ObjectTypeToRun in [ObjectType::Page, ObjectType::Codeunit, ObjectType::Report, ObjectType::XmlPort]) then
                Error(InvalidObjectTypeErr);

            if CheckObjectValidity then
                if not IsObjectToRunValid(ObjectTypeToRun, ObjectIDToRun) then
                    Error(ObjectDoesNotExistErr, ObjectTypeToRun, ObjectIDToRun);
        end;
    end;

    local procedure GetCode(Type: Enum "Guided Experience Type"; ObjectType: Enum "Guided Experience Object Type"; ObjectID: Integer; Link: Text[250]): Code[300]
    begin
        exit(StrSubstNo(CodeFormatLbl, Type, ObjectType, ObjectID, Link));
    end;

    local procedure GetVersion(var GuidedExperienceItem: Record "Guided Experience Item"; Code: Code[300]; Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; ExtensionId: Guid; GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: Enum "Guided Experience Object Type"; ObjectIDToRun: Integer; Link: Text[250]; AssistedSetupGroup: Enum "Assisted Setup Group"; VideoUrl: Text[250]; VideoCategory: Enum "Video Category"; HelpUrl: Text[250]; ManualSetupCategory: Enum "Manual Setup Category"; Keywords: Text[250]): Integer
    begin
        GuidedExperienceItem.SetRange(Code, Code);
        if not GuidedExperienceItem.FindLast() then
            exit(0);

        if HasTheRecordChanged(GuidedExperienceItem, Title, ShortTitle, Description, ExpectedDuration, ExtensionId, GuidedExperienceType, ObjectTypeToRun,
            ObjectIDToRun, Link, AssistedSetupGroup, VideoUrl, VideoCategory, HelpUrl, ManualSetupCategory, Keywords)
        then
            exit(GuidedExperienceItem.Version + 1);

        exit(-1);
    end;

    local procedure HasTheRecordChanged(GuidedExperienceItem: Record "Guided Experience Item"; Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; ExtensionId: Guid; GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: Enum "Guided Experience Object Type"; ObjectIDToRun: Integer; Link: Text[250]; AssistedSetupGroup: Enum "Assisted Setup Group"; VideoUrl: Text[250]; VideoCategory: Enum "Video Category"; HelpUrl: Text[250]; ManualSetupCategory: Enum "Manual Setup Category"; Keywords: Text[250]): Boolean
    var
        Translation: Codeunit Translation;
        TranslatedString: Text;
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
        then
            exit(true);

        if GuidedExperienceItem.Title <> Title then begin
            TranslatedString := Translation.Get(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Title), GlobalLanguage);
            if (TranslatedString <> '') and (TranslatedString <> Title) then
                exit(true);
        end;

        if GuidedExperienceItem."Short Title" <> ShortTitle then begin
            TranslatedString := Translation.Get(GuidedExperienceItem, GuidedExperienceItem.FieldNo("Short Title"), GlobalLanguage);
            if (TranslatedString <> '') and (TranslatedString <> ShortTitle) then
                exit(true);
        end;

        if GuidedExperienceItem.Description <> Description then begin
            TranslatedString := Translation.Get(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Description), GlobalLanguage);
            if (TranslatedString <> '') and (TranslatedString <> Description) then
                exit(true);
        end;

        if GuidedExperienceItem.Keywords <> Keywords then begin
            TranslatedString := Translation.Get(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Keywords), GlobalLanguage);
            if (TranslatedString <> '') and (TranslatedString <> Keywords) then
                exit(true);
        end;

        exit(false);
    end;

    local procedure InsertGuidedExperienceItem(var GuidedExperienceItem: Record "Guided Experience Item"; Code: Code[300]; Version: Integer; Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; ExtensionId: Guid; Completed: Boolean; GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: Enum "Guided Experience Object Type"; ObjectIDToRun: Integer; Link: Text[250]; AssistedSetupGroup: Enum "Assisted Setup Group"; VideoUrl: Text[250]; VideoCategory: Enum "Video Category"; HelpUrl: Text[250]; ManualSetupCategory: Enum "Manual Setup Category"; Keywords: Text[250])
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

        if GetIconInStream(IconInStream, ExtensionId) then
            GuidedExperienceItem.Icon.ImportStream(IconInStream, ExtensionId);

        GuidedExperienceItem.Insert();
    end;

    local procedure InsertTranslations(GuidedExperienceItem: Record "Guided Experience Item"; Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; Keywords: Text[250])
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

        // if this isn't the first version of the record, copy all the existing translations for the title and the 
        // description if they haven't changed
        if GuidedExperienceItem.Version > 0 then begin
            if PrevVersionGuidedExperienceItem.Title = GuidedExperienceItem.Title then
                Translation.Copy(PrevVersionGuidedExperienceItem, GuidedExperienceItem, GuidedExperienceItem.FieldNo(Title));
            if PrevVersionGuidedExperienceItem."Short Title" = GuidedExperienceItem."Short Title" then
                Translation.Copy(PrevVersionGuidedExperienceItem, GuidedExperienceItem, GuidedExperienceItem.FieldNo("Short Title"));
            if PrevVersionGuidedExperienceItem.Description = GuidedExperienceItem.Description then
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

    procedure FilterGuidedExperienceItem(var GuidedExperienceItem: Record "Guided Experience Item"; GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer; Link: Text[250])
    var
        ObjectTypeToRun: Enum "Guided Experience Object Type";
    begin
        GetObjectTypeToRun(ObjectTypeToRun, ObjectType);

        FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType, ObjectTypeToRun, ObjectID, Link);
    end;

    procedure FilterGuidedExperienceItem(var GuidedExperienceItem: Record "Guided Experience Item"; GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: Enum "Guided Experience Object Type"; ObjectID: Integer; Link: Text[250])
    begin
        GuidedExperienceItem.SetCurrentKey("Guided Experience Type", "Object Type to Run", "Object ID to Run", Link, Version);
        GuidedExperienceItem.SetRange("Guided Experience Type", GuidedExperienceType);
        GuidedExperienceItem.SetRange("Object Type to Run", ObjectType);
        GuidedExperienceItem.SetRange("Object ID to Run", ObjectID);
        GuidedExperienceItem.SetRange(Link, Link);
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
        AssistedSetup: Codeunit "Assisted Setup";
        HandledAssistedSetup: Boolean;
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
            AssistedSetup.OnReRunOfCompletedSetup(GuidedExperienceItem."Extension ID", GuidedExperienceItem."Object ID to Run", HandledAssistedSetup);
            if Handled or HandledAssistedSetup then
                exit;
#endif

            if not ConfirmManagement.GetResponse(StrSubstNo(RunSetupAgainQst, GuidedExperienceItem.Title), false) then
                exit;
        end;

        Page.RunModal(GuidedExperienceItem."Object ID to Run");

#if not CLEAN18
        if GuidedExperienceItem."Guided Experience Type" = GuidedExperienceItem."Guided Experience Type"::"Assisted Setup" then
            AssistedSetup.OnAfterRun(GuidedExperienceItem."Extension ID", GuidedExperienceItem."Object ID to Run");
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
    begin
        FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceItem."Guided Experience Type"::"Assisted Setup",
            GuidedExperienceItemToRefresh."Object Type to Run", GuidedExperienceItemToRefresh."Object ID to Run", '');

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

        ChecklistImplementation.Delete(GuidedExperienceItem.Code);

        GuidedExperienceItem.DeleteAll();
    end;

    local procedure InsertGuidedExperienceItemIfValid(var GuidedExperienceItemTemp: Record "Guided Experience Item" temporary; GuidedExperienceItem: Record "Guided Experience Item")
    var
        Translation: Text;
    begin
        if IsObjectToRunValid(GetObjectType(GuidedExperienceItem."Object Type to Run"), GuidedExperienceItem."Object ID to Run") then begin
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
        AssistedSetup: Codeunit "Assisted Setup";
        HandledAssistedSetup: Boolean;
#endif
        RoleBasedSetupExperienceID: Integer;
    begin
        RoleBasedSetupExperienceID := Page::"Assisted Setup";

        GuidedExperience.OnBeforeOpenRoleBasedAssistedSetupExperience(RoleBasedSetupExperienceID, Handled);
#if not CLEAN18
        AssistedSetup.OnBeforeOpenRoleBasedSetupExperience(RoleBasedSetupExperienceID, HandledAssistedSetup);
        if not (HandledAssistedSetup or Handled) then
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
        LogMessageOnDatabaseEvent(Rec, '0000EIN', GuidedExperienceItemDeletedLbl);
    end;
}