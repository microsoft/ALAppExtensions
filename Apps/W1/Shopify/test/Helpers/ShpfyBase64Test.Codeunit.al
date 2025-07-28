// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;
using System.Text;

codeunit 139572 "Shpfy Base64 Test"
{
    Subtype = Test;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestIsBase64String()
    var
        Base64Convert: Codeunit "Base64 Convert";
        Base64: Codeunit "Shpfy Base64";
        Result: Boolean;
        Base64String: Text;
        RandomString: Text;
    begin
        // [SCENARIO] Testing of a variable of Text contains a Base64 encode string.

        // [GIVEN] Base64String
        Base64String := Base64Convert.ToBase64(Any.AlphanumericText(100));

        // [WHEN] Invoke Base64.IsBase64String(Base64String)
        Result := Base64.IsBase64String(Base64String);

        // [THEN] The result = true;
        LibraryAssert.IsTrue(Result, 'IsBase64String = true');

        // [GIVEN] A random string not Base64.
        RandomString := Any.AlphanumericText(100);

        // [WHEN] Invoke Base64.IsBase64String(RandomString)
        Result := Base64.IsBase64String(RandomString);

        // [THEN] Thesult = false
        LibraryAssert.IsFalse(Result, 'IsBase64String = false');
    end;
}