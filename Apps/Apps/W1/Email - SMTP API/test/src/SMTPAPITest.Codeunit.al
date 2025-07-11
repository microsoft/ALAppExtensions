// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139771 "SMTP API Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        TestServerTxt: Label 'Something@Url.com';
        TestServerPort: Integer;

    [Test]
    [Scope('OnPrem')]
    procedure TestConnect()
    var
        LibrarySMTPAPI: Codeunit "Library - SMTP API";
        SMTPAPIClientMock: Codeunit "SMTP API Client Mock";
        iSMTPClient: Interface "iSMTP Client";
    begin
        // [SCENARIO] Test connecting to servers

        // [GIVEN] Server, port and client
        Initialize(iSMTPClient);
        LibrarySMTPAPI.SetClient(iSMTPClient);

        // [WHEN] Connect with given server, port and client
        // [THEN] Connected
        LibraryAssert.IsTrue(LibrarySMTPAPI.Connect(TestServerTxt, TestServerPort, true), 'Failed to connect to server');

        // [WHEN] Set mock to fail on connect
        SMTPAPIClientMock.FailOnConnect(true);

        // [THEN] Fails to connect to server
        LibraryAssert.IsFalse(LibrarySMTPAPI.Connect(TestServerTxt, TestServerPort, true), 'Connected to server');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestAuthenticate()
    var
        SMTPAuthentication: Codeunit "SMTP Authentication";
        LibrarySMTPAPI: Codeunit "Library - SMTP API";
        SMTPAPIClientMock: Codeunit "SMTP API Client Mock";
        iSMTPClient: Interface "iSMTP Client";
    begin
        // [SCENARIO] Test authentication to servers

        // [GIVEN] Connection info and client 
        Initialize(iSMTPClient);
        LibrarySMTPAPI.SetClient(iSMTPClient);

        // [WHEN] Connect to server and try to authenticate
        // [THEN] Authenticate successfully
        LibraryAssert.IsTrue(LibrarySMTPAPI.Connect(TestServerTxt, TestServerPort, true), 'Failed to connect to server');
        LibraryAssert.IsTrue(LibrarySMTPAPI.Authenticate("SMTP Authentication Types"::Basic, SMTPAuthentication), 'Failed to authenticate');

        // [WHEN] Set mock to fail on authentication
        SMTPAPIClientMock.FailOnAuthenticate(true);

        // [THEN] Fail to authenticate
        LibraryAssert.IsFalse(LibrarySMTPAPI.Authenticate("SMTP Authentication Types"::Basic, SMTPAuthentication), 'Authenticated');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSend()
    var
        SMTPAuthentication: Codeunit "SMTP Authentication";
        LibrarySMTPAPI: Codeunit "Library - SMTP API";
        SMTPAPIClientMock: Codeunit "SMTP API Client Mock";
        SMTPMessage: Codeunit "SMTP Message";
        iSMTPClient: Interface "iSMTP Client";
    begin
        // [SCENARIO] Send email

        // [GIVEN] Connection info and client
        Initialize(iSMTPClient);
        LibrarySMTPAPI.SetClient(iSMTPClient);

        // [WHEN] Connect to server, authenticate and try to send email
        // [THEN] Successfully send email
        LibraryAssert.IsTrue(LibrarySMTPAPI.Connect(TestServerTxt, TestServerPort, true), 'Failed to connect to server');
        LibraryAssert.IsTrue(LibrarySMTPAPI.Authenticate("SMTP Authentication Types"::Basic, SMTPAuthentication), 'Failed to authenticate');
        LibraryAssert.IsTrue(LibrarySMTPAPI.Send(SMTPMessage), 'Message failed to send');

        // [WHEN] Set mock to fail on sending of email
        SMTPAPIClientMock.FailOnSendMessage(true);

        // [THEN] Fails to send email
        LibraryAssert.IsFalse(LibrarySMTPAPI.Send(SMTPMessage), 'Message sent');
    end;

    local procedure Initialize(var iSMTPClient: Interface "iSMTP Client")
    var
        SMTPAPIClientMock: Codeunit "SMTP API Client Mock";
    begin
        TestServerPort := 255;
        SMTPAPIClientMock.Initialize(iSMTPClient);
    end;

}