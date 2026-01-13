// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Integration.Entity;
using Microsoft.Finance.Currency;
using Microsoft.Sales.Document;
using System.Agents;

#pragma warning disable AS0049
codeunit 4595 "SOA - KPI Track All"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    EventSubscriberInstance = Manual;
    Access = Internal;
#pragma warning restore AS0049

    [EventSubscriber(ObjectType::Table, Database::"Sales Quote Entity Buffer", 'OnAfterModifyEvent', '', false, false)]
    local procedure UpdateSalesQuoteChanged(var Rec: Record "Sales Quote Entity Buffer")
    begin
        UpdateSalesQuoteBuffer(Rec, BlankSOAKPIEntry.Status::Active, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Quote Entity Buffer", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteSalesQuoteChanged(var Rec: Record "Sales Quote Entity Buffer")
    begin
        UpdateSalesQuoteBuffer(Rec, BlankSOAKPIEntry.Status::Deleted, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Order Entity Buffer", 'OnAfterModifyEvent', '', false, false)]
    local procedure UpdateSalesOrderChanged(var Rec: Record "Sales Order Entity Buffer")
    begin
        UpdateSalesOrderBuffer(Rec, BlankSOAKPIEntry.Status::Active, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Order Entity Buffer", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteSalesOrderChanged(var Rec: Record "Sales Order Entity Buffer")
    var
        SalesInvoiceEntryAggregate: Record "Sales Invoice Entity Aggregate";
    begin
        SalesInvoiceEntryAggregate.SetRange("Order No.", Rec."No.");
        if not SalesInvoiceEntryAggregate.IsEmpty() then
            UpdateSalesOrderBuffer(Rec, BlankSOAKPIEntry.Status::Posted, true)
        else
            UpdateSalesOrderBuffer(Rec, BlankSOAKPIEntry.Status::Deleted, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Order Entity Buffer", 'OnAfterInsertEvent', '', false, false)]
    local procedure InsertSalesOrderChanged(var Rec: Record "Sales Order Entity Buffer")
    var
        AgentQuoteKPIEntry: Record "SOA KPI Entry";
        AgentOrderKPIEntry: Record "SOA KPI Entry";
        SOAKPITrackAll: Codeunit "SOA - KPI Track All";
    begin
        if not AgentQuoteExists(AgentQuoteKPIEntry, Rec) then
            exit;

        AgentQuoteKPIEntry.Status := AgentQuoteKPIEntry.Status::"Converted to Order";
        AgentQuoteKPIEntry.Modify(true);
        SOAKPITrackAll.UpdateSalesOrderBuffer(Rec, BlankSOAKPIEntry.Status::Active, false);

        AgentOrderKPIEntry.Get(AgentQuoteKPIEntry."Record Type"::"Sales Order", Rec."No.");
        AgentOrderKPIEntry."Quote No." := AgentQuoteKPIEntry."No.";
        AgentOrderKPIEntry."Created by User ID" := AgentQuoteKPIEntry."Created by User ID";
        AgentOrderKPIEntry.Modify(true);
    end;

    internal procedure UpdateSalesQuoteBuffer(var SalesQuoteEntityBuffer: Record "Sales Quote Entity Buffer"; EntryStatus: Option; UpdateOnly: Boolean)
    begin
        UpdateEntry(BlankSOAKPIEntry."Record Type"::"Sales Quote", SalesQuoteEntityBuffer."No.", SalesQuoteEntityBuffer."Amount Including VAT", EntryStatus, SalesQuoteEntityBuffer."Sell-to Customer No.", SalesQuoteEntityBuffer."Sell-To Contact No.", UpdateOnly, SalesQuoteEntityBuffer."Currency Code", SalesQuoteEntityBuffer."Posting Date");
    end;

    internal procedure UpdateSalesOrderBuffer(var SalesOrderEntityBuffer: Record "Sales Order Entity Buffer"; EntryStatus: Option; UpdateOnly: Boolean)
    begin
        UpdateEntry(BlankSOAKPIEntry."Record Type"::"Sales Order", SalesOrderEntityBuffer."No.", SalesOrderEntityBuffer."Amount Including VAT", EntryStatus, SalesOrderEntityBuffer."Sell-to Customer No.", SalesOrderEntityBuffer."Sell-To Contact No.", UpdateOnly, SalesOrderEntityBuffer."Currency Code", SalesOrderEntityBuffer."Posting Date");
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"SOA KPI Entry", 'R')]
    local procedure AgentQuoteExists(var AgentQuoteKPIEntry: Record "SOA KPI Entry"; var SalesOrderEntityBuffer: Record "Sales Order Entity Buffer"): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.ReadIsolation := IsolationLevel::ReadUncommitted;
        SalesHeader.SetLoadFields("Document Type", "No.", "Quote No.");
        if not SalesHeader.Get(SalesHeader."Document Type"::Order, SalesOrderEntityBuffer."No.") then
            exit(false);

        if SalesHeader."Quote No." = '' then
            exit(false);

        AgentQuoteKPIEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
        exit(AgentQuoteKPIEntry.Get(AgentQuoteKPIEntry."Record Type"::"Sales Quote", SalesHeader."Quote No."));
    end;

    local procedure UpdateEntry(TableType: Option; "No.": Code[20]; EntryAmount: Decimal; EntryStatus: Option; CustomerNo: Code[20]; ContactNo: Code[20]; UpdateOnly: Boolean; CurrencyCode: Code[10]; DocumentDate: Date)
    var
        SOAKPIEntry: Record "SOA KPI Entry";
        SOAgentKPI: Record "SOA KPI";
        Currency: Record "Currency";
        SalesHeader: Record "Sales Header";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        AgentSession: Codeunit "Agent Session";
        SOAKPIEntryExist: Boolean;
        PreviousAmount: Decimal;
        LCYEntryAmount: Decimal;
    begin
        SOAKPIEntryExist := SOAKPIEntry.Get(TableType, "No.");
        if not SOAKPIEntryExist then begin
            if UpdateOnly then
                exit;

            SOAKPIEntry."Record Type" := TableType;
            SOAKPIEntry."No." := "No.";
        end;

        if CurrencyCode = '' then
            LCYEntryAmount := EntryAmount
        else begin
            Currency.InitRoundingPrecision();
            if GetSalesHeader(SOAKPIEntry, SalesHeader) then
                LCYEntryAmount :=
                       Round(
                         CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                           DocumentDate, CurrencyCode,
                           EntryAmount, SalesHeader."Currency Factor"),
                         Currency."Amount Rounding Precision")
            else
                LCYEntryAmount := 0;
        end;

        PreviousAmount := SOAKPIEntry."Amount Including Tax";
        if (not SOAKPIEntryExist) or (SOAKPIEntry."Amount Including Tax" < LCYEntryAmount) then
            SOAKPIEntry."Amount Including Tax" := LCYEntryAmount;

        if not (SOAKPIEntry.Status in [SOAKPIEntry.Status::Posted, SOAKPIEntry.Status::"Converted to Order"]) then
            SOAKPIEntry.Status := EntryStatus;

        SOAKPIEntry."Contact No." := ContactNo;
        SOAKPIEntry."Customer No." := CustomerNo;

        if not SOAKPIEntryExist then begin
            SOAKPIEntry."Created by User ID" := UserSecurityId();
            SOAKPIEntry."Task ID" := AgentSession.GetCurrentSessionAgentTaskId();
            SOAKPIEntry.Insert(true);
            SOAgentKPI.UpdateEntryKPIs(SOAKPIEntry, PreviousAmount, true);
        end else begin
            SOAKPIEntry.Modify(true);
            SOAgentKPI.UpdateEntryKPIs(SOAKPIEntry, PreviousAmount, false);
        end;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"SOA KPI Entry", 'R')]
    internal procedure TrackChanges(): Boolean
    var
        SOAKPIEntry: Record "SOA KPI Entry";
        SOAImpl: Codeunit "SOA Impl";
    begin
        SOAKPIEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
        SOAKPIEntry.SetFilter(Status, '<>%1&<>%2&<>%3', SOAKPIEntry.Status::Posted, SOAKPIEntry.Status::Deleted, SOAKPIEntry.Status::" ");
        if not SOAKPIEntry.IsEmpty() then
            exit(true);

        exit(SOAImpl.ActiveAgentExistInCurrentCompany());
    end;

    internal procedure IsOrderTakerAgentSession(): Boolean
    var
        AgentTaskID: BigInteger;
    begin
        exit(IsOrderTakerAgentSession(AgentTaskID));
    end;

    internal procedure IsOrderTakerAgentSession(var AgentTaskID: BigInteger): Boolean
    var
        AgentSession: Codeunit "Agent Session";
        AgentMetadataProvider: Enum "Agent Metadata Provider";
    begin
        if not GuiAllowed() then
            exit(false);

        if not AgentSession.IsAgentSession(AgentMetadataProvider) then
            exit(false);

        if AgentMetadataProvider <> "Agent Metadata Provider"::"SO Agent" then
            exit(false);

        AgentTaskID := AgentSession.GetCurrentSessionAgentTaskId();
        if AgentTaskID = 0 then
            exit(false);

        exit(true);
    end;

    local procedure GetSalesHeader(var SOAKPIEntry: Record "SOA KPI Entry"; var SalesHeader: Record "Sales Header"): Boolean
    begin
        if SOAKPIEntry."Record Type" = SOAKPIEntry."Record Type"::"Sales Order" then
            exit(SalesHeader.Get(SalesHeader."Document Type"::Order, SOAKPIEntry."No."));

        if SOAKPIEntry."Record Type" = SOAKPIEntry."Record Type"::"Sales Quote" then
            exit(SalesHeader.Get(SalesHeader."Document Type"::Quote, SOAKPIEntry."No."));

        exit(false);
    end;

    var
        BlankSOAKPIEntry: Record "SOA KPI Entry";
}