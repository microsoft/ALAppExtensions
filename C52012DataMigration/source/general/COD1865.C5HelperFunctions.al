// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 1865 "C5 Helper Functions"
{
    var
        TypeHelper: Codeunit "Type Helper";
        SubstitutionTable: array[130, 2] of Text;
        IsSubstitutionTableInitialized: Boolean;
        PostCodeOrCityNotFoundErr: Label 'The combination of PostCode ''%1'' and City ''%2'' was not found.', Comment = '%1 = Post code and %2 = City';
        CountryNotFoundErr: Label 'The country ''%1'' was not found.', Comment = '%1 = country name';
        DepartmentDimensionCodeTxt: Label 'C5DEPARTMENT';
        DepartmentDimensionDescriptionTxt: Label 'C5 Department Dimension';
        CostCenterDimensionCodeTxt: Label 'C5COSTCENTRE';
        CostCenterDimensionDescriptionTxt: Label 'C5 Cost Centre';
        PurposeDimensionCodeTxt: Label 'C5PURPOSE';
        PurposeDimensionDescriptionTxt: Label 'C5 Purpose';
        LanguageNotFoundErr: Label 'The language ''%1'' was not found.', Comment = '%1 = language name';


    local procedure InitSubstitutionTable()
    begin
        // Initializing substitution table, which is Codepage 850 with 'C5 encoding -> char' mapping.
        // First index ([first, _]) represents one table item.
        // Second index ([_, second]) represents individual properties: [_, 1] is string to search, [_, 2] is UTF-8 char. 
        if not IsSubstitutionTableInitialized then begin
            SubstitutionTable[1, 1] := '\200';
            SubstitutionTable[1, 2] := 'Ç';

            SubstitutionTable[2, 1] := '\201';
            SubstitutionTable[2, 2] := 'ü';

            SubstitutionTable[3, 1] := '\202';
            SubstitutionTable[3, 2] := 'é';

            SubstitutionTable[4, 1] := '\203';
            SubstitutionTable[4, 2] := 'â';

            SubstitutionTable[5, 1] := '\204';
            SubstitutionTable[5, 2] := 'ä';

            SubstitutionTable[6, 1] := '\205';
            SubstitutionTable[6, 2] := 'à';

            SubstitutionTable[7, 1] := '\206';
            SubstitutionTable[7, 2] := 'å';

            SubstitutionTable[8, 1] := '\207';
            SubstitutionTable[8, 2] := 'ç';

            SubstitutionTable[9, 1] := '\210';
            SubstitutionTable[9, 2] := 'ê';

            SubstitutionTable[10, 1] := '\211';
            SubstitutionTable[10, 2] := 'ë';

            SubstitutionTable[11, 1] := '\212';
            SubstitutionTable[11, 2] := 'è';

            SubstitutionTable[12, 1] := '\213';
            SubstitutionTable[12, 2] := 'ï';

            SubstitutionTable[13, 1] := '\214';
            SubstitutionTable[13, 2] := 'î';

            SubstitutionTable[14, 1] := '\215';
            SubstitutionTable[14, 2] := 'ì';

            SubstitutionTable[15, 1] := '\216';
            SubstitutionTable[15, 2] := 'Ä';

            SubstitutionTable[16, 1] := '\217';
            SubstitutionTable[16, 2] := 'Å';

            SubstitutionTable[17, 1] := '\220';
            SubstitutionTable[17, 2] := 'É';

            SubstitutionTable[18, 1] := '\221';
            SubstitutionTable[18, 2] := 'æ';

            SubstitutionTable[19, 1] := '\222';
            SubstitutionTable[19, 2] := 'Æ';

            SubstitutionTable[20, 1] := '\223';
            SubstitutionTable[20, 2] := 'ô';

            SubstitutionTable[21, 1] := '\224';
            SubstitutionTable[21, 2] := 'ö';

            SubstitutionTable[22, 1] := '\225';
            SubstitutionTable[22, 2] := 'ò';

            SubstitutionTable[23, 1] := '\226';
            SubstitutionTable[23, 2] := 'û';

            SubstitutionTable[24, 1] := '\227';
            SubstitutionTable[24, 2] := 'ù';

            SubstitutionTable[25, 1] := '\230';
            SubstitutionTable[25, 2] := 'ÿ';

            SubstitutionTable[26, 1] := '\231';
            SubstitutionTable[26, 2] := 'Ö';

            SubstitutionTable[27, 1] := '\232';
            SubstitutionTable[27, 2] := 'Ü';

            SubstitutionTable[28, 1] := '\233';
            SubstitutionTable[28, 2] := 'ø';

            SubstitutionTable[29, 1] := '\234';
            SubstitutionTable[29, 2] := '£';

            SubstitutionTable[30, 1] := '\235';
            SubstitutionTable[30, 2] := 'Ø';

            SubstitutionTable[31, 1] := '\236';
            SubstitutionTable[31, 2] := '×';

            SubstitutionTable[32, 1] := '\237';
            SubstitutionTable[32, 2] := 'ƒ';

            SubstitutionTable[33, 1] := '\240';
            SubstitutionTable[33, 2] := 'á';

            SubstitutionTable[34, 1] := '\241';
            SubstitutionTable[34, 2] := 'í';

            SubstitutionTable[35, 1] := '\242';
            SubstitutionTable[35, 2] := 'ó';

            SubstitutionTable[36, 1] := '\243';
            SubstitutionTable[36, 2] := 'ú';

            SubstitutionTable[37, 1] := '\244';
            SubstitutionTable[37, 2] := 'ñ';

            SubstitutionTable[38, 1] := '\245';
            SubstitutionTable[38, 2] := 'Ñ';

            SubstitutionTable[39, 1] := '\246';
            SubstitutionTable[39, 2] := 'ª';

            SubstitutionTable[40, 1] := '\247';
            SubstitutionTable[40, 2] := 'º';

            SubstitutionTable[41, 1] := '\250';
            SubstitutionTable[41, 2] := '¿';

            SubstitutionTable[42, 1] := '\251';
            SubstitutionTable[42, 2] := '®';

            SubstitutionTable[43, 1] := '\252';
            SubstitutionTable[43, 2] := '¬';

            SubstitutionTable[44, 1] := '\253';
            SubstitutionTable[44, 2] := '½';

            SubstitutionTable[45, 1] := '\254';
            SubstitutionTable[45, 2] := '¼';

            SubstitutionTable[46, 1] := '\255';
            SubstitutionTable[46, 2] := '¡';

            SubstitutionTable[47, 1] := '\256';
            SubstitutionTable[47, 2] := '«';

            SubstitutionTable[48, 1] := '\257';
            SubstitutionTable[48, 2] := '»';

            SubstitutionTable[49, 1] := '\260';
            SubstitutionTable[49, 2] := '░';

            SubstitutionTable[50, 1] := '\261';
            SubstitutionTable[50, 2] := '▒';

            SubstitutionTable[51, 1] := '\262';
            SubstitutionTable[51, 2] := '▓';

            SubstitutionTable[52, 1] := '\263';
            SubstitutionTable[52, 2] := '│';

            SubstitutionTable[53, 1] := '\264';
            SubstitutionTable[53, 2] := '┤';

            SubstitutionTable[54, 1] := '\265';
            SubstitutionTable[54, 2] := 'Á';

            SubstitutionTable[55, 1] := '\266';
            SubstitutionTable[55, 2] := 'Â';

            SubstitutionTable[56, 1] := '\267';
            SubstitutionTable[56, 2] := 'À';

            SubstitutionTable[57, 1] := '\270';
            SubstitutionTable[57, 2] := '©';

            SubstitutionTable[58, 1] := '\271';
            SubstitutionTable[58, 2] := '╣';

            SubstitutionTable[59, 1] := '\272';
            SubstitutionTable[59, 2] := '║';

            SubstitutionTable[60, 1] := '\273';
            SubstitutionTable[60, 2] := '╗';

            SubstitutionTable[61, 1] := '\274';
            SubstitutionTable[61, 2] := '╝';

            SubstitutionTable[62, 1] := '\275';
            SubstitutionTable[62, 2] := '¢';

            SubstitutionTable[63, 1] := '\276';
            SubstitutionTable[63, 2] := '¥';

            SubstitutionTable[64, 1] := '\277';
            SubstitutionTable[64, 2] := '┐';

            SubstitutionTable[65, 1] := '\300';
            SubstitutionTable[65, 2] := '└';

            SubstitutionTable[66, 1] := '\301';
            SubstitutionTable[66, 2] := '┴';

            SubstitutionTable[67, 1] := '\302';
            SubstitutionTable[67, 2] := '┬';

            SubstitutionTable[68, 1] := '\303';
            SubstitutionTable[68, 2] := '├';

            SubstitutionTable[69, 1] := '\304';
            SubstitutionTable[69, 2] := '─';

            SubstitutionTable[70, 1] := '\305';
            SubstitutionTable[70, 2] := '┼';

            SubstitutionTable[71, 1] := '\306';
            SubstitutionTable[71, 2] := 'ã';

            SubstitutionTable[72, 1] := '\307';
            SubstitutionTable[72, 2] := 'Ã';

            SubstitutionTable[73, 1] := '\310';
            SubstitutionTable[73, 2] := '╚';

            SubstitutionTable[74, 1] := '\311';
            SubstitutionTable[74, 2] := '╔';

            SubstitutionTable[75, 1] := '\312';
            SubstitutionTable[75, 2] := '╩';

            SubstitutionTable[76, 1] := '\313';
            SubstitutionTable[76, 2] := '╦';

            SubstitutionTable[77, 1] := '\314';
            SubstitutionTable[77, 2] := '╠';

            SubstitutionTable[78, 1] := '\315';
            SubstitutionTable[78, 2] := '═';

            SubstitutionTable[79, 1] := '\316';
            SubstitutionTable[79, 2] := '╬';

            SubstitutionTable[80, 1] := '\317';
            SubstitutionTable[80, 2] := '¤';

            SubstitutionTable[81, 1] := '\320';
            SubstitutionTable[81, 2] := 'ð';

            SubstitutionTable[82, 1] := '\321';
            SubstitutionTable[82, 2] := 'Ð';

            SubstitutionTable[83, 1] := '\322';
            SubstitutionTable[83, 2] := 'Ê';

            SubstitutionTable[84, 1] := '\323';
            SubstitutionTable[84, 2] := 'Ë';

            SubstitutionTable[85, 1] := '\324';
            SubstitutionTable[85, 2] := 'È';

            SubstitutionTable[86, 1] := '\325';
            SubstitutionTable[86, 2] := 'ı';

            SubstitutionTable[87, 1] := '\326';
            SubstitutionTable[87, 2] := 'Í';

            SubstitutionTable[88, 1] := '\327';
            SubstitutionTable[88, 2] := 'Î';

            SubstitutionTable[89, 1] := '\330';
            SubstitutionTable[89, 2] := 'Ï';

            SubstitutionTable[90, 1] := '\331';
            SubstitutionTable[90, 2] := '┘';

            SubstitutionTable[91, 1] := '\332';
            SubstitutionTable[91, 2] := '┌';

            SubstitutionTable[92, 1] := '\333';
            SubstitutionTable[92, 2] := '█';

            SubstitutionTable[93, 1] := '\334';
            SubstitutionTable[93, 2] := '▄';

            SubstitutionTable[94, 1] := '\335';
            SubstitutionTable[94, 2] := '¦';

            SubstitutionTable[95, 1] := '\336';
            SubstitutionTable[95, 2] := 'Ì';

            SubstitutionTable[96, 1] := '\337';
            SubstitutionTable[96, 2] := '▀';

            SubstitutionTable[97, 1] := '\340';
            SubstitutionTable[97, 2] := 'Ó';

            SubstitutionTable[98, 1] := '\341';
            SubstitutionTable[98, 2] := 'ß';

            SubstitutionTable[99, 1] := '\342';
            SubstitutionTable[99, 2] := 'Ô';

            SubstitutionTable[100, 1] := '\343';
            SubstitutionTable[100, 2] := 'Ò';

            SubstitutionTable[101, 1] := '\344';
            SubstitutionTable[101, 2] := 'õ';

            SubstitutionTable[102, 1] := '\345';
            SubstitutionTable[102, 2] := 'Õ';

            SubstitutionTable[103, 1] := '\346';
            SubstitutionTable[103, 2] := 'µ';

            SubstitutionTable[104, 1] := '\347';
            SubstitutionTable[104, 2] := 'þ';

            SubstitutionTable[105, 1] := '\350';
            SubstitutionTable[105, 2] := 'Þ';

            SubstitutionTable[106, 1] := '\351';
            SubstitutionTable[106, 2] := 'Ú';

            SubstitutionTable[107, 1] := '\352';
            SubstitutionTable[107, 2] := 'Û';

            SubstitutionTable[108, 1] := '\353';
            SubstitutionTable[108, 2] := 'Ù';

            SubstitutionTable[109, 1] := '\354';
            SubstitutionTable[109, 2] := 'ý';

            SubstitutionTable[110, 1] := '\355';
            SubstitutionTable[110, 2] := 'Ý';

            SubstitutionTable[111, 1] := '\356';
            SubstitutionTable[111, 2] := '¯';

            SubstitutionTable[112, 1] := '\357';
            SubstitutionTable[112, 2] := '´';

            SubstitutionTable[113, 1] := '\360';
            SubstitutionTable[113, 2] := '­';

            SubstitutionTable[114, 1] := '\361';
            SubstitutionTable[114, 2] := '±';

            SubstitutionTable[115, 1] := '\362';
            SubstitutionTable[115, 2] := '‗';

            SubstitutionTable[116, 1] := '\363';
            SubstitutionTable[116, 2] := '¾';

            SubstitutionTable[117, 1] := '\364';
            SubstitutionTable[117, 2] := '¶';

            SubstitutionTable[118, 1] := '\365';
            SubstitutionTable[118, 2] := '§';

            SubstitutionTable[119, 1] := '\366';
            SubstitutionTable[119, 2] := '÷';

            SubstitutionTable[120, 1] := '\367';
            SubstitutionTable[120, 2] := '¸';

            SubstitutionTable[121, 1] := '\370';
            SubstitutionTable[121, 2] := '°';

            SubstitutionTable[122, 1] := '\371';
            SubstitutionTable[122, 2] := '¨';

            SubstitutionTable[123, 1] := '\372';
            SubstitutionTable[123, 2] := '·';

            SubstitutionTable[124, 1] := '\373';
            SubstitutionTable[124, 2] := '¹';

            SubstitutionTable[125, 1] := '\374';
            SubstitutionTable[125, 2] := '³';

            SubstitutionTable[126, 1] := '\375';
            SubstitutionTable[126, 2] := '²';

            SubstitutionTable[127, 1] := '\376';
            SubstitutionTable[127, 2] := '■';

            SubstitutionTable[128, 1] := '\377';
            SubstitutionTable[128, 2] := ' ';

            SubstitutionTable[129, 1] := '\\';
            SubstitutionTable[129, 2] := '\';

            // We need to replace \" so that we're able to have quotes inside strings.
            // We can't replace it to " since it's a delimeter in XML port for text fields,
            // so instead we replace it with '.
            SubstitutionTable[130, 1] := '\"';
            SubstitutionTable[130, 2] := '''';

            IsSubstitutionTableInitialized := TRUE;
        end;
    end;

    procedure TryConvertFromStringDate(DateString: Text[20]; Format: Text[20]; var Date: Date): Boolean
    var
        TempVariant: Variant;
    begin
        if DateString = '' then begin
            Date := 0D;
            exit(true);
            // false means the format is incorrect. Here we don't want to error out.
        end;

        TempVariant := Date;
        if not TypeHelper.Evaluate(TempVariant, DateString, Format, '') then
            exit(false);
        Date := TempVariant;
        exit(true);
    end;

    procedure ReplaceLettersSubstitutions(String: Text): Text
    var
        Position: Integer;
        SubstitutionIndex: Integer;
    begin
        InitSubstitutionTable();

        Position := FindNextSubstitution(String, SubstitutionIndex);
        while (Position > 0) do begin
            String := DelStr(String, Position, StrLen(SubstitutionTable[SubstitutionIndex, 1]));
            String := InsStr(String, SubstitutionTable[SubstitutionIndex, 2], Position);
            Position := FindNextSubstitution(String, SubstitutionIndex);
        end;

        exit(String);
    end;

    local procedure FindNextSubstitution(String: Text; var SubstitutionIndex: Integer): Integer
    var
        Position: Integer;
    begin
        for SubstitutionIndex := 1 to ArrayLen(SubstitutionTable, 1) do begin
            Position := StrPos(String, SubstitutionTable[SubstitutionIndex, 1]);
            if (Position > 0) then
                Exit(Position);
        end;

        exit(0);
    end;

    procedure ProcessStreamForSubstitutions(var TempBlob: Record TempBlob temporary; InStream: InStream; var ProcessedStream: InStream)
    var
        HelperFunctions: Codeunit "C5 Helper Functions";
        OutStream: OutStream;
        Line: Text;
    begin
        TempBlob.Init();
        TempBlob.Blob.CreateOutStream(OutStream);
        while not InStream.EOS() do begin
            InStream.ReadText(Line);
            Line := HelperFunctions.ReplaceLettersSubstitutions(Line);

            OutStream.WriteText(Line);
            OutStream.WriteText();
        end;
        TempBlob.Blob.CreateInStream(ProcessedStream);
    end;

    procedure GetDimensionValueName(TableNum: Integer; DimensionValue: Code[10]) DimensionName: Text[30]
    var
        C5Centre: Record "C5 Centre";
        C5Department: Record "C5 Department";
        C5Purpose: Record "C5 Purpose";
    begin
        case TableNum of
            Database::"C5 Department":
                begin
                    C5Department.SetRange(Department, DimensionValue);
                    if C5Department.FindFirst() then
                        DimensionName := C5Department.Name;
                end;
            Database::"C5 Centre":
                begin
                    C5Centre.SetRange(Centre, DimensionValue);
                    if C5Centre.FindFirst() then
                        DimensionName := C5Centre.Name;
                end;
            Database::"C5 Purpose":
                begin
                    C5Purpose.SetRange(Purpose, DimensionValue);
                    if C5Purpose.FindFirst() then
                        DimensionName := C5Purpose.Name;
                end;
        end;
    end;

    procedure GetDepartmentDimensionCodeTxt(): Code[20]
    begin
        exit(CopyStr(DepartmentDimensionCodeTxt, 1, 20));
    end;

    procedure GetCostCenterDimensionCodeTxt(): Code[20]
    begin
        exit(CopyStr(CostCenterDimensionCodeTxt, 1, 20));
    end;

    procedure GetPurposeDimensionCodeTxt(): Code[20]
    begin
        exit(CopyStr(PurposeDimensionCodeTxt, 1, 20));
    end;

    procedure GetDepartmentDimensionDescTxt(): Code[50]
    begin
        exit(CopyStr(DepartmentDimensionDescriptionTxt, 1, 50));
    end;

    procedure GetCostCenterDimensionDescTxt(): Code[50]
    begin
        exit(CopyStr(CostCenterDimensionDescriptionTxt, 1, 50));
    end;

    procedure GetPurposeDimensionDescTxt(): Code[50]
    begin
        exit(CopyStr(PurposeDimensionDescriptionTxt, 1, 50));
    end;

    procedure FixLCYCode(Currency: Code[10]): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();

        if Currency = GeneralLedgerSetup."LCY Code" then
            exit('');

        exit(Currency);
    end;

    procedure ExtractPostCodeAndCity(C5ZipCity: Text[50]; C5Country: Text[30]; var D365PostCode: Code[20]; var D365City: Text[30]; var D365CountryRegionCode: Code[10])
    var
        CompanyInformation: Record "Company Information";
        CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade";
        ZipCityTemp: Text[50];
        FirstBlankIdx: Integer;
    begin
        D365PostCode := '';
        D365City := '';
        D365CountryRegionCode := GetCountry(C5Country);
        ZipCityTemp := CopyStr(TrimSpaces(C5ZipCity), 1, 50);

        FirstBlankIdx := StrPos(ZipCityTemp, ' ');
        if ZipCityTemp = '' then
            exit;
        if FirstBlankIdx > 1 then begin
            D365PostCode := CopyStr(CopyStr(ZipCityTemp, 1, FirstBlankIdx - 1), 1, 20);
            D365City := FixCityCase(CopyStr(ZipCityTemp, FirstBlankIdx + 1));
            if not CustomerDataMigrationFacade.DoesPostCodeExist(D365PostCode, D365City) then begin
                CompanyInformation.Get();
                if (D365CountryRegionCode <> '') and (D365CountryRegionCode <> CompanyInformation."Country/Region Code") then begin
                    if Strpos(D365PostCode, '-') <> 3 then // already formatted like DK-2800, do not make it like DK-DK-2800
                        D365PostCode := CopyStr(StrSubstNo('%1-%2', D365CountryRegionCode, D365PostCode), 1, 20);
                    if not CustomerDataMigrationFacade.DoesPostCodeExist(D365PostCode, D365City) then
                        CustomerDataMigrationFacade.CreatePostCodeIfNeeded(D365PostCode, D365City, '', D365CountryRegionCode);
                    exit;
                end;
                CustomerDataMigrationFacade.CreatePostCodeIfNeeded(D365PostCode, D365City, '', CompanyInformation."Country/Region Code");
            end;
        end else
            Error(PostCodeOrCityNotFoundErr, ZipCityTemp, '');
    end;

    local procedure GetCountry(C5CountryTxt: Text[30]): Code[10]
    var
        C5Country: Record "C5 Country";
        CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade";
        ResultCode: Code[10];
    begin
        if C5CountryTxt = '' then
            exit(CopyStr(C5CountryTxt, 1, 10));
        if CustomerDataMigrationFacade.SearchCountry('', C5CountryTxt, '', '', ResultCode) then
            exit(ResultCode);
        C5Country.SetRange(Country, C5CountryTxt);
        if C5Country.FindFirst() then begin
            if C5Country.VatCountryCode <> '' then begin
                if CustomerDataMigrationFacade.SearchCountry(C5Country.VatCountryCode, '', '', '', ResultCode) then
                    exit(ResultCode);
                if CustomerDataMigrationFacade.SearchCountry('', '', C5Country.VatCountryCode, '', ResultCode) then
                    exit(ResultCode);
            end;
            if C5Country.IntrastatCode <> '' then
                if CustomerDataMigrationFacade.SearchCountry('', '', '', C5Country.IntrastatCode, ResultCode) then
                    exit(ResultCode);
        end;
        if C5Country.VatCountryCode <> '' then
            CreateCounty(C5Country.VatCountryCode, C5Country.Country)
        else
            Error(CountryNotFoundErr, C5CountryTxt);
    end;

    local procedure FixCityCase(City: Text): Text[30]
    var
        Pos: Integer;
        Left: Text;
        Right: Text;
    begin
        City := TrimSpaces(City);
        if City in ['NV', 'SV', 'NØ', 'SØ'] then
            exit(CopyStr(City, 1, 30));
        Pos := StrPos(City, ' ');
        if Pos > 1 then begin
            Left := CopyStr(City, 1, Pos - 1);
            Right := CopyStr(City, Pos + 1);
            exit(CopyStr(FixCityCase(Left) + ' ' + FixCityCase(Right), 1, 30))
        end else
            exit(CopyStr(UpperCase(City[1]) + LowerCase(CopyStr(City, 2)), 1, 30));
    end;

    local procedure CreateCounty(CountryCode: Code[10]; Country: Text[50])
    var
        CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade";
        AddressFormatToSet: Option "Post Code+City","City+Post Code","City+County+Post Code","Blank Line+Post Code+City";
        ContactAddressFormatToSet: Option First,"After Company Name",Last;
    begin
        CustomerDataMigrationFacade.CreateCountryIfNeeded(CountryCode, Country, AddressFormatToSet::"Post Code+City", ContactAddressFormatToSet::"After Company Name");
    end;

    procedure GetLanguageCodeForC5Language(C5Language: Option): Code[10]
    var
        C5VendTable: Record "C5 VendTable";
        CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade";
        AbbreviatedLanguage: Code[3];
        ResultCode: Code[10];
    begin
        // as C5 language code is a global enum and are the same set of options irrespective of the entity in which they reside.
        C5VendTable.Language_ := C5Language;
        case C5VendTable.Language_ of
            C5VendTable.Language_::Default:
                exit('');

            C5VendTable.Language_::Danish:
                AbbreviatedLanguage := 'DAN';
            C5VendTable.Language_::Dutch:
                AbbreviatedLanguage := 'NLD';
            C5VendTable.Language_::English:
                AbbreviatedLanguage := 'ENU';
            C5VendTable.Language_::French:
                AbbreviatedLanguage := 'FRA';
            C5VendTable.Language_::German:
                AbbreviatedLanguage := 'DEU';
            C5VendTable.Language_::Icelandic:
                AbbreviatedLanguage := 'ISL';
            C5VendTable.Language_::Italian:
                AbbreviatedLanguage := 'ITA';
        end;

        if not CustomerDataMigrationFacade.SearchLanguage(AbbreviatedLanguage, ResultCode) then
            Error(LanguageNotFoundErr, Format(C5VendTable.Language_));
        exit(ResultCode);
    end;

    procedure TrimSpaces(Input: Text): Text
    begin
        exit(DelChr(Input, '<>', ' '));
    end;

    procedure CreateGLAccount(AccountCode: Code[10])
    var
        GLAccDataMigrationFacade: Codeunit "GL Acc. Data Migration Facade";
        C5LedTableMigrator: Codeunit "C5 LedTable Migrator";
        GLAccountNoWithLeadingZeros: Text;
        AccountType: Option Posting,Heading,Total,"Begin-Total","End-Total";
    begin
        GLAccountNoWithLeadingZeros := C5LedTableMigrator.FillWithLeadingZeros(AccountCode);

        if not GLAccDataMigrationFacade.CreateGLAccountIfNeeded(CopyStr(GLAccountNoWithLeadingZeros, 1, 20), AccountCode, AccountType::Posting) then
            exit;

        GLAccDataMigrationFacade.SetDirectPosting(true);
        GLAccDataMigrationFacade.ModifyGLAccount(true);
    end;

    procedure MigrateExchangeRatesForCurrency(Currency: Code[10])
    var
        C5ExchRates: Record "C5 ExchRate";
        ExchangeRatesMigrationFacade: Codeunit "Ex. Rate Data Migration Facade";
    begin
        C5ExchRates.SetRange(Currency, Currency);
        if C5ExchRates.FindSet() then
            repeat
                ExchangeRatesMigrationFacade.CreateSimpleExchangeRateIfNeeded(
                    Currency,
                    C5ExchRates.FromDate,
                    C5ExchRates.ExchRate,
                    100); // we hard-code ExchRateAmount to 100 since it's always 100 in C5
            until C5ExchRates.Next() = 0;
    end;

    procedure GetFileContentAsStream(Filename: Text; var NameValueBuffer: Record "Name/Value Buffer"; var FileContentStream: InStream): Boolean
    begin
        NameValueBuffer.SetRange(Name, Filename);
        if not NameValueBuffer.FindFirst() then
            exit(false);
        NameValueBuffer.CalcFields("Value BLOB");
        NameValueBuffer."Value BLOB".CreateInStream(FileContentStream);
        exit(true);
    end;

}