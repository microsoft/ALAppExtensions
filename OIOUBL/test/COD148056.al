// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148056 "OIOUBL-Pmt. Export Validation"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryUtility: Codeunit "Library - Utility";
        GetPaymentChannelCodeErr: Label 'Country/Region Code must have a value in Country/Region: Code=%1. It cannot be zero or empty.', Comment = '%1 - Country code';

    trigger OnRun();
    begin
        // [FEATURE] [OIOUBL]
    end;

    [Test]
    procedure UT_GetPaymentChannelCode();
    var
        CompanyInformation: Record "Company Information";
        CountryRegion: Record "Country/Region";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 378054] Company Information returns Payment Channel Code based on country's "OIOUBL-Country/Region Code" value.
        CountryRegion.INIT();
        CountryRegion.Code := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(2, 0), 1, 2);
        CountryRegion."OIOUBL-Country/Region Code" :=
          COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(2, 0), 1, 2);
        if not CountryRegion.INSERT() then
            CountryRegion.MODIFY();

        CompanyInformation.INIT();
        CompanyInformation.VALIDATE("Country/Region Code", CountryRegion.Code);
        Assert.AreEqual(CountryRegion."OIOUBL-Country/Region Code" + ':BANK', CompanyInformation.GetOIOUBLPaymentChannelCode(), '');
    end;

    [Test]
    procedure UT_GetPaymentChannelCodeBlankOIOUBLCode();
    var
        CompanyInformation: Record "Company Information";
        CountryRegion: Record "Country/Region";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 378054] "Company Information".GetPaymentChannelCode throws error when country's "OIOUBL-Country/Region Code" is blank
        CountryRegion.INIT();
        CountryRegion.Code := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(2, 0), 1, 2);
        CountryRegion."OIOUBL-Country/Region Code" := '';
        if not CountryRegion.INSERT() then
            CountryRegion.MODIFY();

        CompanyInformation.INIT();
        CompanyInformation.VALIDATE("Country/Region Code", CountryRegion.Code);
        asserterror CompanyInformation.GetOIOUBLPaymentChannelCode();
        Assert.ExpectedError(STRSUBSTNO(GetPaymentChannelCodeErr, CountryRegion.Code));
    end;
}