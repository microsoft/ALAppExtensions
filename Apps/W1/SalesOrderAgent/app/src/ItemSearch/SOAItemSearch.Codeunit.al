// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Inventory.Availability;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Document;
using System.Environment.Configuration;
using System.Telemetry;

codeunit 4591 "SOA Item Search"
{
    Access = Internal;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        AgentTaskID: BigInteger;
        NotificationMsg: Label 'The available inventory for item %1 is lower than the entered quantity at this location at the requested shipment date.', Comment = '%1=Item Description';
        NotificationCTPDateMsg: Label 'Earliest possible shipping date for the new quantity is %1.', Comment = '%1=Earliest Shipment Date';

    procedure SetAgentTaskID(NewAgentTaskID: BigInteger)
    begin
        AgentTaskID := NewAgentTaskID;
    end;

    [TryFunction]
    procedure GetItemFilters(var ItemFilter: Text; SearchPrimaryKeyWords: List of [Text])
    var
        DummySearchType: Text;
    begin
        GetItemFilters(ItemFilter, SearchPrimaryKeyWords, DummySearchType);
    end;

    [TryFunction]
    local procedure GetItemFilters(var ItemFilter: Text; SearchPrimaryKeyWords: List of [Text]; var SearchType: Text)
    var
        Item: Record Item;
        GlobalItemSearch: Codeunit "Global Item Search";
        DummySearchOptionalKeyWords: List of [Text];
        ItemNoFilter: Text;
    begin
        // If we can get the item uniquely by it's key fields i.e. No., then we don't need to perform extensive search when there is ItemNoFilter.
        if SearchPrimaryKeyWords.Count = 1 then begin
            ItemNoFilter := SearchPrimaryKeyWords.Get(1);
            if (ItemNoFilter <> '') and (StrLen(ItemNoFilter) <= MaxStrLen(Item."No.")) then begin
                Clear(Item);
                Item.SetLoadFields(SystemId);
                Item.ReadIsolation := IsolationLevel::ReadCommitted;
                Item.SetRange("No.", ItemNoFilter);
                Item.SetRange(Blocked, false);
                Item.SetRange("Sales Blocked", false);

                // Search only using key fields
                if Item.FindFirst() then begin
                    ItemFilter := Item.SystemId;
                    SearchType := 'item_get';
                    exit;
                end;
            end;
        end;

        GlobalItemSearch.CheckIsItemSearchReady(true);
        GlobalItemSearch.InitializeSearchOptionsObject(false, true);
        GlobalItemSearch.AddSearchFilter(Item.FieldNo(Blocked), Text.StrSubstNo('<> %1', true));
        GlobalItemSearch.AddSearchFilter(Item.FieldNo("Sales Blocked"), Text.StrSubstNo('<> %1', true));
        GlobalItemSearch.AddSearchRankingContext('', '', 0);
        GlobalItemSearch.SetupSOACapabilityInformation();
        GlobalItemSearch.SetupSearchQuery(SearchPrimaryKeyWords.Get(1), SearchPrimaryKeyWords, DummySearchOptionalKeyWords, true, 50);
        ItemFilter := GlobalItemSearch.SearchAndReturnResultAsTxt(SearchPrimaryKeyWords.Get(1), 0, '|');
        SearchType := 'item_search';
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item List", OnBeforeFindRecord, '', false, false)]
    local procedure FindRecordItemFromList(var Rec: Record Item; Which: Text; var CrossColumnSearchFilter: Text; var Found: Boolean; var IsHandled: Boolean)
    var
        MatchingItem: Boolean;
    begin
        FindRecordItem(Rec, Which, CrossColumnSearchFilter, Found, 0, '', IsHandled, false, MatchingItem);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Lookup", OnBeforeFindRecord, '', false, false)]
    local procedure FindRecordItemFromLookup(var Rec: Record Item; Which: Text; var CrossColumnSearchFilter: Text; var Found: Boolean; var IsHandled: Boolean)
    var
        MatchingItem: Boolean;
    begin
        FindRecordItem(Rec, Which, CrossColumnSearchFilter, Found, 0, '', IsHandled, false, MatchingItem);
    end;

    [EventSubscriber(ObjectType::Page, Page::"SOA Multi Items Availability", OnBeforeFindRecord, '', false, false)]
    local procedure FindRecordItemFromMultiItemsAvailability(var Rec: Record Item; Which: Text; var CrossColumnSearchFilter: Text; var Found: Boolean; RequiredQuantity: Decimal; InUOMCode: Code[10]; var IsHandled: Boolean; var MatchingItem: Boolean)
    var
        TelemetryCustomDimension: Dictionary of [Text, Text];
    begin
        FindRecordItem(Rec, Which, CrossColumnSearchFilter, Found, RequiredQuantity, InUOMCode, IsHandled, true, MatchingItem, TelemetryCustomDimension);
        LogTelemetryForFindItems(TelemetryCustomDimension);
    end;

    [EventSubscriber(ObjectType::Page, Page::"SOA Multi Items Availability", OnOpenPageEvent, '', false, false)]
    local procedure LogInventoryInquiryReplied()
    var
        SOABilling: Codeunit "SOA Billing";
    begin
        SOABilling.LogInventoryInquiryReplied(AgentTaskID);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterCheckItemAvailable, '', false, false)]
    local procedure OnAfterCheckItemAvailable(var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer; HideValidationDialog: Boolean)
    var
        Item: Record Item;
        SOASetup: Record "SOA Setup";
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        SOAShipmentDateMgt: Codeunit "SOA Shipment Date Mgt.";
        QuoteAvailabilityCheckNotification: Notification;
        Msg: Text;
    begin
        if SalesLine.IsTemporary() or (SalesLine."Document Type" <> SalesLine."Document Type"::Quote) or
           (SalesLine.Type <> SalesLine.Type::Item) or (SalesLine."No." = '') or (SalesLine.Quantity = 0)
        then
            exit;

        if not SOASetup.FindFirst() or not SOASetup."Search Only Available Items" then
            exit;

        Item.Get(SalesLine."No.");
        Item.SetRange("Drop Shipment Filter", false);
        Item.SetRange("Variant Filter", '');
        Item.SetFilter("Date Filter", '..%1', SalesLine."Shipment Date");
        Item.SetFilter("Location Filter", '%1', SalesLine."Location Code");

        if IsRequiredQuantityAvailable(Item, SalesLine.Quantity, SalesLine."Unit of Measure Code") then
            exit;

        Msg := StrSubstNo(NotificationMsg, Item.Description);

        if SOASetup."Incl. Capable to Promise" then begin
            SOAShipmentDateMgt.SetParamenters(Item."No.", '', SalesLine."Location Code", SalesLine."Unit of Measure Code", SalesLine."Shipment Date", SalesLine.Quantity);
            SOAShipmentDateMgt.Run();
            if SOAShipmentDateMgt.GetEarliestShipmentDate() <= SalesLine."Shipment Date" then
                exit;
            Msg += StrSubstNo(NotificationCTPDateMsg, SOAShipmentDateMgt.GetEarliestShipmentDate());
        end;

        NotificationLifecycleMgt.RecallNotificationsForRecordWithAdditionalContext(SalesLine.RecordId, GetQuoteItemAvailabilityNotificationId(), true);
        QuoteAvailabilityCheckNotification.Id(CreateGuid());
        QuoteAvailabilityCheckNotification.Message(Msg);
        QuoteAvailabilityCheckNotification.Scope(NotificationScope::LocalScope);
        NotificationLifecycleMgt.SendNotificationWithAdditionalContext(QuoteAvailabilityCheckNotification, SalesLine.RecordId, GetQuoteItemAvailabilityNotificationId());
    end;

    local procedure GetQuoteItemAvailabilityNotificationId(): Guid
    begin
        exit('61dfb790-bf0c-47be-b95c-8e51afecd066');
    end;

    local procedure FindRecordItem(var Rec: Record Item; Which: Text; var CrossColumnSearchFilter: Text; var Found: Boolean; RequiredQuantity: Decimal; InUOMCode: Code[10]; var IsHandled: Boolean; CheckAvailability: Boolean; var MatchingItem: Boolean)
    var
        DummyCustomDimension: Dictionary of [Text, Text];
    begin
        FindRecordItem(Rec, Which, CrossColumnSearchFilter, Found, RequiredQuantity, InUOMCode, IsHandled, CheckAvailability, MatchingItem, DummyCustomDimension);
    end;

    local procedure FindRecordItem(var Rec: Record Item; Which: Text; var CrossColumnSearchFilter: Text; var Found: Boolean; RequiredQuantity: Decimal; InUOMCode: Code[10]; var IsHandled: Boolean; CheckAvailability: Boolean; var MatchingItem: Boolean; var TelemetryCustomDimension: Dictionary of [Text, Text])
    var
        SOASetup: Record "SOA Setup";
        Item: Record Item;
        BroaderItemSearch: Codeunit "SOA Broader Item Search";
        SearchKeyWordsTrimmed: List of [Text];
        SearchFilter: Text;
        SplitSearchKeywords: Text;
        ItemFilter: Text;
        TrimmedItemFilter: Text;
        OriginalFilterGroup: Integer;
        ItemSystemId: Guid;
        SearchType: Text;
        CountBeforeAvailabilityCheck: Integer;
    begin
        MatchingItem := true;
        OriginalFilterGroup := Rec.FilterGroup();
        Rec.FilterGroup(-1);
        SearchFilter := Rec.GetFilter("No."); //Get current search filter
        Rec.FilterGroup(OriginalFilterGroup);

        if (SearchFilter = CrossColumnSearchFilter) or (SearchFilter = '=''<>*''') then //If the search filter is the same as the last one, or empty filter then we don't need to search
            exit;
        CrossColumnSearchFilter := SearchFilter;

        ExtractSearchKeyWords(SearchFilter, SplitSearchKeywords, SearchKeyWordsTrimmed);

        if SearchKeyWordsTrimmed.Count() = 0 then
            exit;
        if not GetItemFilters(ItemFilter, SearchKeyWordsTrimmed, SearchType) then //Search for the items using the entity search
            exit;

        if (ItemFilter = '') and (SplitSearchKeywords <> '') then begin
            BroaderItemSearch.BroaderItemSearch(ItemFilter, SplitSearchKeywords.TrimEnd(','));
            MatchingItem := false;
            SearchType := 'broader_item_search';
        end;

        if SOASetup.FindFirst() then
            if ItemFilter <> '' then begin
                CountBeforeAvailabilityCheck := ItemFilter.Split('|').Count();
                foreach ItemSystemId in ItemFilter.Split('|') do begin
                    if Item.GetBySystemId(ItemSystemId) then
                        Item.CopyFilters(Rec);

                    if CheckAvailability and (SOASetup."Search Only Available Items" and not SOASetup."Incl. Capable to Promise") then begin
                        if IsRequiredQuantityAvailable(Item, RequiredQuantity, InUOMCode) then
                            TrimmedItemFilter += ItemSystemId + '|'
                    end else
                        TrimmedItemFilter += ItemSystemId + '|';

                    if TrimmedItemFilter.Split('|').Count() - 1 = 10 then
                        break;
                end;
                ItemFilter := TrimmedItemFilter.TrimEnd('|');
            end;

        if ItemFilter <> '' then begin //IsHandled only if the search is successful
            Item.CopyFilters(Rec);

            Rec.Reset();
            Rec.SetFilter(SystemId, ItemFilter);

            Item.CopyFilter("Drop Shipment Filter", Rec."Drop Shipment Filter");
            Item.CopyFilter("Date Filter", Rec."Date Filter");
            Item.CopyFilter("Location Filter", Rec."Location Filter");
            Item.CopyFilter("Variant Filter", Rec."Variant Filter");
            Found := Rec.Find(Which);
        end;

        // Prepare Custom Dimensions for Telemetry
        TelemetryCustomDimension.Add('SearchType', SearchType);
        TelemetryCustomDimension.Add('ResultCount', Format(ItemFilter.Split('|').Count()));
        TelemetryCustomDimension.Add('CountBeforeAvailabilityCheck', Format(CountBeforeAvailabilityCheck));

        IsHandled := true;
        OnAfterFindRecordItem(ItemFilter, Which, CrossColumnSearchFilter, Found, RequiredQuantity, InUOMCode);
    end;

    local procedure ExtractSearchKeyWords(SearchFilter: Text; var SplitSearchKeywords: Text; var SearchKeyWordsTrimmed: List of [Text])
    var
        SearchKeyWord, KeyWord : Text;
        SearchKeyWords: List of [Text];
    begin
        if SearchFilter.StartsWith('&&') then begin // Modern search filter
            SearchKeyWords := SearchFilter.Split('&&');
            foreach KeyWord in SearchKeyWords do begin
                SearchKeyword := KeyWord.TrimStart('&').TrimEnd('*').Trim();
                if SearchKeyword <> '' then begin
                    SearchKeyWordsTrimmed.Add(SearchKeyword);
                    SplitSearchKeywords += SearchKeyword + ',';
                end;
            end;
        end
        else
            if SearchFilter.StartsWith('@*') then begin // Legacy search filter
                SearchKeyWords := SearchFilter.Split(' ');
                foreach KeyWord in SearchKeyWords do begin
                    SearchKeyword := KeyWord.TrimStart('@*').TrimEnd('*').Trim();
                    if SearchKeyword <> '' then begin
                        SearchKeyWordsTrimmed.Add(SearchKeyword);
                        SplitSearchKeywords += SearchKeyword + ',';
                    end;
                end;
            end;
    end;

    local procedure IsRequiredQuantityAvailable(var Item: Record Item; RequiredQuantity: Decimal; LineUOM: Code[10]): Boolean
    var
        Item2: Record Item;
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        ExpectedInventory, DummyQtyAvailable, PlannedOrderReleases, GrossRequirement, PlannedOrderRcpt, ScheduledRcpt, ProjAvailableBalance, ProjAvailableBalanceInOUM, AvailableInventory : Decimal;
    begin
        if Item.Type <> Item.Type::Inventory then
            exit(true);

        // Copy the item to avoid potential modifying the original record in ItemAvailFormsMgt.CalcAvailQuantities
        Item2.Copy(Item);
        ItemAvailFormsMgt.CalcAvailQuantities(Item2, true, GrossRequirement, PlannedOrderRcpt, ScheduledRcpt,
            PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, DummyQtyAvailable, AvailableInventory);

        if ProjAvailableBalance <= 0 then
            exit(false);

        if LineUOM = '' then
            LineUOM := Item."Sales Unit of Measure";

        ProjAvailableBalanceInOUM := CalcProjAvailableBalanceInUOM(Item, ProjAvailableBalance, LineUOM);
        if ProjAvailableBalanceInOUM <= 0 then
            exit(false);

        exit(ProjAvailableBalanceInOUM >= RequiredQuantity);
    end;

    internal procedure CalcProjAvailableBalanceInUOM(Item: Record Item; ProjAvailableBalance: Decimal; LineUOM: Code[10]): Decimal;
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        QtyRoundingPrecision: Decimal;
    begin
        if LineUOM in ['', Item."Base Unit of Measure"] then
            exit(ProjAvailableBalance)
        else
            if ItemUnitOfMeasure.Get(Item."No.", LineUOM) and (ItemUnitOfMeasure."Qty. per Unit of Measure" <> 0) then begin
                QtyRoundingPrecision := ItemUnitOfMeasure."Qty. Rounding Precision";
                if QtyRoundingPrecision = 0 then
                    QtyRoundingPrecision := 0.00001;
                exit(Round(ProjAvailableBalance / ItemUnitOfMeasure."Qty. per Unit of Measure", QtyRoundingPrecision));
            end else
                exit(0);
    end;

    local procedure LogTelemetryForFindItems(TelemetryCustomDimension: Dictionary of [Text, Text])
    var
        SOASetupRec: Record "SOA Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SOASetup: Codeunit "SOA Setup";
    begin
        // Log only for agent session
        if AgentTaskID = 0 then
            exit;

        // Agent session context
        TelemetryCustomDimension.Add('TaskId', Format(AgentTaskID));
        TelemetryCustomDimension.Add('AgentUserSecurityId', Format(UserSecurityId()));

        // Search setup
        if SOASetupRec.FindFirst() then begin
            TelemetryCustomDimension.Add('SearchOnlyAvailableItems', Format(SOASetupRec."Search Only Available Items"));
            TelemetryCustomDimension.Add('IncludeCapableToPromise', Format(SOASetupRec."Incl. Capable to Promise"));
        end;

        // Log usage
        FeatureTelemetry.LogUsage('0000QB0', SOASetup.GetFeatureName(), 'SOA Multi Items Availability: Find Items', TelemetryCustomDimension)
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterFindRecordItem(ItemFilter: Text; Which: Text; CrossColumnSearchFilter: Text; Found: Boolean; RequiredQuantity: Decimal; InUOMCode: Code[10])
    begin
    end;
}