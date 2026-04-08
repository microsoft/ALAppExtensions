// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.Designer.AgentSamples.SalesValidation;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Sales.Document;
using System.TestTools.AITestToolkit;
using System.TestTools.TestRunner;

codeunit 133745 "SVA Utilities"
{
    Access = Internal;

    /// <summary>
    /// Gets the 'from' and 'message' values from the current test data.
    /// </summary>
    procedure GetFromAndMessageFromTestData(var FromValue: Text; var MessageValue: Text)
    begin
        FromValue := AITTestContext.GetQuestion().Element('from').ToText().Trim().TrimStart('"').TrimEnd('"');
        MessageValue := AITTestContext.GetQuestion().Element('message').ToText();
    end;

    /// <summary>
    /// Gets the shipment date from the current test data.
    /// </summary>
    procedure GetShipmentDateFromTestData(): Date
    var
        ShipmentDate: Date;
    begin
        Evaluate(ShipmentDate, AITTestContext.GetQuestion().Element('shipment_date').ToText());
        exit(ShipmentDate);
    end;

    /// <summary>
    /// Creates sales orders for testing based on the test question data.
    /// Returns lists of expected released and non-released order numbers.
    /// </summary>
    procedure CreateSalesOrderTestData(var ExpectedReleasedOrders: List of [Code[20]]; var ExpectedNonReleasedOrders: List of [Code[20]])
    var
        Item: Record Item;
        ItemJournalLine: Record "Item Journal Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesOrderInput: Codeunit "Test Input Json";
        ReleaseInput, NoReleaseInput : Codeunit "Test Input Json";
        ShipmentDate, NonMatchingShipmentDate : Date;
        Matching, ElementExist : Boolean;
        Partial, Complete : Integer;
        NoOfSalesOrders, NoOfItems : Integer;
        Quantity, QuantityAvailable : Integer;
        IdxSO, IdxItem, Idx : Integer;
        CustNo: Code[20];
    begin
        Clear(ExpectedReleasedOrders);
        Clear(ExpectedNonReleasedOrders);

        ShipmentDate := GetShipmentDateFromTestData();
        NonMatchingShipmentDate := CalcDate('<-1Y>', ShipmentDate);

        // Clean up existing sales orders with the test shipment dates
        CleanupSalesOrdersByShipmentDate(ShipmentDate);
        CleanupSalesOrdersByShipmentDate(NonMatchingShipmentDate);

        SalesOrderInput := AITTestContext.GetQuestion().Element('sales_orders');
        NoOfSalesOrders := SalesOrderInput.GetElementCount();

        for IdxSO := 0 to NoOfSalesOrders - 1 do begin
            Matching := SalesOrderInput.ElementAt(IdxSO).Element('matching').ValueAsBoolean();

            // Process release orders
            SalesOrderInput.ElementAt(IdxSO).ElementExists('release', ElementExist);
            if ElementExist then begin
                ReleaseInput := SalesOrderInput.ElementAt(IdxSO).Element('release');

                // Create partial shipping advice orders that should be released
                ReleaseInput.ElementExists('partial', ElementExist);
                if ElementExist then begin
                    Partial := ReleaseInput.Element('partial').ValueAsInteger();
                    for Idx := 0 to Partial - 1 do begin
                        CustNo := LibrarySales.CreateCustomerNo();
                        Clear(SalesHeader);
                        LibrarySales.CreateSalesOrderWithLocation(SalesHeader, CustNo, 'BLUE');
                        NoOfItems := LibraryRandom.RandInt(5);

                        for IdxItem := 0 to NoOfItems - 1 do begin
                            Quantity := LibraryRandom.RandInt(5);
                            QuantityAvailable := LibraryRandom.RandInt(5);

                            LibraryInventory.CreateItemWithUnitPriceAndUnitCost(Item, LibraryRandom.RandDecInDecimalRange(5.0, 100.0, 2), 2.0);
                            LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", Matching ? ShipmentDate : NonMatchingShipmentDate, Quantity);
                            if QuantityAvailable > 0 then begin
                                LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, Item."No.", 'BLUE', '', QuantityAvailable);
                                LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
                            end;
                            if Matching then
                                SalesLine.AutoReserve(false);
                        end;
                        SalesHeader."Shipping Advice" := SalesHeader."Shipping Advice"::Partial;
                        SalesHeader."Shipment Date" := Matching ? ShipmentDate : NonMatchingShipmentDate;
                        SalesHeader.Modify();
                        if Matching then
                            ExpectedReleasedOrders.Add(SalesHeader."No.");
                    end;
                end;

                // Create complete shipping advice orders that should be released
                ReleaseInput.ElementExists('complete', ElementExist);
                if ElementExist then begin
                    Complete := ReleaseInput.Element('complete').ValueAsInteger();
                    for Idx := 0 to Complete - 1 do begin
                        CustNo := LibrarySales.CreateCustomerNo();
                        LibrarySales.CreateSalesOrderWithLocation(SalesHeader, CustNo, 'BLUE');
                        NoOfItems := LibraryRandom.RandInt(5);

                        for IdxItem := 0 to NoOfItems - 1 do begin
                            Quantity := LibraryRandom.RandInt(5);
                            QuantityAvailable := Quantity; // Full availability for complete orders

                            LibraryInventory.CreateItemWithUnitPriceAndUnitCost(Item, LibraryRandom.RandDecInDecimalRange(5.0, 100.0, 2), 2.0);
                            LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", Matching ? ShipmentDate : NonMatchingShipmentDate, Quantity);
                            if QuantityAvailable > 0 then begin
                                LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, Item."No.", 'BLUE', '', QuantityAvailable);
                                LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
                            end;
                            if Matching then
                                SalesLine.AutoReserve(false);
                        end;
                        SalesHeader."Shipping Advice" := SalesHeader."Shipping Advice"::Complete;
                        SalesHeader."Shipment Date" := Matching ? ShipmentDate : NonMatchingShipmentDate;
                        SalesHeader.Modify();
                        if Matching then
                            ExpectedReleasedOrders.Add(SalesHeader."No.");
                    end;
                end;
            end;

            // Process no_release orders
            SalesOrderInput.ElementAt(IdxSO).ElementExists('no_release', ElementExist);
            if ElementExist then begin
                NoReleaseInput := SalesOrderInput.ElementAt(IdxSO).Element('no_release');

                // Create partial shipping advice orders that should NOT be released (no inventory)
                NoReleaseInput.ElementExists('partial', ElementExist);
                if ElementExist then begin
                    Partial := NoReleaseInput.Element('partial').ValueAsInteger();
                    for Idx := 0 to Partial - 1 do begin
                        CustNo := LibrarySales.CreateCustomerNo();
                        LibrarySales.CreateSalesOrderWithLocation(SalesHeader, CustNo, 'BLUE');
                        NoOfItems := LibraryRandom.RandInt(5);

                        for IdxItem := 0 to NoOfItems - 1 do begin
                            Quantity := 0; // No quantity requested
                            QuantityAvailable := LibraryRandom.RandInt(5);

                            LibraryInventory.CreateItemWithUnitPriceAndUnitCost(Item, LibraryRandom.RandDecInDecimalRange(5.0, 100.0, 2), 2.0);
                            LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", Matching ? ShipmentDate : NonMatchingShipmentDate, Quantity);
                            if QuantityAvailable > 0 then begin
                                LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, Item."No.", 'BLUE', '', QuantityAvailable);
                                LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
                            end;
                            if Matching then
                                SalesLine.AutoReserve(false);
                        end;
                        SalesHeader."Shipping Advice" := SalesHeader."Shipping Advice"::Partial;
                        SalesHeader."Shipment Date" := Matching ? ShipmentDate : NonMatchingShipmentDate;
                        SalesHeader.Modify();
                        if Matching then
                            ExpectedNonReleasedOrders.Add(SalesHeader."No.");
                    end;
                end;

                // Create complete shipping advice orders that should NOT be released (insufficient inventory)
                NoReleaseInput.ElementExists('complete', ElementExist);
                if ElementExist then begin
                    Complete := NoReleaseInput.Element('complete').ValueAsInteger();
                    for Idx := 0 to Complete - 1 do begin
                        CustNo := LibrarySales.CreateCustomerNo();
                        LibrarySales.CreateSalesOrderWithLocation(SalesHeader, CustNo, 'BLUE');
                        NoOfItems := LibraryRandom.RandInt(5);

                        for IdxItem := 0 to NoOfItems - 1 do begin
                            QuantityAvailable := LibraryRandom.RandInt(5);
                            Quantity := QuantityAvailable + 1; // Request more than available

                            LibraryInventory.CreateItemWithUnitPriceAndUnitCost(Item, LibraryRandom.RandDecInDecimalRange(5.0, 100.0, 2), 2.0);
                            LibrarySales.CreateSalesLineWithShipmentDate(SalesLine, SalesHeader, Enum::"Sales Line Type"::Item, Item."No.", Matching ? ShipmentDate : NonMatchingShipmentDate, Quantity);
                            if QuantityAvailable > 0 then begin
                                LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, Item."No.", 'BLUE', '', QuantityAvailable);
                                LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
                            end;
                            if Matching then
                                SalesLine.AutoReserve(false);
                        end;
                        SalesHeader."Shipping Advice" := SalesHeader."Shipping Advice"::Complete;
                        SalesHeader."Shipment Date" := Matching ? ShipmentDate : NonMatchingShipmentDate;
                        SalesHeader.Modify();
                        if Matching then
                            ExpectedNonReleasedOrders.Add(SalesHeader."No.");
                    end;
                end;
            end;
        end;
    end;

    /// <summary>
    /// Validates that the expected sales orders were released and non-released.
    /// </summary>
    procedure ValidateSalesOrderRelease(ExpectedReleasedOrders: List of [Code[20]]; ExpectedNonReleasedOrders: List of [Code[20]]; var ErrorReason: Text): Boolean
    var
        SalesHeader: Record "Sales Header";
        FailedOrders: List of [Code[20]];
        OrderNo: Code[20];
        Idx: Integer;
        TB: TextBuilder;
    begin
        // Verify orders that should NOT have been released
        for Idx := 1 to ExpectedNonReleasedOrders.Count() do begin
            OrderNo := ExpectedNonReleasedOrders.Get(Idx);
            SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
            if SalesHeader.Status <> SalesHeader.Status::Open then
                FailedOrders.Add(OrderNo);
        end;

        if FailedOrders.Count() > 0 then begin
            TB.Append('The following sales orders were expected to remain open but were released: ');
            foreach OrderNo in FailedOrders do
                TB.Append(OrderNo + ', ');
            ErrorReason := TB.ToText();
            exit(false);
        end;

        // Verify orders that should have been released
        Clear(FailedOrders);
        for Idx := 1 to ExpectedReleasedOrders.Count() do begin
            OrderNo := ExpectedReleasedOrders.Get(Idx);
            SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
            if SalesHeader.Status <> SalesHeader.Status::Released then
                FailedOrders.Add(OrderNo);
        end;

        if FailedOrders.Count() > 0 then begin
            TB.Append('The following sales orders were expected to be released but were not: ');
            foreach OrderNo in FailedOrders do
                TB.Append(OrderNo + ', ');
            ErrorReason := TB.ToText();
            exit(false);
        end;

        exit(true);
    end;

    local procedure CleanupSalesOrdersByShipmentDate(ShipmentDate: Date)
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("Shipment Date", ShipmentDate);
        SalesHeader.DeleteAll();
    end;

    var
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        AITTestContext: Codeunit "AIT Test Context";
}
