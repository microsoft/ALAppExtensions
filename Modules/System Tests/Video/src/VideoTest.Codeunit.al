// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135038 "Video Test"
{
    Subtype = Test;
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        UrlTxt: Label 'https://www.youtube.com/watch?v=CH1XGdu-hzQ';
        SourceVideoTableNum: Integer;
        SourceVideoSystemID: Guid;
        HandleOnVideoPlayedSuccess: Boolean;

    [Test]
    [HandlerFunctions('HandleVideoLink')]
    procedure VideoPlay()
    var
        Video: Codeunit Video;
    begin
        // [SCENARIO] Calling play on a link opens the player
        PermissionsMock.Set('Video Read');

        // [GIVEN, WHEN] A link is passed to Play
        Video.Play(UrlTxt);

        // [THEN] Video Link page opens, captured in the handler
    end;

    [Test]
    [HandlerFunctions('HandleVideoLink')]
    procedure RegisterVideoTest()
    var
        VideoTest: Codeunit "Video Test";
        ProductVideo: TestPage "Product Videos";
    begin
        // [SCENARIO] Registering a video shows it up on the list
        // [GIVEN] Bind the subscriber which registers
        BindSubscription(VideoTest);

        // [WHEN] Open the page
        ProductVideo.OpenView();

        // [THEN] My Video is present in the list
        ProductVideo.Filter.SetFilter(Title, 'My Video');
        Assert.IsTrue(ProductVideo.First(), 'My Video not found.');

        // [WHEN] Drill down on the Title plays the video and raises the event
        HandleOnVideoPlayedSuccess := false;
        ProductVideo.Title.DrillDown();

        // [THEN] The right video source was raised on the event
        Assert.IsTrue(HandleOnVideoPlayedSuccess, 'Video for the right source was not played.');

        UnbindSubscription(VideoTest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Video, 'OnRegisterVideo', '', false, false)]
    local procedure HandleOnRegisterManualSetup(var Sender: Codeunit Video)
    var
        MyVideoSource: Record "My Video Source";
        EmptyGuid: Guid;
    begin
        MyVideoSource.DeleteAll();
        MyVideoSource.Init();
        MyVideoSource.PrimaryKey := 1;
        MyVideoSource.Insert();
        SourceVideoTableNum := Database::"My Video Source";
        SourceVideoSystemID := MyVideoSource.SystemId;
        Sender.Register(EmptyGuid, 'My Video', UrlTxt, "Video Category"::Uncategorized, SourceVideoTableNum, SourceVideoSystemID);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Video, 'OnVideoPlayed', '', false, false)]
    local procedure HandleOnVideoPlayed(TableNum: Integer; SystemID: Guid)
    begin
        Assert.AreEqual(SourceVideoTableNum, TableNum, 'Table num for the played video does not match.');
        Assert.AreEqual(SourceVideoSystemID, SystemID, 'System ID for the played video does not match.');
        HandleOnVideoPlayedSuccess := true;
    end;

    [ModalPageHandler]
    procedure HandleVideoLink(var VideoLink: TestPage "Video link")
    begin
        Assert.AreEqual(GetLastErrorText(), '', 'No error should occur when opening the video link page');
    end;
}