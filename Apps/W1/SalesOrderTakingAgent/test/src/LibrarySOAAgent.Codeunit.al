// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Agents.SalesOrderTakerAgent;

using System.TestTools.TestRunner;
using Microsoft.Sales.Document;
using Microsoft.Sales.Customer;
using System.Agents;
using Microsoft.Inventory.Item;
using Microsoft.CRM.Contact;
using System.TestTools.AITestToolkit;
using System.TestLibraries.Agents;
using Agent.SalesOrderTaker;
using Microsoft.Inventory.Setup;

codeunit 135393 "Library - SOA Agent"
{
    internal procedure VerifyDataCreated(AgentTask: Record "Agent Task"; var ErrorReason: Text): Boolean
    var
        SalesHeader: Record "Sales Header";
        AgentTaskMessageAttachment: Record "Agent Task Message Attachment";
        QuoteTestInput: Codeunit "Test Input Json";
        MissingQuotesArray: JsonArray;
        CorrectQuotesArray: JsonArray;
        WrongQuotesArray: JsonArray;
        I: Integer;
        DataCreatedCorrectly: Boolean;
        NumberOfQuotesErr: Label 'Number of quotes created (%1) does not match number of quotes expected (%2)', Comment = '%1: actual, %2: expected';
    begin
        DataCreatedCorrectly := true;
        MissingQuotesArray.ReadFrom('[]');
        QuoteTestInput := this.TestContext.GetExpectedData().Element(this.QuotesLbl);

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        if SalesHeader.Count() <> QuoteTestInput.GetElementCount() then begin
            ErrorReason := StrSubstNo(NumberOfQuotesErr, SalesHeader.Count(), QuoteTestInput.GetElementCount());
            exit(false);
        end;

        for I := 0 to QuoteTestInput.GetElementCount() - 1 do
            DataCreatedCorrectly := DataCreatedCorrectly and this.VerifyQuoteCreatedCorrectly(QuoteTestInput.ElementAt(I), CorrectQuotesArray, WrongQuotesArray, MissingQuotesArray, ErrorReason);

        if DataCreatedCorrectly then begin
            AgentTaskMessageAttachment.SetRange("Task ID", AgentTask.ID);
            if AgentTaskMessageAttachment.IsEmpty() then begin
                ErrorReason := 'No message attachments found for task.';
                exit(false);
            end;
        end;

        exit(DataCreatedCorrectly);
    end;

    internal procedure VerifyQuoteCreatedCorrectly(ExpectedQuote: Codeunit "Test Input Json"; var CorrectQuotesArray: JsonArray; var WrongQuotesArray: JsonArray; var MissingQuotesArray: JsonArray; var ErrorReason: Text): Boolean
    var
        SalesHeader: Record "Sales Header";
        TestJsonObject: JsonObject;
        QuoteIsCorrect: Boolean;
        QuoteNotCreatedErr: Label 'Quote not created when expected.';
        QuoteNotCreatedForCustomerErr: Label 'Quote not created for expected customer.';
        SalesOrderCreatedErr: Label 'Sales order created when it should not be.';
    begin
        TestJsonObject.ReadFrom('{}');

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        if not SalesHeader.FindFirst() then begin
            MissingQuotesArray.Add(ExpectedQuote.ToText());
            ErrorReason := QuoteNotCreatedErr;
            exit(false);
        end;

        SalesHeader.SetRange("Sell-to Customer Name", ExpectedQuote.Element('customerName').ValueAsText());
        if not SalesHeader.FindFirst() then begin
            MissingQuotesArray.Add(ExpectedQuote.ToText());
            ErrorReason := QuoteNotCreatedForCustomerErr;
            exit(false);
        end;

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if SalesHeader.FindFirst() then begin
            ErrorReason := SalesOrderCreatedErr;
            exit(false);
        end;

        QuoteIsCorrect := this.CompareQuoteToExpectedJson(SalesHeader, ExpectedQuote, ErrorReason);

        if QuoteIsCorrect then
            CorrectQuotesArray.Add(ExpectedQuote.ToText())
        else
            WrongQuotesArray.Add(this.QuoteToJson(SalesHeader).ToText());

        exit(QuoteIsCorrect);
    end;

    internal procedure CompareQuoteToExpectedJson(var SalesHeader: Record "Sales Header"; ExpectedQuote: Codeunit "Test Input Json"; var ErrorReason: Text): Boolean
    var
        SalesLine: Record "Sales Line";
        TempSalesLine: Record "Sales Line" temporary;
        LinesTestInputJson: Codeunit "Test Input Json";
        I: Integer;
        ExpectedNumberOfLines: Integer;
        NumberOfQuoteLinesMismatchErr: Label 'Expected number of lines (%1) does not match actual (%2).', Comment = '%1: expected, %2: actual';
        CustomerNameMismatchErr: Label 'Customer name does not match.';
        ContactNameMismatchErr: Label 'Contact name does not match.';
        QuoteLineMismatchErr: Label 'Quote line %1 does not match.', Comment = '%1: line number';
    begin
        if not (ExpectedQuote.Element('customerName').ValueAsText() = SalesHeader."Sell-to Customer Name") then begin
            ErrorReason := CustomerNameMismatchErr;
            exit(false);
        end;

        if not (ExpectedQuote.Element('contactName').ValueAsText() = SalesHeader."Sell-to Contact") then begin
            ErrorReason := ContactNameMismatchErr;
            exit(false);
        end;

        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Quote);
        SalesLine.SetRange("Document No.", SalesHeader."No.");

        LinesTestInputJson := ExpectedQuote.Element('lines');
        ExpectedNumberOfLines := LinesTestInputJson.GetElementCount();
        if ExpectedNumberOfLines <> SalesLine.Count() then begin
            ErrorReason := StrSubstNo(NumberOfQuoteLinesMismatchErr, ExpectedNumberOfLines, SalesLine.Count());
            exit(false);
        end;

        if ExpectedNumberOfLines = 0 then
            exit(true);

        SalesLine.FindSet();
        repeat
            TempSalesLine.TransferFields(SalesLine, true);
            TempSalesLine.Insert();
        until SalesLine.Next() = 0;

        TempSalesLine.CopyFilters(SalesLine);
        for I := 0 to ExpectedNumberOfLines - 1 do begin
            TempSalesLine.SetRange(Description, LinesTestInputJson.ElementAt(I).Element('itemDescription').ValueAsText());
            TempSalesLine.SetRange("Quantity", LinesTestInputJson.ElementAt(I).Element('quantity').ValueAsDecimal());
            TempSalesLine.SetRange("Unit of Measure Code", LinesTestInputJson.ElementAt(I).Element('unitOfMeasure').ValueAsText());
            if TempSalesLine.IsEmpty() then begin
                ErrorReason := StrSubstNo(QuoteLineMismatchErr, I + 1);
                exit(false);
            end;

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
        TestOutputJson.Add('contactNumber', SalesHeader."Sell-to Contact No.");
        TestOutputJson.Add('requestedDeliveryDate', SalesHeader."Requested Delivery Date");
        LinesTestOutputJson := TestOutputJson.AddArray('lines');

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                LineTestOutputJson := LinesTestOutputJson.Add('{}');
                LineTestOutputJson.Add('itemNumber', SalesLine."No.");
                LineTestOutputJson.Add('itemDescription', SalesLine.Description);
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
            SalesLine.Validate(Description, LinesToCreate.ElementAt(I).Element('itemDescription').ValueAsText());
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

    internal procedure UpdateInventorySetup(var CurrentItemNo: Code[20]; Restore: Boolean)
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        if Restore then
            InventorySetup.Validate("Item Nos.", CurrentItemNo)
        else begin
            CurrentItemNo := InventorySetup."Item Nos.";
            InventorySetup.Validate("Item Nos.", '');
        end;
        InventorySetup.Modify();
    end;

    internal procedure CreateItems()
    var
        ItemsToCreateArray: Codeunit "Test Input Json";
        ItemsInputExists: Boolean;
        ItemsToCreateCount: Integer;
        I: Integer;
    begin
        ItemsToCreateArray := this.TestContext.GetTestSetup().ElementExists('itemsToCreate', ItemsInputExists);

        if (not ItemsInputExists) then
            exit;

        ItemsToCreateCount := ItemsToCreateArray.GetElementCount();
        for I := 0 to ItemsToCreateCount - 1 do
            this.CreateItem(ItemsToCreateArray.ElementAt(I));
    end;

    internal procedure CreateCustomers()
    var
        CustomersToCreateArray: Codeunit "Test Input Json";
        CustomersInputExists: Boolean;
        CustomersToCreateCount: Integer;
        I: Integer;
    begin
        CustomersToCreateArray := this.TestContext.GetTestSetup().ElementExists('customersToCreate', CustomersInputExists);
        if (not CustomersInputExists) then
            exit;

        CustomersToCreateCount := CustomersToCreateArray.GetElementCount();
        for I := 0 to CustomersToCreateCount - 1 do
            this.CreateCustomer(CustomersToCreateArray.ElementAt(I));
    end;

    internal procedure CreateContacts()
    var
        ContactsToCreateArray: Codeunit "Test Input Json";
        ContactsInputExists: Boolean;
        ContactsToCreateCount: Integer;
        I: Integer;
    begin
        ContactsToCreateArray := this.TestContext.GetTestSetup().ElementExists('contactsToCreate', ContactsInputExists);
        if (not ContactsInputExists) then
            exit;

        ContactsToCreateCount := ContactsToCreateArray.GetElementCount();
        for I := 0 to ContactsToCreateCount - 1 do
            this.CreateContact(ContactsToCreateArray.ElementAt(I));
    end;

    local procedure CreateItem(ItemToCreate: Codeunit "Test Input Json")
    var
        Item: Record Item;
        ItemCard: TestPage "Item Card";
    begin
        Item.SetRange(Description, ItemToCreate.Element('description').ValueAsText());
        if Item.FindSet() then
            Item.DeleteAll(false);

        ItemCard.OpenNew();
        ItemCard."No.".SetValue('AItem-' + Format(System.Random(9999)));
        ItemCard.Description.SetValue(ItemToCreate.Element('description').ValueAsText());
        ItemCard."Base Unit of Measure".SetValue(ItemToCreate.Element('baseUnitOfMeasure').ValueAsText());
        ItemCard."Unit Price".SetValue(ItemToCreate.Element('unitPrice').ValueAsText());
        ItemCard."Gen. Prod. Posting Group".SetValue('RETAIL'); //ToDo: Remove hardcoded value
        ItemCard."Inventory Posting Group".SetValue('RESALE');

        ItemCard.AdjustInventory.Invoke();
        ItemCard.Close();
    end;

    local procedure CreateCustomer(CustomerToCreate: Codeunit "Test Input Json")
    var
        Contact: Record Contact;
        Customer: Record Customer;
        CustomerCard: TestPage "Customer Card";
    begin
        Customer.SetRange(Name, CustomerToCreate.Element('name').ValueAsText());
        if Customer.FindSet() then
            Customer.DeleteAll(true);
        Contact.SetRange(Name, CustomerToCreate.Element('name').ValueAsText());
        if Contact.FindSet() then
            Contact.DeleteAll(true);

        CustomerCard.OpenNew();
        CustomerCard.Name.SetValue(CustomerToCreate.Element('name').ValueAsText());
        CustomerCard.Address.SetValue(CustomerToCreate.Element('address').ValueAsText());
        CustomerCard."Country/Region Code".SetValue(CustomerToCreate.Element('countryRegionCode').ValueAsText());
        CustomerCard."Post Code".SetValue(CustomerToCreate.Element('postCode').ValueAsText());
        CustomerCard.City.SetValue(CustomerToCreate.Element('city').ValueAsText());
        CustomerCard."Phone No.".SetValue(CustomerToCreate.Element('phoneNo').ValueAsText());
        CustomerCard."E-Mail".SetValue(CustomerToCreate.Element('email').ValueAsText());
        CustomerCard.Close();

        Commit();
    end;

    local procedure CreateContact(ContactToCreate: Codeunit "Test Input Json")
    var
        Contact: Record Contact;
        ContactCard: TestPage "Contact Card";
    begin
        Contact.SetRange(Name, ContactToCreate.Element('name').ValueAsText());
        if Contact.FindSet() then
            Contact.DeleteAll(true);

        ContactCard.OpenNew();
        ContactCard.Type.SetValue(Contact.Type::Person);
        ContactCard.Name.SetValue(ContactToCreate.Element('name').ValueAsText());
        ContactCard."Company Name".SetValue(ContactToCreate.Element('companyName').ValueAsText());
        ContactCard."Phone No.".SetValue(ContactToCreate.Element('phoneNo').ValueAsText());
        ContactCard."E-Mail".SetValue(ContactToCreate.Element('email').ValueAsText());
        ContactCard.Close();
    end;

    var
        Agent: Record Agent;
        TestContext: Codeunit "AIT Test Context";
        LibraryAgent: Codeunit "Library Agent";
        QuotesLbl: Label 'quotes', Locked = true;
}