// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13625 "OIOUBL-Document Encode"
{
    var
        CompanyInfo: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        InvalidCodeErr: Label 'should be %1 characters long', Comment = 'starts with some field name, %1 = a length';
        CompanyInfoRead: Boolean;
        GLSetupRead: Boolean;
        NonDanishCustomerErr: Label 'The customer must be Danish.';

    procedure DateToText(VarDate: Date): Text[20];
    begin
        if VarDate = 0D then
            exit('1753-01-01');
        exit(FORMAT(VarDate, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    procedure BooleanToText(VarBoolean: Boolean): Text[5];
    begin
        case VarBoolean of
            TRUE:
                exit('true');
            FALSE:
                exit('false');
        end;
    end;

    procedure DecimalToText(VarDecimal: Decimal): Text[30];
    begin
        exit(FORMAT(VarDecimal, 0, '<Precision,2:3><Sign><Integer><Decimals><Comma,.>'));
    end;

    procedure IntegerToText(VarInteger: Integer): Text[250];
    begin
        exit(FORMAT(VarInteger, 0, '<Sign><Integer,2><Filler Character,0>'));
    end;

    procedure IsValidGLN(GLN: Code[13]): Boolean;
    var
        GLNCalculator: Codeunit "GLN Calculator";
    begin
        exit(GLNCalculator.IsValidCheckDigit13(GLN));
    end;

    procedure CheckCurrencyCode(CurrencyCode: Code[10]): Boolean;
    begin
        exit(STRLEN(CurrencyCode) = 3);
    end;

    procedure DecimalToPromille(Decimal: Decimal): Text[4];
    begin
        exit(FORMAT(ABS(Decimal * 10), 0, '<Integer,4><Filler Character,0>'));
    end;

    procedure GetOIOUBLCountryRegionCode(CountryRegionCode: Code[10]): Code[10];
    var
        CountryRegion: Record "Country/Region";
    begin
        if CountryRegionCode = '' then begin
            ReadCompanyInfo();
            CompanyInfo.TESTFIELD("Country/Region Code");
            CountryRegionCode := CompanyInfo."Country/Region Code";
        end;
        CountryRegion.GET(CountryRegionCode);
        CountryRegion.TESTFIELD("OIOUBL-Country/Region Code");
        if STRLEN(CountryRegion."OIOUBL-Country/Region Code") <> 2 then
            CountryRegion.FIELDERROR("OIOUBL-Country/Region Code", STRSUBSTNO(InvalidCodeErr, 2));
        exit(CountryRegion."OIOUBL-Country/Region Code");
    end;

    procedure GetOIOUBLCurrencyCode(CurrencyCode: Code[10]): Code[10];
    var
        Currency: Record Currency;
    begin
        if CurrencyCode = '' then begin
            ReadGLSetup();
            GLSetup.TESTFIELD("LCY Code");
            CurrencyCode := GLSetup."LCY Code";
        end;

        if NOT Currency.GET(CurrencyCode) then begin
            if STRLEN(CurrencyCode) <> 3 then
                GLSetup.FIELDERROR("LCY Code", STRSUBSTNO(InvalidCodeErr, 3));
            exit(CurrencyCode);
        end;
        Currency.TESTFIELD("OIOUBL-Currency Code");
        if STRLEN(Currency."OIOUBL-Currency Code") <> 3 then
            Currency.FIELDERROR("OIOUBL-Currency Code", STRSUBSTNO(InvalidCodeErr, 3));
        exit(Currency."OIOUBL-Currency Code");
    end;

    procedure ReadCompanyInfo();
    begin
        if NOT CompanyInfoRead then begin
            CompanyInfo.GET();
            CompanyInfoRead := TRUE;
        end;
    end;

    procedure ReadGLSetup();
    begin
        if NOT GLSetupRead then begin
            GLSetup.GET();
            GLSetupRead := TRUE;
        end;
    end;

    procedure IsValidCountryCode(CountryCode: Code[10]);
    begin
        ReadCompanyInfo();
        if CountryCode <> CompanyInfo."Country/Region Code" then
            ERROR(NonDanishCustomerErr);
    end;

    [Obsolete('Kept for testing and potentially dealing with dependency issues','16.0')]
    procedure GetCompanyVATRegNoOld(VATRegNo: Text[20]): Text[20];
    begin
        ReadCompanyInfo();
        if COPYSTR(VATRegNo, 1, 2) <> CompanyInfo."Country/Region Code" then
            exit(Format(CompanyInfo."Country/Region Code" + VATRegNo));
        exit(VATRegNo);
    end;

    [Obsolete('Kept for testing and potentially dealing with dependency issues','16.0')]
    procedure GetCustomerVATRegNoOld(VATRegNo: Text[20]): Text[20];
    begin
        ReadCompanyInfo();
        if COPYSTR(VATRegNo, 1, 2) <> CompanyInfo."Country/Region Code" then
            exit(Format(CompanyInfo."Country/Region Code" + VATRegNo));
        exit(VATRegNo);
    end;

    procedure GetCompanyVATRegNo(VATRegNo: Text[20]): Text[30];
    begin
        ReadCompanyInfo();
        if COPYSTR(VATRegNo, 1, 2) <> CompanyInfo."Country/Region Code" then
            exit(CompanyInfo."Country/Region Code" + VATRegNo);
        exit(VATRegNo);
    end;

    [Obsolete('GetCustomerVATRegNoIncCustomerCountryCode is the new correct version of the function','16.0')]
    procedure GetCustomerVATRegNo(VATRegNo: Text[20]): Text[30];
    begin
        ReadCompanyInfo();
        if COPYSTR(VATRegNo, 1, 2) <> CompanyInfo."Country/Region Code" then
            exit(CompanyInfo."Country/Region Code" + VATRegNo);
        exit(VATRegNo);
    end;

    procedure GetCustomerVATRegNoIncCustomerCountryCode(VATRegNo: Text[20]; CountryRegionCode: Code[10]): Text[30];
    begin
        if COPYSTR(VATRegNo, 1, 2) <> CountryRegionCode then
            exit(CountryRegionCode + VATRegNo);
        exit(VATRegNo);
    end;

    procedure GetUoMCode(UoMCode: Code[10]): Text;
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        if NOT UnitofMeasure.GET(UoMCode) then
            exit(FORMAT(UoMCode));
        if UnitofMeasure."International Standard Code" <> '' then
            exit(UnitofMeasure."International Standard Code");
        exit(UoMCode);
    end;
}