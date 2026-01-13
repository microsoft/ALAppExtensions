// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Reporting;
using System.Xml;
using System;
using Microsoft.Foundation.Company;
using Microsoft.Finance.GeneralLedger.Setup;
using System.TestLibraries.Environment;

codeunit 144029 "ECSL XML Gen. Test"
{
    // // [FEATURE] [Record Link]

    Subtype = Test;
    TestPermissions = Disabled;
    TestType = Uncategorized;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        MonthsTok: Label 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';

    [Test]
    [Scope('OnPrem')]
    procedure ECSLXMLGenerateAllNodesQuarterly()
    var
        VATEntry: Record "VAT Entry";
        ECSLVATReportLine: Record "ECSL VAT Report Line";
        VATReportHeader: Record "VAT Report Header";
        ECSalesListPopulateXML: Codeunit "EC Sales List XML";
        ECSalesListSuggestLines: Codeunit "EC Sales List Suggest Lines";
        GovTalkRequestXMLNode: DotNet XmlNode;
        StartDate: Date;
        EndDate: Date;
        VATRegNo: Text[20];
        DummyGuid: Guid;
    begin
        // [Scenario] generating full XML for a quarter
        VATRegNo := '100001';
        StartDate := DMY2Date(1, 1, 2017);
        EndDate := DMY2Date(31, 3, 2017);
        InitPrerequisites();
        // [Given] VAT report header
        InitReportHeader(VATReportHeader, StartDate, EndDate);
        VATReportHeader."Period Type" := VATReportHeader."Period Type"::Quarter;
        VATReportHeader."Period No." := 1;
        VATReportHeader.Modify();

        // [Given] 1 B2B Goods, 1 B2B Services and 1 EU 3-Party Trade  Vat Entry
        VATEntry.DeleteAll();
        InitVatEntry(VATEntry, VATRegNo, StartDate);

        InitVatEntry(VATEntry, VATRegNo, StartDate);
        VATEntry."EU 3-Party Trade" := true;
        VATEntry.Modify();

        InitVatEntry(VATEntry, VATRegNo, EndDate);
        VATEntry."EU Service" := true;
        VATEntry.Modify();

        // [When] Generate the XML
        ECSalesListSuggestLines.Run(VATReportHeader);
        ECSalesListPopulateXML.GetECSLDeclarationRequestMessage(GovTalkRequestXMLNode, VATReportHeader, DummyGuid);

        // [THEN] XML has all the expected values and elements
        AssertXML(VATReportHeader, GovTalkRequestXMLNode);

        // Teardown
        ECSLVATReportLine.DeleteAll();
        VATReportHeader.DeleteAll();
        VATEntry.DeleteAll();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ECSLXMLGenerateAllNodesMonthly()
    var
        VATEntry: Record "VAT Entry";
        ECSLVATReportLine: Record "ECSL VAT Report Line";
        VATReportHeader: Record "VAT Report Header";
        ECSalesListPopulateXML: Codeunit "EC Sales List XML";
        ECSalesListSuggestLines: Codeunit "EC Sales List Suggest Lines";
        GovTalkRequestXMLNode: DotNet XmlNode;
        StartDate: Date;
        EndDate: Date;
        VATRegNo: Text[20];
        DummyGuid: Guid;
    begin
        // [Scenario] generating full XML for a quarter
        VATRegNo := '100001';
        StartDate := DMY2Date(1, 1, 2017);
        EndDate := DMY2Date(31, 1, 2017);
        InitPrerequisites();

        // [Given] VAT report header
        InitReportHeader(VATReportHeader, StartDate, EndDate);

        // [Given] 1 B2B Goods, 1 B2B Services and 1 EU 3-Party Trade  Vat Entry
        VATEntry.DeleteAll();
        InitVatEntry(VATEntry, VATRegNo, StartDate);

        InitVatEntry(VATEntry, VATRegNo, StartDate);
        VATEntry."EU 3-Party Trade" := true;
        VATEntry.Modify();

        InitVatEntry(VATEntry, VATRegNo, EndDate);
        VATEntry."EU Service" := true;
        VATEntry.Modify();

        // [When] Generate the XML
        ECSalesListSuggestLines.Run(VATReportHeader);
        ECSalesListPopulateXML.GetECSLDeclarationRequestMessage(GovTalkRequestXMLNode, VATReportHeader, DummyGuid);

        // [Given] 1 B2B Goods, 1 B2B Services and 1 EU 3-Party Trade  Vat Entry
        AssertXML(VATReportHeader, GovTalkRequestXMLNode);

        // Teardown
        ECSLVATReportLine.DeleteAll();
        VATReportHeader.DeleteAll();
        VATEntry.DeleteAll();
    end;

    local procedure InitReportHeader(var VATReportHeader: Record "VAT Report Header"; StartDate: Date; EndDate: Date)
    begin
        VATReportHeader.Init();
        VATReportHeader."Start Date" := StartDate;
        VATReportHeader."End Date" := EndDate;
        VATReportHeader."No." := CopyStr(CreateGuid(), 2, 20);

        VATReportHeader."Period Type" := VATReportHeader."Period Type"::Month;
        VATReportHeader."Period No." := Date2DMY(StartDate, 2);
        VATReportHeader."Period Year" := Date2DMY(StartDate, 3);

        VATReportHeader."VAT Report Config. Code" := VATReportHeader."VAT Report Config. Code"::"EC Sales List";
        VATReportHeader.Insert();
    end;

    local procedure InitVatEntry(var VATEntry: Record "VAT Entry"; VatRegNo: Text[20]; PostingDate: Date)
    var
        LastId: Integer;
    begin
        if VATEntry.FindLast() then
            LastId := VATEntry."Entry No.";

        VATEntry.Init();
        VATEntry."Entry No." := LastId + 1;
        VATEntry.Base := -1.7;
        VATEntry."Posting Date" := PostingDate;
        VATEntry.Type := VATEntry.Type::Sale;
        VATEntry."EU 3-Party Trade" := false;
        VATEntry."VAT Registration No." := VatRegNo;
        VATEntry."EU Service" := false;
        VATEntry."Country/Region Code" := 'DE';
        VATEntry.Insert();
    end;

    local procedure AssertXML(VATReportHeader: Record "VAT Report Header"; GovTalkRequestXMLNode: DotNet XmlNode)
    var
        CompanyInformation: Record "Company Information";
        ECSLVATReportLine: Record "ECSL VAT Report Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        XMLDOMManagement: Codeunit "XML DOM Management";
        DummyXMLNodeList: DotNet XmlNodeList;
        XPathNavigator: DotNet XPathNavigator;
        XPathExpression: DotNet XPathExpression;
        TotalStr: Text;
        TotalInt: Integer;
    begin
        CompanyInformation.Get();
        Assert.AreEqual(CompanyInformation."Contact Person", XMLDOMManagement.FindNodeText(
            GovTalkRequestXMLNode, GetSalesReqHeaderXpath('[name()=''VATCore:SubmittersContactName'']')), '');

        GeneralLedgerSetup.Get();
        Assert.AreEqual(GeneralLedgerSetup."LCY Code", XMLDOMManagement.FindNodeText(GovTalkRequestXMLNode,
            GetSalesReqHeaderXpath('[name()=''VATCore:CurrencyCode'']')), '');
        Assert.AreEqual('true', XMLDOMManagement.FindNodeText(GovTalkRequestXMLNode,
            GetSalesReqHeaderXpath('[name()=''VATCore:ApplyStrictEuropeanSaleValidation'']')), '');

        if VATReportHeader."Period Type" = VATReportHeader."Period Type"::Month then begin
            Assert.AreEqual(GetMonthCode(VATReportHeader."Period No."), XMLDOMManagement.FindNodeText(GovTalkRequestXMLNode,
                GetSalesReqHeaderXpath('[name()=''VATCore:TaxMonthlyPeriod'']/*[name()=''VATCore:TaxMonth'']')),
              'Expected that the Month value are the same');

            Assert.AreEqual(Format(VATReportHeader."Period Year"), XMLDOMManagement.FindNodeText(GovTalkRequestXMLNode,
                GetSalesReqHeaderXpath('[name()=''VATCore:TaxMonthlyPeriod'']/*[name()=''VATCore:TaxMonthPeriodYear'']')),
              'Expected that the Years are the same');
        end else begin
            Assert.AreEqual(Format(VATReportHeader."Period No."), XMLDOMManagement.FindNodeText(GovTalkRequestXMLNode,
                GetSalesReqHeaderXpath('[name()=''VATCore:TaxQuarter'']/*[name()=''VATCore:TaxQuarterNumber'']')),
              'Expected that the Quarter value are the same');
            Assert.AreEqual(Format(VATReportHeader."Period Year"), XMLDOMManagement.FindNodeText(
                GovTalkRequestXMLNode, GetSalesReqHeaderXpath('[name()=''VATCore:TaxQuarter'']/*[name()=''VATCore:TaxQuarterYear'']')),
              'Expected that the Years are the same');
        end;

        ECSLVATReportLine.SetFilter("Report No.", VATReportHeader."No.");
        Assert.IsTrue(XMLDOMManagement.FindNodes(GovTalkRequestXMLNode,
            GetSalesReqBodyXpath('[name()=''EuropeanSale'']/*[name()=''VATCore:TotalValueOfSupplies'']'),
            DummyXMLNodeList), 'Expected to get nodes back');
        Assert.AreEqual(ECSLVATReportLine.Count, DummyXMLNodeList.Count, 'Expected to have a node per record');

        XPathNavigator := GovTalkRequestXMLNode.CreateNavigator();
        XPathExpression := XPathNavigator.Compile(
            'sum(' + GetSalesReqBodyXpath('[name()=''EuropeanSale'']/*[name()=''VATCore:TotalValueOfSupplies'']') + ')');
        TotalStr := Format(XPathNavigator.Evaluate(XPathExpression));
        Evaluate(TotalInt, TotalStr);
        Assert.AreEqual(GetReportTotalValue(VATReportHeader), TotalInt, '');
    end;

    local procedure GetReportTotalValue(VATReportHeader: Record "VAT Report Header"): Integer
    var
        ECSLVATReportLine: Record "ECSL VAT Report Line";
    begin
        ECSLVATReportLine.SetRange("Report No.", VATReportHeader."No.");
        ECSLVATReportLine.SetCurrentKey("Report No.");
        ECSLVATReportLine.CalcSums("Total Value Of Supplies");
        exit(ECSLVATReportLine."Total Value Of Supplies");
    end;

    local procedure GetSalesReqHeaderXpath(xpath: Text): Text
    begin
        exit('//*[name()=''EuropeanSalesDeclarationRequest'']/*[name()=''Header'']/*' + xpath);
    end;

    local procedure GetSalesReqBodyXpath(xpath: Text): Text
    begin
        exit('//*[name()=''EuropeanSalesDeclarationRequest'']/*[name()=''Body'']/*' + xpath);
    end;

    local procedure GetMonthCode(MonthNo: Integer): Text
    begin
        exit(SelectStr(MonthNo, MonthsTok));
    end;

    local procedure InitPrerequisites()
    var
        CompanyInformation: Record "Company Information";
        GovTalkSetup: Record "Gov Talk Setup";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        CompanyInformation.Get();
        CompanyInformation."VAT Registration No." := '7777777';
        CompanyInformation."Branch Number GB" := '000';
        CompanyInformation."Post Code" := '12345';
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        CompanyInformation.Modify();

        if not GovTalkSetup.Get() then
            GovTalkSetup.Insert();
        GovTalkSetup.Username := 'DummyUserName';
        GovTalkSetup.Password := CreateGuid();
        GovTalkSetup.Modify();
    end;
}

