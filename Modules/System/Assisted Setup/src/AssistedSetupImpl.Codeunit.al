//------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1813 "Assisted Setup Impl."
{
    Access = Internal;

    var
        RunSetupAgainQst: Label 'You have already completed the %1 assisted setup guide. Do you want to run it again?', Comment = '%1 = Assisted Setup Name';

    procedure Add(ExtensionId: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group"; VideoLink: Text[250]; VideoCategory: Enum "Video Category"; HelpLink: Text[250])
    var
        AssistedSetup: Record "Assisted Setup";
        Translation: Codeunit Translation;
        Video: Codeunit Video;
        ExtensionManagement: Codeunit "Extension Management";
        LogoBlob: Codeunit "Temp Blob";
        IconInStream: InStream;
    begin
        if not AssistedSetup.WritePermission() then
            exit;
        if not AssistedSetup.Get(PageID) then begin
            AssistedSetup.Init();
            AssistedSetup."Page ID" := PageID;
            AssistedSetup."App ID" := ExtensionId;
            AssistedSetup.Insert(true);
        end;

        if (AssistedSetup."Page ID" <> PageID) or
        (Translation.Get(AssistedSetup, AssistedSetup.FieldNo(Name)) <> AssistantName) or
        (AssistedSetup."Group Name" <> GroupName) or
        (AssistedSetup."Video Url" <> VideoLink) or
        (AssistedSetup."Video Category" <> VideoCategory) or
        (AssistedSetup."Help Url" <> HelpLink)
        then begin
            AssistedSetup."Page ID" := PageID;
            AssistedSetup.Name := CopyStr(AssistantName, 1, 2048);
            AssistedSetup."Group Name" := GroupName;
            AssistedSetup."Video Url" := VideoLink;
            AssistedSetup."Video Category" := VideoCategory;
            AssistedSetup."Help Url" := HelpLink;
            AssistedSetup.Modify(true);
        end;

        Translation.Set(AssistedSetup, AssistedSetup.FieldNo(Name), CopyStr(AssistantName, 1, 2048));

        if AssistedSetup."Video Url" <> VideoLink then
            Video.Register(AssistedSetup."App ID", CopyStr(AssistedSetup.Name, 1, 250), VideoLink, VideoCategory, Database::"Assisted Setup", AssistedSetup.SystemId);

        ExtensionManagement.GetExtensionLogo(ExtensionId, LogoBlob);
        if not LogoBlob.HasValue() then
            exit;
        LogoBlob.CreateInStream(IconInStream);
        AssistedSetup.Icon.ImportStream(IconInStream, AssistedSetup.Name);
        AssistedSetup.Modify(true);
    end;

    procedure AddSetupAssistantTranslation(ExtensionId: Guid; PageID: Integer; LanguageID: Integer; TranslatedName: Text)
    var
        AssistedSetup: Record "Assisted Setup";
        Translation: Codeunit Translation;
    begin
        if not AssistedSetup.Get(PageID) then
            exit;
        if LanguageID <> GlobalLanguage() THEN
            Translation.Set(AssistedSetup, AssistedSetup.FIELDNO(Name), LanguageID, CopyStr(TranslatedName, 1, 2048));
    end;

    procedure IsComplete(ExtensionID: Guid; PageID: Integer): Boolean
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        if not AssistedSetup.ReadPermission() then
            exit(false);
        if AssistedSetup.Get(PageID) then
            exit(AssistedSetup.Completed);
    end;

    procedure Exists(ExtensionID: Guid; PageID: Integer): Boolean
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        if not AssistedSetup.ReadPermission() then
            exit(false);
        exit(AssistedSetup.Get(PageID));
    end;

    procedure Complete(ExtensionId: Guid; PageID: Integer)
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        if not AssistedSetup.WritePermission() then
            exit;
        if not AssistedSetup.Get(PageID) then
            exit;
        AssistedSetup.Validate(Completed, true);
        AssistedSetup.Modify(true);
    end;

    procedure Reset(PageID: Integer)
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        if not AssistedSetup.WritePermission() then
            exit;
        if not AssistedSetup.Get(PageID) then
            exit;
        AssistedSetup.Validate(Completed, false);
        AssistedSetup.Modify(true);
    end;

    procedure ExistsAndIsNotComplete(ExtensionID: Guid; PageID: Integer): Boolean
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        if not AssistedSetup.ReadPermission() then
            exit(false);
        if not AssistedSetup.Get(PageID) then
            exit(false);
        exit(not AssistedSetup.Completed);
    end;

    procedure Run(ExtensionID: Guid; PageID: Integer)
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        if not AssistedSetup.ReadPermission() then
            exit;
        if not AssistedSetup.Get(PageID) then
            exit;
        Run(AssistedSetup);
    end;

    procedure Run(var AssistedSetup: Record "Assisted Setup")
    var
        AssistedSetupApi: Codeunit "Assisted Setup";
        Handled: Boolean;
    begin
        if AssistedSetup.Completed then begin
            AssistedSetupApi.OnReRunOfCompletedSetup(AssistedSetup."App ID", AssistedSetup."Page ID", Handled);
            if Handled then
                exit;
            if not Confirm(RunSetupAgainQst, false, AssistedSetup.Name) then
                exit;
        end;

        Page.RunModal(AssistedSetup."Page ID");
        AssistedSetupApi.OnAfterRun(AssistedSetup."App ID", AssistedSetup."Page ID");
    end;

    procedure RunAndRefreshRecord(var TempAssistedSetup: Record "Assisted Setup" temporary)
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        Run(TempAssistedSetup);
        AssistedSetup.Get(TempAssistedSetup."Page ID");
        TempAssistedSetup := AssistedSetup;
        TempAssistedSetup.Modify();
    end;

    procedure NavigateHelpPage(AssistedSetup: Record "Assisted Setup")
    begin
        if AssistedSetup."Help Url" = '' then
            exit;

        HyperLink(AssistedSetup."Help Url");
    end;

    procedure RefreshBuffer(var TempAssistedSetup: Record "Assisted Setup" temporary)
    var
        i: Integer;
        LastGroupId: Integer;
    begin
        TempAssistedSetup.DeleteAll();
        LastGroupId := -1;
        foreach i in "Assisted Setup Group".Ordinals() do
            AddRecordsForGroup("Assisted Setup Group".FromInteger(i), LastGroupId, TempAssistedSetup);
    end;

    local procedure AddRecordsForGroup(AssistedSetupGroup: Enum "Assisted Setup Group"; var LastGroupId: Integer; var AssistedSetupToPopulate: Record "Assisted Setup")
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        AssistedSetup.SetRange("Group Name", AssistedSetupGroup);
        if AssistedSetup.FindSet() then begin
            AssistedSetupToPopulate.Init();
            AssistedSetupToPopulate."Page ID" := LastGroupId;
            LastGroupId := LastGroupId - 1;
            AssistedSetupToPopulate.Name := Format(AssistedSetupGroup);
            AssistedSetupToPopulate."Group Name" := AssistedSetupGroup;
            AssistedSetupToPopulate.Insert();

            repeat
                AssistedSetupToPopulate := AssistedSetup;
                AssistedSetupToPopulate.Insert();
            until AssistedSetup.Next() = 0;
        end;
    end;

    procedure IsSetupRecord(AssistedSetup: Record "Assisted Setup"): Boolean
    begin
        exit(AssistedSetup."Page ID" > 0);
    end;

    procedure GetTranslatedName(PageID: Integer): Text
    var
        AssistedSetupPersistedRecord: Record "Assisted Setup";
        Translation: Codeunit Translation;
    begin
        AssistedSetupPersistedRecord.Get(PageID);
        exit(Translation.Get(AssistedSetupPersistedRecord, AssistedSetupPersistedRecord.FieldNo(Name)));
    end;

    procedure Open()
    begin
        Page.RunModal(Page::"Assisted Setup");
    end;

    procedure Open(AssistedSetupGroup: Enum "Assisted Setup Group")
    var
        AssistedSetup: Page "Assisted Setup";
    begin
        AssistedSetup.SetGroupToDisplay(AssistedSetupGroup);
        AssistedSetup.RunModal();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Video, 'OnVideoPlayed', '', false, false)]
    local procedure OnVideoPlayed(TableNum: Integer; SystemID: Guid)
    var
        AssistedSetup: Record "Assisted Setup";
        ConstAssistedSetupLog: Record "Assisted Setup Log";
    begin
        if TableNum <> Database::"Assisted Setup" then
            exit;

        AssistedSetup.SetRange(SystemId, SystemID);
        if not AssistedSetup.FindFirst() then
            exit;

        ConstAssistedSetupLog."Date Time" := CurrentDateTime();
        ConstAssistedSetupLog."Entery No." := AssistedSetup."Page ID";
        ConstAssistedSetupLog.Insert(true);
        Commit();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Video, 'OnRegisterVideo', '', false, false)]
    local procedure OnRegisterVideo(sender: Codeunit Video)
    var
        AssistedSetup: Record "Assisted Setup";
        AssistedSetupApi: Codeunit "Assisted Setup";
    begin
        AssistedSetupApi.OnRegister();
        AssistedSetup.SetFilter("Video Url", '<>%1', '');
        if AssistedSetup.FindSet() then
            repeat
                sender.Register(AssistedSetup."App ID", CopyStr(AssistedSetup.Name, 1, 250), AssistedSetup."Video Url", AssistedSetup."Video Category", Database::"Assisted Setup", AssistedSetup.SystemId);
            until AssistedSetup.Next() = 0;
    end;
}

