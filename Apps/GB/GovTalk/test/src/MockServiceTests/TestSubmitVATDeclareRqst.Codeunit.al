// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.Foundation.Company;

codeunit 144034 "Test Submit VAT Declare Rqst"
{
    Subtype = Test;
    TestType = Uncategorized;

    trigger OnRun()
    begin
    end;

    var
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        ServiceResponseURLTxt: Label 'https://localhost:8080/GovTalkGateway/response', Locked = true;
        ErrorResponseURLTxt: Label 'https://localhost:8080/GovTalkGateway/error', Locked = true;

    [Test]
    [Scope('OnPrem')]
    procedure TestSubmitAcceptedRequest()
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        Initialize(ServiceResponseURLTxt);
        // [GIVEN] VAT Declaration Request Created
        CreateVATReportHeader(VATReportHeader);
        PopulateRequestLines(VATReportHeader);
        CODEUNIT.Run(CODEUNIT::"Create VAT Declaration Req.", VATReportHeader);
        LibraryLowerPermissions.SetO365Setup();

        // [WHEN] Submitting a correct request
        CODEUNIT.Run(CODEUNIT::"Submit VAT Declaration Req.", VATReportHeader);

        // [THEN] VAT Report Header status is changed to Accepted
        Assert.AreEqual(VATReportHeader.Status::Accepted, VATReportHeader.Status, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSubmitRejectedRequest()
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        Initialize(ErrorResponseURLTxt);
        // [GIVEN] VAT Declaration Request Created
        CreateVATReportHeader(VATReportHeader);
        PopulateRequestLines(VATReportHeader);
        CODEUNIT.Run(CODEUNIT::"Create VAT Declaration Req.", VATReportHeader);
        LibraryLowerPermissions.SetO365Setup();

        // [WHEN] Submitting a correct request
        CODEUNIT.Run(CODEUNIT::"Submit VAT Declaration Req.", VATReportHeader);

        // [THEN] VAT Report Header status is changed to Rejected
        Assert.AreEqual(VATReportHeader.Status::Rejected, VATReportHeader.Status, '');
    end;

    local procedure Initialize(GovTalkEndpoint: Text)
    begin
        SetupGovTalkParameters(GovTalkEndpoint);
    end;

    local procedure CreateVATReportHeader(var VATReportHeader: Record "VAT Report Header")
    begin
        VATReportHeader.Init();
        VATReportHeader."No." := LibraryUtility.GenerateRandomCode(VATReportHeader.FieldNo("No."), DATABASE::"VAT Report Header");
        VATReportHeader."VAT Report Config. Code" := VATReportHeader."VAT Report Config. Code"::"VAT Return";
        VATReportHeader."Start Date" := CalcDate('<CM>', LibraryUtility.GenerateRandomDate(
              CalcDate('<CY-2Y>', Today), CalcDate('<CY-1Y>', Today)));
        VATReportHeader."End Date" := CalcDate('<CM+30D>', VATReportHeader."Start Date");
        VATReportHeader.Insert();
    end;

    local procedure SetupGovTalkParameters(GovTalkEndpoint: Text)
    var
        CompanyInformation: Record "Company Information";
        GovTalkSetup: Record "Gov Talk Setup";
    begin
        GovTalkSetup.DeleteAll();
        GovTalkSetup.Init();
        GovTalkSetup.Id := '1';
        GovTalkSetup.Username := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(GovTalkSetup.Username));
        GovTalkSetup.Endpoint := CopyStr(GovTalkEndpoint, 1, MaxStrLen(GovTalkSetup.Endpoint));
        GovTalkSetup.Insert();
        GovTalkSetup.SavePassword(CopyStr(LibraryUtility.GenerateRandomText(10), 1, 250));
        GovTalkSetup.Modify();

        if not CompanyInformation.Get() then begin
            CompanyInformation.Init();
            CompanyInformation."VAT Registration No." := CopyStr(LibraryUtility.GenerateRandomText(20), 1,
                MaxStrLen(CompanyInformation."VAT Registration No."));
            CompanyInformation.Insert();
        end;
    end;

    local procedure PopulateRequestLines(VATReportHeader: Record "VAT Report Header")
    var
        i: Integer;
    begin
        for i := 1 to 10 do
            InsertSingleLine(VATReportHeader."VAT Report Config. Code", VATReportHeader."No.", i, LibraryRandom.RandDec(100, 3));
    end;

    local procedure InsertSingleLine(VATReportConfigCode: Enum "VAT Report Configuration"; ReportNo: Code[20]; LineNo: Integer; Amount: Decimal)
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        VATStatementReportLine."VAT Report Config. Code" := VATReportConfigCode;
        VATStatementReportLine."VAT Report No." := ReportNo;
        VATStatementReportLine."Line No." := LineNo;
        VATStatementReportLine."Box No." := Format(LineNo);
        VATStatementReportLine.Amount := Amount;
        VATStatementReportLine.Insert();
    end;
}

