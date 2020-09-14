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
}
