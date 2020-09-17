// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1877 "Manual Setup Impl."
{
    Access = Internal;

    local procedure InsertBase(var ManualSetup: Record "Manual Setup"; Name: Text[50]; ExtensionId: Guid; Description: Text[250]; Keywords: Text[250]; RunPage: Integer; Category: Enum "Manual Setup Category")
    begin
        ManualSetup.Init();
        ManualSetup.Name := Name;
        ManualSetup."App ID" := ExtensionId;
        ManualSetup.Description := Description;
        ManualSetup.Keywords := Keywords;
        ManualSetup."Setup Page ID" := RunPage;
        ManualSetup.Category := Category;
        ManualSetup.Insert(true);
    end;

    procedure Insert(var ManualSetup: Record "Manual Setup"; Name: Text[50]; Description: Text[250]; Keywords: Text[250]; RunPage: Integer; ExtensionId: Guid; Category: Enum "Manual Setup Category")
    begin
        if ManualSetup.Get(Name) then
            exit;

        InsertBase(ManualSetup, Name, ExtensionId, Description, Keywords, RunPage, Category);

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

    procedure Open()
    begin
        Page.RunModal(Page::"Manual Setup");
    end;

    procedure Open(ManualSetupCategory: Enum "Manual Setup Category")
    var
        ManualSetup: Page "Manual Setup";
    begin
        ManualSetup.SetCategoryToDisplay(ManualSetupCategory);
        ManualSetup.RunModal();
    end;

    procedure GetPageIDs(var PageIDs: List of [Integer])
    var
        TemporaryManualSetup: Record "Manual Setup" temporary;
        ManualSetupApi: Codeunit "Manual Setup";
    begin
        Clear(PageIDs);
        ManualSetupApi.OnRegisterManualSetup();
        ManualSetupApi.GetTemporaryRecord(TemporaryManualSetup);
        if TemporaryManualSetup.FindSet() then
            repeat
                PageIDs.Add(TemporaryManualSetup."Setup Page ID");
            until TemporaryManualSetup.Next() = 0;
    end;

}