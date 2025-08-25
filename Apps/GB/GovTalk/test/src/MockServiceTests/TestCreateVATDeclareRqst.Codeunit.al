// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Finance.VAT.Reporting;
using System.IO;
using Microsoft.Foundation.Company;

codeunit 144032 "Test Create VAT Declare Rqst"
{
    Subtype = Test;
    TestType = Uncategorized;

    trigger OnRun()
    begin
    end;

    var
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        Assert: Codeunit Assert;
        ServiceResponseURLTxt: Label 'https://localhost:8080/GovTalkGateway/response', Locked = true;
        VATDeclarationRequestTxt: Label 'VATDeclarationRequest', Locked = true;
        VATDueOnOutputsTxt: Label 'VATDueOnOutputs', Locked = true;
        VATDueOnECAcquisitionsTxt: Label 'VATDueOnECAcquisitions', Locked = true;
        TotalVATTxt: Label 'TotalVAT', Locked = true;
        VATReclaimedOnInputsTxt: Label 'VATReclaimedOnInputs', Locked = true;
        NetVATTxt: Label 'NetVAT', Locked = true;
        NetSalesAndOutputsTxt: Label 'NetSalesAndOutputs', Locked = true;
        NetPurchasesAndInputsTxt: Label 'NetPurchasesAndInputs', Locked = true;
        NetECSuppliesTxt: Label 'NetECSupplies', Locked = true;
        NetECAcquisitionsTxt: Label 'NetECAcquisitions', Locked = true;
        AASBalancingPaymentTxt: Label 'AASBalancingPayment', Locked = true;
        VATDeclarationMessageClassTxt: Label 'HMRC-VAT-DEC', Locked = true;
        Initialized: Boolean;

    [Test]
    [Scope('OnPrem')]
    procedure TestCreateVATDeclarationRequest()
    var
        VATReportHeader: Record "VAT Report Header";
        GovTalkMessage: Record "GovTalk Message";
        XMLBuffer: Record "XML Buffer";
    begin
        Initialize();
        // [GIVEN] A VAT Report Header is created with all lines in place
        CreateVATReportHeader(VATReportHeader);
        PopulateRequestLines(VATReportHeader);
        LibraryLowerPermissions.SetO365Setup();

        // [WHEN] A request is sent to form xml request
        CODEUNIT.Run(CODEUNIT::"Create VAT Declaration Req.", VATReportHeader);

        // [THEN] A GovTalkMessage is created
        GovTalkMessage.SetRange(ReportConfigCode, VATReportHeader."VAT Report Config. Code");
        GovTalkMessage.SetRange(ReportNo, VATReportHeader."No.");
        Assert.IsTrue(GovTalkMessage.FindFirst(), '');
        Assert.AreEqual(VATReportHeader."Start Date", GovTalkMessage.PeriodStart, '');
        Assert.AreEqual(VATReportHeader."End Date", GovTalkMessage.PeriodEnd, '');
        Assert.AreEqual(1000, GovTalkMessage."Polling Count", '');
        Assert.AreEqual(VATDeclarationMessageClassTxt, GovTalkMessage."Message Class", '');

        // [THEN] An XML Buffer is created and associated with the GovTalkMessage with correct name
        XMLBuffer.SetRange("Entry No.", GovTalkMessage.RootXMLBuffer);
        Assert.RecordCount(XMLBuffer, 1);
        XMLBuffer.FindFirst();
        Assert.AreEqual(VATDeclarationRequestTxt, XMLBuffer.Name, '');

        // [THEN] Report Lines are added to the XML buffer with correct naming and formatting
        ValidateReportLine(XMLBuffer, VATDueOnOutputsTxt, 1, 0);
        ValidateReportLine(XMLBuffer, VATDueOnECAcquisitionsTxt, 2, 0);
        ValidateReportLine(XMLBuffer, TotalVATTxt, 3, 0);
        ValidateReportLine(XMLBuffer, VATReclaimedOnInputsTxt, 4, 0);
        ValidateReportLine(XMLBuffer, NetVATTxt, 5, 1);
        ValidateReportLine(XMLBuffer, NetSalesAndOutputsTxt, 6, 2);
        ValidateReportLine(XMLBuffer, NetPurchasesAndInputsTxt, 7, 2);
        ValidateReportLine(XMLBuffer, NetECSuppliesTxt, 8, 2);
        ValidateReportLine(XMLBuffer, NetECAcquisitionsTxt, 9, 2);
        ValidateReportLine(XMLBuffer, AASBalancingPaymentTxt, 10, 1);
    end;

    local procedure ValidateReportLine(XMLBuffer: Record "XML Buffer"; FieldName: Text; LineNo: Integer; FormatCode: Option)
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
        ChildXMLBuffer: Record "XML Buffer";
    begin
        VATReportHeader.FindFirst();
        VATStatementReportLine.Get(VATReportHeader."No.", VATReportHeader."VAT Report Config. Code", LineNo);
        Assert.IsTrue(FindChildNodes(XMLBuffer, ChildXMLBuffer, FieldName), '');
        Assert.AreEqual(GetFormattedValue(VATStatementReportLine.Amount, FormatCode), ChildXMLBuffer.Value, '');
    end;

    local procedure Initialize()
    begin
        if not Initialized then begin
            SetupGovTalkParameters();
            SetupCompanyInformation();
            Initialized := true;
        end;
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

    local procedure SetupGovTalkParameters()
    var
        GovTalkSetup: Record "Gov Talk Setup";
    begin
        GovTalkSetup.Init();
        GovTalkSetup.Id := '1';
        GovTalkSetup.Username := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(GovTalkSetup.Username));
        GovTalkSetup.Endpoint := CopyStr(ServiceResponseURLTxt, 1, MaxStrLen(GovTalkSetup.Endpoint));
        GovTalkSetup.Insert();
        GovTalkSetup.SavePassword(CopyStr(LibraryUtility.GenerateRandomText(10), 1, 250));
        GovTalkSetup.Modify();
    end;

    local procedure SetupCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
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

    local procedure InsertSingleLine(ReportType: Enum "VAT Report Configuration"; ReportNo: Code[20]; LineNo: Integer; Amount: Decimal)
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        VATStatementReportLine."VAT Report Config. Code" := ReportType;
        VATStatementReportLine."VAT Report No." := ReportNo;
        VATStatementReportLine."Line No." := LineNo;
        VATStatementReportLine."Box No." := Format(LineNo);
        VATStatementReportLine.Amount := Amount;
        VATStatementReportLine.Insert();
    end;

    local procedure GetFormattedValue(Value: Decimal; FormatType: Option): Text
    var
        BaseType: Option ElevenPointTwoDigitDecimalType,ElevenPointTwoDigitNonNegativeDecimalType,ThirteenDigitIntegerType;
    begin
        if FormatType = BaseType::ElevenPointTwoDigitDecimalType then
            exit(ElevenPointTwoDigitDecimalFormat(Value));
        if FormatType = BaseType::ElevenPointTwoDigitNonNegativeDecimalType then
            exit(ElevenPointTwoDigitNonNegativeDecimalFormat(Value));
        if FormatType = BaseType::ThirteenDigitIntegerType then
            exit(ThirteenDigitIntegerFormat(Value));
    end;

    local procedure ElevenPointTwoDigitDecimalFormat(Value: Decimal): Text
    begin
        exit(Format(Round(Value, 0.01), 0, '<Precision,2><Standard Format,2>'));
    end;

    local procedure ElevenPointTwoDigitNonNegativeDecimalFormat(Value: Decimal): Text
    begin
        exit(ElevenPointTwoDigitDecimalFormat(Abs(Value)));
    end;

    local procedure ThirteenDigitIntegerFormat(Value: Decimal): Text
    begin
        exit(Format(Round(Value, 1), 0, '<Sign><Integer>'));
    end;

    local procedure FindChildNodes(RootXMLBuffer: Record "XML Buffer"; var ResultXMLBuffer: Record "XML Buffer"; NodeName: Text): Boolean
    begin
        ResultXMLBuffer.SetRange("Parent Entry No.", RootXMLBuffer."Entry No.");
        ResultXMLBuffer.SetRange(Name, NodeName);
        exit(ResultXMLBuffer.FindFirst())
    end;
}

