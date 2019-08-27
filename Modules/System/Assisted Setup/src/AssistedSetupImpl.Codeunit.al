//------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1813 "Assisted Setup Impl."
{
    Access = Internal;

    procedure Add(ExtensionId: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group"; VideoLink: Text[250]; HelpLink: Text[250])
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
        if not AssistedSetup.Get(ExtensionId, PageID) then begin
            AssistedSetup.Init();
            AssistedSetup."Page ID" := PageID;
            AssistedSetup."App ID" := ExtensionId;
            AssistedSetup.Insert(true);
        end;

        if (AssistedSetup."Page ID" <> PageID) or
        (Translation.Get(AssistedSetup, AssistedSetup.FieldNo(Name)) <> AssistantName) or
        (AssistedSetup."Group Name" <> GroupName) or
        (AssistedSetup."Video Url" <> VideoLink) or
        (AssistedSetup."Help Url" <> HelpLink)
        then begin
            AssistedSetup."Page ID" := PageID;
            AssistedSetup.Name := CopyStr(AssistantName, 1, 2048);
            AssistedSetup."Group Name" := GroupName;
            AssistedSetup."Video Url" := VideoLink;
            AssistedSetup."Help Url" := HelpLink;
            AssistedSetup.Modify(true);
        end;

        Translation.Set(AssistedSetup, AssistedSetup.FieldNo(Name), AssistantName);

        if AssistedSetup."Video Url" <> VideoLink then
            Video.Register(AssistedSetup."App ID", AssistedSetup.Name, VideoLink, Database::"Assisted Setup", AssistedSetup.SystemId);

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
        if not AssistedSetup.Get(ExtensionId, PageID) then
            exit;
        if LanguageID <> GlobalLanguage() THEN
            Translation.Set(AssistedSetup, AssistedSetup.FIELDNO(Name), LanguageID, TranslatedName);
    end;

    procedure IsComplete(ExtensionId: Guid; PageID: Integer): Boolean
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        if not AssistedSetup.ReadPermission() then
            exit(false);
        if AssistedSetup.Get(ExtensionId, PageID) then
            exit(AssistedSetup.Completed);
    end;

    procedure Exists(ExtensionId: Guid; PageID: Integer): Boolean
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        if not AssistedSetup.ReadPermission() then
            exit(false);
        exit(AssistedSetup.Get(ExtensionId, PageID));
    end;

    procedure Complete(ExtensionId: Guid; PageID: Integer)
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        if not AssistedSetup.WritePermission() then
            exit;
        if not AssistedSetup.Get(ExtensionId, PageID) then
            exit;
        AssistedSetup.Validate(Completed, true);
        AssistedSetup.Modify(true);
    end;

    procedure Run(ExtensionId: Guid; PageID: Integer)
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        if not AssistedSetup.ReadPermission() then
            exit;
        if not AssistedSetup.Get(ExtensionId, PageID) then
            exit;
        AssistedSetup.Run();
    end;

    procedure DeleteAll()
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        AssistedSetup.DeleteAll();
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
                sender.Register(AssistedSetup."App ID", AssistedSetup.Name, AssistedSetup."Video Url", Database::"Assisted Setup", AssistedSetup.SystemId);
            until AssistedSetup.Next() = 0;
    end;
}

