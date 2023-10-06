// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Utilities;

using System.Utilities;
using System.TestLibraries.Utilities;

codeunit 135070 "Uri Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    [Scope('OnPrem')]
    procedure InitInvalidURITest()
    var
        Uri: Codeunit Uri;
    begin
        asserterror Uri.Init('this is not a valid URI');

        LibraryAssert.ExpectedError('A call to System.Uri failed with this message: Invalid URI');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EscapeAndUnescapeDataStringTest()
    var
        Uri: Codeunit Uri;
        EscapedUrl: Text;
        UnescapedUrl: Text;
    begin
        // [Given] A Url
        UnescapedUrl := 'http://<some%url.com>';
        EscapedUrl := 'http%3A%2F%2F%3Csome%25url.com%3E';

        // [When] EscapeDataString is called on that url
        // [Then] The url is escaped
        LibraryAssert.AreEqual(EscapedUrl, Uri.EscapeDataString(UnescapedUrl), 'EscapeDataString does not work as expected');
        LibraryAssert.AreEqual(UnescapedUrl, Uri.UnescapeDataString(EscapedUrl), 'UnescapeDataString does not work as expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetSchemeTest()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        Uri.Init('http://microsoft.com');

        // [Then] The scheme should be 'http'
        LibraryAssert.AreEqual('http', Uri.GetScheme(), 'GetScheme does not work as expected');

        Uri.Init('https://microsoft.com');
        LibraryAssert.AreEqual('https', Uri.GetScheme(), 'GetScheme does not work as expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetHostTest()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        Uri.Init('http://microsoft.com/test');

        // [Then] The host should be 'microsoft.com'
        LibraryAssert.AreEqual('microsoft.com', Uri.GetHost(), 'GetHost does not work as expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetPortTest()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        Uri.Init('http://microsoft.com:3000/test');

        // [Then] The port should be 3000
        LibraryAssert.AreEqual(3000, Uri.GetPort(), 'GetPort does not work as expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetAbsolutePathTest()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        Uri.Init('http://microsoft.com/segment2/segment3/?randomquery#main');

        // [Then] The absolute path should be '/segment2/segment3/'
        LibraryAssert.AreEqual('/segment2/segment3/', Uri.GetAbsolutePath(), 'GetAbsolutePath does not work as expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetQuery()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        Uri.Init('http://microsoft.com/segment2/segment3/?randomquery#main');

        // [Then] The query should be '?randomquery'
        LibraryAssert.AreEqual('?randomquery', Uri.GetQuery(), 'GetQuery does not work as expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetFragment()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        Uri.Init('http://microsoft.com/segment2/segment3/?randomquery#main');

        // [Then] The fragment should be '#main'
        LibraryAssert.AreEqual('#main', Uri.GetFragment(), 'GetFragment does not work as expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetAbsoluteURITest()
    var
        Uri: Codeunit Uri;
        UriBuilder: Codeunit "Uri Builder";
        QueryTemplateLbl: Label '%1=%2', Locked = true;
        QueryText: Text;
    begin
        // [Given] A randomly generated simple query and a base URI
        QueryText := StrSubstNo(QueryTemplateLbl, Any.AlphanumericText(10), Any.AlphanumericText(10));
        UriBuilder.Init('http://microsoft.com');

        // [Then] The abosulute URI is as expected
        UriBuilder.GetUri(Uri);
        LibraryAssert.AreEqual('http://microsoft.com/', Uri.GetAbsoluteUri(), 'Wrong absolute URI without query');

        // [When] Setting the query
        UriBuilder.SetQuery(QueryText);
        UriBuilder.GetUri(Uri);

        // [Then] The absolute URI is as expected
        LibraryAssert.AreEqual('http://microsoft.com/?' + QueryText, Uri.GetAbsoluteUri(), 'Wrong absolute URI with query');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetSegmentsSingleElementTest()
    var
        Uri: Codeunit Uri;
        Segments: List of [Text];
        Segment: Text;
    begin
        // [Given] A Url with no segments
        Uri.Init('http://microsoft.com');

        // [When] gettng the segments
        Uri.GetSegments(Segments);

        // [Then] The segments contain a single element
        LibraryAssert.IsTrue(Segments.Get(1, Segment), 'The segments should contain an element');
        LibraryAssert.AreEqual('/', Segment, 'Wrong segment');
        LibraryAssert.IsFalse(Segments.Get(2, Segment), 'The segments should contain only one element');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetMultipleSegmentsTest()
    var
        Uri: Codeunit Uri;
        Segments: List of [Text];
        Segment: Text;
    begin
        // [Given] A Url with no segments
        Uri.Init('http://microsoft.com/segment2/segment3/?randomquery');

        // [When] gettng the segments
        Uri.GetSegments(Segments);

        // [Then] The segments contain all the URI's segmetns
        LibraryAssert.IsTrue(Segments.Get(1, Segment), 'The segments should contain a first element');
        LibraryAssert.AreEqual('/', Segment, 'Wrong first segment');

        LibraryAssert.IsTrue(Segments.Get(2, Segment), 'The segments should contain a second element');
        LibraryAssert.AreEqual('segment2/', Segment, 'Wrong second segment');

        LibraryAssert.IsTrue(Segments.Get(3, Segment), 'The segments should contain a thrird element');
        LibraryAssert.AreEqual('segment3/', Segment, 'Wrong third segment');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure IsBaseUriTest()
    var
        BaseUri: Codeunit Uri;
        Uri: Codeunit Uri;
        BaseUriTxt: Label 'http://www.contoso.com/', Locked = true;
        NotBaseOfTxt: Label 'Uri: "%1" should be base of uri "%2".', Comment = '%1 = Base Uri, %2 = Uri to test';
        UriToTestTxt: Label 'http://www.contoso.com/index.htm?date=today', Locked = true;
    begin
        // [Given] A uri where contoso is the base uri
        BaseUri.Init(BaseUriTxt);

        // [Given] A uri with contoso
        Uri.Init(UriToTestTxt);

        // [Then] Contoso is the base uri.
        LibraryAssert.IsTrue(BaseUri.IsBaseOf(Uri), StrSubstNo(NotBaseOfTxt, BaseUriTxt, UriToTestTxt));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure IsWellFormedUriStringTest()
    var
        UriKind: Enum UriKind;
    begin
        TestUriWellformed('http://www.contoso.com/path???/file name', UriKind::Absolute, false);
        TestUriWellformed('c:\\directory\filename', UriKind::Absolute, false);
        TestUriWellformed('file://c:/directory/filename', UriKind::Absolute, false);
        TestUriWellformed('http:\\\host/path/file', UriKind::Absolute, false);
    end;

    local procedure TestUriWellformed(UriString: Text; UriKind: Enum UriKind; ExpectedResult: Boolean)
    var
        LocalUri: Codeunit Uri;
        InvalidResultTxt: Label 'The result of "IsWellFormedUriString" is invalid for URI "%1".', Comment = '%1 = Uri String';
    begin
        LibraryAssert.AreEqual(ExpectedResult, LocalUri.IsWellFormedUriString(UriString, UriKind), StrSubstNo(InvalidResultTxt, UriString));
    end;

}