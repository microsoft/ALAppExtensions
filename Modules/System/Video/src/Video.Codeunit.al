// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary> Lists and enables playing of available videos.</summary>
codeunit 3710 Video
{
    Access = Public;

    /// <summary> Use a link to display a video in a new page. </summary>
    /// <param name="Url"> The link to the video.</param>
    procedure Play(Url: Text)
    begin
        VideoImpl.Play(Url);
    end;

    /// <summary> Adds a link to a video to the Product Videos page. 
    /// </summary>
    /// <param name="AppID"> The ID of the extension that registers this video.</param>
    /// <param name="Title"> The title of the video.</param>
    /// <param name="VideoUrl"> The link to the video.</param>
    procedure Register(AppID: Guid; Title: Text[250]; VideoUrl: Text[2048])
    var
        EmptyGuid: Guid;
    begin
        VideoImpl.InsertIntoBuffer(TempProductVideoBuffer, AppID, Title, VideoUrl, 0, EmptyGuid);
    end;

    /// <summary> Adds a link to a video to the Product Videos page. 
    /// </summary>
    /// <param name="AppID"> The ID of the extension that registers this video.</param>
    /// <param name="Title"> The title of the video.</param>
    /// <param name="VideoUrl"> The link to the video.</param>
    /// <param name="TableNum"> The table number of the record that is the source of this video. This is 
    /// <param name="SystemId"> The system id of the record related to this video. This is 
    /// used to raise the OnVideoPlayed event with that record once the video is 
    /// played.</param>
    procedure Register(AppID: Guid; Title: Text[250]; VideoUrl: Text[2048]; TableNum: Integer; SystemId: Guid)
    begin
        VideoImpl.InsertIntoBuffer(TempProductVideoBuffer, AppID, Title, VideoUrl, TableNum, SystemId);
    end;

    /// <summary> Gets the data for the video list that displays the content on the Product Videos page. </summary>
    /// <param name="TemporaryProductVideoBuffer"> The new record to which the data is 
    /// copied.</param>
    internal procedure GetTemporaryRecord(var TemporaryProductVideoBuffer: Record "Product Video Buffer" temporary)
    begin
        TemporaryProductVideoBuffer.Copy(TempProductVideoBuffer, true);
    end;

    /// <summary> Notifies the subscribers that they can add links to videos to the Product Videos page.</summary>
    [IntegrationEvent(true, false)]
    internal procedure OnRegisterVideo()
    begin
    end;

    /// <summary> Notifies the subscribers that they can act on the source record when a related video is played.</summary>
    /// <param name = "TableNum">The table number of the source record.</param>
    /// <param name = "SystemID">The surrogate key of the source record.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnVideoPlayed(TableNum: Integer; SystemID: Guid)
    begin
    end;

    var
        TempProductVideoBuffer: Record "Product Video Buffer" temporary;
        VideoImpl: Codeunit "Video Impl.";
}