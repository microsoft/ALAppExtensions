// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using System.Utilities;

codeunit 10044 "Data Check IRIS"
{
    Access = Internal;

    var
        Helper: Codeunit "Helper IRIS";
        OAuthClient: Codeunit "OAuth Client IRIS";
        ErrorMessageMgt: Codeunit "Error Message Management";
        EmptyFieldErr: Label 'must be set.';
        PeriodNoErr: Label 'The period of the transmission must be a valid year in the format YYYY.';
        VendorNotFoundErr: Label 'The vendor %1 is not found for the document %2.', Comment = '%1 - vendor number, %2 - document ID';
        IncorrectTINLengthErr: Label '(TIN) must be exactly %1 digits long.', Comment = '%1 - expected length';
        IncorrectPhoneNoLengthErr: Label 'must be between %1 and %2 digits. Multiple numbers or extensions numbers can be separated by commas.', Comment = '%1 - min length, %2 - max length';
        IncorrectEmailErr: Label 'address must be between %1 and %2 characters and include @ symbol.', Comment = '%1 - min length, %2 - max length';
        IncorrectFieldLengthErr: Label 'must be between %1 and %2 characters. Allowed characters: %3.', Comment = '%1 - min length, %2 - max length, %3 - allowed characters';
        IncorrectStateAbbrErr: Label 'must be a valid 2-letter US state code. Example: WA, IL, FL.';
        IncorrectZipCodeErr: Label 'must be 5, 9 or 12 digits.';
        PersonNameAllowedCharsTxt: Label 'A-Z, a-z, 0-9, hyphen, apostrophe and single space';
        UserIDMustBeSetErr: Label 'IRIS User ID must be specified. Use the action Setup IRIS User ID on the IRS Forms Setup page to see instructions for getting your IRIS User ID.';

    procedure CheckDataToReport(var Transmission: Record "Transmission IRIS")
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ProcessTransmission: Codeunit "Process Transmission IRIS";
    begin
        Helper.GetAmtXmlElementsFileContent(Transmission."Period No.");

        ErrorMessageMgt.Activate(ErrorMessageHandler);

        ValidateSetup();
        ValidateTransmission(Transmission);
        ValidateCompanyInformation();

        IRS1099FormDocHeader.SetRange("IRIS Transmission Document ID", Transmission."Document ID");
        IRS1099FormDocHeader.SetFilter(Status, ProcessTransmission.GetFormDocToSendStatusFilter());
        ValidateVendors(IRS1099FormDocHeader);

        if ErrorMessageHandler.HasErrors() then begin
            ErrorMessageHandler.ShowErrors();
            Error('');
        end;
    end;

    local procedure ValidateSetup()
    var
        IRSFormsSetup: Record "IRS Forms Setup";

    begin
        IRSFormsSetup.Get();
        if IRSFormsSetup."Business Name Control" = '' then
            ErrorMessageMgt.LogFieldError(IRSFormsSetup, IRSFormsSetup.FieldNo("Business Name Control"), EmptyFieldErr);

        ValidateUserID();
    end;

    [NonDebuggable]
    local procedure ValidateUserID()
    var
        IRSFormsSetup: Record "IRS Forms Setup";
        UserParamsIRIS: Record "User Params IRIS";
        UserID: SecretText;
    begin
        UserParamsIRIS.GetRecord();
        UserID := OAuthClient.GetToken(UserParamsIRIS."IRIS User ID Key");
        if UserID.IsEmpty() then
            ErrorMessageMgt.LogError(IRSFormsSetup, UserIDMustBeSetErr, '');
    end;

    local procedure ValidateTransmission(Transmission: Record "Transmission IRIS")
    var
        PeriodNoInt: Integer;
    begin
        if not Evaluate(PeriodNoInt, Transmission."Period No.") then
            ErrorMessageMgt.LogFieldError(Transmission, Transmission.FieldNo("Period No."), PeriodNoErr);

        if (PeriodNoInt < 2000) or (PeriodNoInt > 3000) then
            ErrorMessageMgt.LogFieldError(Transmission, Transmission.FieldNo("Period No."), PeriodNoErr);
    end;

    local procedure ValidateCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
        TIN: Text;
        PhoneNo: Text;
        ContactPersonName: Text;
        ContactEmail: Text;
        ZipCode: Text;
        StateTypeIRIS: Enum "State Type IRIS";
    begin
        CompanyInformation.Get();

        TIN := Helper.FormatTIN(CompanyInformation."Federal ID No.");
        if StrLen(TIN) <> GetTINLength() then
            ErrorMessageMgt.LogFieldError(
                CompanyInformation, CompanyInformation.FieldNo("Federal ID No."),
                StrSubstNo(IncorrectTINLengthErr, GetTINLength()));

        PhoneNo := Helper.FormatPhoneNumber(CompanyInformation."Phone No.");
        if (StrLen(PhoneNo) < GetPhoneNoMinLength()) or (StrLen(PhoneNo) > GetPhoneNoMaxLength()) then
            ErrorMessageMgt.LogFieldError(
                CompanyInformation, CompanyInformation.FieldNo("Phone No."),
                StrSubstNo(IncorrectPhoneNoLengthErr, GetPhoneNoMinLength(), GetPhoneNoMaxLength()));

        ContactPersonName := Helper.FormatContactPersonName(CompanyInformation."Contact Person");
        if (StrLen(ContactPersonName) < 1) or (StrLen(ContactPersonName) > GetPersonNameMaxLength()) then
            ErrorMessageMgt.LogFieldError(
                CompanyInformation, CompanyInformation.FieldNo("Contact Person"),
                StrSubstNo(IncorrectFieldLengthErr, 1, GetPersonNameMaxLength(), PersonNameAllowedCharsTxt));

        ContactEmail := CompanyInformation."E-Mail";
        if (StrLen(ContactEmail) < 1) or (StrLen(ContactEmail) > GetEmailMaxLength()) or
           (StrPos(ContactEmail, '@') <= 1) or (StrPos(ContactEmail, '@') = StrLen(ContactEmail))
        then
            ErrorMessageMgt.LogFieldError(
                CompanyInformation, CompanyInformation.FieldNo("E-Mail"), StrSubstNo(IncorrectEmailErr, 1, GetEmailMaxLength()));

        // only for US
        if not Helper.IsForeignCountryRegion(CompanyInformation."Country/Region Code") then begin
            if not Evaluate(StateTypeIRIS, CompanyInformation.County) then
                ErrorMessageMgt.LogFieldError(CompanyInformation, CompanyInformation.FieldNo(County), IncorrectStateAbbrErr);

            ZipCode := Helper.FormatZipCode(CompanyInformation."Post Code");
            if not (StrLen(ZipCode) in [5, 9, 12]) then
                ErrorMessageMgt.LogFieldError(CompanyInformation, CompanyInformation.FieldNo("Post Code"), IncorrectZipCodeErr);
        end
    end;

    local procedure ValidateVendors(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header")
    var
        Vendor: Record Vendor;
        TIN: Text;
        ZipCode: Text;
        CityName: Text;
        StateTypeIRIS: Enum "State Type IRIS";
        VendorList: Dictionary of [Text, Text];
        VendorNo: Text;
    begin
        if not IRS1099FormDocHeader.FindSet() then
            exit;

        Vendor.SetLoadFields("No.", "Federal ID No.", "Country/Region Code", "County", "Post Code", City);

        // add unique vendors to the list
        repeat
            if not Vendor.Get(IRS1099FormDocHeader."Vendor No.") then begin
                ErrorMessageMgt.LogError(
                    IRS1099FormDocHeader, StrSubstNo(VendorNotFoundErr, IRS1099FormDocHeader."Vendor No.", IRS1099FormDocHeader.ID), '');
                continue;
            end;

            if not VendorList.ContainsKey(Vendor."No.") then
                VendorList.Add(Vendor."No.", '');
        until IRS1099FormDocHeader.Next() = 0;

        foreach VendorNo in VendorList.Keys do begin
            Vendor.Get(VendorNo);
            TIN := Helper.FormatTIN(Vendor."Federal ID No.");
            if StrLen(TIN) <> GetTINLength() then
                ErrorMessageMgt.LogFieldError(
                    Vendor, Vendor.FieldNo("Federal ID No."),
                    StrSubstNo(IncorrectTINLengthErr, GetTINLength()));

            if not Helper.IsForeignCountryRegion(Vendor."Country/Region Code") then begin
                if not Evaluate(StateTypeIRIS, Vendor.County) then
                    ErrorMessageMgt.LogFieldError(Vendor, Vendor.FieldNo(County), IncorrectStateAbbrErr);

                ZipCode := Helper.FormatZipCode(Vendor."Post Code");
                if not (StrLen(ZipCode) in [5, 9, 12]) then
                    ErrorMessageMgt.LogFieldError(Vendor, Vendor.FieldNo("Post Code"), IncorrectZipCodeErr);

                // city name is optional in xml schema, but transmission is not processed without it
                CityName := Helper.FormatCityName(Vendor.City, Enum::"Address Type IRIS"::USAddress);
                if CityName = '' then
                    ErrorMessageMgt.LogFieldError(Vendor, Vendor.FieldNo(City), EmptyFieldErr);
            end;
        end;
    end;

    procedure GetFormBoxListWithEmptyAmtXmlElemName(PeriodNo: Code[20]) FormBoxes: List of [Text]
    var
        IRS1099FormBox: Record "IRS 1099 Form Box";
        AmountXmlElementNames: Dictionary of [Text, Text];
        AmtXmlElemName: Text;
    begin
        AmountXmlElementNames := Helper.GetFormBoxAmountXmlElementNames(PeriodNo);
        IRS1099FormBox.SetRange("Period No.", PeriodNo);
        if IRS1099FormBox.FindSet() then
            repeat
                AmtXmlElemName := '';
                if AmountXmlElementNames.Get(IRS1099FormBox."No.", AmtXmlElemName) then;
                if AmtXmlElemName = '' then
                    FormBoxes.Add(StrSubstNo('%1 %2', IRS1099FormBox."No.", IRS1099FormBox.Description));
            until IRS1099FormBox.Next() = 0;
    end;

    local procedure GetTINLength(): Integer
    begin
        exit(9);
    end;

    local procedure GetPersonNameMaxLength(): Integer
    begin
        exit(35);
    end;

    local procedure GetPhoneNoMinLength(): Integer
    begin
        exit(10);
    end;

    local procedure GetPhoneNoMaxLength(): Integer
    begin
        exit(30);
    end;

    local procedure GetEmailMaxLength(): Integer
    begin
        exit(75);
    end;
}