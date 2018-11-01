// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 148001 "C5 Helper Functions Test"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        ItemtrackingCode: Record "Item Tracking Code";
        C5HelperFunctions: Codeunit "C5 Helper Functions";
        Assert: Codeunit Assert;
        PostCodeOrCityNotFoundErr: Label 'The combination of PostCode ''%1'' and City ''%2'' was not found.', Comment = '%1 = Post code and %2 = City';
        LanguageNotFoundErr: Label 'The language ''%1'' was not found.', Comment = '%1 = language name';
        CountryNotFoundErr: Label 'The country ''%1'' was not found.', Comment = '%1 = country name';
        SubstitutionStringPairs: array[15, 2] of Text;
        AreSubstitutionPairsInitialized: Boolean;

    trigger OnRun();
    begin
        // [FEATURE] [C5 Data Migration]
    end;

    [Test]
    procedure TestSubstitution()
    var
        SubstitutedString: Text;
        Index: Integer;
    begin
        InitSubstitutionPairs();

        for Index := 1 to ArrayLen(SubstitutionStringPairs, 1) do begin
            SubstitutedString := C5HelperFunctions.ReplaceLettersSubstitutions(SubstitutionStringPairs[Index, 1]);
            Assert.AreEqual(SubstitutionStringPairs[Index, 2], SubstitutedString, '');
        end;
    end;

    [Test]
    procedure TestStreamSubstitution()
    var
        TempBlob: Record TempBlob temporary;
        TempBlob2: Record TempBlob temporary;
        OutStream: OutStream;
        ResultStream: InStream;
        InStream: InStream;
        Index: Integer;
        Line: Text;
    begin
        InitSubstitutionPairs();

        TempBlob.Init();
        TempBlob.Blob.CreateOutStream(OutStream);
        for Index := 1 to ArrayLen(SubstitutionStringPairs, 1) do begin
            OutStream.WriteText(SubstitutionStringPairs[Index, 1]);
            OutStream.WriteText();
        end;

        TempBlob.Blob.CreateInStream(InStream);
        C5HelperFunctions.ProcessStreamForSubstitutions(TempBlob2, InStream, ResultStream);

        for Index := 1 to ArrayLen(SubstitutionStringPairs, 1) do begin
            ResultStream.ReadText(Line);
            Assert.AreEqual(SubstitutionStringPairs[Index, 2], Line, '');
        end;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestExtractPostCodeCity()
    var
        C5Country: Record "C5 Country";
        PostCode: Code[20];
        City: Text[30];
        CountryRegionCode: Code[10];
    begin
        Initialize();

        C5HelperFunctions.ExtractPostCodeAndCity('1100 Wien', 'Austria', PostCode, City, CountryRegionCode);
        Assert.AreEqual('AT', CountryRegionCode, 'Incorrect country');
        Assert.AreEqual('AT-1100', PostCode, 'Incorrect post code');
        Assert.AreEqual('Wien', City, 'Incorrect city');

        C5HelperFunctions.ExtractPostCodeAndCity('2355 Wr. neudorf', 'Austria', PostCode, City, CountryRegionCode);
        Assert.AreEqual('AT', CountryRegionCode, 'Incorrect country');
        Assert.AreEqual('AT-2355', PostCode, 'Incorrect post code');
        Assert.AreEqual('Wr. Neudorf', City, 'Incorrect city');

        C5HelperFunctions.ExtractPostCodeAndCity('2355 WR. NEUDORF', 'Austria', PostCode, City, CountryRegionCode);
        Assert.AreEqual('AT', CountryRegionCode, 'Incorrect country');
        Assert.AreEqual('AT-2355', PostCode, 'Incorrect post code');
        Assert.AreEqual('Wr. Neudorf', City, 'Incorrect city');

        C5HelperFunctions.ExtractPostCodeAndCity('2355  Wr. Neudorf', 'Austria', PostCode, City, CountryRegionCode);
        Assert.AreEqual('AT', CountryRegionCode, 'Incorrect country');
        Assert.AreEqual('AT-2355', PostCode, 'Incorrect post code');
        Assert.AreEqual('Wr. Neudorf', City, 'Incorrect city');

        C5HelperFunctions.ExtractPostCodeAndCity('', 'Austria', PostCode, City, CountryRegionCode);
        Assert.AreEqual('AT', CountryRegionCode, 'Incorrect country');
        Assert.AreEqual('', PostCode, 'Incorrect post code');
        Assert.AreEqual('', City, 'Incorrect city');

        C5HelperFunctions.ExtractPostCodeAndCity(' ', 'Austria', PostCode, City, CountryRegionCode);
        Assert.AreEqual('AT', CountryRegionCode, 'Incorrect country');
        Assert.AreEqual('', PostCode, 'Incorrect post code');
        Assert.AreEqual('', City, 'Incorrect city');

        C5HelperFunctions.ExtractPostCodeAndCity('  ', 'Austria', PostCode, City, CountryRegionCode);
        Assert.AreEqual('AT', CountryRegionCode, 'Incorrect country');
        Assert.AreEqual('', PostCode, 'Incorrect post code');
        Assert.AreEqual('', City, 'Incorrect city');

        C5Country.DeleteAll();
        C5Country.Init();
        C5Country.Country := 'Osterrig';
        C5Country.IntrastatCode := 'AT';
        C5Country.Insert();

        C5HelperFunctions.ExtractPostCodeAndCity('AT-1100 Wien', C5Country.Country, PostCode, City, CountryRegionCode);
        Assert.AreEqual('AT', CountryRegionCode, 'Incorrect country');
        Assert.AreEqual('AT-1100', PostCode, 'Incorrect post code');
        Assert.AreEqual('Wien', City, 'Incorrect city');

        C5Country.DeleteAll();
        C5Country.Init();
        C5Country.Country := 'Osterrig';
        C5Country.VatCountryCode := 'AT';
        C5Country.Insert();

        C5HelperFunctions.ExtractPostCodeAndCity('AT-1100 Wien', C5Country.Country, PostCode, City, CountryRegionCode);
        Assert.AreEqual('AT', CountryRegionCode, 'Incorrect country');
        Assert.AreEqual('AT-1100', PostCode, 'Incorrect post code');
        Assert.AreEqual('Wien', City, 'Incorrect city');

        asserterror C5HelperFunctions.ExtractPostCodeAndCity('2355  ', 'Austria', PostCode, City, CountryRegionCode);
        Assert.ExpectedError(StrSubstNo(PostCodeOrCityNotFoundErr, '2355', ''));

        Initialize();

        asserterror C5HelperFunctions.ExtractPostCodeAndCity('1100Wien', 'Austria', PostCode, City, CountryRegionCode);
        Assert.ExpectedError(StrSubstNo(PostCodeOrCityNotFoundErr, '1100Wien', ''));

        asserterror C5HelperFunctions.ExtractPostCodeAndCity('1234 SomeCity', 'Schweisz', PostCode, City, CountryRegionCode);
        Assert.ExpectedError(StrSubstNo(CountryNotFoundErr, 'Schweisz'));
    end;

    [Test]
    procedure TestGetLanguageCode()
    var
        C5VendTable: Record "C5 VendTable";
    begin
        Initialize();
        Assert.AreEqual('', C5HelperFunctions.GetLanguageCodeForC5Language(C5VendTable.Language_::Default), 'Default language is blank');
        Assert.AreEqual('DAN', C5HelperFunctions.GetLanguageCodeForC5Language(C5VendTable.Language_::Danish), 'Language is Danish');
        Assert.AreEqual('ENU', C5HelperFunctions.GetLanguageCodeForC5Language(C5VendTable.Language_::English), 'Language is English');
        Assert.AreEqual('DEU', C5HelperFunctions.GetLanguageCodeForC5Language(C5VendTable.Language_::German), 'Language is Dutch');
        Assert.AreEqual('FRA', C5HelperFunctions.GetLanguageCodeForC5Language(C5VendTable.Language_::French), 'Language is French');
        Assert.AreEqual('ITA', C5HelperFunctions.GetLanguageCodeForC5Language(C5VendTable.Language_::Italian), 'Language is Italian');
        Assert.AreEqual('NLD', C5HelperFunctions.GetLanguageCodeForC5Language(C5VendTable.Language_::Dutch), 'Language is Dutch');
        Assert.AreEqual('ISL', C5HelperFunctions.GetLanguageCodeForC5Language(C5VendTable.Language_::Icelandic), 'Language is Icelandic');
        asserterror C5HelperFunctions.GetLanguageCodeForC5Language(120);
        Assert.ExpectedError(StrSubstNo(LanguageNotFoundErr, FORMAT(120)));
    end;

    [Test]
    procedure TestGenerateTrackingCodes()
    var
        C5ItemMigrator: codeunit "C5 Item Migrator";
        C5OrderTrackingPolicy: Option None,Batch,"Serial number";
        TrackingCode: Code[10];
    begin
        TrackingCode := C5ItemMigrator.GetOrCreateItemTrackingCode(C5OrderTrackingPolicy::Batch);
        Assert.AreEqual('BATCH', TrackingCode, 'Incorrect trtacking code value');
        ItemTrackingCode.Get('BATCH');
        Assert.AreEqual('Batch tracking', ItemTrackingCode.Description, 'ItemTrackingCode.Description incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Purchase Inbound Tracking", '"Lot Purchase Inbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Sales Inbound Tracking", '"Lot Sales Inbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Pos. Adjmt. Inb. Tracking", '"Lot Pos. Adjmt. Inb. Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Neg. Adjmt. Inb. Tracking", '"Lot Neg. Adjmt. Inb. Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Assembly Inbound Tracking", '"Lot Assembly Inbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Manuf. Inbound Tracking", '"Lot Manuf. Inbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Transfer Tracking", '"Lot Transfer Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Purchase Outbound Tracking", '"Lot Purchase Outbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Sales Outbound Tracking", '"Lot Sales Outbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Pos. Adjmt. Outb. Tracking", '"Lot Pos. Adjmt. Outb. Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Neg. Adjmt. Outb. Tracking", '"Lot Neg. Adjmt. Outb. Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Assembly Outbound Tracking", '"Lot Assembly Outbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."Lot Manuf. Outbound Tracking", '"Lot Manuf. Outbound Tracking" incorrect');
        ItemTrackingCode.Delete();

        TrackingCode := C5ItemMigrator.GetOrCreateItemTrackingCode(C5OrderTrackingPolicy::"Serial number");
        Assert.AreEqual('SN', TrackingCode, 'Incorrect tracking code value');
        ItemTrackingCode.Get('SN');
        Assert.AreEqual('Serial number tracking', ItemTrackingCode.Description, 'ItemTrackingCode.Description incorrect');
        Assert.IsTrue(ItemTrackingCode."SN Purchase Inbound Tracking", '"SN Purchase Inbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."SN Sales Inbound Tracking", '"SN Sales Inbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."SN Pos. Adjmt. Inb. Tracking", '"SN Pos. Adjmt. Inb. Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."SN Neg. Adjmt. Inb. Tracking", '"SN Neg. Adjmt. Inb. Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."SN Assembly Inbound Tracking", '"SN Assembly Inbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."SN Manuf. Inbound Tracking", '"SN Manuf. Inbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."SN Transfer Tracking", '"SN Transfer Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."SN Purchase Outbound Tracking", '"SN Purchase Outbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."SN Sales Outbound Tracking", '"SN Sales Outbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."SN Pos. Adjmt. Outb. Tracking", '"SN Pos. Adjmt. Outb. Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."SN Neg. Adjmt. Outb. Tracking", '"SN Neg. Adjmt. Outb. Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."SN Assembly Outbound Tracking", '"SN Assembly Outbound Tracking" incorrect');
        Assert.IsTrue(ItemTrackingCode."SN Manuf. Outbound Tracking", '"SN Manuf. Outbound Tracking" incorrect');
        ItemTrackingCode.Delete();

        TrackingCode := C5ItemMigrator.GetOrCreateItemTrackingCode(C5OrderTrackingPolicy::None);
        Assert.AreEqual('', TrackingCode, 'Should be empty in case of None for tracking code')
    end;

    local procedure InitSubstitutionPairs()
    begin
        if (AreSubstitutionPairsInitialized) then
            Exit;

        SubstitutionStringPairs[1, 1] := '\200a';
        SubstitutionStringPairs[1, 2] := 'Ça';

        SubstitutionStringPairs[2, 1] := 'a\320';
        SubstitutionStringPairs[2, 2] := 'að';

        SubstitutionStringPairs[3, 1] := '\233';
        SubstitutionStringPairs[3, 2] := 'ø';

        SubstitutionStringPairs[4, 1] := '';
        SubstitutionStringPairs[4, 2] := '';

        // FIXME: This is by design for now, but actually '\\235' should be transformed to '\235'.
        SubstitutionStringPairs[5, 1] := '\\235';
        SubstitutionStringPairs[5, 2] := '\Ø';

        SubstitutionStringPairs[6, 1] := '\321a\235';
        SubstitutionStringPairs[6, 2] := 'ÐaØ';

        SubstitutionStringPairs[7, 1] := 'abc\266abc';
        SubstitutionStringPairs[7, 2] := 'abcÂabc';

        SubstitutionStringPairs[8, 1] := 'abc\266\245\232abc';
        SubstitutionStringPairs[8, 2] := 'abcÂÑÜabc';

        SubstitutionStringPairs[9, 1] := 'abc\26abc';
        SubstitutionStringPairs[9, 2] := 'abc\26abc';

        SubstitutionStringPairs[10, 1] := 'abc\26abc\216';
        SubstitutionStringPairs[10, 2] := 'abc\26abcÄ';

        SubstitutionStringPairs[11, 1] := 'abc\"xxxx\"abc';
        SubstitutionStringPairs[11, 2] := 'abc''xxxx''abc';

        SubstitutionStringPairs[12, 1] := '\\abc\\def\\ghi\\';
        SubstitutionStringPairs[12, 2] := '\abc\def\ghi\';

        SubstitutionStringPairs[13, 1] := 'x\\a\"';
        SubstitutionStringPairs[13, 2] := 'x\a''';

        SubstitutionStringPairs[14, 1] := 'x\\a\"w';
        SubstitutionStringPairs[14, 2] := 'x\a''w';

        SubstitutionStringPairs[15, 1] := 'qwerty';
        SubstitutionStringPairs[15, 2] := 'qwerty';

        AreSubstitutionPairsInitialized := True;
    end;

    procedure Initialize()
    var
        CountryRegion: Record "Country/Region";
        Language: Record "Language";
    begin
        CountryRegion.DeleteAll();

        CountryRegion.Init();
        CountryRegion.Validate(Code, 'AT');
        CountryRegion.Validate(Name, 'Austria');
        CountryRegion.Validate("Intrastat Code", 'AT');
        CountryRegion.Insert();

        Language.DeleteAll();
        Language.Validate(Code, 'DAN');
        Language.Validate(Name, 'Danish');
        Language.Validate("Windows Language ID", 1030);
        Language.Insert();


        Language.Validate(Code, 'ENU');
        Language.Validate(Name, 'English');
        Language.Validate("Windows Language ID", 1033);
        Language.Insert();

        Language.Validate(Code, 'DEU');
        Language.Validate(Name, 'German');
        Language.Validate("Windows Language ID", 1031);
        Language.Insert();

        Language.Validate(Code, 'FRA');
        Language.Validate(Name, 'French');
        Language.Validate("Windows Language ID", 1036);
        Language.Insert();

        Language.Validate(Code, 'ITA');
        Language.Validate(Name, 'Italian');
        Language.Validate("Windows Language ID", 1040);
        Language.Insert();

        Language.Validate(Code, 'NLD');
        Language.Validate(Name, 'Dutch');
        Language.Validate("Windows Language ID", 1043);
        Language.Insert();

        Language.Validate(Code, 'ISL');
        Language.Validate(Name, 'Icelandic');
        Language.Validate("Windows Language ID", 1039);
        Language.Insert();


    end;
}

