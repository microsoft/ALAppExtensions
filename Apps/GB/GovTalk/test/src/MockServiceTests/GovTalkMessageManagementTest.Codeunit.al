// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.Foundation.Company;
using System.Xml;
using System.Utilities;
using System;

codeunit 144030 "GovTalkMessage Management Test"
{
    Permissions = TableData "VAT Report Archive" = rimd,
                  TableData "GovTalk Message" = rim;
    Subtype = Test;
    TestType = Uncategorized;

    trigger OnRun()
    begin
        // [FEATURE] [GovTalk]
    end;

    var
        GovTalkMessage: Record "GovTalk Message";
        GovTalkSetup: Record "Gov Talk Setup";
        CompanyInformation: Record "Company Information";
        GovTalkMessageManagement: Codeunit "GovTalk Message Management";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        LibraryUtility: Codeunit "Library - Utility";
        XMLDOMManagement: Codeunit "XML DOM Management";
        Assert: Codeunit Assert;
        Initialized: Boolean;
        VATDeclarationMessageClassTxt: Label 'HMRC-VAT-DEC', Locked = true;
        GovTalkNameSpaceTxt: Label 'http://www.govtalk.gov.uk/CM/envelope', Locked = true;
        ServiceResponseURLTxt: Label 'https://localhost:8080/GovTalkGateway/response', Locked = true;
        ErrorResponseURLTxt: Label 'https://localhost:8080/GovTalkGateway/error', Locked = true;
        ECSLServiceResponseURLTxt: Label 'https://localhost:8080/GovTalkGateway/ECSLresponse', Locked = true;
        ECSLErrorResponseURLTxt: Label 'https://localhost:8080/GovTalkGateway/ECSLerror', Locked = true;
        NilPaymentTxt: Label 'This is a repayment return. No payment is due.', Locked = true;
        ErrorResponseTxt: Label 'The VAT Period you have entered 2001-04 for the VRN 999900001 was not found, please check and resubmit if necessary.', Locked = true;
        ECSLLineResponse1Txt: Label 'Line No. 001 Acknowledged', Locked = true;
        ECSLLineResponse2Txt: Label 'Line No. 002 failed with error: VAT Registration Number Invalid For Specified Country', Locked = true;
        ECSLLineResponse3Txt: Label 'The declaration submitted contained an excessive amount of invalid submission lines. The entire submission has been rejected. The following lines have caused one or more validation failures.', Locked = true;
        ECSLLineResponse4Txt: Label 'Line No. 11 failed with error: VAT Registration Number Invalid For Specified Country', Locked = true;

    [Test]
    [Scope('OnPrem')]
    procedure TestVATDeclarationMissingPrerequisites()
    var
        VATReportHeader: Record "VAT Report Header";
        ErrorMessage: Record "Error Message";
        GovTalkVATReportValidate: Codeunit "GovTalk Validate VAT Report";
        BodyXMLNode: DotNet XmlNode;
        GovTalkRequestXMLNode: DotNet XmlNode;
    begin
        Initialize();
        // [GIVEN] GovTalk Setup parameters missing
        ClearGovTalkParameters();
        ClearCompanyInformation();
        CreateVATReportHeaderForVATReturn(VATReportHeader);
        LibraryLowerPermissions.SetO365Setup();

        // [WHEN] Validating prerequisites
        GovTalkVATReportValidate.ValidateGovTalkPrerequisites(VATReportHeader);

        // [THEN] 3 Errors are logged in context of the GovTalk Setup
        ErrorMessage.SetRange("Context Record ID", VATReportHeader.RecordId);
        ErrorMessage.SetRange("Record ID", GovTalkSetup.RecordId);
        ErrorMessage.SetRange("Message Type", ErrorMessage."Message Type"::Warning);
        Assert.RecordCount(ErrorMessage, 1);
        ErrorMessage.FindFirst();
        Assert.AreEqual(GovTalkSetup.FieldNo(Username), ErrorMessage."Field Number", '');

        // [THEN] 2 Error are logged in context of the Company Information
        ErrorMessage.SetRange("Record ID", CompanyInformation.RecordId);
        ErrorMessage.SetRange("Message Type", ErrorMessage."Message Type"::Error);
#pragma warning disable AA0210
        ErrorMessage.SetCurrentKey("Field Number");
#pragma warning restore AA0210
        Assert.RecordCount(ErrorMessage, 2);
        ErrorMessage.FindSet();
        Assert.AreEqual(CompanyInformation.FieldNo("VAT Registration No."), ErrorMessage."Field Number", '');
        ErrorMessage.Next();
        Assert.AreEqual(CompanyInformation.FieldNo("Country/Region Code"), ErrorMessage."Field Number", '');

        // [THEN] Attempting to create a GovTalk Message header fails
        Assert.IsFalse(GovTalkMessageManagement.CreateBlankGovTalkXmlMessage(
            GovTalkRequestXMLNode, BodyXMLNode, VATReportHeader, 'request', 'submit', true), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestECSLDeclarationMissingPrerequisites()
    var
        VATReportHeader: Record "VAT Report Header";
        ErrorMessage: Record "Error Message";
        GovTalkVATReportValidate: Codeunit "GovTalk Validate VAT Report";
        BodyXMLNode: DotNet XmlNode;
        GovTalkRequestXMLNode: DotNet XmlNode;
    begin
        Initialize();
        // [GIVEN] GovTalk Setup parameters missing
        ClearGovTalkParameters();
        ClearCompanyInformation();
        CreateVATReportHeaderForECSales(VATReportHeader);
        LibraryLowerPermissions.SetO365Setup();

        // [WHEN] Validating prerequisites
        GovTalkVATReportValidate.ValidateGovTalkPrerequisites(VATReportHeader);

        // [THEN] 3 Errors are logged in context of the GovTalk Setup
        ErrorMessage.SetRange("Context Record ID", VATReportHeader.RecordId);
        ErrorMessage.SetRange("Record ID", GovTalkSetup.RecordId);
        ErrorMessage.SetRange("Message Type", ErrorMessage."Message Type"::Warning);
        Assert.RecordCount(ErrorMessage, 1);
        ErrorMessage.FindFirst();
        Assert.AreEqual(GovTalkSetup.FieldNo(Username), ErrorMessage."Field Number", '');

        // [THEN] 2 Error are logged in context of the Company Information
        ErrorMessage.SetRange("Context Record ID", VATReportHeader.RecordId);
        ErrorMessage.SetRange("Record ID", CompanyInformation.RecordId);
        ErrorMessage.SetRange("Message Type", ErrorMessage."Message Type"::Error);
#pragma warning disable AA0210
        ErrorMessage.SetCurrentKey("Field Number");
#pragma warning restore AA0210
        Assert.RecordCount(ErrorMessage, 4);
        ErrorMessage.FindSet();
        Assert.AreEqual(CompanyInformation.FieldNo("VAT Registration No."), ErrorMessage."Field Number", '');
        ErrorMessage.Next();
        Assert.AreEqual(CompanyInformation.FieldNo("Post Code"), ErrorMessage."Field Number", '');
        ErrorMessage.Next();
        Assert.AreEqual(CompanyInformation.FieldNo("Country/Region Code"), ErrorMessage."Field Number", '');
        ErrorMessage.Next();
        Assert.AreEqual(CompanyInformation.FieldNo("Branch Number GB"), ErrorMessage."Field Number", '');

        // [THEN] Attempting to create a GovTalk Message header fails
        Assert.IsFalse(GovTalkMessageManagement.CreateBlankGovTalkXmlMessage(
            GovTalkRequestXMLNode, BodyXMLNode, VATReportHeader, 'request', 'submit', true), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateBlankRequestXML()
    var
        VATReportHeader: Record "VAT Report Header";
        BodyXMLNode: DotNet XmlNode;
        GovTalkRequestXMLNode: DotNet XmlNode;
    begin
        // [SCENARIO 356154] Request XML includes "Authentication" node with "Method" = "clear", "Value" = <clear password>
        Initialize();
        // [GIVEN] GovTalk Parameters setup and a VAT Report Header is created.
        CreateVATReportHeaderForVATReturn(VATReportHeader);
        LibraryLowerPermissions.SetO365Setup();

        // [WHEN] GovTalk Blank Message is created
        GovTalkMessageManagement.CreateBlankGovTalkXmlMessage(GovTalkRequestXMLNode, BodyXMLNode, VATReportHeader, 'request', 'submit', true);

        // [THEN] Generated XML Node contains correct submission information and user details.
        Assert.AreEqual(GovTalkMessage."Message Class",
          XMLDOMManagement.FindNodeTextWithNamespace(GovTalkRequestXMLNode, '//x:Class', 'x', GovTalkNameSpaceTxt), '');
        Assert.AreEqual('request',
          XMLDOMManagement.FindNodeTextWithNamespace(GovTalkRequestXMLNode, '//x:Qualifier', 'x', GovTalkNameSpaceTxt), '');
        Assert.AreEqual('submit',
          XMLDOMManagement.FindNodeTextWithNamespace(GovTalkRequestXMLNode, '//x:Function', 'x', GovTalkNameSpaceTxt), '');
        Assert.AreEqual(GovTalkSetup.Username,
          XMLDOMManagement.FindNodeTextWithNamespace(GovTalkRequestXMLNode, '//x:SenderID', 'x', GovTalkNameSpaceTxt), '');
        Assert.AreEqual('clear',
          XMLDOMManagement.FindNodeTextWithNamespace(GovTalkRequestXMLNode, '//x:Method', 'x', GovTalkNameSpaceTxt), '');
        Assert.AreEqual(GovTalkSetup.GetPassword(),
          XMLDOMManagement.FindNodeTextWithNamespace(GovTalkRequestXMLNode, '//x:Value', 'x', GovTalkNameSpaceTxt), '');
        Assert.AreEqual(
          GovTalkMessageManagement.FormatVATRegNo(CompanyInformation."Country/Region Code", CompanyInformation."VAT Registration No."),
          XMLDOMManagement.FindNodeTextWithNamespace(GovTalkRequestXMLNode, '//x:Key', 'x', GovTalkNameSpaceTxt), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreatePollRequestXML()
    var
        VATReportHeader: Record "VAT Report Header";
        GovTalkRequestXMLNode: DotNet XmlNode;
    begin
        Initialize();
        // [GIVEN] VAT Report Header is created and has a correlation ID.
        CreateVATReportHeaderForVATReturn(VATReportHeader);
        VATReportHeader."Message Id" := CreateGuid();
        VATReportHeader.Modify();
        LibraryLowerPermissions.SetO365Setup();

        // [WHEN] GovTalk Poll Message is created
        GovTalkMessageManagement.CreateGovTalkPollMessage(GovTalkRequestXMLNode, VATReportHeader);

        // [THEN] Generated XML Node contains correct submission information and Correlation ID.
        Assert.AreEqual(GovTalkMessage."Message Class",
          XMLDOMManagement.FindNodeTextWithNamespace(GovTalkRequestXMLNode, '//x:Class', 'x', GovTalkNameSpaceTxt), '');
        Assert.AreEqual('poll',
          XMLDOMManagement.FindNodeTextWithNamespace(GovTalkRequestXMLNode, '//x:Qualifier', 'x', GovTalkNameSpaceTxt), '');
        Assert.AreEqual('submit',
          XMLDOMManagement.FindNodeTextWithNamespace(GovTalkRequestXMLNode, '//x:Function', 'x', GovTalkNameSpaceTxt), '');
        Assert.AreEqual(VATReportHeader."Message Id",
          XMLDOMManagement.FindNodeTextWithNamespace(GovTalkRequestXMLNode, '//x:CorrelationID', 'x', GovTalkNameSpaceTxt), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSuccessResponse()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReportArchive: Record "VAT Report Archive";
        ErrorMessage: Record "Error Message";
        InStream: InStream;
        BodyXMLNode: DotNet XmlNode;
        GovTalkRequestXMLNode: DotNet XmlNode;
        BlobLoadedXMLNode: DotNet XmlNode;
        SubmissionMessageText: Text;
    begin
        Initialize();
        GovTalkSetup.Endpoint := ServiceResponseURLTxt;
        GovTalkSetup.Modify();
        // [GIVEN] GovTalk Parameters setup, a VAT Report Header is created and an XML message is formed
        CreateVATReportHeaderForVATReturn(VATReportHeader);
        GovTalkMessageManagement.CreateBlankGovTalkXmlMessage(GovTalkRequestXMLNode, BodyXMLNode, VATReportHeader, 'request', 'submit', true);
        LibraryLowerPermissions.SetO365Setup();

        // [WHEN] GovTalk Message is submitted
        GovTalkMessageManagement.SubmitGovTalkRequest(VATReportHeader, GovTalkRequestXMLNode);

        // [THEN] VAT Report Header Status is changed to Accepted
        Assert.AreEqual(VATReportHeader.Status::Accepted, VATReportHeader.Status, '');

        // [THEN] Communication XML is archived
        VATReportArchive.SetRange("VAT Report Type", VATReportHeader."VAT Report Config. Code");
        VATReportArchive.SetRange("VAT Report No.", VATReportHeader."No.");
        Assert.RecordCount(VATReportArchive, 1);
        VATReportArchive.FindFirst();
        Assert.IsTrue(VATReportArchive."Submission Message BLOB".HasValue, '');
        Assert.IsTrue(VATReportArchive."Response Message BLOB".HasValue, '');
        VATReportArchive."Submission Message BLOB".CreateInStream(InStream);
        InStream.Read(SubmissionMessageText);
        XMLDOMManagement.LoadXMLNodeFromText(SubmissionMessageText, BlobLoadedXMLNode);
        Assert.AreEqual(GovTalkRequestXMLNode.OuterXml, BlobLoadedXMLNode.OuterXml, '');

        // [THEN] An information message is logged
        ErrorMessage.SetContext(VATReportHeader);
        Assert.AreEqual(1, ErrorMessage.ErrorMessageCount(ErrorMessage."Message Type"::Information), '');
        ErrorMessage.FindFirst();
        Assert.AreEqual(ErrorMessage."Message Type"::Information, ErrorMessage."Message Type", '');
        Assert.AreEqual(NilPaymentTxt, ErrorMessage."Message", '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestErrorResponse()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReportArchive: Record "VAT Report Archive";
        ErrorMessage: Record "Error Message";
        BodyXMLNode: DotNet XmlNode;
        GovTalkRequestXMLNode: DotNet XmlNode;
    begin
        Initialize();
        GovTalkSetup.Endpoint := ErrorResponseURLTxt;
        GovTalkSetup.Modify();
        // [GIVEN] GovTalk Parameters setup, a VAT Report Header is created and an XML message is formed
        CreateVATReportHeaderForVATReturn(VATReportHeader);
        GovTalkMessageManagement.CreateBlankGovTalkXmlMessage(GovTalkRequestXMLNode, BodyXMLNode, VATReportHeader, 'request', 'submit', true);
        LibraryLowerPermissions.SetO365Setup();

        // [WHEN] GovTalk Message is submitted
        GovTalkMessageManagement.SubmitGovTalkRequest(VATReportHeader, GovTalkRequestXMLNode);

        // [THEN] VAT Report Header Status is changed to Rejected
        Assert.AreEqual(VATReportHeader.Status::Rejected, VATReportHeader.Status, '');

        // [THEN] Communication XML is archived
        VATReportArchive.SetRange("VAT Report Type", VATReportHeader."VAT Report Config. Code");
        VATReportArchive.SetRange("VAT Report No.", VATReportHeader."No.");
        Assert.RecordCount(VATReportArchive, 1);
        VATReportArchive.FindFirst();
        Assert.IsTrue(VATReportArchive."Submission Message BLOB".HasValue, '');
        Assert.IsTrue(VATReportArchive."Response Message BLOB".HasValue, '');

        // [THEN] An information message is logged
        ErrorMessage.SetContext(VATReportHeader);
        Assert.AreEqual(1, ErrorMessage.ErrorMessageCount(ErrorMessage."Message Type"::Error), '');
        ErrorMessage.FindFirst();
        Assert.AreEqual(ErrorMessage."Message Type"::Error, ErrorMessage."Message Type", '');
        Assert.AreEqual(ErrorResponseTxt, ErrorMessage."Message", '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestECSLSuccessResponse()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReportArchive: Record "VAT Report Archive";
        ErrorMessage: Record "Error Message";
        BodyXMLNode: DotNet XmlNode;
        GovTalkRequestXMLNode: DotNet XmlNode;
    begin
        Initialize();
        GovTalkSetup.Endpoint := ECSLServiceResponseURLTxt;
        GovTalkSetup.Modify();
        // [GIVEN] GovTalk Parameters setup, a VAT Report Header is created and an XML message is formed
        CreateVATReportHeaderForECSales(VATReportHeader);
        CreateECSLLine(VATReportHeader);
        GovTalkMessageManagement.CreateBlankGovTalkXmlMessage(GovTalkRequestXMLNode, BodyXMLNode, VATReportHeader, 'request', 'submit', true);
        LibraryLowerPermissions.SetO365Setup();

        // [WHEN] GovTalk Message is submitted
        CODEUNIT.Run(CODEUNIT::"EC Sales List Submit GB", VATReportHeader);

        // [THEN] VAT Report Header Status is changed to Accepted
        Assert.AreEqual(VATReportHeader.Status::Accepted, VATReportHeader.Status, '');

        // [THEN] Communication XML is archived
        VATReportArchive.SetRange("VAT Report Type", VATReportHeader."VAT Report Config. Code");
        VATReportArchive.SetRange("VAT Report No.", VATReportHeader."No.");
        Assert.RecordCount(VATReportArchive, 1);
        VATReportArchive.FindFirst();
        Assert.IsTrue(VATReportArchive."Response Message BLOB".HasValue, '');

        // [THEN] 1 information message is logged for success line
        ErrorMessage.SetRange("Context Record ID", VATReportHeader.RecordId);
        ErrorMessage.SetRange("Message Type", ErrorMessage."Message Type"::Information);
        Assert.RecordCount(ErrorMessage, 1);
        ErrorMessage.FindFirst();
        Assert.AreEqual(ErrorMessage."Message Type"::Information, ErrorMessage."Message Type", '');
        Assert.AreEqual(ECSLLineResponse1Txt, ErrorMessage."Message", '');

        // [THEN] 1 error message is logged for sucess line
        ErrorMessage.Reset();
        ErrorMessage.SetRange("Context Record ID", VATReportHeader.RecordId);
        ErrorMessage.SetRange("Message Type", ErrorMessage."Message Type"::Error);
        Assert.RecordCount(ErrorMessage, 1);
        ErrorMessage.FindFirst();
        Assert.AreEqual(ErrorMessage."Message Type"::Error, ErrorMessage."Message Type", '');
        Assert.AreEqual(ECSLLineResponse2Txt, ErrorMessage."Message", '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestECSLErrorResponse()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReportArchive: Record "VAT Report Archive";
        ErrorMessage: Record "Error Message";
        BodyXMLNode: DotNet XmlNode;
        GovTalkRequestXMLNode: DotNet XmlNode;
    begin
        Initialize();
        GovTalkSetup.Endpoint := ECSLErrorResponseURLTxt;
        GovTalkSetup.Modify();
        // [GIVEN] GovTalk Parameters setup, a VAT Report Header is created and an XML message is formed
        CreateVATReportHeaderForECSales(VATReportHeader);
        CreateECSLLine(VATReportHeader);
        GovTalkMessageManagement.CreateBlankGovTalkXmlMessage(GovTalkRequestXMLNode, BodyXMLNode, VATReportHeader, 'request', 'submit', true);
        LibraryLowerPermissions.SetO365Setup();

        // [WHEN] GovTalk Message is submitted
        CODEUNIT.Run(CODEUNIT::"EC Sales List Submit GB", VATReportHeader);

        // [THEN] VAT Report Header Status is changed to Rejected
        Assert.AreEqual(VATReportHeader.Status::Rejected, VATReportHeader.Status, '');

        // [THEN] Communication XML is archived
        VATReportArchive.SetRange("VAT Report Type", VATReportHeader."VAT Report Config. Code");
        VATReportArchive.SetRange("VAT Report No.", VATReportHeader."No.");
        Assert.RecordCount(VATReportArchive, 1);
        VATReportArchive.FindFirst();
        Assert.IsTrue(VATReportArchive."Submission Message BLOB".HasValue, '');
        Assert.IsTrue(VATReportArchive."Response Message BLOB".HasValue, '');

        // [THEN] An information message is logged
        ErrorMessage.SetContext(VATReportHeader);
        Assert.AreEqual(2, ErrorMessage.ErrorMessageCount(ErrorMessage."Message Type"::Error), '');
        ErrorMessage.FindFirst();
        Assert.AreEqual(ErrorMessage."Message Type"::Error, ErrorMessage."Message Type", '');
        Assert.AreEqual(ECSLLineResponse3Txt, ErrorMessage."Message", '');
        ErrorMessage.FindLast();
        Assert.AreEqual(ErrorMessage."Message Type"::Error, ErrorMessage."Message Type", '');
        Assert.AreEqual(ECSLLineResponse4Txt, ErrorMessage."Message", '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestReleaseNotAllowed()
    var
        VATReportHeader: Record "VAT Report Header";
        ErrorMessage: Record "Error Message";
        GovTalkSetup2: Record "Gov Talk Setup";
        VATReportReleaseReopen: Codeunit "VAT Report Release/Reopen";
    begin
        Initialize();
        LibraryLowerPermissions.SetO365Setup();
        ClearCompanyInformation();
        ClearGovTalkParameters();
        CreateVATReportHeaderAndLines(VATReportHeader);

        VATReportReleaseReopen.Release(VATReportHeader);
        VATReportHeader.TestField(Status, VATReportHeader.Status::Open);

        GovTalkSetup2.FindFirst();
        ErrorMessage.SetRange("Context Record ID", VATReportHeader.RecordId);
        ErrorMessage.SetRange("Record ID", GovTalkSetup2.RecordId);
        ErrorMessage.SetRange("Message Type", ErrorMessage."Message Type"::Warning);
        Assert.RecordCount(ErrorMessage, 1);
    end;

    local procedure Initialize()
    begin
        if not Initialized then begin
            SetupGovTalkParameters();
            Initialized := true;
        end;
    end;

    local procedure CreateVATReportHeaderForVATReturn(var VATReportHeader: Record "VAT Report Header")
    begin
        CreateVATReportHeader(VATReportHeader, VATReportHeader."VAT Report Config. Code"::"VAT Return", 'govtalk');
    end;

    local procedure CreateVATReportHeaderForECSales(var VATReportHeader: Record "VAT Report Header")
    begin
        CreateVATReportHeader(VATReportHeader, VATReportHeader."VAT Report Config. Code"::"EC Sales List", 'current');
    end;

    local procedure CreateVATReportHeader(var VATReportHeader: Record "VAT Report Header"; VATReportConfigCode: Enum "VAT Report Configuration"; VATReportVersion: Code[10])
    begin
        VATReportHeader.Init();
        VATReportHeader."No." := LibraryUtility.GenerateRandomCodeWithLength(
            VATReportHeader.FieldNo("No."), DATABASE::"VAT Report Header", 20);
        VATReportHeader."VAT Report Config. Code" := VATReportConfigCode;
        VATReportHeader."VAT Report Version" := VATReportVersion;
        VATReportHeader."Start Date" := CalcDate('<CM>', Today);
        VATReportHeader."End Date" := CalcDate('<CM+30D>', Today);
        VATReportHeader.Insert();
        CreateGovTalkMessage(VATReportHeader);
    end;

    local procedure CreateGovTalkMessage(VATReportHeader: Record "VAT Report Header")
    begin
        GovTalkMessage.ReportConfigCode := VATReportHeader."VAT Report Config. Code".AsInteger();
        GovTalkMessage.ReportNo := VATReportHeader."No.";
        GovTalkMessage.PeriodID := GetPeriodID(VATReportHeader."End Date");
        GovTalkMessage.PeriodStart := VATReportHeader."Start Date";
        GovTalkMessage.PeriodEnd := VATReportHeader."End Date";
        GovTalkMessage."Message Class" := VATDeclarationMessageClassTxt;
#pragma warning disable AA0205
        GovTalkMessage.Insert();
#pragma warning restore AA0205
    end;

    local procedure CreateECSLLine(VATReportHeader: Record "VAT Report Header")
    var
        ECSLVATReportLine: Record "ECSL VAT Report Line";
    begin
        ECSLVATReportLine.DeleteAll();
        ECSLVATReportLine.Init();
        ECSLVATReportLine."Line No." := 1;
        ECSLVATReportLine."Report No." := VATReportHeader."No.";
        ECSLVATReportLine.Insert();
    end;

    local procedure CreateVATReportHeaderAndLines(var VATReportHeader: Record "VAT Report Header")
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        CreateVATReportHeaderForVATReturn(VATReportHeader);
        VATStatementReportLine.Init();
        VATStatementReportLine."VAT Report No." := VATReportHeader."No.";
        VATStatementReportLine."VAT Report Config. Code" := VATReportHeader."VAT Report Config. Code";
        VATStatementReportLine."Line No." := 1;
        VATStatementReportLine.Insert();
    end;

    local procedure SetupGovTalkParameters()
    begin
        GovTalkSetup.DeleteAll();
        GovTalkSetup.Id := LibraryUtility.GenerateRandomCodeWithLength(GovTalkSetup.FieldNo(Id), DATABASE::"Gov Talk Setup", 10);
        GovTalkSetup.Username := 'VATDEC030a01';
        GovTalkSetup.Endpoint := ServiceResponseURLTxt;
#pragma warning disable AA0205
        GovTalkSetup.Insert();
#pragma warning restore AA0205
        GovTalkSetup.SavePassword('testing1');
        GovTalkSetup.Modify();
        if CompanyInformation.Get() then begin
            CompanyInformation."Country/Region Code" := 'GB';
            CompanyInformation."VAT Registration No." := 'GB999900001';
            CompanyInformation."Branch Number GB" := '000';
            CompanyInformation."Post Code" := 'AA11AA';
            CompanyInformation.Modify();
        end else begin
            CompanyInformation.Init();
            CompanyInformation."Country/Region Code" := 'GB';
            CompanyInformation."VAT Registration No." := 'GB999900001';
            CompanyInformation."Branch Number GB" := '000';
            CompanyInformation."Post Code" := 'AA11AA';
            CompanyInformation.Insert();
        end;
    end;

    local procedure ClearGovTalkParameters()
    begin
        Clear(GovTalkSetup.Username);
        Clear(GovTalkSetup.Password);
        Clear(GovTalkSetup.Endpoint);
        GovTalkSetup.Modify();
        Initialized := false;
    end;

    local procedure ClearCompanyInformation()
    begin
        Clear(CompanyInformation."VAT Registration No.");
        Clear(CompanyInformation."Country/Region Code");
        Clear(CompanyInformation."Branch Number GB");
        Clear(CompanyInformation."Post Code");
        CompanyInformation.Modify();
        Initialized := false;
    end;

    local procedure GetPeriodID(PeriodEnd: Date): Code[10]
    begin
        exit(Format(PeriodEnd, 0, '<Year4>-<Month,2>'));
    end;
}

