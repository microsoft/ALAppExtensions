// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1877 "Manual Setup Impl."
{
    Access = Internal;

    local procedure InsertBase(var ManualSetup: Record "Manual Setup"; Name: Text[50]; ExtensionId: GUID; Description: Text[250]; Keywords: Text[250]; RunPage: Integer)
    begin
        ManualSetup.Init();
        ManualSetup.Name := Name;
        ManualSetup."App ID" := ExtensionId;
        ManualSetup.Description := Description;
        ManualSetup.Keywords := Keywords;
        ManualSetup."Setup Page ID" := RunPage;
        ManualSetup.Insert(true);
    end;

    procedure Insert(var ManualSetup: Record "Manual Setup"; Name: Text[50]; Description: Text[250]; Keywords: Text[250]; RunPage: Integer; IconName: Text[50])
    var
        EmptyGuid: Guid;
    begin
        if ManualSetup.Get(Name) then
            exit;

        InsertBase(ManualSetup, Name, EmptyGuid, Description, Keywords, RunPage);

        SetIconOnRecord(ManualSetup, IconName);
    end;

    procedure Insert(var ManualSetup: Record "Manual Setup"; Name: Text[50]; Description: Text[250]; Keywords: Text[250]; RunPage: Integer; ExtensionId: Guid)
    begin
        if ManualSetup.Get(Name) then
            exit;

        InsertBase(ManualSetup, Name, ExtensionId, Description, Keywords, RunPage);

        AddExtensionIcon(ManualSetup, ExtensionId);
    end;

    local procedure AddExtensionIcon(var ManualSetup: Record "Manual Setup"; ExtensionId: Guid);
    var
        BusinessSetupIcon: Record "Business Setup Icon";
        ExtensionManagement: Codeunit "Extension Management";
        LogoBlob: Codeunit "Temp Blob";
        IconInStream: InStream;
    begin
        if not BusinessSetupIcon.Get(ManualSetup.Name) then begin
            ExtensionManagement.GetExtensionLogo(ExtensionId, LogoBlob);

            if not LogoBlob.HasValue() then
                exit;

            LogoBlob.CreateInStream(IconInStream);

            BusinessSetupIcon.Init();
            BusinessSetupIcon."Business Setup Name" := ManualSetup.Name;
            BusinessSetupIcon.Icon.ImportStream(IconInStream, ManualSetup.Name);
            BusinessSetupIcon.Insert(true);
        end;

        ManualSetup.Icon := BusinessSetupIcon.Icon;
        if ManualSetup.Modify(true) then;
    end;

    local procedure SetIconOnRecord(var ManualSetup: Record "Manual Setup"; IconName: Text[50])
    VAR
        MediaResources: Record "Media Resources";
        BusinessSetupIcon: Record "Business Setup Icon";
    begin
        if not BusinessSetupIcon.Get(IconName) then
            exit;

        if BusinessSetupIcon.Icon.HasValue() then begin
            ManualSetup.Icon := BusinessSetupIcon.Icon;
            ManualSetup.Modify(true);
        end else
            if MediaResources.Get(BusinessSetupIcon."Media Resources Ref") then begin
                ManualSetup.Icon := MediaResources."Media Reference";
                ManualSetup.Modify(true);
            end;
    end;

    procedure ClearAllIcons()
    var
        BusinessSetupIcon: Record "Business Setup Icon";
    begin
        BusinessSetupIcon.DeleteAll();
    end;

    procedure AddIcon(Name: Text[50]; MediaRef: Code[50])
    var
        BusinessSetupIcon: Record "Business Setup Icon";
    begin
        BusinessSetupIcon.Init();
        BusinessSetupIcon."Business Setup Name" := Name;
        BusinessSetupIcon."Media Resources Ref" := MediaRef;
        BusinessSetupIcon.Insert(true);
    end;
}