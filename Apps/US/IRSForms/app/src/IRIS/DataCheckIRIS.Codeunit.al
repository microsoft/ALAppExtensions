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
        TransmissionContext: Record "Transmission IRIS";
        Helper: Codeunit "Helper IRIS";
        OAuthClient: Codeunit "OAuth Client IRIS";
        ErrorMessageMgt: Codeunit "Error Message Management";
        EmptyFieldErr: Label 'must be set.';
        PeriodNoErr: Label 'The period of the transmission must be a valid year in the format YYYY.';
        VendorNotFoundErr: Label 'The vendor %1 is not found for the document %2.', Comment = '%1 - vendor number, %2 - document ID';
        IncorrectTINLengthErr: Label '(TIN) must be exactly %1 digits long.', Comment = '%1 - expected length';
        IncorrectFieldLengthErr: Label 'must be between %1 and %2 characters. Allowed characters: %3.', Comment = '%1 - min length, %2 - max length, %3 - allowed characters';
        IncorrectPhoneNoLengthErr: Label 'must be between %1 and %2 digits. Multiple numbers or extensions numbers can be separated by commas.', Comment = '%1 - min length, %2 - max length';
        IncorrectStateAbbrErr: Label 'must be a valid 2-letter US state code. Example: WA, IL, FL.';
        IncorrectZipCodeErr: Label 'must be 5, 9 or 12 digits.';
        PersonNameAllowedCharsTxt: Label 'A-Z, a-z, 0-9, hyphen, apostrophe and single space';
        UserIDMustBeSetErr: Label 'IRIS User ID must be specified. Use the action Setup IRIS User ID on the IRS Forms Setup page to see instructions for getting your IRIS User ID.';
        DuplicateTINErr: Label '%1 vendors have the same TIN %2. Set up different Preferred Bank Account Codes with unique Bank Account No. for each vendor. Use the Open Related Record action to see the affected vendors.', Comment = '%1 - number of vendors, %2 - TIN';

    procedure CheckDataToReport(var Transmission: Record "Transmission IRIS")
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ProcessTransmission: Codeunit "Process Transmission IRIS";
    begin
        Helper.GetAmtXmlElementsFileContent(Transmission."Period No.");

        TransmissionContext := Transmission;
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
        ContactPersonName: Text;
        PhoneNo: Text;
        ZipCode: Text;
        StateCode: Text;
    begin
        CompanyInformation.Get();

        TIN := Helper.FormatTIN(CompanyInformation."Federal ID No.");
        if StrLen(TIN) <> GetTINLength() then
            ErrorMessageMgt.LogFieldError(
                CompanyInformation, CompanyInformation.FieldNo("Federal ID No."),
                StrSubstNo(IncorrectTINLengthErr, GetTINLength()));

        ContactPersonName := Helper.FormatContactPersonName(CompanyInformation."Contact Person");
        if (StrLen(ContactPersonName) < 1) or (StrLen(ContactPersonName) > GetPersonNameMaxLength()) then
            ErrorMessageMgt.LogFieldError(
                CompanyInformation, CompanyInformation.FieldNo("Contact Person"),
                StrSubstNo(IncorrectFieldLengthErr, 1, GetPersonNameMaxLength(), PersonNameAllowedCharsTxt));

        PhoneNo := Helper.FormatPhoneNumber(CompanyInformation."Phone No.");
        if (StrLen(PhoneNo) < GetPhoneNoMinLength()) or (StrLen(PhoneNo) > GetPhoneNoMaxLength()) then
            ErrorMessageMgt.LogFieldError(
                CompanyInformation, CompanyInformation.FieldNo("Phone No."),
                StrSubstNo(IncorrectPhoneNoLengthErr, GetPhoneNoMinLength(), GetPhoneNoMaxLength()));

        // only for US
        if not Helper.IsForeignCountryRegion(CompanyInformation."Country/Region Code") then begin
            if not Helper.MatchStateCode(CompanyInformation.County, StateCode) then
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
        StateCode: Text;
        VendorList: Dictionary of [Text, Text];
        VendorsByFormNo: Dictionary of [Code[20], List of [Code[20]]];
        VendorNo: Text;
    begin
        if not IRS1099FormDocHeader.FindSet() then
            exit;

        Vendor.SetLoadFields("No.", "Federal ID No.", "Country/Region Code", "County", "Post Code", City, "Preferred Bank Account Code");

        // add unique vendors to the list and collect vendor-form mapping
        repeat
            if not Vendor.Get(IRS1099FormDocHeader."Vendor No.") then begin
                ErrorMessageMgt.LogError(
                    IRS1099FormDocHeader, StrSubstNo(VendorNotFoundErr, IRS1099FormDocHeader."Vendor No.", IRS1099FormDocHeader.ID), '');
                continue;
            end;

            if not VendorList.ContainsKey(Vendor."No.") then
                VendorList.Add(Vendor."No.", '');

            AddVendorToFormNoGroup(VendorsByFormNo, Vendor."No.", IRS1099FormDocHeader."Form No.");
        until IRS1099FormDocHeader.Next() = 0;

        foreach VendorNo in VendorList.Keys do begin
            Vendor.Get(VendorNo);
            TIN := Helper.FormatTIN(Vendor."Federal ID No.");
            if StrLen(TIN) <> GetTINLength() then
                ErrorMessageMgt.LogFieldError(
                    Vendor, Vendor.FieldNo("Federal ID No."),
                    StrSubstNo(IncorrectTINLengthErr, GetTINLength()));

            if not Helper.IsForeignCountryRegion(Vendor."Country/Region Code") then begin
                if not Helper.MatchStateCode(Vendor.County, StateCode) then
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

        ValidateDuplicateTINs(VendorsByFormNo);
    end;

    local procedure AddVendorToFormNoGroup(var VendorsByFormNo: Dictionary of [Code[20], List of [Code[20]]]; VendorNo: Code[20]; FormNo: Code[20])
    var
        FormVendorNos: List of [Code[20]];
    begin
        if not VendorsByFormNo.ContainsKey(FormNo) then
            VendorsByFormNo.Add(FormNo, FormVendorNos);
        VendorsByFormNo.Get(FormNo, FormVendorNos);
        if not FormVendorNos.Contains(VendorNo) then
            FormVendorNos.Add(VendorNo);
        VendorsByFormNo.Set(FormNo, FormVendorNos);
    end;

    local procedure ValidateDuplicateTINs(VendorsByFormNo: Dictionary of [Code[20], List of [Code[20]]])
    var
        VendorNos: List of [Code[20]];
        FormNo: Code[20];
    begin
        // check duplicate TINs within each submission (form type)
        foreach FormNo in VendorsByFormNo.Keys do begin
            VendorsByFormNo.Get(FormNo, VendorNos);
            ValidateDuplicateTINsForSubmission(VendorNos);
        end;
    end;

    local procedure ValidateDuplicateTINsForSubmission(SubmissionVendorNos: List of [Code[20]])
    var
        Vendor: Record Vendor;
        VendorsByTIN: Dictionary of [Text, List of [Code[20]]];
        TINVendorNos: List of [Code[20]];
        BankAccountNumbers: Dictionary of [Text, Text];
        VendorNo: Code[20];
        TIN: Text;
        BankAccountNo: Text;
        VendorFilter: Text;
        HasError: Boolean;
    begin
        Vendor.SetLoadFields("No.", "Federal ID No.", "Preferred Bank Account Code");

        // Group vendors by TIN within this submission
        foreach VendorNo in SubmissionVendorNos do
            if Vendor.Get(VendorNo) then begin
                TIN := Helper.FormatTIN(Vendor."Federal ID No.");
                if TIN <> '' then begin
                    if not VendorsByTIN.ContainsKey(TIN) then begin
                        Clear(TINVendorNos);
                        VendorsByTIN.Add(TIN, TINVendorNos);
                    end;
                    VendorsByTIN.Get(TIN, TINVendorNos);
                    if not TINVendorNos.Contains(Vendor."No.") then
                        TINVendorNos.Add(Vendor."No.");
                    VendorsByTIN.Set(TIN, TINVendorNos);
                end;
            end;

        // Check each TIN group with multiple vendors
        foreach TIN in VendorsByTIN.Keys do begin
            VendorsByTIN.Get(TIN, TINVendorNos);
            if TINVendorNos.Count() > 1 then begin
                Clear(BankAccountNumbers);
                HasError := false;
                VendorFilter := '';

                foreach VendorNo in TINVendorNos do begin
                    Vendor.Get(VendorNo);
                    BankAccountNo := Helper.GetVendorBankAccountNo(Vendor);

                    if BankAccountNo = '' then
                        HasError := true;

                    if BankAccountNumbers.ContainsKey(BankAccountNo) then
                        HasError := true
                    else
                        BankAccountNumbers.Add(BankAccountNo, '');

                    if VendorFilter <> '' then
                        VendorFilter += '|';
                    VendorFilter += Vendor."No.";
                end;

                if HasError then
                    LogDuplicateTINError(TIN, TINVendorNos.Count(), CopyStr(VendorFilter, 1, 250));
            end;
        end;
    end;

    local procedure LogDuplicateTINError(TIN: Text; VendorCount: Integer; VendorFilter: Text[250])
    var
        Vendor: Record Vendor;
        ErrorContextElement: Codeunit "Error Context Element";
    begin
        ErrorMessageMgt.PushContext(ErrorContextElement, TransmissionContext, 0, VendorFilter);
        ErrorMessageMgt.LogError(Vendor, StrSubstNo(DuplicateTINErr, VendorCount, TIN), '');
        ErrorMessageMgt.PopContext(ErrorContextElement);
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
}