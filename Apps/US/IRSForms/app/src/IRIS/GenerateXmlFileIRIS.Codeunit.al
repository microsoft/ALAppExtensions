// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.CRM.Contact;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Enums;
using Microsoft.Purchases.Vendor;
using System.Telemetry;
using System.Utilities;

codeunit 10033 "Generate Xml File IRIS"
{
    Access = Internal;

    var
        Helper: Codeunit "Helper IRIS";
        KeyVaultClient: Codeunit "Key Vault Client IRIS";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SubmissionIdGlobal: Integer;
        RecordIdGlobal: Integer;
        TotalSubmissionCountGlobal: Integer;
        TotalRecordCountGlobal: Integer;
        UsedSubmissionIdsGlobal: Dictionary of [Text, Integer];
        UsedRecordIdsGlobal: Dictionary of [Text, Integer];
        CorrectionToZeroModeGlobal: Boolean;
        TransmissionTypeGlobal: Enum "Transmission Type IRIS";
        TransmRootNodeNameTxt: label 'IRTransmission', Locked = true;
        GetStatusRootNodeNameTxt: Label 'TransStatusOrAckRequest', Locked = true;
        MailingAddressGrpTxt: Label 'MailingAddressGrp', Locked = true;
        Form1099TotalAmtGrpTxt: Label 'Form%1TotalAmtGrp', Comment = '%1 - Form Type Code, ex. 1099INT', Locked = true;
        Form1099DetailTxt: Label 'Form%1Detail', Comment = '%1 - Form Type Code, ex. 1099INT', Locked = true;
        CorrectionToZeroModeErr: Label 'Correction to zero mode can only be used for corrections.', Locked = true;
        CreateAckRequestEventTxt: Label 'CreateAcknowledgementRequest', Locked = true;
        CreateGetStatusRequestEventTxt: Label 'CreateGetStatusRequest', Locked = true;
        NoDocumentsSelectedErr: Label 'No 1099 documents were selected for the transmission of the type %1. Current filters: \%2', Comment = '%1 - transmission type, %2 - filters for IRS 1099 Form Doc. Header';
        EmptySearchIdErr: Label 'Record Id or Unique Transmission ID cannot be empty.';

    procedure CreateTransmission(var Transmission: Record "Transmission IRIS"; TransmissionType: Enum "Transmission Type IRIS"; var UniqueTransmissionId: Text[100]; var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary; var TempBlob: Codeunit "Temp Blob")
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        ProcessTransmission: Codeunit "Process Transmission IRIS";
        FormType: Text;
    begin
        if CorrectionToZeroModeGlobal then
            if TransmissionType <> Enum::"Transmission Type IRIS"::"C" then
                Error(CorrectionToZeroModeErr);

        IRS1099FormDocHeader.SetRange("IRIS Transmission Document ID", Transmission."Document ID");
        IRS1099FormDocHeader.SetFilter(Status, ProcessTransmission.GetFormDocToSendStatusFilter());
        case TransmissionType of
            Enum::"Transmission Type IRIS"::"R":
                IRS1099FormDocHeader.SetRange("IRIS Submission Status", Enum::"Transmission Status IRIS"::Rejected);  // replace only rejected submissions
            Enum::"Transmission Type IRIS"::"C":
                IRS1099FormDocHeader.SetRange("IRIS Needs Correction", true);
        end;

        if not IRS1099FormDocHeader.FindSet() then
            Error(NoDocumentsSelectedErr, TransmissionType, IRS1099FormDocHeader.GetFilters());

        TempIRS1099FormDocHeader.Reset();
        TempIRS1099FormDocHeader.DeleteAll();
        repeat
            TempIRS1099FormDocHeader := IRS1099FormDocHeader;
            TempIRS1099FormDocHeader.Insert();
        until IRS1099FormDocHeader.Next() = 0;

        UniqueTransmissionId := Helper.CreateUniqueTransmissionIdentifier();
        TransmissionTypeGlobal := TransmissionType;
        InitSubmissionAndRecordIds(Transmission."Document ID");

        InitTransmissionDocElement();
        AddIRTransmissionManifest(Transmission, UniqueTransmissionId, TransmissionType);

        // add IRSubmission1Grp for each form type: DIV, INT, MISC, NEC
        foreach FormType in "Form Type IRIS".Names() do begin
            TempIRS1099FormDocHeader.Reset();
            TempIRS1099FormDocHeader.SetRange("Form No.", FormType);
            if not TempIRS1099FormDocHeader.IsEmpty() then
                AddIRSubmission1Grp(TempIRS1099FormDocHeader);
        end;
        Helper.UpdateSingleXmlNode('TotalIssuerFormCnt', Format(TotalSubmissionCountGlobal));
        Helper.UpdateSingleXmlNode('TotalRecipientFormCnt', Format(TotalRecordCountGlobal));

        Helper.WriteXMLDocToTempBlob(TempBlob);

        // save SubmissionId and RecordId to use them later for replacements
        TempIRS1099FormDocHeader.Reset();
        TempIRS1099FormDocHeader.FindSet();
        repeat
            IRS1099FormDocHeader.Get(TempIRS1099FormDocHeader.ID);
            IRS1099FormDocHeader."IRIS Submission ID" := TempIRS1099FormDocHeader."IRIS Submission ID";
            IRS1099FormDocHeader."IRIS Record ID" := TempIRS1099FormDocHeader."IRIS Record ID";
            IRS1099FormDocHeader.Modify();
        until TempIRS1099FormDocHeader.Next() = 0;

        FeatureTelemetry.LogUptake('0000P83', Helper.GetIRISFeatureName(), Enum::"Feature Uptake Status"::"Used");
    end;

    /// <summary>
    /// Set the special correction mode to indicate that all the amounts in the correction transmission should be set to zero.
    /// </summary>
    procedure SetCorrectionToZeroMode(CorrectionToZeroMode: Boolean)
    begin
        CorrectionToZeroModeGlobal := CorrectionToZeroMode;
    end;

    local procedure InitTransmissionDocElement()
    begin
        Helper.Initialize(TransmRootNodeNameTxt);
    end;

    local procedure InitGetStatusDocElement()
    begin
        Helper.Initialize(GetStatusRootNodeNameTxt);
    end;

    local procedure AddIRTransmissionManifest(var Transmission: Record "Transmission IRIS"; UniqueTransmissionId: Text; TransmissionType: Enum "Transmission Type IRIS")
    var
        PrevTransmissionStatus: Enum "Transmission Status IRIS";
    begin
        Helper.AddParentXmlNode('IRTransmissionManifest');
        Helper.AppendXmlNode('UniqueTransmissionId', UniqueTransmissionId);
        Helper.AppendXmlNode('TaxYr', Transmission."Period No.");
        Helper.AppendXmlNode('PriorYearDataInd', '0');
        Helper.AppendXmlNode('TransmissionTypeCd', Helper.GetTransmissionTypeName(TransmissionType));
        Helper.AppendXmlNode('TestCd', GetTestFileIndicator());

        // add OriginalReceiptId when the whole transmission is replaced
        PrevTransmissionStatus := Transmission.Status;
        if (TransmissionType = Enum::"Transmission Type IRIS"::"R") and
           (PrevTransmissionStatus = Enum::"Transmission Status IRIS"::Rejected)
        then
            Helper.AppendXmlNode('OriginalReceiptId', Transmission."Original Receipt ID");

        AddTransmitterInfo();

        Helper.AppendXmlNode('VendorCd', 'I');
        Helper.AppendXmlNode('SoftwareId', KeyVaultClient.GetSoftwareId());


        Helper.AppendXmlNode('TotalIssuerFormCnt', 'N');            // updated after all forms are added
        Helper.AppendXmlNode('TotalRecipientFormCnt', 'N');         // updated after all forms are added
        Helper.AppendXmlNode('PaperSubmissionInd', '0');
        Helper.AppendXmlNode('MediaSourceCd', 'M');
        Helper.AppendXmlNode('SubmissionChannelCd', 'A2A');

        Helper.CloseParentXmlNode();
    end;

    local procedure AddTransmitterInfo()
    var
        TIN: Text;
        CompanyName: Text;
        StreetAddress: Text;
        CityName: Text;
        StateCode: Text;
        PostCode: Text;
        ContactName: Text;
        ContactEmail: Text;
        ContactPhone: Text;
    begin
        Helper.AddParentXmlNode('TransmitterGrp');

        GetMicrosoftData(TIN, CompanyName, StreetAddress, CityName, StateCode, PostCode, ContactName, ContactEmail, ContactPhone);
        Helper.AppendXmlNode('TIN', Helper.FormatTIN(TIN));
        Helper.AppendXmlNode('TINSubmittedTypeCd', 'BUSINESS_TIN');
        Helper.AppendXmlNode('TransmitterControlCd', KeyVaultClient.GetTCC());
        Helper.AppendXmlNode('ForeignEntityInd', '0');

        AddBusinessName(CompanyName);

        Helper.AddParentXmlNode('CompanyGrp');
        AddBusinessName(CompanyName);
        AddUSAddress(MailingAddressGrpTxt, StreetAddress, CityName, StateCode, PostCode);
        Helper.CloseParentXmlNode();

        Helper.AddParentXmlNode('ContactNameGrp');
        Helper.AppendXmlNode('PersonNm', ContactName);
        Helper.CloseParentXmlNode();
        Helper.AppendXmlNode('ContactEmailAddressTxt', ContactEmail);
        Helper.AppendXmlNode('ContactPhoneNum', ContactPhone);

        Helper.CloseParentXmlNode();
    end;

    local procedure AddIRSubmission1Grp(var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary)
    var
        VendorList: List of [Text];
    begin
        // one submission must be used for one form type and one tax year
        Helper.AddParentXmlNode('IRSubmission1Grp');

        VendorList := GetVendorList(TempIRS1099FormDocHeader);
        AddIRSubmission1Header(GetNextSubmissionId(TempIRS1099FormDocHeader."IRIS Submission ID"), TempIRS1099FormDocHeader, VendorList.Count());
        AddIRSubmission1Detail(TempIRS1099FormDocHeader, VendorList);

        Helper.CloseParentXmlNode();
    end;

    local procedure AddIRSubmission1Header(SubmissionId: Text[20]; var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary; RecipientFormCount: Integer)
    var
        Transmission: Record "Transmission IRIS";
        PrevTransmissionStatus: Enum "Transmission Status IRIS";
        OriginalUniqueSubmissionId: Text;
    begin
        Helper.AddParentXmlNode('IRSubmission1Header');

        Helper.AppendXmlNode('SubmissionId', SubmissionId);

        Transmission.Get(TempIRS1099FormDocHeader."IRIS Transmission Document ID");
        PrevTransmissionStatus := Transmission.Status;
        if (TransmissionTypeGlobal = Enum::"Transmission Type IRIS"::"R") and
           (PrevTransmissionStatus = Enum::"Transmission Status IRIS"::"Partially Accepted")
        then begin
            OriginalUniqueSubmissionId := StrSubstNo('%1|%2', Transmission."Receipt ID", TempIRS1099FormDocHeader."IRIS Submission ID");
            Helper.AppendXmlNode('OriginalUniqueSubmissionId', OriginalUniqueSubmissionId);
        end;

        Helper.AppendXmlNode('TaxYr', TempIRS1099FormDocHeader."Period No.");

        AddIssuerDetails();
        AddContactPersonInformationGrp();

        Helper.AppendXmlNode('FormTypeCd', GetFormTypeCode(TempIRS1099FormDocHeader."Form No."));
        Helper.AppendXmlNode('ParentFormTypeCd', '1096');
        Helper.AppendXmlNode('CFSFElectionInd', '0');
        Helper.AppendXmlNode('TotalReportedRcpntFormCnt', Format(RecipientFormCount));

        AddIRSubmission1FormTotals(TempIRS1099FormDocHeader);

        Helper.CloseParentXmlNode();

        // update SubmissionId for temporary IRS 1099 Document records
        if TempIRS1099FormDocHeader.FindSet() then
            repeat
                TempIRS1099FormDocHeader."IRIS Submission ID" := CopyStr(SubmissionId, 1, MaxStrLen(TempIRS1099FormDocHeader."IRIS Submission ID"));
                TempIRS1099FormDocHeader.Modify();
            until TempIRS1099FormDocHeader.Next() = 0;
    end;

    local procedure AddIRSubmission1FormTotals(var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary)
    var
        FormType: Enum "Form Type IRIS";
        FormTotalAmounts: Dictionary of [Text, Decimal];
        TotalReportedAmt: Decimal;
        FederalIncomeTaxWithheldAmt: Decimal;
        Form1099TotalAmtGrpTagName: Text;
        FormBoxAmtXmlElemNamesValues: Dictionary of [Text, Text];
        AmtXmlElemNames: List of [Text];
        AmtXmlElemName: Text;
        AmtXmlElemValue: Text;
    begin
        if not Evaluate(FormType, TempIRS1099FormDocHeader."Form No.") then
            exit;

        Helper.AddParentXmlNode('IRSubmission1FormTotals');

        CalcFormTotalAmounts(TempIRS1099FormDocHeader, FormTotalAmounts, TotalReportedAmt, FederalIncomeTaxWithheldAmt);
        GetFormBoxAmtXmlElemNamesAndValues(TempIRS1099FormDocHeader, FormTotalAmounts, FormBoxAmtXmlElemNamesValues);
        FormBoxAmtXmlElemNamesValues.Add('TotalReportedAmt', Helper.FormatDecimal(TotalReportedAmt));

        Form1099TotalAmtGrpTagName := GetForm1099TotalAmtGrpTagName(FormType);

        Helper.AddParentXmlNode(Form1099TotalAmtGrpTagName);

        // elements with total amounts must be added in a specific order
        AmtXmlElemNames := Helper.GetTotalAmountsXmlElementsOrder(TempIRS1099FormDocHeader."Period No.", FormType);
        foreach AmtXmlElemName in AmtXmlElemNames do
            if FormBoxAmtXmlElemNamesValues.Get(AmtXmlElemName, AmtXmlElemValue) then
                Helper.AppendXmlNode(AmtXmlElemName, AmtXmlElemValue);

        Helper.CloseParentXmlNode();

        Helper.CloseParentXmlNode();
    end;

    local procedure AddIssuerDetails()
    var
        CompanyInformation: Record "Company Information";
        IRSFormsSetup: Record "IRS Forms Setup";
        RecRef: RecordRef;
    begin
        Helper.AddParentXmlNode('IssuerDetail');

        CompanyInformation.Get();
        IRSFormsSetup.Get();
        Helper.AppendXmlNode('ForeignEntityInd', GetForeignEntityInd(CompanyInformation."Country/Region Code"));
        Helper.AppendXmlNode('TIN', Helper.FormatTIN(CompanyInformation."Federal ID No."));
        Helper.AppendXmlNode('TINSubmittedTypeCd', 'BUSINESS_TIN');
        Helper.AppendXmlNode('BusinessNameControlTxt', IRSFormsSetup."Business Name Control");

        AddBusinessName(Helper.ConcatenateWithSpace(CompanyInformation.Name, CompanyInformation."Name 2"));

        RecRef.GetTable(CompanyInformation);
        AddAddress(MailingAddressGrpTxt, RecRef);

        Helper.AppendXmlNode('PhoneNum', Helper.FormatPhoneNumber(CompanyInformation."Phone No."));

        Helper.CloseParentXmlNode();
    end;

    local procedure AddContactPersonInformationGrp()
    var
        CompanyInformation: Record "Company Information";
    begin
        Helper.AddParentXmlNode('ContactPersonInformationGrp');

        CompanyInformation.Get();
        Helper.AppendXmlNode('ContactPersonNm', Helper.FormatContactPersonName(CompanyInformation."Contact Person"));
        Helper.AppendXmlNode('ContactPhoneNum', Helper.FormatPhoneNumber(CompanyInformation."Phone No."));
        Helper.AppendXmlNode('ContactEmailAddressTxt', CompanyInformation."E-Mail");

        Helper.CloseParentXmlNode();
    end;

    local procedure AddIRSubmission1Detail(var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary; VendorList: List of [Text])
    var
        VendorNo: Text;
    begin
        Helper.AddParentXmlNode('IRSubmission1Detail');

        foreach VendorNo in VendorList do begin
            TempIRS1099FormDocHeader.SetRange("Vendor No.", VendorNo);
            AddForm1099Detail(TempIRS1099FormDocHeader);
        end;

        Helper.CloseParentXmlNode();
    end;

    local procedure AddForm1099Detail(var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary)
    var
        Vendor: Record Vendor;
        FormType: Enum "Form Type IRIS";
        RecordId: Text[20];
        Form1099DetailTagName: Text;
        TotalAmounts: Dictionary of [Text, Decimal];
        FormBoxAmtXmlElemNamesValues: Dictionary of [Text, Text];
        AmtXmlElemNames: List of [Text];
        AmtXmlElemName: Text;
        AmtXmlElemValue: Text;
    begin
        if not TempIRS1099FormDocHeader.FindFirst() then
            exit;
        if not Evaluate(FormType, TempIRS1099FormDocHeader."Form No.") then
            exit;
        if not Vendor.Get(TempIRS1099FormDocHeader."Vendor No.") then
            exit;

        Form1099DetailTagName := GetForm1099DetailTagName(FormType);
        Helper.AddParentXmlNode(Form1099DetailTagName);

        RecordId := GetNextRecordId(TempIRS1099FormDocHeader."IRIS Record ID");
        Helper.AppendXmlNode('TaxYr', TempIRS1099FormDocHeader."Period No.");
        Helper.AppendXmlNode('RecordId', RecordId);
        Helper.AppendXmlNode('VoidInd', '0');
        Helper.AppendXmlNode('CorrectedInd', GetCorrectedInd(TransmissionTypeGlobal));

        if TransmissionTypeGlobal = "Transmission Type IRIS"::"C" then
            AddPrevSubmittedRecRecipientGrp(TempIRS1099FormDocHeader);

        AddRecipientDetails(Vendor);

        Helper.AppendXmlNode('RecipientAccountNum', GetVendorBankAccountNo(Vendor));

        CalcFormTotalAmounts(TempIRS1099FormDocHeader, TotalAmounts);
        GetFormBoxAmtXmlElemNamesAndValues(TempIRS1099FormDocHeader, TotalAmounts, FormBoxAmtXmlElemNamesValues);

        case FormType of
            FormType::"DIV":
                AddForm1099DIVDetailsPart(Vendor);
            FormType::"INT":
                AddForm1099INTDetailsPart(Vendor);
            FormType::"MISC":
                AddForm1099MISCDetailsPart(Vendor);
            FormType::"NEC":
                AddForm1099NECDetailsPart();
            else
                Helper.AddOtherForm1099DetailsPart(TempIRS1099FormDocHeader);
        end;

        AmtXmlElemNames := Helper.GetDetailAmountsXmlElementsOrder(TempIRS1099FormDocHeader."Period No.", FormType);
        foreach AmtXmlElemName in AmtXmlElemNames do
            if FormBoxAmtXmlElemNamesValues.Get(AmtXmlElemName, AmtXmlElemValue) then
                Helper.AppendXmlNode(AmtXmlElemName, AmtXmlElemValue);

        Helper.CloseParentXmlNode();

        // update RecordId for temporary IRS 1099 Document records
        if TempIRS1099FormDocHeader.FindSet() then
            repeat
                TempIRS1099FormDocHeader."IRIS Record ID" := CopyStr(RecordId, 1, MaxStrLen(TempIRS1099FormDocHeader."IRIS Record ID"));
                TempIRS1099FormDocHeader.Modify();
            until TempIRS1099FormDocHeader.Next() = 0;
    end;

    local procedure AddForm1099DIVDetailsPart(var Vendor: Record Vendor)
    begin
        Helper.AppendXmlNode('FATCAFilingRequirementInd', Helper.FormatBoolean(Vendor."FATCA Requirement"));
        Helper.AppendXmlNode('SecondTINNoticeInd', '0');
    end;

    local procedure AddForm1099INTDetailsPart(var Vendor: Record Vendor)
    begin
        Helper.AppendXmlNode('SecondTINNoticeInd', '0');
        Helper.AppendXmlNode('FATCAFilingRequirementInd', Helper.FormatBoolean(Vendor."FATCA Requirement"));
    end;

    local procedure AddForm1099MISCDetailsPart(var Vendor: Record Vendor)
    begin
        Helper.AppendXmlNode('SecondTINNoticeInd', '0');
        Helper.AppendXmlNode('FATCAFilingRequirementInd', Helper.FormatBoolean(Vendor."FATCA Requirement"));
    end;

    local procedure AddForm1099NECDetailsPart()
    begin
        Helper.AppendXmlNode('SecondTINNoticeInd', '0');
    end;

    local procedure AddPrevSubmittedRecRecipientGrp(var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary)
    var
        Transmission: Record "Transmission IRIS";
        PrevAcceptedReceiptId: Text[100];
        UniqueRecordId: Text;
    begin
        Helper.AddParentXmlNode('PrevSubmittedRecRecipientGrp');

        PrevAcceptedReceiptId := TempIRS1099FormDocHeader."IRIS Last Accepted Receipt ID";
        if PrevAcceptedReceiptId = '' then begin
            Transmission.Get(TempIRS1099FormDocHeader."IRIS Transmission Document ID");
            if Transmission.Status in [Enum::"Transmission Status IRIS"::Accepted, Enum::"Transmission Status IRIS"::"Partially Accepted", Enum::"Transmission Status IRIS"::"Accepted with Errors"] then
                PrevAcceptedReceiptId := Transmission."Receipt ID";
        end;

        UniqueRecordId := StrSubstNo('%1|%2|%3', PrevAcceptedReceiptId, TempIRS1099FormDocHeader."IRIS Submission ID", TempIRS1099FormDocHeader."IRIS Record ID");
        Helper.AppendXmlNode('UniqueRecordId', UniqueRecordId);

        Helper.CloseParentXmlNode();
    end;

    local procedure AddRecipientDetails(var Vendor: Record Vendor)
    var
        RecRef: RecordRef;
    begin
        Helper.AddParentXmlNode('RecipientDetail');

        Helper.AppendXmlNode('TIN', Helper.FormatTIN(Vendor."Federal ID No."));
        Helper.AppendXmlNode('TINSubmittedTypeCd', GetTINSubmittedType(Vendor."Tax Identification Type"));

        case Vendor."Tax Identification Type" of
            "Tax Identification Type"::"Legal Entity":
                AddBusinessName(Helper.ConcatenateWithSpace(Vendor.Name, Vendor."Name 2"));
            "Tax Identification Type"::"Natural Person":
                AddPersonName(Vendor);
        end;

        RecRef.GetTable(Vendor);
        AddAddress(MailingAddressGrpTxt, RecRef);

        Helper.CloseParentXmlNode();
    end;

    local procedure AddBusinessName(BusinessName: Text)
    var
        BusinessNameLine1: Text;
        BusinessNameLine2: Text;
    begin
        Helper.AddParentXmlNode('BusinessName');

        Helper.FormatBusinessName(BusinessName, BusinessNameLine1, BusinessNameLine2);
        Helper.AppendXmlNode('BusinessNameLine1Txt', BusinessNameLine1);
        Helper.AppendXmlNode('BusinessNameLine2Txt', BusinessNameLine2);

        Helper.CloseParentXmlNode();
    end;

    local procedure AddPersonName(var Vendor: Record Vendor)
    var
        Contact: Record Contact;
        FirstName: Text;
        MiddleName: Text;
        LastName: Text;
        FullName: List of [Text];
    begin
        Helper.AddParentXmlNode('PersonName');

        if Vendor."Primary Contact No." <> '' then
            if Contact.Get(Vendor."Primary Contact No.") then begin
                FirstName := Contact."First Name";
                MiddleName := Contact."Middle Name";
                LastName := Contact.Surname;
            end;

        if (FirstName = '') and (LastName = '') then begin
            FullName := Vendor.Name.Split(' ');
            if FullName.Get(1, FirstName) then;
            if FullName.Get(2, LastName) then;
            MiddleName := '';
        end;

        Helper.AppendXmlNode('PersonFirstNm', Helper.FormatPersonName(FirstName));
        Helper.AppendXmlNode('PersonMiddleNm', Helper.FormatPersonName(MiddleName));
        Helper.AppendXmlNode('PersonLastNm', Helper.FormatPersonName(LastName));

        Helper.CloseParentXmlNode();
    end;

    local procedure AddAddress(AddressTagName: Text; RecRef: RecordRef)
    var
        CompanyInformation: Record "Company Information";
        Vendor: Record Vendor;
        CountryRegion: Code[10];
        AddressLine1: Text;
        AddressLine2: Text;
        StreetAddress: Text;
        CityName: Text;
        ProvinceOrStateName: Text;
        FIPSCountryCode: Text;
        PostCode: Text;
    begin
        case RecRef.Number of
            Database::"Company Information":
                begin
                    CountryRegion := RecRef.Field(CompanyInformation.FieldNo("Country/Region Code")).Value;
                    AddressLine1 := RecRef.Field(CompanyInformation.FieldNo("Address")).Value;
                    AddressLine2 := RecRef.Field(CompanyInformation.FieldNo("Address 2")).Value;
                    CityName := RecRef.Field(CompanyInformation.FieldNo("City")).Value;
                    ProvinceOrStateName := RecRef.Field(CompanyInformation.FieldNo(County)).Value;
                    PostCode := RecRef.Field(CompanyInformation.FieldNo("Post Code")).Value;
                end;
            Database::Vendor:
                begin
                    CountryRegion := RecRef.Field(Vendor.FieldNo("Country/Region Code")).Value;
                    AddressLine1 := RecRef.Field(Vendor.FieldNo("Address")).Value;
                    AddressLine2 := RecRef.Field(Vendor.FieldNo("Address 2")).Value;
                    CityName := RecRef.Field(Vendor.FieldNo("City")).Value;
                    ProvinceOrStateName := RecRef.Field(Vendor.FieldNo(County)).Value;
                    PostCode := RecRef.Field(Vendor.FieldNo("Post Code")).Value;
                end;
        end;

        StreetAddress := Helper.ConcatenateWithSpace(AddressLine1, AddressLine2);
        FIPSCountryCode := Helper.ISOToFIPSCountryCode(CountryRegion);

        if Helper.IsForeignCountryRegion(CountryRegion) then
            AddForeignAddress(AddressTagName, StreetAddress, CityName, ProvinceOrStateName, FIPSCountryCode, PostCode)
        else
            AddUSAddress(AddressTagName, StreetAddress, CityName, ProvinceOrStateName, PostCode);
    end;

    local procedure AddUSAddress(AddressTagName: Text; StreetAddress: Text; CityName: Text; StateCode: Text; PostCode: Text)
    var
        AddressLine1: Text;
        AddressLine2: Text;
    begin
        Helper.AddParentXmlNode(AddressTagName);
        Helper.AddParentXmlNode(Format(Enum::"Address Type IRIS"::USAddress));

        Helper.FormatStreetAddress(StreetAddress, AddressLine1, AddressLine2);
        Helper.AppendXmlNode('AddressLine1Txt', AddressLine1);
        Helper.AppendXmlNode('AddressLine2Txt', AddressLine2);
        Helper.AppendXmlNode('CityNm', Helper.FormatCityName(CityName, Enum::"Address Type IRIS"::USAddress));
        Helper.AppendXmlNode('StateAbbreviationCd', Format(StateCode));
        Helper.AppendXmlNode('ZIPCd', Helper.FormatZipCode(PostCode));

        Helper.CloseParentXmlNode();
        Helper.CloseParentXmlNode();
    end;

    local procedure AddForeignAddress(AddressTagName: Text; StreetAddress: Text; CityName: Text; ProvinceOrStateName: Text; FIPSCountryCode: Text; PostCode: Text)
    var
        AddressLine1: Text;
        AddressLine2: Text;
    begin
        Helper.AddParentXmlNode(AddressTagName);
        Helper.AddParentXmlNode(Format(Enum::"Address Type IRIS"::ForeignAddress));

        Helper.FormatStreetAddress(StreetAddress, AddressLine1, AddressLine2);
        Helper.AppendXmlNode('AddressLine1Txt', AddressLine1);
        Helper.AppendXmlNode('AddressLine2Txt', AddressLine2);
        Helper.AppendXmlNode('CityNm', Helper.FormatCityName(CityName, Enum::"Address Type IRIS"::ForeignAddress));
        Helper.AppendXmlNode('ProvinceOrStateNm', Helper.FormatText(ProvinceOrStateName, 17));
        Helper.AppendXmlNode('CountryCd', FIPSCountryCode);
        Helper.AppendXmlNode('ForeignPostalCd', Helper.FormatText(PostCode, 16));

        Helper.CloseParentXmlNode();
        Helper.CloseParentXmlNode();
    end;

    local procedure GetForeignEntityInd(CountryRegionCode: Code[10]) ForeignEntityInd: Text
    begin
        ForeignEntityInd := Helper.FormatBoolean(false);        // default is US
        if Helper.IsForeignCountryRegion(CountryRegionCode) then
            ForeignEntityInd := Helper.FormatBoolean(true);
    end;

    local procedure GetCorrectedInd(TransmissionTypeIRIS: Enum "Transmission Type IRIS") CorrectedInd: Text
    begin
        CorrectedInd := Helper.FormatBoolean(false);
        if TransmissionTypeIRIS = "Transmission Type IRIS"::"C" then
            CorrectedInd := Helper.FormatBoolean(true);
    end;

    local procedure GetTestFileIndicator(): Text[1]
    begin
        if KeyVaultClient.TestMode() then
            exit('T');  // T for Test

        exit('P');  // P for Production
    end;

    local procedure GetTINSubmittedType(TaxIdentificationType: Enum "Tax Identification Type") TINTypeCd: Text
    begin
        case TaxIdentificationType of
            "Tax Identification Type"::"Legal Entity":
                TINTypeCd := 'BUSINESS_TIN';
            "Tax Identification Type"::"Natural Person":
                TINTypeCd := 'INDIVIDUAL_TIN';
        end;
    end;

    local procedure FilterIRSFormDocLines(var IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line"; var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary)
    begin
        IRS1099FormDocLine.Reset();
        IRS1099FormDocLine.SetRange("Period No.", TempIRS1099FormDocHeader."Period No.");
        IRS1099FormDocLine.SetRange("Vendor No.", TempIRS1099FormDocHeader."Vendor No.");
        IRS1099FormDocLine.SetRange("Form No.", TempIRS1099FormDocHeader."Form No.");
        IRS1099FormDocLine.SetRange("Document ID", TempIRS1099FormDocHeader.ID);
        IRS1099FormDocLine.SetRange("Include In 1099", true);
    end;

    local procedure GetVendorList(var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary): List of [Text]
    var
        VendorNos: Dictionary of [Text, Text];
    begin
        if TempIRS1099FormDocHeader.FindSet() then
            repeat
                if VendorNos.Add(TempIRS1099FormDocHeader."Vendor No.", '') then;
            until TempIRS1099FormDocHeader.Next() = 0;

        exit(VendorNos.Keys());
    end;

    local procedure GetVendorBankAccountNo(var Vendor: Record Vendor) BankAccountNo: Text
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        if Vendor."Preferred Bank Account Code" <> '' then begin
            VendorBankAccount.Get(Vendor."No.", Vendor."Preferred Bank Account Code");
            BankAccountNo := VendorBankAccount.GetBankAccountNo();
        end;

        BankAccountNo := Helper.FormatText(BankAccountNo);
        if StrLen(BankAccountNo) > 30 then
            BankAccountNo := '';
    end;

    local procedure CalcFormTotalAmounts(var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary; var TotalAmounts: Dictionary of [Text, Decimal])
    var
        DummyTotalReportedAmt: Decimal;
        DummyFederalIncomeTaxWithheldAmt: Decimal;
    begin
        CalcFormTotalAmounts(TempIRS1099FormDocHeader, TotalAmounts, DummyTotalReportedAmt, DummyFederalIncomeTaxWithheldAmt);
    end;

    local procedure CalcFormTotalAmounts(var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary; var FormTotalAmounts: Dictionary of [Text, Decimal]; var TotalReportedAmt: Decimal; var FederalIncomeTaxWithheldAmt: Decimal)
    var
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        FederalIncomeTaxWithheldFormBoxes: Dictionary of [Text, Boolean];
        FormBoxNo: Code[20];
        LineAmount: Decimal;
    begin
        // totals must be calculated only for one form type (DIV / INT / MISC / NEC) and one tax year
        Clear(FormTotalAmounts);
        TotalReportedAmt := 0;
        FederalIncomeTaxWithheldAmt := 0;

        if not TempIRS1099FormDocHeader.FindSet() then
            exit;

        // get form boxes related to federal income tax withheld
        FederalIncomeTaxWithheldFormBoxes := Helper.GetFederalIncomeTaxWithheldFormBoxes(TempIRS1099FormDocHeader."Period No.");

        repeat
            FilterIRSFormDocLines(IRS1099FormDocLine, TempIRS1099FormDocHeader);
            if IRS1099FormDocLine.FindSet() then
                repeat
                    FormBoxNo := IRS1099FormDocLine."Form Box No.";
                    LineAmount := IRS1099FormDocLine.Amount;
                    if CorrectionToZeroModeGlobal then
                        LineAmount := 0;
                    if not FormTotalAmounts.ContainsKey(FormBoxNo) then
                        FormTotalAmounts.Add(FormBoxNo, 0);
                    FormTotalAmounts.Set(FormBoxNo, FormTotalAmounts.Get(FormBoxNo) + LineAmount);
                    if FederalIncomeTaxWithheldFormBoxes.ContainsKey(FormBoxNo) then
                        FederalIncomeTaxWithheldAmt += LineAmount
                    else
                        TotalReportedAmt += LineAmount;
                until IRS1099FormDocLine.Next() = 0;
        until TempIRS1099FormDocHeader.Next() = 0;
    end;

    local procedure GetFormBoxAmtXmlElemNamesAndValues(var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary; FormTotalAmounts: Dictionary of [Text, Decimal]; var XmlElemNamesValues: Dictionary of [Text, Text])
    var
        IRS1099FormBox: Record "IRS 1099 Form Box";
        FormBoxAmtXmlElemNames: Dictionary of [Text, Text];
        FormBoxNo: Text;
        FormBoxAmt: Decimal;
        XmlElemName: Text;
        XmlElemValue: Text;
    begin
        Clear(XmlElemNamesValues);

        // get xml element names for form boxes ('DIV-01' -> 'DividendIncomeAmt')
        FormBoxAmtXmlElemNames := Helper.GetFormBoxAmountXmlElementNames(TempIRS1099FormDocHeader."Period No.", TempIRS1099FormDocHeader."Form No.");

        foreach FormBoxNo in FormBoxAmtXmlElemNames.Keys() do begin
            FormBoxAmt := 0;
            if FormTotalAmounts.Get(FormBoxNo, FormBoxAmt) then;
            case FormBoxNo of
                'MISC-07', 'NEC-02':          // DirectSaleAboveThresholdInd
                    begin
                        IRS1099FormBox.Get(TempIRS1099FormDocHeader."Period No.", TempIRS1099FormDocHeader."Form No.", FormBoxNo);
                        XmlElemValue := Helper.FormatBoolean(FormBoxAmt >= IRS1099FormBox."Minimum Reportable Amount");
                    end;
                else
                    XmlElemValue := Helper.FormatDecimal(FormBoxAmt);
            end;
            XmlElemName := FormBoxAmtXmlElemNames.Get(FormBoxNo);
            if XmlElemNamesValues.Add(XmlElemName, XmlElemValue) then;
        end;
    end;

    local procedure GetFormTypeCode(FormNo: Code[20]): Text
    begin
        // 1099NEC, 1099MISC, 1099DIV, 1099INT etc.
        exit(StrSubstNo('%1%2', '1099', FormNo));
    end;

    local procedure GetForm1099TotalAmtGrpTagName(FormType: Enum "Form Type IRIS") TagName: Text
    begin
        // Form1099NECTotalAmtGrp etc.
        TagName := StrSubstNo(Form1099TotalAmtGrpTxt, GetFormTypeCode(Format(FormType)));
    end;

    local procedure GetForm1099DetailTagName(FormType: Enum "Form Type IRIS") TagName: Text
    begin
        // Form1099NECDetail etc.
        TagName := StrSubstNo(Form1099DetailTxt, GetFormTypeCode(Format(FormType)));
    end;

    local procedure InitSubmissionAndRecordIds(TransmissionDocumentID: Integer)
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
    begin
        IRS1099FormDocHeader.SetLoadFields("IRIS Submission ID", "IRIS Record ID");
        IRS1099FormDocHeader.SetRange("IRIS Transmission Document ID", TransmissionDocumentID);
        if IRS1099FormDocHeader.FindSet() then
            repeat
                if IRS1099FormDocHeader."IRIS Submission ID" <> '' then
                    if UsedSubmissionIdsGlobal.Add(IRS1099FormDocHeader."IRIS Submission ID", 0) then;
                if IRS1099FormDocHeader."IRIS Record ID" <> '' then
                    if UsedRecordIdsGlobal.Add(IRS1099FormDocHeader."IRIS Record ID", 0) then;
            until IRS1099FormDocHeader.Next() = 0;

        SubmissionIdGlobal := 1;
        RecordIdGlobal := 1;
    end;

    local procedure GetNextSubmissionId(CurrSubmissionId: Text[20]): Text[20]
    begin
        TotalSubmissionCountGlobal += 1;

        if CurrSubmissionId <> '' then
            exit(CurrSubmissionId);

        while UsedSubmissionIdsGlobal.ContainsKey(Format(SubmissionIdGlobal)) do
            SubmissionIdGlobal += 1;
        if UsedSubmissionIdsGlobal.Add(Format(SubmissionIdGlobal), 0) then;
        exit(Format(SubmissionIdGlobal));
    end;

    local procedure GetNextRecordId(CurrRecordId: Text[20]): Text[20]
    begin
        TotalRecordCountGlobal += 1;

        if CurrRecordId <> '' then
            exit(CurrRecordId);

        while UsedRecordIdsGlobal.ContainsKey(Format(RecordIdGlobal)) do
            RecordIdGlobal += 1;
        if UsedRecordIdsGlobal.Add(Format(RecordIdGlobal), 0) then;
        exit(Format(RecordIdGlobal));
    end;

    local procedure GetMicrosoftData(var TIN: Text; var CompanyName: Text; var StreetAddress: Text; var CityName: Text; var StateCode: Text; var PostCode: Text; var ContactName: Text; var ContactEmail: Text; var ContactPhone: Text)
    begin
        TIN := '91-1144442';
        CompanyName := 'Microsoft';
        StreetAddress := 'One Microsoft Way';
        CityName := 'Redmond';
        StateCode := 'WA';
        PostCode := '98052';

        KeyVaultClient.GetContactInfo(ContactName, ContactEmail, ContactPhone);
    end;

    procedure CreateGetStatusRequest(SearchParamType: Enum "Search Param Type IRIS"; SearchId: Text; var TempBlob: Codeunit "Temp Blob")
    var
        CustomDimensions: Dictionary of [Text, Text];
    begin
        if SearchId = '' then
            Error(EmptySearchIdErr);

        InitGetStatusDocElement();
        Helper.AppendXmlNode('TransmitterControlCd', KeyVaultClient.GetTCC());
        Helper.AppendXmlNode('SearchTypeCd', 'S');      // S - Status request (status only)
        Helper.AppendXmlNode('SearchParameterTypeCd', Format(SearchParamType));
        Helper.AppendXmlNode('SearchId', SearchId);
        Helper.WriteXMLDocToTempBlob(TempBlob);

        CustomDimensions.Add('SearchTypeCd', 'S');
        CustomDimensions.Add('SearchParameterTypeCd', Format(SearchParamType));
        FeatureTelemetry.LogUsage('0000PAE', Helper.GetIRISFeatureName(), CreateGetStatusRequestEventTxt, CustomDimensions);
    end;

    procedure CreateAcknowledgementRequest(SearchParamType: Enum "Search Param Type IRIS"; SearchId: Text; var TempBlob: Codeunit "Temp Blob")
    var
        CustomDimensions: Dictionary of [Text, Text];
    begin
        if SearchId = '' then
            Error(EmptySearchIdErr);

        InitGetStatusDocElement();
        Helper.AppendXmlNode('TransmitterControlCd', KeyVaultClient.GetTCC());
        Helper.AppendXmlNode('SearchTypeCd', 'A');      // A - Acknowledgement request (status and errors)
        Helper.AppendXmlNode('SearchParameterTypeCd', Format(SearchParamType));
        Helper.AppendXmlNode('SearchId', SearchId);
        Helper.WriteXMLDocToTempBlob(TempBlob);

        CustomDimensions.Add('SearchTypeCd', 'A');
        CustomDimensions.Add('SearchParameterTypeCd', Format(SearchParamType));
        FeatureTelemetry.LogUsage('0000PAF', Helper.GetIRISFeatureName(), CreateAckRequestEventTxt);
    end;
}