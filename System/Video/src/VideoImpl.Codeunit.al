// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3709 "Video Impl."
{
    Access = Internal;

    procedure InsertIntoBuffer(var ProductVideoBuffer: Record "Product Video Buffer"; AppID: Guid; Title: Text[250]; VideoUrl: Text[2048]; TableNum: Integer; SystemId: Guid; Category: Enum "Video Category")
    var
        ProductVideoBuff: Record "Product Video Buffer";
        EntryNo: Integer;
    begin
        if VideoUrl = '' then
            exit;

        ProductVideoBuff.SetRange("Video Url", VideoUrl);
        if not ProductVideoBuff.IsEmpty() then
            exit;

        ProductVideoBuff.Reset();
        if ProductVideoBuffer.FindLast() then
            EntryNo := ProductVideoBuffer.ID;
        EntryNo += 1;
        ProductVideoBuffer.Init();
        ProductVideoBuffer.ID := EntryNo;
        ProductVideoBuffer.Title := Title;
        ProductVideoBuffer."Video Url" := VideoUrl;
        ProductVideoBuffer."Table Num" := TableNum;
        ProductVideoBuffer."System ID" := SystemId;
        ProductVideoBuffer."App ID" := AppID;
        ProductVideoBuffer.Category := Category;
        ProductVideoBuffer.Insert();
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