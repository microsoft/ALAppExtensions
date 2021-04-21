// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135070 "Uri Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        Uri: Codeunit Uri;

    [Test]
    [Scope('OnPrem')]
    procedure InitInvalidURITest()
    begin
        asserterror Uri.Init('this is not a valid URI');

        Assert.ExpectedError('A call to System.Uri failed with this message: Invalid URI');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EscapeAndUnescapeDataStringTest()
    var
        UnescapedUrl: Text;
        EscapedUrl: Text;
    begin
        // [Given] A Url
        UnescapedUrl := 'http://<some%url.com>';
        EscapedUrl := 'http%3A%2F%2F%3Csome%25url.com%3E';

        // [When] EscapeDataString is called on that url
        // [Then] The url is escaped
        Assert.AreEqual(EscapedUrl, Uri.EscapeDataString(UnescapedUrl), 'EscapeDataString does not work as expected');
        Assert.AreEqual(UnescapedUrl, Uri.UnescapeDataString(EscapedUrl), 'UnescapeDataString does not work as expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetSchemeTest()
    begin
        // [Given] A Url
        Uri.Init('http://microsoft.com');

        // [Then] The scheme should be 'http'
        Assert.AreEqual('http', Uri.GetScheme(), 'GetScheme does not work as expected');

        Uri.Init('https://microsoft.com');
        Assert.AreEqual('https', Uri.GetScheme(), 'GetScheme does not work as expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetHostTest()
    begin
        // [Given] A Url
        Uri.Init('http://microsoft.com/test');

        // [Then] The host should be 'microsoft.com'
        Assert.AreEqual('microsoft.com', Uri.GetHost(), 'GetHost does not work as expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetPortTest()
    begin
        // [Given] A Url
        Uri.Init('http://microsoft.com:3000/test');

        // [Then] The port should be 3000
        Assert.AreEqual(3000, Uri.GetPort(), 'GetPort does not work as expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetAbsolutePathTest()
    begin
        // [Given] A Url
        Uri.Init('http://microsoft.com/segment2/segment3/?randomquery#main');

        // [Then] The absolute path should be '/segment2/segment3/'
        Assert.AreEqual('/segment2/segment3/', Uri.GetAbsolutePath(), 'GetAbsolutePath does not work as expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetQuery()
    begin
        // [Given] A Url
        Uri.Init('http://microsoft.com/segment2/segment3/?randomquery#main');

        // [Then] The query should be '?randomquery'
        Assert.AreEqual('?randomquery', Uri.GetQuery(), 'GetQuery does not work as expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetFragment()
    begin
        // [Given] A Url
        Uri.Init('http://microsoft.com/segment2/segment3/?randomquery#main');

        // [Then] The fragment should be '#main'
        Assert.AreEqual('#main', Uri.GetFragment(), 'GetFragment does not work as expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetAbsoluteURITest()
    var
        UriBuilder: Codeunit "Uri Builder";
        QueryText: Text;
        QueryTemplateLbl: Label '%1=%2', Locked = true;
    begin
        // [Given] A randomly generated simple query and a base URI
        QueryText := StrSubstNo(QueryTemplateLbl, Any.AlphanumericText(10), Any.AlphanumericText(10));
        UriBuilder.Init('http://microsoft.com');

        // [Then] The abosulute URI is as expected
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('http://microsoft.com/', Uri.GetAbsoluteUri(), 'Wrong absolute URI without query');

        // [When] Setting the query
        UriBuilder.SetQuery(QueryText);
        UriBuilder.GetUri(Uri);

        // [Then] The absolute URI is as expected
        Assert.AreEqual('http://microsoft.com/?' + QueryText, Uri.GetAbsoluteUri(), 'Wrong absolute URI with query');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetSegmentsSingleElementTest()
    var
        Segments: List of [Text];
        Segment: Text;
    begin
        // [Given] A Url with no segments
        Uri.Init('http://microsoft.com');

        // [When] gettng the segments
        Uri.GetSegments(Segments);

        // [Then] The segments contain a single element
        Assert.IsTrue(Segments.Get(1, Segment), 'The segments should contain an element');
        Assert.AreEqual('/', Segment, 'Wrong segment');
        Assert.IsFalse(Segments.Get(2, Segment), 'The segments should contain only one element');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetMultipleSegmentsTest()
    var
        Segments: List of [Text];
        Segment: Text;
    begin
        // [Given] A Url with no segments
        Uri.Init('http://microsoft.com/segment2/segment3/?randomquery');

        // [When] gettng the segments
        Uri.GetSegments(Segments);

        // [Then] The segments contain all the URI's segmetns
        Assert.IsTrue(Segments.Get(1, Segment), 'The segments should contain a first element');
        Assert.AreEqual('/', Segment, 'Wrong first segment');


        Assert.IsTrue(Segments.Get(2, Segment), 'The segments should contain a second element');
        Assert.AreEqual('segment2/', Segment, 'Wrong second segment');

        Assert.IsTrue(Segments.Get(3, Segment), 'The segments should contain a thrird element');
        Assert.AreEqual('segment3/', Segment, 'Wrong third segment');
    end;

}