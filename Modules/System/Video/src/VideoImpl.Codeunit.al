// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3709 "Video Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure InsertIntoBuffer(var ProductVideoBufferRec: Record "Product Video Buffer"; AppID: Guid; Title: Text[250]; VideoUrl: Text[2048]; TableNum: Integer; SystemId: Guid; Category: Enum "Video Category")
    var
        ProductVideoBuffer: Record "Product Video Buffer";
        EntryNo: Integer;
    begin
        if VideoUrl = '' then
            exit;

        ProductVideoBuffer.SetRange("Video Url", VideoUrl);
        if not ProductVideoBuffer.IsEmpty() then
            exit;

        ProductVideoBuffer.Reset();
        if ProductVideoBufferRec.FindLast() then
            EntryNo := ProductVideoBufferRec.ID;
        EntryNo += 1;
        ProductVideoBufferRec.Init();
        ProductVideoBufferRec.ID := EntryNo;
        ProductVideoBufferRec.Title := Title;
        ProductVideoBufferRec."Video Url" := VideoUrl;
        ProductVideoBufferRec."Table Num" := TableNum;
        ProductVideoBufferRec."System ID" := SystemId;
        ProductVideoBufferRec."App ID" := AppID;
        ProductVideoBufferRec.Category := Category;
        ProductVideoBufferRec.Insert();
    end;

    procedure Play(Url: Text)
    var
        VideoLink: Page "Video Link";
    begin
        VideoLink.SetURL(Url);
        VideoLink.RunModal();
    end;

    procedure Show(Category: Enum "Video Category")
    var
        ProductVideos: Page "Product Videos";
    begin
        ProductVideos.SetSpecificCategory(Category);
        ProductVideos.Run();
    end;

}