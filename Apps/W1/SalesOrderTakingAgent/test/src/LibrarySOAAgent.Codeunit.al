// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Agents.SalesOrderTakerAgent;

using System.TestTools.TestRunner;
using Microsoft.Sales.Document;
using System.Agents;
using Microsoft.Inventory.Item;
using Microsoft.CRM.Contact;
using System.TestTools.AITestToolkit;
using System.TestLibraries.Agents;
using Agent.SalesOrderTaker;

codeunit 135393 "Library - SOA Agent"
{
    internal procedure VerifyDataCreated(): Boolean
    var
        QuoteTestInput: Codeunit "Test Input Json";
        MissingQuotesArray: JsonArray;
        CorrectQuotesArray: JsonArray;
        WrongQuotesArray: JsonArray;
        I: Integer;
        DataCreatedCorrectly: Boolean;
    begin
        DataCreatedCorrectly := true;
        MissingQuotesArray.ReadFrom('[]');
        QuoteTestInput := this.TestContext.GetExpectedData().Element(this.QuotesLbl);
        for I := 0 to QuoteTestInput.GetElementCount() - 1 do
            DataCreatedCorrectly := DataCreatedCorrectly and this.VerifyQuoteCreatedCorrectly(QuoteTestInput.ElementAt(I), CorrectQuotesArray, WrongQuotesArray, MissingQuotesArray);

        exit(DataCreatedCorrectly);
    end;

    internal procedure VerifyQuoteCreatedCorrectly(ExpectedQuote: Codeunit "Test Input Json"; var CorrectQuotesArray: JsonArray; var WrongQuotesArray: JsonArray; var MissingQuotesArray: JsonArray): Boolean
    var
        SalesHeader: Record "Sales Header";
        TestJsonObject: JsonObject;
        QuoteIsCorrect: Boolean;
    begin
        TestJsonObject.ReadFrom('{}');

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetRange("Sell-to Customer Name", ExpectedQuote.Element('customerName').ValueAsText());

        if not SalesHeader.FindFirst() then begin
            MissingQuotesArray.Add(ExpectedQuote.ToText());
            exit(false);
        end;

        QuoteIsCorrect := this.CompareQuoteToExpectedJson(SalesHeader, ExpectedQuote);

        if QuoteIsCorrect then
            CorrectQuotesArray.Add(ExpectedQuote.ToText())
        else
            WrongQuotesArray.Add(this.QuoteToJson(SalesHeader).ToText());

        exit(QuoteIsCorrect);
    end;

    internal procedure CompareQuoteToExpectedJson(var SalesHeader: Record "Sales Header"; ExpectedQuote: Codeunit "Test Input Json"): Boolean
    var
        SalesLine: Record "Sales Line";
        TempSalesLine: Record "Sales Line" temporary;
        LinesTestInputJson: Codeunit "Test Input Json";
        I: Integer;
        ExpectedNumberOfLines: Integer;
    begin
        if not (ExpectedQuote.Element('customerName').ValueAsText() = SalesHeader."Sell-to Customer No.") then
            exit(false);

        if not (ExpectedQuote.Element('customerName').ValueAsText() = SalesHeader."Sell-to Customer Name") then
            exit(false);

        if not (ExpectedQuote.Element('contactName').ValueAsText() = SalesHeader."Sell-to Contact No.") then
            exit(false);

        LinesTestInputJson := ExpectedQuote.Element('lines');
        ExpectedNumberOfLines := LinesTestInputJson.GetElementCount();
        if ExpectedNumberOfLines <> SalesLine.Count() then
            exit(false);

        if ExpectedNumberOfLines = 0 then
            exit(true);

        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Quote);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindSet();
        repeat
            TempSalesLine.TransferFields(SalesLine, true);
            TempSalesLine.Insert();
        until SalesLine.Next() = 0;

        TempSalesLine.CopyFilters(SalesLine);
        for I := 1 to ExpectedNumberOfLines do begin
            TempSalesLine.SetRange("No.", LinesTestInputJson.ElementAt(I).Element('itemName').ValueAsText());
            TempSalesLine.SetRange("Quantity", LinesTestInputJson.ElementAt(I).Element('quantity').ValueAsDecimal());
            TempSalesLine.SetRange("Unit of Measure", LinesTestInputJson.ElementAt(I).Element('unitOfMeasure').ValueAsText());
            if not TempSalesLine.FindFirst() then
                exit(false);

            TempSalesLine.Delete();
        end;

        exit(TempSalesLine.Count() = 0);
    end;

    internal procedure WriteTestOutput(var AgentTask: Record "Agent Task")
    var
        SalesHeader: Record "Sales Header";
        AgentOutputText: Codeunit "Test Output Json";
        TestJsonObject: JsonObject;
        TestJsonArray: JsonArray;
        ContextText: Text;
        QuestionText: Text;
        AnswerText: Text;
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        TestJsonArray.ReadFrom('[]');
        if SalesHeader.FindSet() then
            repeat
                TestJsonArray.Add(this.QuoteToJson(SalesHeader).ToText());
            until SalesHeader.Next() = 0;

        TestJsonObject.ReadFrom('{}');
        TestJsonObject.Add('quotes', TestJsonArray);
        AgentOutputText.Initialize();
        LibraryAgent.WriteAgentTaskToOutput(AgentTask, AgentOutputText);
        TestJsonObject.Add('taskDetails', AgentOutputText.ToText());
        TestJsonObject.Add('prompt', LibraryAgent.GetAgentInstructions(Agent));

        TestJsonObject.WriteTo(AnswerText);
        ContextText := this.TestContext.GetExpectedData().ToText();
        QuestionText := this.TestContext.GetQuestion().ToText();
        this.TestContext.SetTestOutput(ContextText, QuestionText, AnswerText);
    end;

    internal procedure QuoteToJson(SalesHeader: Record "Sales Header"): Codeunit "Test Output Json"
    var
        SalesLine: Record "Sales Line";
        TestOutputJson: Codeunit "Test Output Json";
        LinesTestOutputJson: Codeunit "Test Output Json";
        LineTestOutputJson: Codeunit "Test Output Json";
    begin
        TestOutputJson.Initialize('{}');
        TestOutputJson.Add('no', SalesHeader."No.");
        TestOutputJson.Add('customerNumber', SalesHeader."Sell-to Customer No.");
        TestOutputJson.Add('customerName', SalesHeader."Sell-to Customer Name");
        TestOutputJson.Add('contactName', SalesHeader."Sell-to Contact No.");
        TestOutputJson.Add('requestedDeliveryDate', SalesHeader."Requested Delivery Date");
        LinesTestOutputJson := TestOutputJson.AddArray('lines');

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                LineTestOutputJson := LinesTestOutputJson.Add('{}');
                LineTestOutputJson.Add('itemName', SalesLine."No.");
                LineTestOutputJson.Add('quantity', SalesLine.Quantity);
                LineTestOutputJson.Add('unitPrice', SalesLine."Unit Price");
                LineTestOutputJson.Add('unitOfMeasure', SalesLine."Unit Price");
            until SalesLine.Next() = 0;

        exit(TestOutputJson);
    end;

    procedure CreateValidQuote(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        LinesToCreate: Codeunit "Test Input Json";
        QuoteToCreate: Codeunit "Test Input Json";
        UnitOfMeasureFound: Boolean;
        I: Integer;
    begin
        SalesHeader."Document Type" := SalesHeader."Document Type"::Quote;
        SalesHeader.Insert(true);

        QuoteToCreate := this.TestContext.GetExpectedData().Element(QuotesLbl).ElementAt(0);

        SalesHeader.Validate("Sell-to Contact", QuoteToCreate.Element('contactName').ValueAsText());
        SalesHeader.Validate("Sell-to Customer Name", QuoteToCreate.Element('customerName').ValueAsText());
        SalesHeader.Modify(true);

        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;

        LinesToCreate := QuoteToCreate.Element('lines');
        for I := 0 to LinesToCreate.GetElementCount() - 1 do begin
            SalesLine.Validate(Type, SalesLine.Type::Item);
            SalesLine."Line No." += 10000;
            SalesLine.Validate("No.", LinesToCreate.ElementAt(I).Element('itemName').ValueAsText());
            SalesLine.Validate("Quantity", LinesToCreate.ElementAt(I).Element('quantity').ValueAsDecimal());
            LinesToCreate.ElementAt(I).ElementExists('unitOfMeasure', UnitOfMeasureFound);
            if UnitOfMeasureFound then
                SalesLine.Validate("Unit of Measure", LinesToCreate.ElementAt(I).Element('unitOfMeasure').ValueAsText());
            SalesLine.Insert(true);
        end;
    end;

    procedure InvokeOrderTakerAgentAndWait(var AgentTask: Record "Agent Task"): Boolean
    begin
        InvokeOrderTakerAgent(AgentTask);
        exit(LibraryAgent.WaitForAgentTaskToComplete(AgentTask));
    end;

    procedure InvokeOrderTakerAgent(var AgentTask: Record "Agent Task")
    begin
        LibraryAgent.CreateTask(TestContext.GetQuestion().ToText(), AgentTask, Agent);
        Commit();
    end;

    internal procedure EnableOrderTakerAgent()
    begin
        Agent.SetRange(State, Agent.State::Enabled);
        Agent.SetRange("Setup Page ID", Page::"SOA Setup");
        if Agent.FindFirst() then
            exit;

        Codeunit.Run(Codeunit::"SOA Setup");
        Commit();
        Agent.FindFirst()
    end;

    internal procedure CreateItems()
    var
        ItemsToCreateArray: Codeunit "Test Input Json";
        ItemsToCreateCount: Integer;
        I: Integer;
    begin
        if (this.TestContext.GetTestSetup().ElementValue().IsNull()) then
            exit;

        ItemsToCreateArray := this.TestContext.GetTestSetup().Element('itemsToCreate');
        ItemsToCreateCount := ItemsToCreateArray.GetElementCount() - 1;
        for I := 0 to ItemsToCreateCount - 1 do
            this.CreateItem(ItemsToCreateArray.ElementAt(I));
    end;

    internal procedure CreateContacts()
    var
        ContactsToCreateArray: Codeunit "Test Input Json";
        ContactsToCreateCount: Integer;
        I: Integer;
    begin
        if (this.TestContext.GetTestSetup().ElementValue().IsNull()) then
            exit;

        ContactsToCreateArray := this.TestContext.GetTestSetup().Element('contactsToCreate');
        ContactsToCreateCount := ContactsToCreateArray.GetElementCount() - 1;
        for I := 0 to ContactsToCreateCount - 1 do
            this.CreateContact(ContactsToCreateArray.ElementAt(I));
    end;

    local procedure CreateItem(ItemToCreate: Codeunit "Test Input Json")
    var
        Item: Record Item;
        ItemCard: TestPage "Item Card";
    begin
        if Item.Get(ItemToCreate.Element('no').ValueAsText()) then
            Item.Delete(true);

        ItemCard.OpenNew();
        ItemCard."No.".SetValue(ItemToCreate.Element('no').ValueAsText());
        ItemCard.Description.SetValue(ItemToCreate.Element('description').ValueAsText());
        ItemCard."Base Unit of Measure".SetValue(ItemToCreate.Element('baseUnitOfMeasure').ValueAsText());
        ItemCard.AdjustInventory.Invoke();
    end;

    local procedure CreateContact(ContactToCreate: Codeunit "Test Input Json")
    var
        Contact: Record Contact;
        ContactCard: TestPage "Contact Card";
    begin
        if Contact.Get(ContactToCreate.Element('no').ValueAsText()) then
            Contact.Delete(true);

        ContactCard.OpenNew();
        ContactCard."No.".SetValue(ContactToCreate.Element('no').ValueAsText());
        ContactCard.Name.SetValue(ContactToCreate.Element('name').ValueAsText());
        ContactCard.Address.SetValue(ContactToCreate.Element('address').ValueAsText());
        ContactCard."Country/Region Code".SetValue(ContactToCreate.Element('countryRegionCode').ValueAsText());
        ContactCard."Post Code".SetValue(ContactToCreate.Element('postCode').ValueAsText());
        ContactCard.City.SetValue(ContactToCreate.Element('city').ValueAsText());
        ContactCard."Phone No.".SetValue(ContactToCreate.Element('phoneNo').ValueAsText());
        ContactCard."E-Mail".SetValue(ContactToCreate.Element('email').ValueAsText());
    end;

    var
        Agent: Record Agent;
        TestContext: Codeunit "AIT Test Context";
        LibraryAgent: Codeunit "Library Agent";
        QuotesLbl: Label 'quotes', Locked = true;
}