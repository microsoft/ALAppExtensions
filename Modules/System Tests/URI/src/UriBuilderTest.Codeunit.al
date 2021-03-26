// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135071 "Uri Builder Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        UriBuilder: Codeunit "Uri Builder";

    [Test]
    [Scope('OnPrem')]
    procedure InitInvalidURITest()
    begin
        asserterror UriBuilder.Init('this is not a valid URI');

        Assert.ExpectedError('A call to System.UriBuilder failed with this message: Invalid URI');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SetAndGetSchemeTest()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A URI with an http scheme
        UriBuilder.Init('http://microsoft.com:80/');

        // [Then] The Scheme is in place
        Assert.AreEqual('http', UriBuilder.GetScheme(), 'GetScheme does not work as expected');

        // [When] Setting the scheme to https
        UriBuilder.SetScheme('https');

        // [Then] The URI is as expected
        Assert.AreEqual('https', UriBuilder.GetScheme(), 'GetScheme after SetScheme does not work as expected');

        UriBuilder.GetUri(Uri);
        Assert.AreEqual('https://microsoft.com:80/', Uri.GetAbsoluteUri(), 'The scheme does not match');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SetIncorrectSchemeTest()
    begin
        // [Given] A Url
        UriBuilder.Init('http://microsoft.com');

        // [When] Setting an invalid scheme
        asserterror UriBuilder.SetScheme('invalid scheme');

        // [Then] The URI is as expected
        Assert.ExpectedError('A call to System.UriBuilder.Scheme failed with this message: value'); // 'The scheme cannot be set to an invalid scheme name.'
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SetAndGetHostTest()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        UriBuilder.Init('http://microsoft.com/test');

        // [Then] The host should be 'microsoft.com'
        Assert.AreEqual('microsoft.com', UriBuilder.GetHost(), 'GetHost does not work as expected');

        // [When] The host is set
        UriBuilder.SetHost('www.example.org');

        // [Then] The URI is as expected
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('http://www.example.org/test', Uri.GetAbsoluteUri(), 'The host does not match');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SetAndGetPortTest()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        UriBuilder.Init('http://microsoft.com:3000/test');

        // [Then] The port should be 3000
        Assert.AreEqual(3000, UriBuilder.GetPort(), 'GetPort does not work as expected');

        // [When] Setting the port to 5000
        UriBuilder.SetPort(5000);

        // [Then] The URI is as expected
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('http://microsoft.com:5000/test', Uri.GetAbsoluteUri(), 'The port does not match');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SetIncorrectPortTest()
    var
        ExpectedErr: Label 'A call to System.UriBuilder.Port failed with this message: Specified argument was out of the range of valid values.\Parameter name: value', Locked = true;
    begin
        // [Given] A Url
        UriBuilder.Init('http://microsoft.com');

        // [When] Setting the port number too low
        asserterror UriBuilder.SetPort(-2);

        // [Then] An error occurs
        Assert.ExpectedError(ExpectedErr);

        // [When] Setting the port number too high
        asserterror UriBuilder.SetPort(65536);

        // [Then] An error occurs
        Assert.ExpectedError(ExpectedErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SetAndGetPathTest()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        UriBuilder.Init('http://microsoft.com/segment2/segment3/?randomquery');

        // [Then] The path should be /segment2/segment3
        Assert.AreEqual('/segment2/segment3/', UriBuilder.GetPath(), 'GetPath does not work as expected');

        // [When] Setting the path to /test
        UriBuilder.SetPath('/test.htm');

        // [Then] The URI is as expected
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('http://microsoft.com/test.htm?randomquery', Uri.GetAbsoluteUri(), 'The path does not match');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SetAndGetQueryTest()
    var
        QueryText: Text;
        QueryTemplateLbl: Label '%1=%2', Locked = true;
    begin
        // [Given] A randomly generated simple query and a base URI
        QueryText := StrSubstNo(QueryTemplateLbl, Any.AlphanumericText(10), Any.AlphanumericText(10));
        UriBuilder.Init('http://microsoft.com');

        // [When] Setting the query
        UriBuilder.SetQuery(QueryText);

        // [Then] The URI is as expected
        Assert.AreEqual('?' + QueryText, UriBuilder.GetQuery(), 'The query does not match');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SetAndGetFragmentTest()
    var
        Uri: Codeunit Uri;
    begin
        // [Given] A Url
        UriBuilder.Init('http://microsoft.com/test/?randomquery#randomfragment');

        // [Then] The fragment should be #randomfragment
        Assert.AreEqual('#randomfragment', UriBuilder.GetFragment(), 'GetFragment does not work as expected');

        // [When] Setting the fragment to #main
        UriBuilder.SetFragment('main');

        // [Then] The URI is as expected
        UriBuilder.GetUri(Uri);
        Assert.AreEqual('http://microsoft.com/test/?randomquery#main', Uri.GetAbsoluteUri(), 'The fragment does not match');
    end;
}