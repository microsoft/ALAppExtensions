// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.PayablesAgent;

using Microsoft.Agent.PayablesAgent;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.EServices.EDocumentConnector.Microsoft365;
using Microsoft.Finance.Deferral;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Enums;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Setup;
using System.Agents;
using System.AI;
using System.Environment.Configuration;
using System.Reflection;
using System.TestLibraries.Agents;
using System.TestLibraries.AI;
using System.TestTools.AIEvaluate;
using System.TestTools.AITestToolkit;
using System.TestTools.TestRunner;
using System.Utilities;

// Notes: Don't delete, for reference only
// AI.GetTestInput(); // entire input block for current test in tests  (same for multi and single turn)
// AITestContext.GetTestSetup(); // multi: 'test_setup' in the current turn, single: 'test_setup' in the current test
// AITestContext.GetInput(); // entire input block for current test in tests  (same for multi and single turn)
// AITestContext.GetExpectedData(); // multi: 'expected data'  inside the current turn, single: 'expected data' in the current test
// AITestContext.GetContext(); // 'context' inside the turn 

codeunit 133712 "Payables Agent Utilities"
{

    #region Agent config
    internal procedure EnablePayableAgent()
    var
        PayablesAgentSetup: Record "Payables Agent Setup";
        Agent: Record Agent;
        OutlookSetup: Record "Outlook Setup";
        LibraryCopilotCapability: Codeunit "Library - Copilot Capability";
    begin
        if not OutlookSetup.FindFirst() then begin
            OutlookSetup.Validate("Consent Received", true);
            OutlookSetup.Insert();
        end else begin
            OutlookSetup.Validate("Consent Received", true);
            OutlookSetup.Modify();
        end;

        PayablesAgentSetup.GetSetup();
        PayablesAgentSetup."Review Incoming Invoice" := false;
        PayablesAgentSetup.Modify();

        Agent.SetRange(State, Agent.State::Enabled);
        Agent.SetRange("Setup Page ID", Page::"Payables Agent Setup");

        if Agent.IsEmpty() then begin
            CreateDefaultAgent();
            // Activate AI Evaluate capability
            LibraryCopilotCapability.ActivateCopilotCapability(Enum::System.AI."Copilot Capability"::"AI Evaluate", '4f820121-b9a0-4b0a-ade8-a4fc5ee2fde1');
        end;
    end;

    local procedure CreateDefaultAgent()
    var
        TempAgentSetupBuffer: Record "Agent Setup Buffer";
        PASetup: Record "Payables Agent Setup";
        EDocumentService: Record "E-Document Service";
        AzureOpenAI: Codeunit "Azure OpenAI";
        LibraryCopilotCapability: Codeunit "Library - Copilot Capability";
        PayablesAgentSetup: Codeunit "Payables Agent Setup";
        PASetupConfiguration: Codeunit "PA Setup Configuration";
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Payables Agent", true) then
            // If the capability is not enabled then enable it
            LibraryCopilotCapability.ActivateCopilotCapability(Enum::"Copilot Capability"::"Payables Agent", GetPayablesAgentAppId());
        // The Payables Agent is inactive, no EDocumentServices are configured
        PayablesAgentSetup.LoadSetupConfiguration(PASetupConfiguration);
        // Activating the Payables Agent
        TempAgentSetupBuffer := PASetupConfiguration.GetAgentSetupBuffer();
        PASetup := PASetupConfiguration.GetPayablesAgentSetup();
        TempAgentSetupBuffer.State := TempAgentSetupBuffer.State::Enabled;
        PASetup."Monitor Outlook" := false;
        PASetup."Review Incoming Invoice" := false;
        PASetupConfiguration.SetAgentSetupBuffer(TempAgentSetupBuffer);
        PASetupConfiguration.SetPayablesAgentSetup(PASetup);
        PASetupConfiguration.SetSkipEmailVerification(true);
        PayablesAgentSetup.ApplyPayablesAgentSetup(PASetupConfiguration);
        // Creating the E-Document Service for the agent
        PayablesAgentSetup.LoadSetupConfiguration(PASetupConfiguration);
        PASetup := PASetupConfiguration.GetPayablesAgentSetup();
        EDocumentService.Get(PASetup."E-Document Service Code");
    end;
    #endregion

    #region Common Test Procedures
    internal procedure InitializeTest(var AgentTask: Record "Agent Task")
    var
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
    begin
        CleanCompanyData();
        ConfigureCompany();
        EnablePayableAgent();
        CreatePDFInvoiceFile(TempBlob);
        ImportPDFAsEDocument(TempBlob, EDocument);
        InvokeAgentTaskForEDocument(EDocument, AgentTask);
    end;

    internal procedure VerifyExpectedTestOutcome(var AgentTask: Record "Agent Task"; var OutputDictionary: Dictionary of [Text, JsonToken]): Boolean
    var
        EDocument: Record "E-Document";
        ExpectedOutput: Codeunit "Test Input Json";
        PurchaseInvoiceWasCreated: Boolean;
    begin
        GetEDocumentFromAgentTask(AgentTask, EDocument);
        ExpectedOutput := GetAITTestContext().GetInput().Element('expected').Element('data');
        PurchaseInvoiceWasCreated := ValidateGeneratedPurchaseInvoice(ExpectedOutput, OutputDictionary);
        if PurchaseInvoiceWasCreated then
            exit(true)
        else begin
            // If we fail to generate a valid Purchase Invoice, we still want to output the draft document for analysis
            OutputDraftDocument(EDocument, OutputDictionary);
            OutputVendorInformation(EDocument, OutputDictionary);
            exit(false);
        end;
    end;

    internal procedure LogTestExecutionDetails(var AgentTask: Record "Agent Task"; var OutputDictionary: Dictionary of [Text, JsonToken]; DataCreatedSuccessfully: Boolean)
    var
        Assert: Codeunit Assert;
        AgentOutput: Codeunit "Test Output Json";
        ContextJson, AnswerJson : JsonObject;
        ContextText, QueryText, AnswerText, DictionaryKey : Text;
        FailedToCreateExpectedDataMsg: Label 'Failed to create expected data.';
    begin
        QueryText := GetAITTestContext().GetInput().Element('description').ValueAsText();

        foreach DictionaryKey in OutputDictionary.Keys do
            AnswerJson.Add(DictionaryKey, OutputDictionary.Get(DictionaryKey));

        AgentOutput.Initialize();
        LibraryAgent.WriteTaskToOutput(AgentTask, AgentOutput);
        AnswerJson.Add('taskDetails', AgentOutput.AsJsonToken());
        AnswerJson.WriteTo(AnswerText);

        ContextJson.Add('vendor', GetAITTestContext().GetInput().Element('vendor').AsJsonToken().AsObject());
        ContextJson.Add('inboundInvoice', GetAITTestContext().GetInput().Element('inboundInvoice').AsJsonToken().AsObject());
        ContextJson.Add('inboundInvoiceLines', GetAITTestContext().GetInput().Element('inboundInvoiceLines').AsJsonToken().AsArray());
        ContextJson.WriteTo(ContextText);

        GetAITTestContext().SetQueryResponse(QueryText, AnswerText, ContextText);
        Assert.IsTrue(DataCreatedSuccessfully, FailedToCreateExpectedDataMsg);
    end;
    #endregion

    #region AI Test Setup
    internal procedure CleanCompanyData()
    var
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        DeferralTemplate: Record "Deferral Template";
        Vendor: Record Vendor;
        Customer: Record Customer;
        VendorTemplate: Record "Vendor Templ.";
        EDocVendorAssignHistory: Record "E-Doc. Vendor Assign. History";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PostedPurchaseHeader: Record "Purch. Inv. Header";
        PurchaseLine: Record "Purchase Line";
        PurchaseHeader: Record "Purchase Header";
        EDocument: Record "E-Document";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        CustomerPostingGroup: Record "Customer Posting Group";
        VendorPostingGroup: Record "Vendor Posting Group";
        VATPostingSetup: Record "VAT Posting Setup";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        GeneralPostingSetup: Record "General Posting Setup";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
    begin
        GLAccount.DeleteAll(false);
        DeferralTemplate.DeleteAll(false);
        Vendor.DeleteAll(false);
        VendorTemplate.DeleteAll(false);
        EDocVendorAssignHistory.DeleteAll(false);
        VendorLedgerEntry.DeleteAll(false);
        PostedPurchaseHeader.DeleteAll(false);
        PurchaseLine.DeleteAll(false);
        PurchaseHeader.DeleteAll(false);
        PurchInvLine.DeleteAll(false);
        PurchInvHeader.DeleteAll(false);
        SalesHeader.DeleteAll(false);
        SalesLine.DeleteAll(false);
        SalesInvoiceHeader.DeleteAll(false);
        SalesInvoiceLine.DeleteAll(false);
        CustomerPostingGroup.DeleteAll(false);
        VendorPostingGroup.DeleteAll(false);
        VATPostingSetup.DeleteAll(false);
        VATProductPostingGroup.DeleteAll(false);
        VATBusinessPostingGroup.DeleteAll(false);
        GeneralPostingSetup.DeleteAll(false);
        GenProductPostingGroup.DeleteAll(false);
        GenBusinessPostingGroup.DeleteAll(false);
        GLEntry.DeleteAll(false);
        Customer.DeleteAll(false);

        if EDocument.FindSet() then
            repeat
                EDocument.CleanupDocument();
                EDocument.Delete(false);
            until EDocument.Next() = 0;
    end;

    internal procedure ConfigureCompany()
    var
        SalesAndReceivablesSetup: Record "Sales & Receivables Setup";
        ScaffoldVendor: Record Vendor;
        ScaffoldGLAccount: Record "G/L Account";
        ScaffoldDeferralTemplate: Record "Deferral Template";
        CompanySetupInput, ElementToCreateArray : Codeunit "Test Input Json";
        CompanySetupInputExists: Boolean;
    begin
        CompanySetupInput := GetTestSetup();
        ConfigureDomainSetup(CompanySetupInput);

        // Configure specific records relevant for the Payables Agent tests
        ElementToCreateArray := CompanySetupInput.ElementExists('vendorsToCreate', CompanySetupInputExists);
        if CompanySetupInputExists then begin
            LibraryPurchase.CreateVendor(ScaffoldVendor);
            CreateRecordsFromSetup(ScaffoldVendor, ElementToCreateArray);
        end;

        ElementToCreateArray := CompanySetupInput.ElementExists('glAccountsToCreate', CompanySetupInputExists);
        if CompanySetupInputExists then begin
            LibraryERM.CreateGLAccount(ScaffoldGLAccount);
            CreateRecordsFromSetup(ScaffoldGLAccount, ElementToCreateArray);
        end;

        ElementToCreateArray := CompanySetupInput.ElementExists('deferralTemplatesToCreate', CompanySetupInputExists);
        if CompanySetupInputExists then begin
            LibraryERM.CreateDeferralTemplate(ScaffoldDeferralTemplate, Enum::"Deferral Calculation Method"::"Straight-Line", Enum::"Deferral Calculation Start Date"::"Posting Date", 1);
            CreateRecordsFromSetup(ScaffoldDeferralTemplate, ElementToCreateArray);
        end;

        ElementToCreateArray := CompanySetupInput.ElementExists('historicalPurchaseEntriesToCreate', CompanySetupInputExists);
        if CompanySetupInputExists then
            CreateHistoricalPurchaseEntriesFromCompanySetup(ElementToCreateArray);

        SalesAndReceivablesSetup.GetRecordOnce(); // Todo fix bug 617649
        SalesAndReceivablesSetup."Link Doc. Date To Posting Date" := false;
        SalesAndReceivablesSetup.Modify(false);
    end;

    local procedure ConfigureDomainSetup(CompanySetupInput: Codeunit "Test Input Json")
    var
        ScaffoldGenBusinessPostingGroup: Record "Gen. Business Posting Group";
        ScaffoldGenProductPostingGroup: Record "Gen. Product Posting Group";
        ScaffoldGeneralPostingSetup: Record "General Posting Setup";
        ScaffoldVATBusinessPostingGroup: Record "VAT Business Posting Group";
        ScaffoldVATProductPostingGroup: Record "VAT Product Posting Group";
        ScaffoldVATPostingSetup: Record "VAT Posting Setup";
        ScaffoldVendorPostingGroup: Record "Vendor Posting Group";
        ScaffoldCustomerPostingGroup: Record "Customer Posting Group";
        ScaffoldVendorTemplate: Record "Vendor Templ.";
        ElementToCreateArray: Codeunit "Test Input Json";
        LibraryTemplates: Codeunit "Library - Templates";
        CompanySetupInputExists: Boolean;
    begin
        ElementToCreateArray := CompanySetupInput.ElementExists('genBusinessPostingGroupToCreate', CompanySetupInputExists);
        if CompanySetupInputExists then begin
            LibraryERM.CreateGenBusPostingGroup(ScaffoldGenBusinessPostingGroup);
            CreateRecordsFromSetup(ScaffoldGenBusinessPostingGroup, ElementToCreateArray);
        end;

        ElementToCreateArray := CompanySetupInput.ElementExists('genProductPostingGroupToCreate', CompanySetupInputExists);
        if CompanySetupInputExists then begin
            LibraryERM.CreateGenProdPostingGroup(ScaffoldGenProductPostingGroup);
            CreateRecordsFromSetup(ScaffoldGenProductPostingGroup, ElementToCreateArray);
        end;

        ElementToCreateArray := CompanySetupInput.ElementExists('generalPostingSetupToCreate', CompanySetupInputExists);
        if CompanySetupInputExists then begin
            LibraryERM.CreateGeneralPostingSetupInvt(ScaffoldGeneralPostingSetup);
            CreateRecordsFromSetup(ScaffoldGeneralPostingSetup, ElementToCreateArray);
        end;

        ElementToCreateArray := CompanySetupInput.ElementExists('vatBusinessPostingGroupToCreate', CompanySetupInputExists);
        if CompanySetupInputExists then begin
            LibraryERM.CreateVATBusinessPostingGroup(ScaffoldVATBusinessPostingGroup);
            CreateRecordsFromSetup(ScaffoldVATBusinessPostingGroup, ElementToCreateArray);
        end;

        ElementToCreateArray := CompanySetupInput.ElementExists('vatProductPostingGroupToCreate', CompanySetupInputExists);
        if CompanySetupInputExists then begin
            LibraryERM.CreateVATProductPostingGroup(ScaffoldVATProductPostingGroup);
            CreateRecordsFromSetup(ScaffoldVATProductPostingGroup, ElementToCreateArray);
        end;

        ElementToCreateArray := CompanySetupInput.ElementExists('vatPostingSetupToCreate', CompanySetupInputExists);
        if CompanySetupInputExists then begin
            LibraryERM.CreateVATPostingSetupWithAccounts(ScaffoldVATPostingSetup, Enum::"Tax Calculation Type"::"Normal VAT", 99);
            CreateRecordsFromSetup(ScaffoldVATPostingSetup, ElementToCreateArray);
        end;

        ElementToCreateArray := CompanySetupInput.ElementExists('vendorPostingGroupToCreate', CompanySetupInputExists);
        if CompanySetupInputExists then begin
            LibraryPurchase.CreateVendorPostingGroup(ScaffoldVendorPostingGroup);
            CreateRecordsFromSetup(ScaffoldVendorPostingGroup, ElementToCreateArray);
        end;

        ElementToCreateArray := CompanySetupInput.ElementExists('customerPostingGroupToCreate', CompanySetupInputExists);
        if CompanySetupInputExists then begin
            LibrarySales.CreateCustomerPostingGroup(ScaffoldCustomerPostingGroup);
            CreateRecordsFromSetup(ScaffoldCustomerPostingGroup, ElementToCreateArray);
        end;

        ElementToCreateArray := CompanySetupInput.ElementExists('vendorTemplToCreate', CompanySetupInputExists);
        if CompanySetupInputExists then begin
            LibraryTemplates.CreateVendorTemplate(ScaffoldVendorTemplate);
            CreateRecordsFromSetup(ScaffoldVendorTemplate, ElementToCreateArray);
        end;
    end;

    local procedure CreateRecordsFromSetup(ScaffoldRecord: RecordRef; SetupArray: Codeunit "Test Input Json")
    var
        RecordToCreate: Codeunit "Test Input Json";
        NewRecord: RecordRef;
        Count, I : Integer;
    begin
        Count := SetupArray.GetElementCount();
        for I := 0 to Count - 1 do begin
            RecordToCreate := SetupArray.ElementAt(I);
            NewRecord := Json2Record(RecordToCreate.ValueAsJsonObject(), ScaffoldRecord);
            NewRecord.Insert(true);
        end;
        ScaffoldRecord.Delete();
    end;

    local procedure CreateHistoricalPurchaseEntriesFromCompanySetup(HistoricalPurchaseEntriesToCreateArray: Codeunit "Test Input Json")
    var
        PurchaseHeader: Record "Purchase Header";
        HistoricalPurchaseEntryToCreate: Codeunit "Test Input Json";
        VendorNo, DocumentNo : Code[20];
        Count, I : Integer;
    begin
        Count := HistoricalPurchaseEntriesToCreateArray.GetElementCount();
        for I := 0 to Count - 1 do begin
            HistoricalPurchaseEntryToCreate := HistoricalPurchaseEntriesToCreateArray.ElementAt(I);
            VendorNo := CopyStr(HistoricalPurchaseEntryToCreate.Element('Buy-from Vendor No.').ValueAsText(), 1, MaxStrLen(VendorNo));
            DocumentNo := CopyStr(HistoricalPurchaseEntryToCreate.Element('No.').ValueAsText(), 1, MaxStrLen(DocumentNo));
            LibraryPurchase.CreatePurchHeaderWithDocNo(PurchaseHeader, Enum::"Purchase Document Type"::Invoice, VendorNo, DocumentNo);
            PurchaseHeader.Validate("Posting Date", ParseDateFromText(HistoricalPurchaseEntryToCreate.Element('Posting Date').ValueAsText()));
            PurchaseHeader.Validate("Gen. Bus. Posting Group", HistoricalPurchaseEntryToCreate.Element('Gen. Bus. Posting Group').ValueAsText());
            PurchaseHeader.Validate("VAT Bus. Posting Group", HistoricalPurchaseEntryToCreate.Element('VAT Bus. Posting Group').ValueAsText());
            PurchaseHeader.Modify(true);
            CreatePurchaseHeaderLinesFromCompanySetup(PurchaseHeader, HistoricalPurchaseEntryToCreate.Element('lines'));
            LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        end;
    end;

    local procedure CreatePurchaseHeaderLinesFromCompanySetup(var PurchaseHeader: Record "Purchase Header"; LinesToCreateArray: Codeunit "Test Input Json")
    var
        PurchaseLine: Record "Purchase Line";
        HistoricalLineToCreate: Codeunit "Test Input Json";
        LineType: Enum "Purchase Line Type";
        No: Code[20];
        Count, I : Integer;
    begin
        Count := LinesToCreateArray.GetElementCount();
        for I := 0 to Count - 1 do begin
            HistoricalLineToCreate := LinesToCreateArray.ElementAt(I);
            LineType := Enum::"Purchase Line Type".FromInteger(HistoricalLineToCreate.Element('Type').ValueAsInteger());
            No := CopyStr(HistoricalLineToCreate.Element('No.').ValueAsText(), 1, MaxStrLen(No));
            LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, LineType, No, HistoricalLineToCreate.Element('Quantity').ValueAsDecimal());
            PurchaseLine := Json2Record(HistoricalLineToCreate.ValueAsJsonObject(), PurchaseLine);
            PurchaseLine.Modify(true);
        end;
    end;
    #endregion

    #region EDocument Generation


    internal procedure CreatePDFInvoiceFile(var TempBlob: Codeunit "Temp Blob")
    var
        OriginalCompanyAsCustomer: Record Customer;
    begin
        CreateCustomerFromCompanyInformation(OriginalCompanyAsCustomer);
        SetupCompanyAsVendor();
        CreateAndPostSalesInvoice(OriginalCompanyAsCustomer);
        GeneratePDF(OriginalCompanyAsCustomer, TempBlob);
        RestoreCompanyInformation(OriginalCompanyAsCustomer);
    end;

    internal procedure CreateCustomerFromCompanyInformation(var Customer: Record Customer)
    var
        CompanyInformation: Record "Company Information";
        GenBusPostingGroup: Record "Gen. Business Posting Group";
        VATBusPostingGroup: Record "VAT Business Posting Group";
    begin
        CompanyInformation.GetRecordOnce();
        GenBusPostingGroup.FindLast();
        VATBusPostingGroup.FindLast(); // Fix bug (617632)
        Customer.Get(LibrarySales.CreateCustomerWithBusPostingGroups(GenBusPostingGroup.Code, VATBusPostingGroup.Code));
        Customer.Validate(Name, CompanyInformation.Name);
        Customer.Validate(Address, CompanyInformation.Address);
        Customer.Validate("Phone No.", CompanyInformation."Phone No.");
        Customer.Validate("E-Mail", CompanyInformation."E-Mail");
        Customer.Validate("Post Code", CompanyInformation."Post Code");
        Customer.Validate(City, CompanyInformation.City);
        Customer.Validate("Country/Region Code", CompanyInformation."Country/Region Code");
        Customer.Modify(false);
    end;

    internal procedure RestoreCompanyInformation(var Customer: Record Customer)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.GetRecordOnce();
        CompanyInformation.Validate(Name, Customer.Name);
        CompanyInformation.Validate(Address, Customer.Address);
        CompanyInformation.Validate("Phone No.", Customer."Phone No.");
        CompanyInformation.Validate("E-Mail", Customer."E-Mail");
        CompanyInformation.Validate("Country/Region Code", Customer."Country/Region Code");
        CompanyInformation.Validate("Post Code", Customer."Post Code");
        CompanyInformation.Validate(City, Customer.City);
        CompanyInformation.Modify(true);
    end;

    local procedure SetupCompanyAsVendor()
    var
        CompanyInformation: Record "Company Information";
        VendorInput: Codeunit "Test Input Json";
    begin
        CompanyInformation.GetRecordOnce();
        Clear(CompanyInformation.Picture);
        VendorInput := AITTestContext.GetInput().Element('vendor');
        CompanyInformation := Json2Record(VendorInput.ValueAsJsonObject(), CompanyInformation);
        CompanyInformation.Modify(true);
    end;

    local procedure CreateAndPostSalesInvoice(var Customer: Record Customer)
    var
        SalesHeader, ScaffoldSalesHeader : Record "Sales Header";
        NoSeries: Record "No. Series";
        SalesLine: Record "Sales Line";
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        SalesInvoiceInput, SalesInvoiceLinesInput, SalesInvoiceLine : Codeunit "Test Input Json";
        // PostedInvoiceNo: Code[20];
        SalesInvoiceLinesExists: Boolean;
        Count, I : Integer;
    begin
        // Create Purchase Invoice Header
        SalesInvoiceInput := AITTestContext.GetInput().Element('inboundInvoice');
        LibrarySales.CreateSalesHeader(ScaffoldSalesHeader, Enum::"Sales Document Type"::Invoice, Customer."No.");
        NoSeries.Get(ScaffoldSalesHeader.GetNoSeriesCode());
        NoSeries."Manual Nos." := true;
        NoSeries.Modify(true);
        SalesHeader := Json2Record(SalesInvoiceInput.ValueAsJsonObject(), ScaffoldSalesHeader);
        SalesHeader.Insert(true);
        ScaffoldSalesHeader.Delete(true);

        // Create Purchase Invoice Lines
        SalesInvoiceLinesInput := AITTestContext.GetInput().ElementExists('inboundInvoiceLines', SalesInvoiceLinesExists);
        if SalesInvoiceLinesExists then begin
            Count := SalesInvoiceLinesInput.GetElementCount();
            for I := 0 to Count - 1 do begin
                SalesInvoiceLine := SalesInvoiceLinesInput.ElementAt(I);
                LibrarySales.CreateSalesLineSimple(SalesLine, SalesHeader);
                SalesLine := Json2Record(SalesInvoiceLine.ValueAsJsonObject(), SalesLine);
                SalesLine.Modify(true);
            end;
        end;

        GeneralPostingSetup.Get(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");
        GeneralPostingSetup.Validate(Blocked, false);
        GeneralPostingSetup.Modify(true);
        VATPostingSetup.Get(SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group");
        VATPostingSetup.Validate(Blocked, false);
        VATPostingSetup.Modify(true);
    end;

    internal procedure GeneratePDF(OriginalCompanyAsCustomer: Record Customer; var TempBlob: Codeunit "Temp Blob")
    var
        ReportLayoutSelection: Record "Tenant Report Layout Selection";
        ReportLayout: Record "Report Layout List";
        SalesHeader: Record "Sales Header";
        CompanyInformation: Record "Company Information";
        TempCompanyInformation: Record "Company Information" temporary;
        ReportTargetStream: OutStream;
        ReportInTargetStream: InStream;
    // ReportLayoutNameTok: Label 'StandardSalesInvoiceBlueSimple.docx', Locked = true;
    begin
        // Select the Word layout for Sales Invoice Report
        ReportLayout.SetFilter(ReportLayout."Report ID", format(Report::"Standard Sales - Draft Invoice"));
        ReportLayout.SetFilter(ReportLayout."Layout Format", format(ReportLayoutType::Word));
        // ReportLayout.SetFilter(ReportLayout.Name, ReportLayoutNameTok);
        if ReportLayout.IsEmpty() then
            Error('No layout of type %1', ReportLayoutType::Word);

        ReportLayoutSelection.Init();
        ReportLayoutSelection."Report ID" := ReportLayout."Report ID"; // ToDo: Can we validate these?
        ReportLayoutSelection."App ID" := ReportLayout."Application ID";
        ReportLayoutSelection."Layout Name" := ReportLayout.Name;
        if not ReportLayoutSelection.Insert(true) then
            ReportLayoutSelection.Modify(true);

        // Run the Sales Invoice Report to generate the PDF
        TempBlob.CreateInStream(ReportInTargetStream); // ToDo: Do we need this InStream?
        TempBlob.CreateOutStream(ReportTargetStream);
        SalesHeader.SetRange("Sell-to Customer No.", OriginalCompanyAsCustomer."No.");
        SalesHeader.FindLast();

        CompanyInformation.GetRecordOnce(); // Todo: Bug fix 617633
        TempCompanyInformation := CompanyInformation;
        CompanyInformation."Allow Blank Payment Info." := true; // Fix bug (617633) // ES specific requirement to run the report
        CompanyInformation.Modify(false);

        Report.SaveAs(Report::"Standard Sales - Draft Invoice", '', ReportFormat::Pdf, ReportTargetStream, SalesHeader);

        CompanyInformation := TempCompanyInformation;
        CompanyInformation.Modify(false);
    end;

    internal procedure ImportPDFAsEDocument(var TempBlob: Codeunit "Temp Blob"; var EDocument: Record "E-Document")
    var
        PayablesAgentSetup: Record "Payables Agent Setup";
        EDocumentService: Record "E-Document Service";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocImport: Codeunit "E-Doc. Import";
        FileInStream: InStream;
        PDFFileNameTok: Label 'invoice.pdf', Locked = true;
    begin
        TempBlob.CreateInStream(FileInStream);
        PayablesAgentSetup.GetSetup();
        if not EDocumentService.Get(PayablesAgentSetup."E-Document Service Code") then
            exit;

        EDocImport.CreateFromType(EDocument, EDocumentService, Enum::"E-Doc. File Format"::PDF, PDFFileNameTok, FileInStream);
        EDocument."Source Details" := 'Payables Agent Test Invoice';
        EDocument.Modify(true);
        EDocImportParameters := EDocument.GetEDocumentService().GetDefaultImportParameters();
        EDocImportParameters."Processing Customizations" := Enum::"E-Doc. Proc. Customizations"::Default;
        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);
        Commit(); // Necessary to lose the lock on the Agent Task (created within the OnAfterProcessIncomingEDocument event)
    end;
    #endregion

    #region User Intervention Simulation

    internal procedure SimulateUserApprovalForDraftInvoice(var AgentTask: Record "Agent Task"; var OutputDictionary: Dictionary of [Text, JsonToken])
    var
        EvaluationResults: JsonObject;
        UserInterventionMessage: Text;
        Relevant: Boolean;
        SimulateUserApprovalTok: Label 'SimulateUserApprovalForDraftInvoice', Locked = true;
        DraftReadyForReviewMsg: Label 'Review the draft before purchase document is created.', Locked = true;
        NonRelevantUserInterventionErr: Label 'Non relevant user intervention message: %1', Locked = true;
    begin
        if not ValidateTaskReadyForUserIntervention(AgentTask, UserInterventionMessage, OutputDictionary) then
            exit;

        ValidateMessage(UserInterventionMessage, DraftReadyForReviewMsg, Relevant, EvaluationResults);
        if not Relevant then
            AddErrorToOutputDictionary(SimulateUserApprovalTok, StrSubstNo(NonRelevantUserInterventionErr, UserInterventionMessage), OutputDictionary);

        AddEvaluationResultToOutputDictionary(SimulateUserApprovalTok, EvaluationResults, OutputDictionary);
        LibraryAgent.ContinueTaskAndWait(AgentTask, '');
    end;

    internal procedure SimulateUserSelectingVendorForEDocument(var AgentTask: Record "Agent Task"; var OutputDictionary: Dictionary of [Text, JsonToken])
    var
        UserInterventionInput: Codeunit "Test Input Json";
        EvaluationResults: JsonObject;
        UserInterventionMessage: Text;
        Relevant: Boolean;
        SimulateUserSelectingVendorTok: Label 'SimulateUserSelectingVendor', Locked = true;
        NonRelevantUserInterventionErr: Label 'Non relevant user intervention message: %1', Locked = true;
    begin
        if not ValidateTaskReadyForUserIntervention(AgentTask, UserInterventionMessage, OutputDictionary) then
            exit;

        if not GetUserInterventionSelection(UserInterventionInput, OutputDictionary) then
            exit;

        ValidateMessage(UserInterventionMessage, UserInterventionInput.ElementAt(GlobalUserInterventionCounter).Element('reason').ValueAsText(), Relevant, EvaluationResults);
        if Relevant then
            SetVendorDefinedInTestCase(AgentTask, OutputDictionary)
        else
            AddErrorToOutputDictionary(SimulateUserSelectingVendorTok, StrSubstNo(NonRelevantUserInterventionErr, UserInterventionMessage), OutputDictionary);

        GlobalUserInterventionCounter += 1;
        AddEvaluationResultToOutputDictionary(SimulateUserSelectingVendorTok, EvaluationResults, OutputDictionary);
    end;

    internal procedure SimulateUserRequestCreateVendor(var AgentTask: Record "Agent Task"; var OutputDictionary: Dictionary of [Text, JsonToken])
    var
        UserInterventionInput: Codeunit "Test Input Json";
        EvaluationResults: JsonObject;
        UserInterventionMessage: Text;
        Relevant: Boolean;
        SimulateUserRequestCreateVendorTok: Label 'SimulateUserRequestCreateVendor', Locked = true;
        NonRelevantUserInterventionErr: Label 'Non relevant user intervention message: %1', Locked = true;
        MissingCreateVendorInputErr: Label 'Missing create_vendor input in test case for user intervention simulation.', Locked = true;
    begin
        if not ValidateTaskReadyForUserIntervention(AgentTask, UserInterventionMessage, OutputDictionary) then
            exit;

        if not GetUserInterventionSelection(UserInterventionInput, OutputDictionary) then
            exit;

        ValidateMessage(UserInterventionMessage, UserInterventionInput.ElementAt(GlobalUserInterventionCounter).Element('reason').ValueAsText(), Relevant, EvaluationResults);
        if Relevant then begin
            if UserInterventionInput.ElementAt(GlobalUserInterventionCounter).Element('create_vendor').ValueAsBoolean() then
                RequestTaskToCreateVendor(AgentTask, OutputDictionary)
            else
                AddErrorToOutputDictionary(SimulateUserRequestCreateVendorTok, MissingCreateVendorInputErr, OutputDictionary);
        end
        else
            AddErrorToOutputDictionary(SimulateUserRequestCreateVendorTok, StrSubstNo(NonRelevantUserInterventionErr, UserInterventionMessage), OutputDictionary);

        GlobalUserInterventionCounter += 1;
        AddEvaluationResultToOutputDictionary(SimulateUserRequestCreateVendorTok, EvaluationResults, OutputDictionary);
    end;

    internal procedure SimulateUserApprovalForNewVendor(var AgentTask: Record "Agent Task"; var OutputDictionary: Dictionary of [Text, JsonToken])
    var
        Vendor: Record Vendor;
        EvaluationResults: JsonObject;
        UserInterventionMessage: Text;
        Relevant: Boolean;
        SimulateUserApprovalForNewVendorTok: Label 'SimulateUserApprovalForNewVendor', Locked = true;
        VendorReviewMsg: Label 'Review the new vendor card before proceeding with draft processing.', Locked = true;
        NonRelevantUserInterventionErr: Label 'Non relevant user intervention message: %1', Locked = true;
        VendorNotFoundErr: Label 'Vendor not found after user approval simulation.', Locked = true;
    begin
        if not ValidateTaskReadyForUserIntervention(AgentTask, UserInterventionMessage, OutputDictionary) then
            exit;

        ValidateMessage(UserInterventionMessage, VendorReviewMsg, Relevant, EvaluationResults);
        if not Relevant then
            AddErrorToOutputDictionary(SimulateUserApprovalForNewVendorTok, StrSubstNo(NonRelevantUserInterventionErr, UserInterventionMessage), OutputDictionary);

        AddEvaluationResultToOutputDictionary(SimulateUserApprovalForNewVendorTok, EvaluationResults, OutputDictionary);
        Vendor.SetRange(Name, AITTestContext.GetInput().Element('vendor').Element('Name').ValueAsText());
        if Vendor.FindFirst() then begin
            Vendor.Validate(Blocked, Enum::"Vendor Blocked"::" ");
            Vendor.Modify(true);
            LibraryAgent.ContinueTaskAndWait(AgentTask, '');
        end
        else
            AddErrorToOutputDictionary(SimulateUserApprovalForNewVendorTok, VendorNotFoundErr, OutputDictionary);
    end;

    internal procedure SimulateUserSelectingMissingAccount(var AgentTask: Record "Agent Task"; var OutputDictionary: Dictionary of [Text, JsonToken])
    var
        UserInterventionInput: Codeunit "Test Input Json";
        EvaluationResults: JsonObject;
        UserInterventionMessage: Text;
        Relevant: Boolean;
        SimulateUserSelectingMissingAccountTok: Label 'SimulateUserSelectingMissingAccount', Locked = true;
        NonRelevantUserInterventionErr: Label 'Non relevant user intervention message: %1', Locked = true;
    begin
        if not ValidateTaskReadyForUserIntervention(AgentTask, UserInterventionMessage, OutputDictionary) then
            exit;

        if not GetUserInterventionSelection(UserInterventionInput, OutputDictionary) then
            exit;

        ValidateMessage(UserInterventionMessage, UserInterventionInput.ElementAt(GlobalUserInterventionCounter).Element('reason').ValueAsText(), Relevant, EvaluationResults);
        if Relevant then
            SetMissingAccountDefinedInTestCase(AgentTask, OutputDictionary)
        else
            AddErrorToOutputDictionary(SimulateUserSelectingMissingAccountTok, StrSubstNo(NonRelevantUserInterventionErr, UserInterventionMessage), OutputDictionary);

        GlobalUserInterventionCounter += 1;
        AddEvaluationResultToOutputDictionary(SimulateUserSelectingMissingAccountTok, EvaluationResults, OutputDictionary);
    end;

    procedure ValidateTaskReadyForUserIntervention(var AgentTask: Record "Agent Task"; var UserInterventionMessage: Text; var OutputDictionary: Dictionary of [Text, JsonToken]): Boolean
    var
        TempUserInterventionRequest: Record "Agent User Int Request Details" temporary;
        TempUserInterventionAnnotation: Record "Agent Annotation" temporary;
        TempUserInterventionSuggestion: Record "Agent Task User Int Suggestion" temporary;
        AgentTaskNeedsAttentionErr: Label 'Agent Task is not paused or does not require attention. Agent status: %1, Needs Attention: %2', Locked = true;
        UserInterventionRequestNotFoundErr: Label 'No user intervention request found in the latest agent task log entry. Task ID: %1', Locked = true;
        TaskDetailAssistanceExpectedErr: Label 'Expected User intervention of Type Assistance or Review Record. Actual: %1', Locked = true;
    begin
        if not LibraryAgent.RequiresUserIntervention(AgentTask) then begin
            AddErrorToOutputDictionary('ValidateTaskStatus', StrSubstNo(AgentTaskNeedsAttentionErr, Format(AgentTask.Status), Format(AgentTask."Needs Attention")), OutputDictionary);
            exit(false);
        end;

        if not LibraryAgent.GetLastUserInterventionRequestDetails(AgentTask, TempUserInterventionRequest, TempUserInterventionAnnotation, TempUserInterventionSuggestion) then begin
            AddErrorToOutputDictionary('ValidateTaskLogEntryType', StrSubstNo(UserInterventionRequestNotFoundErr, Format(AgentTask.ID)), OutputDictionary);
            exit(false);
        end;

        if not (TempUserInterventionRequest.Type in [TempUserInterventionRequest.Type::Assistance, TempUserInterventionRequest.Type::ReviewRecord]) then begin
            AddErrorToOutputDictionary('ValidateUserInterventionRequestType', StrSubstNo(TaskDetailAssistanceExpectedErr, TempUserInterventionRequest.Type), OutputDictionary);
            exit(false);
        end;

        UserInterventionMessage := TempUserInterventionRequest.Type = TempUserInterventionRequest.Type::Assistance ?
            TempUserInterventionAnnotation.Message :
            TempUserInterventionRequest.Message;
        exit(true);
    end;

    [TryFunction]
    procedure ValidateMessage(GeneratedMessage: Text; Keywords: Text; var Relevant: Boolean; var EvaluationResults: JsonObject)
    var
        PromptEvaluator: Codeunit "Prompt Evaluator";
        AIEvaluateData: Codeunit "AI Evaluate Data";
        AIEvaluate: Codeunit "AI Evaluate";
        EvaluatorStream: InStream;
        Output: JsonObject;
        OutputToken: JsonToken;
    begin
        // Read prompty file
        NavApp.GetResource('PromptyPrompts/EvaluateAgentMessage.prompty', EvaluatorStream, TextEncoding::UTF8);
        PromptEvaluator.Read(EvaluatorStream);

        // Set data
        AIEvaluateData.AddQuery(Keywords);
        AIEvaluateData.AddResponse(GeneratedMessage);
        AIEvaluateData.AddContext('');
        EvaluationResults.Add('generatedMessage', GeneratedMessage);

        // Evaluate
        AIEvaluate.SetEvaluator(PromptEvaluator);
        Output := AIEvaluate.Evaluate(AIEvaluateData);

        Output.get('relevant', OutputToken);
        Relevant := OutputToken.AsValue().AsText() = 'yes';
        EvaluationResults.Add('relevant', Relevant);

        // Get score
        Output.Get('score', OutputToken);
        EvaluationResults.Add('score', OutputToken.AsValue().AsInteger());

        Output.Get('reason', OutputToken);
        EvaluationResults.Add('reason', OutputToken.AsValue().AsText());
    end;

    local procedure SetVendorDefinedInTestCase(var AgentTask: Record "Agent Task"; var OutputDictionary: Dictionary of [Text, JsonToken])
    var
        EDocument: Record "E-Document";
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        Vendor: Record Vendor;
        EDocImportParameters: Record "E-Doc. Import Parameters";
        UserInterventionInput, VendorNameInput : Codeunit "Test Input Json";
        EDocImport: Codeunit "E-Doc. Import";
        VendorNameFieldExists: Boolean;
        VendorNameNotFoundInInputErr: Label 'Vendor name not found in the test case input', Locked = true;
        VendorNotFoundErr: Label 'Vendor not found for the given name %1', Locked = true;
    begin
        GetEDocumentFromAgentTask(AgentTask, EDocument);
        GetUserInterventionSelection(UserInterventionInput, OutputDictionary);

        VendorNameInput := UserInterventionInput.ElementAt(GlobalUserInterventionCounter).ElementExists('selected_vendor', VendorNameFieldExists);
        if not VendorNameFieldExists then begin
            AddErrorToOutputDictionary('FindVendorInTestCase', VendorNameNotFoundInInputErr, OutputDictionary);
            exit;
        end;

        Vendor.SetRange(Name, VendorNameInput.ValueAsText());
        if not Vendor.FindFirst() then begin
            AddErrorToOutputDictionary('FindVendorInDatabase', StrSubstNo(VendorNotFoundErr, VendorNameInput.ValueAsText()), OutputDictionary);
            exit;
        end;

        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        EDocumentPurchaseHeader.Validate("[BC] Vendor No.", Vendor."No.");
        EDocumentPurchaseHeader.Modify(true);

        EDocImportParameters."Step to Run" := Enum::"Import E-Document Steps"::"Prepare draft";
        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);
        LibraryAgent.ContinueTaskAndWait(AgentTask, '');
    end;

    local procedure SetMissingAccountDefinedInTestCase(var AgentTask: Record "Agent Task"; var OutputDictionary: Dictionary of [Text, JsonToken])
    var
        EDocument: Record "E-Document";
        GLAccount: Record "G/L Account";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        UserInterventionInput, AccountCodeInput : Codeunit "Test Input Json";
        EDocImport: Codeunit "E-Doc. Import";
        AccountFieldExists: Boolean;
        AccountCodeNotFoundInInputErr: Label 'Account code not found in the test case input', Locked = true;
        AccountNotFoundErr: Label 'Account not found for the given code %1', Locked = true;
        PurchaseLineNotFoundErr: Label 'No E-Document Purchase Lines found for E-Document Entry No. %1.', Locked = true;
    begin
        GetEDocumentFromAgentTask(AgentTask, EDocument);
        GetUserInterventionSelection(UserInterventionInput, OutputDictionary);

        AccountCodeInput := UserInterventionInput.ElementAt(GlobalUserInterventionCounter).ElementExists('selected_account', AccountFieldExists);
        if not AccountFieldExists then begin
            AddErrorToOutputDictionary('FindAccountInTestCase', AccountCodeNotFoundInInputErr, OutputDictionary);
            exit;
        end;

        GLAccount.SetRange("No.", AccountCodeInput.ValueAsText());
        if not GLAccount.FindFirst() then begin
            AddErrorToOutputDictionary('FindAccountInDatabase', StrSubstNo(AccountNotFoundErr, AccountCodeInput.ValueAsText()), OutputDictionary);
            exit;
        end;

        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        if EDocumentPurchaseLine.IsEmpty() then begin
            AddErrorToOutputDictionary('FindVendorInDatabase', StrSubstNo(PurchaseLineNotFoundErr, EDocument."Entry No"), OutputDictionary);
            exit;
        end;
        EDocumentPurchaseLine.FindSet();
        repeat
            EDocumentPurchaseLine.Validate("[BC] Purchase Line Type", EDocumentPurchaseLine."[BC] Purchase Line Type"::"G/L Account");
            EDocumentPurchaseLine.Validate("[BC] Purchase Type No.", GLAccount."No.");
            EDocumentPurchaseLine.Modify(true);
        until EDocumentPurchaseLine.Next() = 0;

        EDocImportParameters."Step to Run" := Enum::"Import E-Document Steps"::"Prepare draft";
        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);
    end;

    internal procedure RequestTaskToCreateVendor(var AgentTask: Record "Agent Task"; var OutputDictionary: Dictionary of [Text, JsonToken])
    var
        PAAgentTaskExecution: Codeunit "PA Agent Task Execution";
        FailCreateVendorRequestErr: Label 'Failed to request vendor creation for Agent Task ID %1.', Locked = true;
    begin
        if not LibraryAgent.CreateUserInterventionFromSuggestionAndWait(AgentTask, PAAgentTaskExecution.GetCreateVendorInterventionSuggestionCode()) then begin
            AddErrorToOutputDictionary('RequestTaskToCreateVendor', FailCreateVendorRequestErr, OutputDictionary);
            exit;
        end;
    end;
    #endregion

    #region AI Test Utilities
    internal procedure GetAITTestContext(): Codeunit "AIT Test Context"
    begin
        exit(AITTestContext);
    end;

    internal procedure GetTestSetup() SetupTestInputJson: Codeunit "Test Input Json"
    begin
        SetupTestInputJson := AITTestContext.GetTestSetup();
        if SetupTestInputJson.AsJsonToken().IsObject() then
            exit(SetupTestInputJson);

        SetupTestInputJson.Initialize(GetTestSetupJsonObj(SetupTestInputJson.ValueAsText()));
        exit(SetupTestInputJson);
    end;

    internal procedure GetTestSetupJsonObj(SetupName: Text): JsonToken //get the setup data from the file based on the available file name
    var
        SetupInStream: InStream;
        SetupAsText: Text;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        NavApp.GetResource(GetTestSetupPath() + SetupName, SetupInStream, TextEncoding::UTF8);
        SetupInStream.Read(SetupAsText);
        JsonObject.ReadFromYaml(SetupAsText);
        JsonObject.Get('test_setup', JsonToken);

        exit(JsonToken);
    end;

    internal procedure InvokeAgentTaskForEDocument(var EDocument: Record "E-Document"; var AgentTask: Record "Agent Task"): Boolean
    begin
        GlobalUserInterventionCounter := 0;
        AgentTask.SetRange("External ID", Format(EDocument."Entry No"));
        if not AgentTask.FindFirst() then
            exit(false);
        exit(LibraryAgent.WaitForTaskToComplete(AgentTask));
    end;

    internal procedure ValidateGeneratedPurchaseInvoice(ExpectedOutput: Codeunit "Test Input Json"; var OutputDictionary: Dictionary of [Text, JsonToken]): Boolean
    var
        PurchaseHeaderNo: Code[20];
    begin
        if not ValidateGeneratedPurchaseHeader(ExpectedOutput, OutputDictionary, PurchaseHeaderNo) then
            exit(false);
        exit(ValidateGeneratedPurchaseLines(ExpectedOutput, OutputDictionary, PurchaseHeaderNo));
    end;

    internal procedure OutputDraftDocument(EDocument: Record "E-Document"; var OutputDictionary: Dictionary of [Text, JsonToken])
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        EDocumentPurchaseLinesArray: JsonArray;
        JsonValue: JsonValue;
        EDocumentPurchaseHeaderErr: Label 'E-Document Purchase Header not found for E-Document Entry No. %1.', Locked = true;
        EDocumentPurchaseLineErr: Label 'E-Document Purchase Lines not found for E-Document Entry No. %1.', Locked = true;
    begin
        // Output Draft E-Document Purchase Header
        if not EDocumentPurchaseHeader.Get(EDocument."Entry No") then begin
            JsonValue.SetValue(StrSubstNo(EDocumentPurchaseHeaderErr, EDocument."Entry No"));
            OutputDictionary.Add('draftEDocument', JsonValue.AsToken());
            exit;
        end;
        OutputDictionary.Add('draftEDocument', Record2Json(EDocumentPurchaseHeader).AsToken());

        // Output Draft E-Document Purchase Lines
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        if EDocumentPurchaseLine.IsEmpty() then begin
            JsonValue.SetValue(StrSubstNo(EDocumentPurchaseLineErr, EDocument."Entry No"));
            OutputDictionary.Add('draftEDocumentLines', JsonValue.AsToken());
            exit;
        end;
        EDocumentPurchaseLine.FindSet();
        repeat
            EDocumentPurchaseLinesArray.Add(Record2Json(EDocumentPurchaseLine).AsToken());
        until EDocumentPurchaseLine.Next() = 0;
        OutputDictionary.Add('draftEDocumentLines', EDocumentPurchaseLinesArray.AsToken());
    end;

    internal procedure OutputVendorInformation(EDocument: Record "E-Document"; var OutputDictionary: Dictionary of [Text, JsonToken])
    var
        Vendor: Record Vendor;
        JsonValue: JsonValue;
        VendorErr: Label 'Vendor not found for E-Document Bill-to/Pay-to No. %1.', Locked = true;
    begin
        if Vendor.Get(EDocument."Bill-to/Pay-to No.") then
            OutputDictionary.Add('draftEDocumentVendor', Record2Json(Vendor).AsToken())
        else begin
            JsonValue.SetValue(StrSubstNo(VendorErr, EDocument."Bill-to/Pay-to No."));
            OutputDictionary.Add('draftEDocumentVendor', JsonValue.AsToken());
        end;
    end;

    local procedure ValidateGeneratedPurchaseHeader(ExpectedOutput: Codeunit "Test Input Json"; var OutputDictionary: Dictionary of [Text, JsonToken]; var PurchaseHeaderNo: Code[20]): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeaderOutput: Codeunit "Test Input Json";
        JsonValue: JsonValue;
        ElementIsExpected: Boolean;
        ExpectedPurchaseHeaderErr: Label 'Expected purchaseHeader not found in the test case definition.', Locked = true;
        PurchaseHeaderNotFoundErr: Label 'Purchase Header not found for the given vendor invoice number %1.', Locked = true;
    begin
        PurchaseHeaderOutput := ExpectedOutput.ElementExists('purchaseHeader', ElementIsExpected);
        if not ElementIsExpected then begin
            JsonValue.SetValue(ExpectedPurchaseHeaderErr);
            OutputDictionary.Add('purchaseHeader', JsonValue.AsToken());
            exit(false);
        end;

        ApplyFiltersToPurchaseHeader(PurchaseHeaderOutput, PurchaseHeader);
        if not PurchaseHeader.FindLast() then begin
            JsonValue.SetValue(StrSubstNo(PurchaseHeaderNotFoundErr, PurchaseHeaderOutput.Element('Vendor Invoice No.').ValueAsText()));
            OutputDictionary.Add('purchaseHeader', JsonValue.AsToken());
            exit(false);
        end;

        OutputDictionary.Add('purchaseHeader', ExpectedOutputComparedToActualRecord(PurchaseHeaderOutput.ValueAsJsonObject(), PurchaseHeader));
        PurchaseHeaderNo := PurchaseHeader."No.";
        exit(true);
    end;

    local procedure ValidateGeneratedPurchaseLines(ExpectedOutput: Codeunit "Test Input Json"; var OutputDictionary: Dictionary of [Text, JsonToken]; PurchaseHeaderNo: Code[20]): Boolean
    var
        PurchaseLine: Record "Purchase Line";
        PurchaseLinesOutput: Codeunit "Test Input Json";
        PurchaseLinesValidationArray: JsonArray;
        PurchaseLineValidation: JsonObject;
        JsonValue: JsonValue;
        PurchaseLineOutput: JsonToken;
        Counter: Integer;
        ElementIsExpected, FoundAllLines : Boolean;
        ExpectedPurchaseHeaderLinesErr: Label 'Expected purchaseLines not found in the test case definition.', Locked = true;
        PurchaseLinesNotFoundErr: Label 'No Purchase Lines found for the given Purchase Header No. %1.', Locked = true;
        PurchaseLineNotFoundErr: Label 'Purchase Line not found for Line No. %1.', Locked = true;
    begin
        PurchaseLinesOutput := ExpectedOutput.ElementExists('purchaseLines', ElementIsExpected);
        if not ElementIsExpected then begin
            JsonValue.SetValue(ExpectedPurchaseHeaderLinesErr);
            OutputDictionary.Add('purchaseLines', JsonValue.AsToken());
            exit(false);
        end;

        ApplyFiltersToPurchaseLines(PurchaseHeaderNo, PurchaseLine);
        if PurchaseLine.IsEmpty() then begin
            JsonValue.SetValue(StrSubstNo(PurchaseLinesNotFoundErr, PurchaseHeaderNo));
            OutputDictionary.Add('purchaseLines', JsonValue.AsToken());
            exit(false);
        end;

        FoundAllLines := true;
        for Counter := 0 to PurchaseLinesOutput.AsJsonToken().AsArray().Count() - 1 do begin
            PurchaseLine.SetRange("Line No.", PurchaseLinesOutput.ElementAt(Counter).Element('Line No.').ValueAsInteger());
            if PurchaseLine.FindFirst() then begin
                Clear(PurchaseLineValidation);
                PurchaseLinesOutput.AsJsonToken().AsArray().Get(Counter, PurchaseLineOutput);
                PurchaseLineValidation.Add('lineNumber', PurchaseLine."Line No.");
                PurchaseLineValidation.Add('validation', ExpectedOutputComparedToActualRecord(PurchaseLineOutput.AsObject(), PurchaseLine));
                PurchaseLinesValidationArray.Add(PurchaseLineValidation);
            end
            else begin
                JsonValue.SetValue(StrSubstNo(PurchaseLineNotFoundErr, PurchaseLinesOutput.ElementAt(Counter).Element('Line No.').ValueAsInteger()));
                PurchaseLinesValidationArray.Add(JsonValue.AsToken());
                FoundAllLines := false;
                continue;
            end;
        end;
        OutputDictionary.Add('purchaseLines', PurchaseLinesValidationArray.AsToken());
        exit(FoundAllLines);
    end;

    local procedure ApplyFiltersToPurchaseHeader(PurchaseHeaderOutput: Codeunit "Test Input Json"; var PurchaseHeader: Record "Purchase Header")
    var
        VendorInvoiceNumberExists: Boolean;
        VendorInvoiceNo: Text;
    begin
        // Get Vendor Invoice No. from expected output
        PurchaseHeaderOutput.ElementExists('Vendor Invoice No.', VendorInvoiceNumberExists);
        if not VendorInvoiceNumberExists then
            Error('Expected Vendor Invoice No. not found in the test case definition.');
        VendorInvoiceNo := PurchaseHeaderOutput.Element('Vendor Invoice No.').ValueAsText();
        if VendorInvoiceNo = '' then
            Error('Expected Vendor Invoice No. is empty in the test case definition.');

        PurchaseHeader.SetRange("Document Type", Enum::"Purchase Document Type"::"Invoice");
        PurchaseHeader.SetRange("Vendor Invoice No.", VendorInvoiceNo);
    end;

    local procedure ApplyFiltersToPurchaseLines(PurchaseHeaderNo: Code[20]; var PurchaseLine: Record "Purchase Line")
    begin
        PurchaseLine.SetRange("Document Type", Enum::"Purchase Document Type"::"Invoice");
        PurchaseLine.SetRange("Document No.", PurchaseHeaderNo);
    end;

    internal procedure GetEDocumentFromAgentTask(AgentTask: Record "Agent Task"; var EDocument: Record "E-Document")
    var
        PayablesAgent: Codeunit "Payables Agent";
        EDocumentNotFoundErr: Label 'EDocument not found for the given entry number %1', Locked = true;
    begin
        EDocument := PayablesAgent.GetEDocumentForAgentTask(AgentTask.ID);
        if EDocument."Entry No" = 0 then
            Error(EDocumentNotFoundErr, EDocument."Entry No");
    end;

    local procedure GetUserInterventionSelection(var UserInterventionInput: Codeunit "Test Input Json"; var OutputDictionary: Dictionary of [Text, JsonToken]): Boolean
    var
        UserInterventionIsFound: Boolean;
        UserInterventionNotFoundErr: Label 'User intervention not found for test %1.', Comment = '%1= Test name';
    begin
        UserInterventionInput := AITTestContext.GetInput().Element('expected').ElementExists('user_intervention', UserInterventionIsFound);
        if UserInterventionIsFound then
            exit(true);

        AddErrorToOutputDictionary('GetUserInterventionSelection', StrSubstNo(UserInterventionNotFoundErr, AITTestContext.GetInput().Element('name').ValueAsText()), OutputDictionary);
        exit(false);
    end;
    #endregion

    #region JSON Utilities

    local procedure AddErrorToOutputDictionary(Label: Text; Message: Text; var OutputDictionary: Dictionary of [Text, JsonToken])
    var
        JsonArray: JsonArray;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if OutputDictionary.ContainsKey('Errors') then begin
            OutputDictionary.Get('Errors', JsonToken);
            OutputDictionary.Remove('Errors');
            JsonArray := JsonToken.AsArray();
        end;
        JsonObject.Add('Label', Label);
        JsonObject.Add('Message', Message);
        JsonArray.Add(JsonObject);
        OutputDictionary.Add('Errors', JsonArray.AsToken());
    end;

    local procedure AddEvaluationResultToOutputDictionary(Label: Text; EvaluationResults: JsonObject; var OutputDictionary: Dictionary of [Text, JsonToken])
    var
        JsonArray: JsonArray;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if OutputDictionary.ContainsKey('UserInterventions') then begin
            OutputDictionary.Get('UserInterventions', JsonToken);
            OutputDictionary.Remove('UserInterventions');
            JsonArray := JsonToken.AsArray();
        end;
        JsonObject.Add('Label', Label);
        JsonObject.Add('EvaluationResults', EvaluationResults);
        JsonArray.Add(JsonObject);
        OutputDictionary.Add('UserInterventions', JsonArray.AsToken());
    end;

    internal procedure Json2Record(JsonObject: JsonObject; InputRecordRef: RecordRef) OutputRecordRef: RecordRef
    var
        FieldRef: FieldRef;
        FieldHash: Dictionary of [Text, Integer];
        Counter: Integer;
        JsonKey: Text;
        JsonToken: JsonToken;
        JsonValue: JsonValue;
    begin
        OutputRecordRef.Open(InputRecordRef.Number());
        OutputRecordRef.Copy(InputRecordRef);
        for Counter := 1 to InputRecordRef.FieldCount() do begin
            FieldRef := InputRecordRef.FieldIndex(Counter);
            FieldHash.Add(FieldRef.Name(), FieldRef.Number);
        end;
        foreach JsonKey in JsonObject.Keys() do
            if JsonObject.Get(JsonKey, JsonToken) then
                if JsonToken.IsValue() then begin
                    JsonValue := JsonToken.AsValue();
                    FieldRef := OutputRecordRef.Field(FieldHash.Get(JsonKey));
                    AssignValueToFieldRef(FieldRef, JsonValue);
                end;
        exit(OutputRecordRef);
    end;

    local procedure AssignValueToFieldRef(var FieldRef: FieldRef; JsonKeyValue: JsonValue)
    begin
        case FieldRef.Type() of
            FieldType::Code,
            FieldType::Text:
                FieldRef.Validate(JsonKeyValue.AsText());
            FieldType::Integer:
                FieldRef.Validate(JsonKeyValue.AsInteger());
            FieldType::Decimal:
                FieldRef.Validate(JsonKeyValue.AsDecimal());
            FieldType::Date:
                FieldRef.Validate(JsonKeyValue.AsDate());
            FieldType::Option:
                FieldRef.Validate(JsonKeyValue.AsInteger());
            FieldType::Boolean:
                FieldRef.Validate(JsonKeyValue.AsBoolean());
            else
                Error('%1 is not a supported field type', FieldRef.Type());
        end;
    end;

    local procedure ExpectedOutputComparedToActualRecord(ExpectedOutput: JsonObject; RecordRef: RecordRef): JsonToken
    var
        FieldRef: FieldRef;
        FieldHash: Dictionary of [Text, Integer];
        Counter: Integer;
        JsonKey: Text;
        MatchedFields, FailedFields, JsonObjectTemp, ValidationResult : JsonObject;
        JsonToken: JsonToken;
        ExpectedValue, ActualValue : JsonValue;
        ExpectedValueText, ActualValueText : Text;
    begin
        for Counter := 1 to RecordRef.FieldCount() do begin
            FieldRef := RecordRef.FieldIndex(Counter);
            FieldHash.Add(FieldRef.Name(), FieldRef.Number);
        end;
        foreach JsonKey in ExpectedOutput.Keys() do
            if ExpectedOutput.Get(JsonKey, JsonToken) then
                if JsonToken.IsValue() then begin
                    // Expected Value (we need to convert to Text for comparison, there is not direct comparison between JsonValues)
                    ExpectedValue := JsonToken.AsValue();
                    ExpectedValueText := ExpectedValue.AsText();
                    // Actual Value
                    ActualValue := FieldRef2JsonValue(RecordRef.Field(FieldHash.Get(JsonKey)));
                    ActualValueText := ActualValue.AsText();
                    if ActualValueText = ExpectedValueText then
                        MatchedFields.Add(JsonKey, ActualValue)  // We want to return the actual value in the result, to keep the data type
                    else begin
                        Clear(JsonObjectTemp);
                        JsonObjectTemp.Add('expected', ExpectedValue);
                        JsonObjectTemp.Add('actual', ActualValue);
                        FailedFields.Add(JsonKey, JsonObjectTemp);
                    end;
                end;

        ValidationResult.Add('matchedFields', MatchedFields);
        ValidationResult.Add('failedFields', FailedFields);
        exit(ValidationResult.AsToken());
    end;

    local procedure FieldRef2JsonValue(FieldRef: FieldRef): JsonValue
    var
        Value: JsonValue;
        DateTemp: Date;
        TimeTemp: Time;
        IntegerTemp: Integer;
        DecimalTemp: Decimal;
        DateTimeTemp: DateTime;
    begin
        case FieldRef.Type() of
            FieldType::Date:
                begin
                    DateTemp := FieldRef.Value;
                    Value.SetValue(DateTemp);
                end;
            FieldType::Time:
                begin
                    TimeTemp := FieldRef.Value;
                    Value.SetValue(TimeTemp);
                end;
            FieldType::Integer:
                begin
                    IntegerTemp := FieldRef.Value;
                    Value.SetValue(IntegerTemp);
                end;
            FieldType::Decimal:
                begin
                    DecimalTemp := FieldRef.Value;
                    Value.SetValue(DecimalTemp);
                end;
            FieldType::DateTime:
                begin
                    DateTimeTemp := FieldRef.Value;
                    Value.SetValue(DateTimeTemp);
                end;
            else
                Value.SetValue(Format(FieldRef.Value, 0, 9));
        end;
        exit(Value);
    end;

    local procedure Record2Json(RecordRef: RecordRef): JsonObject
    var
        FieldRef: FieldRef;
        ResultJson: JsonObject;
        I: Integer;
    begin
        for I := 1 to RecordRef.FieldCount() do begin
            FieldRef := RecordRef.FieldIndex(I);
            case FieldRef.Class of
                FieldRef.Class::Normal:
                    ResultJson.Add(FieldRef.Name(), FieldRef2JsonValue(FieldRef));
                FieldRef.Class::FlowField:
                    begin
                        FieldRef.CalcField();
                        ResultJson.Add(FieldRef.Name(), FieldRef2JsonValue(FieldRef));
                    end;
            end;
        end;
        exit(ResultJson);
    end;

    local procedure ParseDateFromText(DateText: Text): Date
    var
        DateFormula: DateFormula;
        ParsedDate: Date;
        CalcDateText: Text;
    begin
        // Handle relative date format like "TODAY-30D" by converting to AL DateFormula format
        if DateText.StartsWith('TODAY') then begin
            if DateText = 'TODAY' then
                exit(Today());

            // Convert "TODAY-30D" to AL DateFormula format "-30D"
            CalcDateText := DateText.Replace('TODAY', ''); // Remove "TODAY" to get "-30D"
            if Evaluate(DateFormula, CalcDateText) then
                exit(CalcDate(DateFormula, Today()));

            // If parsing fails, return today
            exit(Today());
        end;

        // Try to evaluate the text as a standard date (supports various formats)
        if Evaluate(ParsedDate, DateText) then
            exit(ParsedDate);

        // If all else fails, return today's date as fallback
        exit(Today());
    end;
    #endregion

    #region Constants
    local procedure GetTestSetupPath(): Text
    begin
        exit('CompanyData/');
    end;

    local procedure GetPayablesAgentAppId(): Text
    begin
        exit('14aa1237-2f69-4c25-9a68-fa7d54e08613');
    end;
    #endregion

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryAgent: Codeunit "Library - Agent";
        AITTestContext: Codeunit "AIT Test Context";
        GlobalUserInterventionCounter: Integer; // We can have multiple user interventions in a single test case
}