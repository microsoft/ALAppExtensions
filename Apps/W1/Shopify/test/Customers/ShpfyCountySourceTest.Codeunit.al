// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;

/// <summary>
/// Codeunit Shpfy CountySource Test (ID 139582).
/// </summary>
codeunit 139582 "Shpfy CountySource Test"
{
    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestCounty()
    var
        TempCustomerAddress: Record "Shpfy Customer Address" temporary;
        ICounty: Interface "Shpfy ICounty";
        RegionCodeTxt: Label 'RC', Locked = true;
        RegionNameTxt: Label 'Region Name', Locked = true;
    begin
        // [SCENARIO] Get the name or code of the region based on the enum value of "Shpfy County Source"
        TempCustomerAddress.Init();
        TempCustomerAddress."Province Code" := RegionCodeTxt;
        TempCustomerAddress."Province Name" := RegionNameTxt;

        // [GIVEN] "Shpfy County Source"::Code
        // [GIVEN] CustomerAddress
        ICounty := "Shpfy County Source"::Code;
        // [THEN] The result must be RegionCode
        LibraryAssert.AreEqual(RegionCodeTxt, ICounty.County(TempCustomerAddress), '"Shpfy County Source"::Code');

        // [GIVEN] "Shpfy County Source"::Name
        // [GIVEN] CustomerAddress
        ICounty := "Shpfy County Source"::Name;
        // [THEN] The result must be First Name + ' ' + Last Name
        LibraryAssert.AreEqual(RegionNameTxt, ICounty.County(TempCustomerAddress), '"Shpfy County Source"::Name');
    end;
}