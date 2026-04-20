// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

codeunit 13924 "Routing No Validation Tests"
{
    Access = Internal;
    Subtype = Test;
    TestType = UnitTest;

    trigger OnRun()
    begin
        // [FEATURE] [E-Document DE] [Leitweg-ID Validation]
    end;

    var
        EDocDEHelper: Codeunit "E-Document DE Helper";
        Assert: Codeunit Assert;

    #region Valid Routing Numbers

    [Test]
    procedure ValidRoutingNoSpecExample()
    begin
        // [SCENARIO] The specification example '04011000-1234512345-06' is accepted as valid.
        EDocDEHelper.ValidateRoutingNo('04011000-1234512345-06');
    end;

    [Test]
    procedure ValidRoutingNoFederalCode()
    begin
        // [SCENARIO] Minimal Leitweg-ID with federal code '99-92' is accepted as valid.
        EDocDEHelper.ValidateRoutingNo('99-92');
    end;

    [Test]
    procedure ValidRoutingNoStateCode01()
    begin
        // [SCENARIO] Minimal Leitweg-ID with state code 01 (Schleswig-Holstein) '01-95' is accepted.
        EDocDEHelper.ValidateRoutingNo('01-95');
    end;

    [Test]
    procedure ValidRoutingNoStateCode16()
    begin
        // [SCENARIO] Leitweg-ID with state code 16 (Thüringen) '16-50' is accepted as valid.
        EDocDEHelper.ValidateRoutingNo('16-50');
    end;

    [Test]
    procedure ValidRoutingNoCoarse3Digits()
    begin
        // [SCENARIO] Leitweg-ID with 3-digit coarse routing '010-68' is accepted as valid.
        EDocDEHelper.ValidateRoutingNo('010-68');
    end;

    [Test]
    procedure ValidRoutingNoCoarse5Digits()
    begin
        // [SCENARIO] Leitweg-ID with 5-digit coarse routing '01001-05' is accepted as valid.
        EDocDEHelper.ValidateRoutingNo('01001-05');
    end;

    [Test]
    procedure ValidRoutingNoCoarse8Digits()
    begin
        // [SCENARIO] Leitweg-ID with 8-digit coarse routing without fine routing '04011000-45' is accepted.
        EDocDEHelper.ValidateRoutingNo('04011000-45');
    end;

    [Test]
    procedure ValidRoutingNoCoarse9Digits()
    begin
        // [SCENARIO] Leitweg-ID with 9-digit coarse routing '040110001-50' is accepted as valid.
        EDocDEHelper.ValidateRoutingNo('040110001-50');
    end;

    [Test]
    procedure ValidRoutingNoCoarse12Digits()
    begin
        // [SCENARIO] Leitweg-ID with 12-digit coarse routing '040110001234-90' is accepted as valid.
        EDocDEHelper.ValidateRoutingNo('040110001234-90');
    end;

    [Test]
    procedure ValidRoutingNoWithLetterFineRouting()
    begin
        // [SCENARIO] Leitweg-ID with letter-based fine routing '04011000-ABC-08' is accepted as valid.
        EDocDEHelper.ValidateRoutingNo('04011000-ABC-08');
    end;

    [Test]
    procedure ValidRoutingNoFederalWithFineRouting()
    begin
        // [SCENARIO] Federal Leitweg-ID with fine routing '99-ABC-16' is accepted as valid.
        EDocDEHelper.ValidateRoutingNo('99-ABC-16');
    end;

    [Test]
    procedure ValidRoutingNoLowercaseFineRouting()
    begin
        // [SCENARIO] Leitweg-ID with lowercase fine routing '04011000-abc-08' is accepted (case-insensitive).
        EDocDEHelper.ValidateRoutingNo('04011000-abc-08');
    end;

    [Test]
    procedure ValidBlankRoutingNo()
    begin
        // [SCENARIO] Blank routing number is accepted without validation.
        EDocDEHelper.ValidateRoutingNo('');
    end;

    #endregion

    #region Invalid Routing Numbers - Overall Format

    [Test]
    procedure InvalidRoutingNoTooShort()
    begin
        // [SCENARIO] Leitweg-ID shorter than 5 characters is rejected.
        asserterror EDocDEHelper.ValidateRoutingNo('01-9');
        Assert.ExpectedError('must be between 5 and 46 characters');
    end;

    [Test]
    procedure InvalidRoutingNoTooLong()
    begin
        // [SCENARIO] Leitweg-ID longer than 46 characters is rejected.
        asserterror EDocDEHelper.ValidateRoutingNo('040110001234-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-90');
        Assert.ExpectedError('must be between 5 and 46 characters');
    end;

    [Test]
    procedure InvalidRoutingNoNoHyphens()
    begin
        // [SCENARIO] Leitweg-ID without hyphens (single segment) is rejected.
        asserterror EDocDEHelper.ValidateRoutingNo('0401100006');
        Assert.ExpectedError('2 or 3 segments');
    end;

    [Test]
    procedure InvalidRoutingNoTooManySegments()
    begin
        // [SCENARIO] Leitweg-ID with more than 3 segments is rejected.
        asserterror EDocDEHelper.ValidateRoutingNo('04-01-10-06');
        Assert.ExpectedError('2 or 3 segments');
    end;

    #endregion

    #region Invalid Routing Numbers - Coarse Routing

    [Test]
    procedure InvalidRoutingNoCoarseNotDigits()
    begin
        // [SCENARIO] Leitweg-ID with non-digit coarse routing is rejected.
        asserterror EDocDEHelper.ValidateRoutingNo('ABCDE-06');
        Assert.ExpectedError('only digits');
    end;

    [Test]
    procedure InvalidRoutingNoCoarseWrongLength()
    begin
        // [SCENARIO] Leitweg-ID with invalid coarse routing length (4 digits) is rejected.
        asserterror EDocDEHelper.ValidateRoutingNo('0401-06');
        Assert.ExpectedError('2, 3, 5, 8, 9, or 12 digits');
    end;

    [Test]
    procedure InvalidRoutingNoStateCode00()
    begin
        // [SCENARIO] Leitweg-ID with state code '00' is rejected.
        asserterror EDocDEHelper.ValidateRoutingNo('00111-06');
        Assert.ExpectedError('valid German state code');
    end;

    [Test]
    procedure InvalidRoutingNoStateCode17()
    begin
        // [SCENARIO] Leitweg-ID with state code '17' (exceeds max 16) is rejected.
        asserterror EDocDEHelper.ValidateRoutingNo('17001-06');
        Assert.ExpectedError('valid German state code');
    end;

    #endregion

    #region Invalid Routing Numbers - Fine Routing

    [Test]
    procedure InvalidRoutingNoFineRoutingTooLong()
    begin
        // [SCENARIO] Leitweg-ID with fine routing exceeding 30 characters is rejected.
        asserterror EDocDEHelper.ValidateRoutingNo('01-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-06');
        Assert.ExpectedError('between 1 and 30 characters');
    end;

    [Test]
    procedure InvalidRoutingNoFineRoutingInvalidChars()
    begin
        // [SCENARIO] Leitweg-ID with special characters in fine routing is rejected.
        asserterror EDocDEHelper.ValidateRoutingNo('04011000-AB!C-06');
        Assert.ExpectedError('only letters (A-Z) and digits');
    end;

    #endregion

    #region Invalid Routing Numbers - Check Digit

    [Test]
    procedure InvalidRoutingNoCheckDigitOneDigit()
    begin
        // [SCENARIO] Leitweg-ID with single-digit check digit is rejected.
        asserterror EDocDEHelper.ValidateRoutingNo('04011000-1234512345-6');
        Assert.ExpectedError('exactly 2 digits');
    end;

    [Test]
    procedure InvalidRoutingNoCheckDigitNotDigits()
    begin
        // [SCENARIO] Leitweg-ID with non-digit check digit is rejected.
        asserterror EDocDEHelper.ValidateRoutingNo('04011000-1234512345-A6');
        Assert.ExpectedError('exactly 2 digits');
    end;

    [Test]
    procedure InvalidRoutingNoCheckDigitFails()
    begin
        // [SCENARIO] Leitweg-ID with wrong check digit (07 instead of 06) is rejected.
        asserterror EDocDEHelper.ValidateRoutingNo('04011000-1234512345-07');
        Assert.ExpectedError('check digit');
    end;

    #endregion
}
