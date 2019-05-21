// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139542 "Sales Forecast Lib"
{
    // version Test,W1,All,Lib

    var
        MSSalesForecastSetup: Record "MS - Sales Forecast Setup";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        MockServiceURITxt: Label 'https://localhost:8080/services.azureml.net/workspaces/2eaccaaec84c47c7a1f8f01ec0a6eea7', Locked = true;
        MockServiceKeyTxt: Label 'TestKey', Locked = true;

    procedure CreateTestData(var Item: Record Item; NumberOfEntries: Integer);
    var
        Customer: Record Customer;
    begin
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateCustomer(Customer);
        CreateLedgerEntriesBeforeWorkdate(Item, Customer, NumberOfEntries, false);
    end;

    procedure CreateTestDataDayWithExitingItem(var Item: Record Item; NumberOfEntries: Integer);
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        CreateLedgerEntriesBeforeWorkdate(Item, Customer, NumberOfEntries, true);
    end;

    procedure CreateLedgerEntriesBeforeWorkdate(var Item: Record Item; var Customer: Record Customer; NumberOfEntries: Integer; PeriodTypeDay: Boolean);
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        PostingDate: Date;
        EntryNo: Integer;
        LastEntryNo: Integer;
        QtyToIncrease: Decimal;
    begin
        PostingDate := CalcDate('<-1D>', WorkDate());
        QtyToIncrease := 5;

        ItemLedgerEntry.FindLast();
        LastEntryNo := ItemLedgerEntry."Entry No.";
        CLEAR(ItemLedgerEntry);

        // Increasing, liniar sales
        for EntryNo := 1 to NumberOfEntries do begin
            ItemLedgerEntry.Init();
            ItemLedgerEntry."Entry No." := LastEntryNo + EntryNo;
            ItemLedgerEntry."Item No." := Item."No.";
            ItemLedgerEntry."Entry Type" := ItemLedgerEntry."Entry Type"::Sale;
            ItemLedgerEntry."Posting Date" := PostingDate;
            ItemLedgerEntry.Quantity := -(NumberOfEntries * QtyToIncrease - (EntryNo - 1) * QtyToIncrease);
            ItemLedgerEntry."Source Type" := ItemLedgerEntry."Source Type"::Customer;
            ItemLedgerEntry."Source No." := Customer."No.";
            ItemLedgerEntry.Insert();

            if PeriodTypeDay then
                PostingDate := CalcDate('<-1D>', PostingDate)
            else
                PostingDate := CalcDate('<-1M>', PostingDate);
        end;
    end;

    procedure Setup();
    begin
        MSSalesForecastSetup.GetSingleInstance();
        MSSalesForecastSetup.Validate("API URI", MockServiceURITxt);
        MSSalesForecastSetup.SetUserDefinedAPIKey(MockServiceKeyTxt);
        MSSalesForecastSetup.Modify(true);
    end;

    procedure GetMockServiceURItxt(): Text;
    begin
        exit(MockServiceURITxt);
    end;
}

