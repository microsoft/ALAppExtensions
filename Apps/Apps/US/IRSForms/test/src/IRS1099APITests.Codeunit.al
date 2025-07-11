// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 148018 "IRS 1099 API Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryIRSReportingPeriod: Codeunit "Library IRS Reporting Period";
        LibraryIRS1099FormBox: Codeunit "Library IRS 1099 Form Box";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        IRS1099DocumentsServiceNameLbl: Label 'irs1099documents';

    [Test]
    procedure IRS1099DocumentsAPISunshine()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        IRS1099FormReport: Record "IRS 1099 Form Report";
        VendNo, FormNo, FormBoxNo : Code[20];
        ResponseText: Text;
    begin
        // [SCENARIO 497835] 
        Initialize();
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo :=
            LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate(), WorkDate());
        FormBoxNo :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), WorkDate(), FormNo);
        VendNo := LibraryPurchase.CreateVendorNo();
        // [GIVEN]
        MockIRS1099FormDocWithLineAndFormReport(IRS1099FormDocHeader, IRS1099FormDocLine, IRS1099FormReport, VendNo, FormNo, FormBoxNo);
        Commit();
        // [WHEN] Call the API
        LibraryGraphMgt.GetFromWebService(ResponseText, GetIRS1099DocumentAPIWithExpands());
        // [THEN] The response contains the header, line and form report
        VerifyResponseSunshine(ResponseText, IRS1099FormDocHeader, IRS1099FormDocLine, IRS1099FormReport);
    end;

    local procedure Initialize()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        IRS1099FormDocHeader.DeleteAll(true);
        IRSReportingPeriod.DeleteAll(true);
        LibraryTestInitialize.OnTestInitialize(Codeunit::"IRS 1099 API Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"IRS 1099 API Tests");

        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"IRS 1099 API Tests");
    end;

    local procedure MockIRS1099FormDocWithLineAndFormReport(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; var IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line"; var IRS1099FormReport: Record "IRS 1099 Form Report"; VendNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20])
    begin
        IRS1099FormDocHeader.ID := LibraryUtility.GetNewRecNo(IRS1099FormDocHeader, IRS1099FormDocHeader.FieldNo(ID));
        IRS1099FormDocHeader."Vendor No." := VendNo;
        IRS1099FormDocHeader."Form No." := FormNo;
        IRS1099FormDocHeader."Receiving 1099 E-Form Consent" := true;
        IRS1099FormDocHeader."Vendor E-Mail" := 'mymail@microsoft.com';
        IRS1099FormDocHeader.Insert();
        IRS1099FormDocLine."Document ID" := IRS1099FormDocHeader.ID;
        IRS1099FormDocLine."Vendor No." := IRS1099FormDocHeader."Vendor No.";
        IRS1099FormDocLine."Form No." := IRS1099FormDocHeader."Form No.";
        IRS1099FormDocLine."Form Box No." := FormBoxNo;
        IRS1099FormDocLine."Manually Changed" := true;
        IRS1099FormDocLine."Include In 1099" := true;
        IRS1099FormDocLine.Amount := 100;
        IRS1099FormDocLine."Minimum Reportable Amount" := 50;
        IRS1099FormDocLine.Insert();
        IRS1099FormReport."Document ID" := IRS1099FormDocHeader.ID;
        IRS1099FormReport."Report Type" := IRS1099FormReport."Report Type"::"Copy B";
        IRS1099FormReport.Insert();
    end;

    local procedure GetIRS1099DocumentAPIWithExpands() Url: Text
    begin
        Url := LibraryGraphMgt.CreateTargetURL('', Page::"IRS 1099 Documents API", IRS1099DocumentsServiceNameLbl);
        Url += '?$expand=irs1099documentlines,irs1099formreports';
        exit(Url);
    end;

    local procedure VerifyResponseSunshine(ResponseText: Text; IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line"; IRS1099FormReport: Record "IRS 1099 Form Report")
    var
        IRS1099FormHeaderJson, IRS1099DocumentLinesSet, IRS1099FormReportsSet : Text;
    begin
        Assert.IsTrue(
            LibraryGraphMgt.GetObjectFromJSONResponse(ResponseText, IRS1099FormHeaderJson, 1), 'No Json response from IRS1099FormDocHeader.SystemId');
        LibraryGraphMgt.VerifyIDInJson(IRS1099FormHeaderJson);
        LibraryGraphMgt.VerifyPropertyInJSON(IRS1099FormHeaderJson, 'vendorNo', IRS1099FormDocHeader."Vendor No.");
        IRS1099FormDocHeader.CalcFields("Vendor Name");
        LibraryGraphMgt.VerifyPropertyInJSON(IRS1099FormHeaderJson, 'vendorName', IRS1099FormDocHeader."Vendor Name");
        LibraryGraphMgt.VerifyPropertyInJSON(IRS1099FormHeaderJson, 'docId', Format(IRS1099FormDocHeader.ID));
        LibraryGraphMgt.VerifyPropertyInJSON(IRS1099FormHeaderJson, 'formNo', IRS1099FormDocHeader."Form No.");
        LibraryGraphMgt.VerifyPropertyInJSON(IRS1099FormHeaderJson, 'receivingConsent', 'True');
        LibraryGraphMgt.VerifyPropertyInJSON(IRS1099FormHeaderJson, 'vendorEmail', IRS1099FormDocHeader."Vendor E-Mail");
        Assert.IsTrue(
            LibraryGraphMgt.GetObjectFromJSONResponseByName(IRS1099FormHeaderJson, 'irs1099documentlines', IRS1099DocumentLinesSet, 1), 'irs1099documentlines does not exist in the response');
        VerifyIRS1099DocumentLineResponse(IRS1099DocumentLinesSet, IRS1099FormDocLine);
        Assert.IsTrue(
            LibraryGraphMgt.GetObjectFromJSONResponseByName(IRS1099FormHeaderJson, 'irs1099formreports', IRS1099FormReportsSet, 1), 'irs1099formreports does not exist in the response');
        VerifyIRS1099FormReportResponse(IRS1099FormReportsSet, IRS1099FormReport);
    end;

    local procedure VerifyIRS1099DocumentLineResponse(ResponseJson: Text; IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line")
    begin
        LibraryGraphMgt.VerifyIDInJson(ResponseJson);
        LibraryGraphMgt.VerifyPropertyInJSON(ResponseJson, 'formBoxNo', IRS1099FormDocLine."Form Box No.");
        LibraryGraphMgt.VerifyPropertyInJSON(ResponseJson, 'manuallyChanged', 'True');
        LibraryGraphMgt.VerifyPropertyInJSON(ResponseJson, 'includeIn1099', 'True');
        LibraryGraphMgt.VerifyPropertyInJSON(ResponseJson, 'amount', Format(IRS1099FormDocLine.Amount));
        LibraryGraphMgt.VerifyPropertyInJSON(ResponseJson, 'minimumReportableAmount', Format(IRS1099FormDocLine."Minimum Reportable Amount"));
    end;

    local procedure VerifyIRS1099FormReportResponse(ResponseJson: Text; IRS1099FormReport: Record "IRS 1099 Form Report")
    begin
        LibraryGraphMgt.VerifyIDInJson(ResponseJson);
        LibraryGraphMgt.VerifyPropertyInJSON(ResponseJson, 'reportType', Format(IRS1099FormReport."Report Type").Replace(' ', '_'));
    end;
}