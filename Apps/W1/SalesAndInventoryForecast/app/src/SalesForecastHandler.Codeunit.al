// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1850 "Sales Forecast Handler"
{
    TableNo = Item;

    var
        MSSalesForecastSetup: Record "MS - Sales Forecast Setup";
        NotEnoughHistoricalDataErr: Label 'There is not enough historical data to predict future sales.';
        SpecifyApiKeyErr: Label 'You must specify an API key and an API URI in the Sales and Inventory Forecast Setup page.';
        Status: Option " ","Missing API","Not enough historical data","Out of limit","Failed Time Series initialization";
        OutOfLimitErr: Label 'Each calculation uses Azure Machine Learning credits, and you have reached your limit for this month.';
        FailedTimeSeriesInitializationErr: Label 'Failed to initialize the forecast method. Please, contact your system administrator.';
        SalesForecastNameTxt: Label 'Sales and Inventory Forecast';
        SalesForecastBusinessSetupDescriptionTxt: Label 'Set up and enable the Sales and Inventory Forecast service.';
        SalesForecastBusinessSetupKeywordsTxt: Label 'Sales,Inventory,Forecast';
        UpdateDialogTxt: Label 'We''re updating the inventory forecast for item #1', comment = '#1 = an Item No.';

    procedure CalculateForecast(var Item: Record Item; TimeSeriesManagement: Codeunit "Time Series Management"): Boolean
    var
        TempTimeSeriesForecast: Record "Time Series Forecast" temporary;
        MSSalesForecast: Record "MS - Sales Forecast";
        MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
    begin
        if not InitializeSetup() then
            exit(false);

        if not PrepareForecast(MSSalesForecastParameter, Item."No.", TimeSeriesManagement) then
            exit(false);

        TimeSeriesManagement.Forecast(MSSalesForecastParameter.Horizon, 80, MSSalesForecastSetup."Timeseries Model");

        // Insert forecasted data
        TimeSeriesManagement.GetForecast(TempTimeSeriesForecast);
        MSSalesForecast.PopulateForecastResult(TempTimeSeriesForecast);
        exit(true);
    end;

    procedure PrepareForecast(var MSSalesForecastParameter: Record "MS - Sales Forecast Parameter"; ItemNo: Code[20]; TimeSeriesManagement: Codeunit "Time Series Management"): Boolean
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        TempTimeSeriesBuffer: Record "Time Series Buffer" temporary;
        MSSalesForecast: Record "MS - Sales Forecast";
        ForecastStartDate: Date;
        NumberOfPeriodsWithHistory: Integer;
        NumberOfPeriodsWithHistoryLoc: Integer;
        HasMinimumHistory: Boolean;
        HasMinimumHistoryLoc: Boolean;
    begin
        if not InitializeSetup() then
            exit(false);

        // Clean up
        MSSalesForecastParameter.SetRange("Item No.", ItemNo);
        MSSalesForecastParameter.DeleteAll();
        MSSalesForecast.SetRange("Item No.", ItemNo);
        MSSalesForecast.DeleteAll();

        // populate Item Sales Parameters
        MSSalesForecastParameter.NewRecord(ItemNo);

        SetItemLedgerEntryFilters(ItemLedgerEntry, ItemNo);
        ItemLedgerEntry.SetFilter("Posting Date", '<=%1', WorkDate());

        if not InitializeTimeseries(TimeSeriesManagement, MSSalesForecastSetup) then
            exit(false);

        TimeSeriesManagement.SetMaximumHistoricalPeriods(MSSalesForecastSetup."Historical Periods");

        // Verify if Item has enough ledger entries to create forecast
        HasMinimumHistory := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsWithHistory,
            ItemLedgerEntry,
            ItemLedgerEntry.FieldNo("Posting Date"),
            MSSalesForecastSetup."Period Type",
            WorkDate());

        OnAfterHasMinimumSIHistData(ItemNo, HasMinimumHistoryLoc, NumberOfPeriodsWithHistoryLoc, MSSalesForecastSetup."Period Type", WorkDate(), Status);
        HasMinimumHistory := (HasMinimumHistory OR HasMinimumHistoryLoc);
        if NumberOfPeriodsWithHistoryLoc > NumberOfPeriodsWithHistory then
            NumberOfPeriodsWithHistory := NumberOfPeriodsWithHistoryLoc; // Otherwise, NumberOfPeriodsWithHistory is already the bigger number
        if not HasMinimumHistory then begin
            Status := Status::"Not enough historical data";
            Commit();
            exit(false);
        end;

        ForecastStartDate := CalcDate('<+1D>', WorkDate());
        TimeSeriesManagement.PrepareData(
          ItemLedgerEntry, ItemLedgerEntry.FieldNo("Item No."), ItemLedgerEntry.FieldNo("Posting Date"), ItemLedgerEntry.FieldNo(Quantity),
          MSSalesForecastParameter."Time Series Period Type", ForecastStartDate, NumberOfPeriodsWithHistory);
        TimeSeriesManagement.GetPreparedData(TempTimeSeriesBuffer);
        OnAfterPrepareSalesInvData(ItemNo, TempTimeSeriesBuffer, MSSalesForecastSetup."Period Type", ForecastStartDate, NumberOfPeriodsWithHistory, Status);

        if TempTimeSeriesBuffer.FindSet() then
            repeat
                TempTimeSeriesBuffer.Value := -TempTimeSeriesBuffer.Value;
                TempTimeSeriesBuffer.Modify();
            until TempTimeSeriesBuffer.Next() = 0;

        MSSalesForecast.PopulateForecastBase(TempTimeSeriesBuffer);

        exit(true);
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    procedure InitializeTimeseries(var TimeSeriesManagement: Codeunit "Time Series Management"; MSSalesForecastSetup: Record "MS - Sales Forecast Setup"): Boolean
    var
        AzureAIUsage: Codeunit "Azure AI Usage";
        AzureAIService: Enum "Azure AI Service";
        APIURI: Text[250];
        APIKey: Text[200];
        LimitType: Option;
        Limit: Decimal;
    begin
        // if null, then using standard credentials
        if IsNullGuid(MSSalesForecastSetup."API Key ID") then begin
            TimeSeriesManagement.GetMLForecastCredentials(APIURI, APIKey, LimitType, Limit);

            if not TimeSeriesManagement.Initialize(APIURI, APIKey, MSSalesForecastSetup."Timeout (seconds)", true) then begin
                Status := Status::"Failed Time Series initialization";
                exit(false);
            end;

            if AzureAIUsage.IsLimitReached(AzureAIService::"Machine Learning", Limit) then begin
                Status := Status::"Out of limit";
                exit(false);
            end;
        end else
            if not TimeSeriesManagement.Initialize(
              MSSalesForecastSetup.GetAPIUri(),
              MSSalesForecastSetup.GetAPIKey(),
              MSSalesForecastSetup."Timeout (seconds)",
              false) then begin
                Status := Status::"Failed Time Series initialization";
                exit(false);
            end;
        exit(true);
    end;

    procedure SetItemLedgerEntryFilters(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemNo: Code[20])
    begin
        ItemLedgerEntry.SetCurrentKey("Posting Date");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetRange(Positive, false);
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
    end;

    procedure ThrowStatusError();
    begin
        case Status of
            Status::"Missing API":
                Error(SpecifyApiKeyErr);
            Status::"Not enough historical data":
                Error(NotEnoughHistoricalDataErr);
            Status::"Out of limit":
                Error(OutOfLimitErr);
            Status::"Failed Time Series initialization":
                LogInternalError(FailedTimeSeriesInitializationErr, DataClassification::SystemMetadata, Verbosity::Error);
        end;
    end;

    procedure UpdateSalesForecastItemList(var Item: Record Item)
    var
        TimeSeriesManagement: Codeunit "Time Series Management";
        ItemCounter: Integer;
        ProgressWindow: Dialog;
    begin
        if not Item.FindSet() then
            exit;
        ItemCounter := Item.Count();
        ProgressWindow.OPEN(UpdateDialogTxt);
        repeat
            ProgressWindow.Update(1, Item."No.");
            if not CalculateForecast(Item, TimeSeriesManagement) then
                if ItemCounter = 1 then begin
                    ProgressWindow.Close();
                    ThrowStatusError();
                    exit;
                end;
        until Item.Next() = 0;

        ProgressWindow.Close();
    end;


    [EventSubscriber(ObjectType::Page, Page::"Item Card", 'OnAfterGetCurrRecordEvent', '', false, false)]
    local procedure OnAfterGetCurrRecordOnItemCard(var Rec: Record Item)
    begin
        Rec."Has Sales Forecast" := HasSalesForecast(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item List", 'OnAfterGetCurrRecordEvent', '', false, false)]
    local procedure OnAfterGetCurrRecordOnItemList(var Rec: Record Item)
    begin
        Rec."Has Sales Forecast" := HasSalesForecast(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnItemDelete(var Rec: Record Item; RunTrigger: Boolean)
    var
        MSSalesForecast: Record "MS - Sales Forecast";
        MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
        ItemToCheckExistenceFor: Record Item;
    begin
        if Rec.ISTEMPORARY() then
            exit;

        if ItemToCheckExistenceFor.Get(Rec."No.") then
            exit;

        MSSalesForecast.SetRange("Item No.", Rec."No.");
        MSSalesForecast.DeleteAll(true);

        MSSalesForecastParameter.SetRange("Item No.", Rec."No.");
        MSSalesForecastParameter.DeleteAll(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
    local procedure HandleSalesInventoryForecastSetupRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    var
        SalesForecastSetupCard: Page "Sales Forecast Setup Card";
    begin
        MSSalesForecastSetup.GetSingleInstance();

        ServiceConnection.Status := ServiceConnection.Status::Enabled;
        if MSSalesForecastSetup.URIOrKeyEmpty() then
            ServiceConnection.Status := ServiceConnection.Status::Disabled;
        ServiceConnection.InsertServiceConnection(
          ServiceConnection, MSSalesForecastSetup.RecordId(), SalesForecastSetupCard.Caption(),
          MSSalesForecastSetup.GetAPIUri(), Page::"Sales Forecast Setup Card");
    end;

    local procedure InitializeSetup(): Boolean
    begin
        Clear(Status);
        MSSalesForecastSetup.GetSingleInstance();
        if MSSalesForecastSetup.URIOrKeyEmpty() then begin
            Status := Status::"Missing API";
            exit(false);
        end;
        exit(true);
    end;

    local procedure HasSalesForecast(Item: Record Item): Boolean
    var
        MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
        MSSalesForecast: Record "MS - Sales Forecast";
        VariancePercSetup: Decimal;
        LastValidDate: Date;
    begin
        if not MSSalesForecastSetup.Get() then
            exit(false);

        if not MSSalesForecastParameter.Get(Item."No.") then
            exit(false);

        if MSSalesForecastSetup."Period Type" <> MSSalesForecastParameter."Time Series Period Type" then
            exit(false);

        VariancePercSetup := MSSalesForecastSetup."Variance %";
        MSSalesForecast.SetRange("Item No.", Item."No.");
        MSSalesForecast.SetRange("Forecast Data", MSSalesForecast."Forecast Data"::Result);
        MSSalesForecast.SetFilter("Variance %", '<=%1', VariancePercSetup);
        if MSSalesForecast.IsEmpty() then
            exit(false);

        // check if forecast expired
        if MSSalesForecastParameter."Last Updated" <> 0DT then begin
            LastValidDate := CalcDate('<+' + Format(MSSalesForecastSetup."Expiration Period (Days)") + 'D>',
              DT2Date(MSSalesForecastParameter."Last Updated"));
            if LastValidDate <= WorkDate() then
                exit(false);
        end;

        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', false, false)]
    local procedure HandleRegisterBusinessSetup(var Sender: Codeunit "Guided Experience")
    var
        ManualSetupCategory: Enum "Manual Setup Category";
    begin
        Sender.InsertManualSetup(
          SalesForecastNameTxt, SalesForecastNameTxt, SalesForecastBusinessSetupDescriptionTxt, 5,
          ObjectType::Page, Page::"Sales Forecast Setup Card", ManualSetupCategory::Service, SalesForecastBusinessSetupKeywordsTxt);
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPrepareSalesInvData(ItemNo: Code[20]; VAR TempTimeSeriesBuffer: Record "Time Series Buffer"; PeriodType: Integer; ForecastStartDate: Date; NumberOfPeriodsWithHistory: Integer; VAR Status: Option " ","Missing API","Not enough historical data","Out of limit");
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterHasMinimumSIHistData(ItemNo: Code[20]; VAR HasMinimumHistoryLoc: boolean; VAR NumberOfPeriodsWithHistoryLoc: Integer; PeriodType: Integer; ForecastStartDate: Date; VAR Status: Option " ","Missing API","Not enough historical data","Out of limit");
    begin
    end;
}
