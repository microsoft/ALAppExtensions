// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using System;

codeunit 144033 TestIRMark
{
    Subtype = Test;
    TestType = Uncategorized;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        GovTalkNameSpaceTxt: Label 'http://www.govtalk.gov.uk/CM/envelope', Locked = true;
        TaxNameSpaceTxt: Label 'http://www.govtalk.gov.uk/taxation/vat/vatdeclaration/2', Locked = true;
        SampleXMLTxt: Label '<GovTalkMessage xmlns="http://www.govtalk.gov.uk/CM/envelope"><Body><vat:IRenvelope xmlns:vat="http://www.govtalk.gov.uk/taxation/vat/vatdeclaration/2"><vat:IRheader><vat:Keys><vat:Key Type="VATRegNo">999900001</vat:Key></vat:Keys><vat:PeriodID>2017-04</vat:PeriodID><vat:IRmark Type="generic">0fqQVgz9pYo9PBgN/+xJ2ZejSLA=</vat:IRmark><vat:Sender>Individual</vat:Sender></vat:IRheader><vat:VATDeclarationRequest><vat:VATDueOnOutputs>1.50</vat:VATDueOnOutputs><vat:VATDueOnECAcquisitions>0.50</vat:VATDueOnECAcquisitions><vat:TotalVAT>2.00</vat:TotalVAT><vat:VATReclaimedOnInputs>2.00</vat:VATReclaimedOnInputs><vat:NetVAT>0.00</vat:NetVAT><vat:NetSalesAndOutputs>20</vat:NetSalesAndOutputs><vat:NetPurchasesAndInputs>10</vat:NetPurchasesAndInputs><vat:NetECSupplies>10</vat:NetECSupplies><vat:NetECAcquisitions>5</vat:NetECAcquisitions></vat:VATDeclarationRequest></vat:IRenvelope></Body></GovTalkMessage>', Locked = true;

    [Test]
    [Scope('OnPrem')]
    procedure TestIRMark()
    var
        HMRCSubmissionHelpers: Codeunit "HMRC Submission Helpers";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        XMLDocument: DotNet XmlDocument;
        XMLNSMgr: DotNet XmlNamespaceManager;
        CorrectIRMark: Text;
    begin
        // [SCENARIO] Online submission XML that has the correct IRMark.
        // [GIVEN] FULL XML document that has the header and body which has IRMark element populated with correct value.
        LibraryLowerPermissions.SetO365Basic();

        // [WHEN] XML is loaded and function CreateIRMark is called
        XMLDocument := XMLDocument.XmlDocument();
        XMLDocument.PreserveWhitespace := true;
        XMLDocument.LoadXml(SampleXMLTxt);

        // [WHEN] Extract the correct IRMark provided in the online example.
        XMLNSMgr := XMLNSMgr.XmlNamespaceManager(XMLDocument.NameTable);
        XMLNSMgr.AddNamespace('Tax', TaxNameSpaceTxt);
        CorrectIRMark := XMLDocument.SelectSingleNode('//Tax:IRmark', XMLNSMgr).InnerText;

        // [THEN] The calculated IRMark should be equal to the correct IRMark that exists in the document already.
        Assert.AreEqual(CorrectIRMark, HMRCSubmissionHelpers.CreateIRMark(XMLDocument, GovTalkNameSpaceTxt, TaxNameSpaceTxt),
          'IRMark is not correct');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPasswordHashing()
    var
        HMRCSubmissionHelpers: Codeunit "HMRC Submission Helpers";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
    begin
        // [SCENARIO] Test hashing the password with MD5 for HMRC Authentication.
        // [GIVEN] Password as a text and pre-calculated hashed passwords with different condition.
        LibraryLowerPermissions.SetO365Basic();

        // [THEN] Empty password should hashed as followed
        Assert.AreEqual('1B2M2Y8AsgTpgAmY7PhCfg==', HMRCSubmissionHelpers.HashPassword(''), '');
    end;
}

