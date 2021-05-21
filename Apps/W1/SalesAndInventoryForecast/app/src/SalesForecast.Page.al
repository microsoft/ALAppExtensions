// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 1850 "Sales Forecast"
{
    Caption = 'Forecast';
    PageType = CardPart;
    SourceTable = Item;
    ContextSensitiveHelpPage = 'ui-extensions-sales-forecast';

    layout
    {
        area(content)
        {
            usercontrol(ForecastBusinessChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = Basic, Suite;

                trigger DataPointClicked(point: JsonObject)
                var
                    MSSalesForecast: Record "MS - Sales Forecast";
                    ColumndDate: Date;
                    XValueString: JsonToken;
                begin
                    with MSSalesForecast do begin
                        point.Get('XValueString', XValueString);
                        if Evaluate(ColumndDate, XValueString.AsValue().AsText()) then
                            if Get("No.", ColumndDate) then
                                Message(ExpectedSalesMsg, Quantity, Delta);
                    end;
                end;

                trigger AddInReady()
                begin
                    IsChartAddInReady := true;
                    UpdateStatus();
                    if IsChartDataReady then
                        UpdateChart();
                end;

                trigger Refresh()
                begin
                    if IsChartDataReady and IsChartAddInReady then begin
                        NeedsUpdate := true;
                        UpdateChart();
                    end;
                end;
            }

            field(StatusText; StatusTextValue)
            {
                ApplicationArea = Basic, Suite;
                CaptionClass = LastUpdatedText;
                Enabled = IsStatusTextEnabled;
                Style = AttentionAccent;
                StyleExpr = true;
                ToolTip = 'Specifies the status of the forecast based on the current setup data.';
                Caption = 'Status';

                trigger OnDrillDown();
                begin
                    case StatusType of
                        StatusType::"No columns due to high variance":
                            Message(VarianceTooHighMsg);
                        StatusType::"Limited columns due to high variance":
                            Message(ForecastPeriodFilterMsg);
                        StatusType::"Forecast expired":
                            Message(ExistingForecastExpiredMsg);
                        StatusType::"Forecast period type changed":
                            Message(ForecastPeriodTypeChangedMsg);
                        StatusType::"Not enough historical data":
                            Message(NotEnoughHistoricalDataMsg);
                        StatusType::"Zero Forecast":
                            Message(ZeroForecastMsg);
                        StatusType::"No Forecast available":
                            Message(NoForecastMsg);
                    end;
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Purchase Invoice")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Create Purchase Invoice';
                ToolTip = 'Creates a purchase invoice for this item';
                Image = NewPurchaseInvoice;

                trigger OnAction();
                var
                    SalesForecastNotifier: Codeunit "Sales Forecast Notifier";
                begin
                    SalesForecastNotifier.CreateAndShowPurchaseInvoice("No.");
                end;
            }
            action("Create Purchase Order")
            {
                ApplicationArea = Suite;
                Caption = 'Create Purchase Order';
                ToolTip = 'Creates a purchase order for this item';
                Image = NewOrder;

                trigger OnAction();
                var
                    SalesForecastNotifier: Codeunit "Sales Forecast Notifier";
                begin
                    SalesForecastNotifier.CreateAndShowPurchaseOrder("No.");
                end;
            }
            action("Show Inventory Forecast")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show Inventory Forecast';
                ToolTip = 'View Item Inventory Forecast';
                Image = ShowChart;

                trigger OnAction();
                begin
                    if ForecastType <> ForecastType::Inventory then begin
                        ForecastType := ForecastType::Inventory;
                        NeedsUpdate := true;
                    end;
                end;
            }
            action("Show Sales Forecast")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show Sales Forecast';
                ToolTip = 'View Item Sales Forecast';
                Image = ShowChart;

                trigger OnAction();
                begin
                    if ForecastType <> ForecastType::Sales then begin
                        ForecastType := ForecastType::Sales;
                        NeedsUpdate := true;
                    end;
                end;
            }
            action("Forecast Settings")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Forecast Settings';
                ToolTip = 'View or edit the setup for the forecast.';
                Image = OrderPromisingSetup;

                trigger OnAction();
                begin
                    Page.Run(Page::"Sales Forecast Setup Card");
                end;
            }
            action("Delete Sales Forecast")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Deletes the sales forecast for this item';
                Image = Delete;

                trigger OnAction();
                var
                    MSSalesForecast: Record "MS - Sales Forecast";
                    MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
                begin
                    MSSalesForecast.SetRange("Item No.", Rec."No.");
                    MSSalesForecast.DeleteAll(true);

                    MSSalesForecastParameter.SetRange("Item No.", Rec."No.");
                    MSSalesForecastParameter.DeleteAll(true);
                    UpdateChart();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        IsChartDataReady := true;
        if not IsChartAddInReady then
            exit;

        if (Rec."No." = '') or (PrevRecNo <> Rec."No.") or NeedsUpdate or IsForecastUpdated() then
            UpdatePage();

        PrevRecNo := Rec."No.";
    end;

    trigger OnOpenPage()
    begin
        ForecastType := ForecastType::Inventory;
        NeedsUpdate := true;
        LastUpdatedText := StatusLbl;
    end;

    var
        MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
        MSSalesForecastSetup: Record "MS - Sales Forecast Setup";
        StartingDate: Date;
        EndingDate: Date;
        NeedsUpdate: Boolean;
        StatusTextValue: Text;
        LastUpdatedText: Text;
        ForecastType: Option Sales,Inventory;
        UpdateSuccessfulFactboxMsg: Label 'Update Successful';
        NotEnoughHistoricalDataFactboxMsg: Label 'Not enough historical data';
        VarianceHigherDefinedLevelFactboxMsg: Label 'Variance too high';
        ExistingForecastExpiredFactboxMsg: Label 'Forecast expired';
        ForecastPeriodTypeChangedFactboxMsg: Label 'The %1 has been changed', Comment = '%1=Forecast Period Type';
        ForecastPeriodFilterFactboxMsg: Label 'High variance';
        ZeroForecastFactboxMsg: Label 'Forecast is equal to 0';
        StatusType: Option " ","No columns due to high variance","Limited columns due to high variance","Forecast expired","Forecast period type changed","Not enough historical data","Zero Forecast","No Forecast available";
        NoForecastFactboxMsg: Label 'Sales forecast not available.';
        NotEnoughHistoricalDataMsg: Label 'There is not enough historical data to predict future sales.\You need at least five periods of historical sales in order to predict future sales.';
        VarianceTooHighMsg: Label 'The calculated forecast shows a degree of variance that is higher than the setup allows.';
        ExistingForecastExpiredMsg: Label 'The forecast has passed the expiration date and is no longer valid.';
        ForecastPeriodTypeChangedMsg: Label 'The forecast is not valid. Someone has changed the forecast period type in the setup on the Sales and Inventory Forecast Setup page. Recalculate the forecast to see the latest figures.';
        ForecastPeriodFilterMsg: Label 'The forecast shows periods with a Variance % that is lower than specified in setup.';
        ZeroForecastMsg: Label 'The calculated forecast contains values equal to 0.';
        ExpectedSalesMsg: Label 'The sales forecast for this period is %1 with a variance of %2.', Comment = '%1 = amount, %2 = amount. Ex.The sales forecast for this period is 15 with a variance of 3.';
        LastUpdatedValue: DateTime;
        IsChartAddInReady: Boolean;
        IsChartDataReady: Boolean;
        NoForecastMsg: Label 'To get an updated inventory forecast, you must set up forecasting on the Sales and Inventory Forecast page.';
        InventoryForecastTxt: Label 'Inventory Forecast';
        SalesForecastTxt: Label 'Sales Forecast';
        StatusLbl: Label 'Status';
        IsStatusTextEnabled: Boolean;
        PrevRecNo: Code[20];

    local procedure UpdatePage()
    begin
        if not MSSalesForecastSetup.Get() then;
        InitializeLabels();
        UpdateStatus();
        UpdateChart();
        LastUpdatedValue := MSSalesForecastParameter."Last Updated";
    end;

    local procedure AddInventoryForecastedData(var BusinessChartBuffer: Record "Business Chart Buffer"; var MSSalesForecast: Record "MS - Sales Forecast"; var ColumnNo: Integer)
    var
        ForecastWithHighVariance: Boolean;
        RunningInventory: Decimal;
    begin
        ForecastWithHighVariance := false;
        CalcFields(Inventory);
        RunningInventory := Inventory;

        with BusinessChartBuffer do begin
            MSSalesForecast.SetRange(Date, WorkDate(), EndingDate);
            if MSSalesForecast.FindSet() then
                repeat
                    if CheckVariancePerc(MSSalesForecast) then begin
                        SetStatusText(StatusType::" ");
                        AddColumn(Format(MSSalesForecast.Date));
                        SetValue(InventoryForecastTxt, ColumnNo, RunningInventory);
                        RunningInventory -= MSSalesForecast.Quantity;
                        ColumnNo += 1;
                    end else begin
                        ForecastWithHighVariance := true;
                        if ColumnNo = 0 then
                            SetStatusText(StatusType::"No columns due to high variance")
                        else
                            SetStatusText(StatusType::"Limited columns due to high variance");
                    end;
                until (MSSalesForecast.Next() = 0) or ForecastWithHighVariance;
        end;
    end;

    local procedure AddSalesForecastedData(var BusinessChartBuffer: Record "Business Chart Buffer"; var MSSalesForecast: Record "MS - Sales Forecast"; var ColumnNo: Integer)
    var
        ForecastWithHighVariance: Boolean;
    begin
        ForecastWithHighVariance := false;

        with BusinessChartBuffer do begin
            MSSalesForecast.SetRange(Date, WorkDate(), EndingDate);

            if IsForecastZero(MSSalesForecast) then
                exit;
            if MSSalesForecast.FindSet() then
                repeat
                    if CheckVariancePerc(MSSalesForecast) then begin
                        SetStatusText(StatusType::" ");
                        AddColumn(Format(MSSalesForecast.Date));
                        SetValue(SalesForecastTxt, ColumnNo, MSSalesForecast.Quantity);
                        ColumnNo += 1;
                    end else begin
                        ForecastWithHighVariance := true;
                        if ColumnNo = 0 then
                            SetStatusText(StatusType::"No columns due to high variance")
                        else
                            SetStatusText(StatusType::"Limited columns due to high variance");
                    end;
                until (MSSalesForecast.Next() = 0) or ForecastWithHighVariance;
        end;
    end;

    local procedure AddSalesHistoricData(var BusinessChartBuffer: Record "Business Chart Buffer"; var MSSalesForecast: Record "MS - Sales Forecast"; var ColumnNo: Integer)
    begin
        with BusinessChartBuffer do begin
            MSSalesForecast.SetFilter(Date, '>%1 & <%2', StartingDate, WorkDate());
            if MSSalesForecast.FindSet() then
                repeat
                    AddColumn(Format(MSSalesForecast.Date));
                    SetValue(SalesForecastTxt, ColumnNo, MSSalesForecast.Quantity);
                    ColumnNo += 1;
                until MSSalesForecast.Next() = 0;
        end;
    end;

    local procedure CheckVariancePerc(MSSalesForecast: Record "MS - Sales Forecast"): Boolean
    var
        VariancePercSetup: Decimal;
        VariancePercValue: Decimal;
    begin
        // Variance % Setup
        if MSSalesForecastSetup."Variance %" = 0 then
            exit(true);
        VariancePercSetup := MSSalesForecastSetup."Variance %";

        // Variance % Forecast
        VariancePercValue := MSSalesForecast."Variance %";

        if VariancePercSetup > VariancePercValue then
            exit(true);

        exit(false);
    end;

    local procedure IsForecastZero(var MSSalesForecast: Record "MS - Sales Forecast"): Boolean
    var
        MSSalesForecastHelper: Record "MS - Sales Forecast";
    begin
        with MSSalesForecastHelper do begin
            CopyFilters(MSSalesForecast);
            SetFilter(Quantity, '<>%1', 0);
            if IsEmpty() then begin
                SetStatusText(StatusType::"Zero Forecast");
                exit(true);
            end;
        end;

        exit(false);
    end;

    local procedure DefineMasuresAndAxis(var BusinessChartBuffer: Record "Business Chart Buffer")
    var
        MSSalesForecast: Record "MS - Sales Forecast";
    begin
        if ForecastType = ForecastType::Sales then begin
            BusinessChartBuffer.AddMeasure(SalesForecastTxt, 1,
            BusinessChartBuffer."Data Type"::Decimal, BusinessChartBuffer."Chart Type"::Column);
            BusinessChartBuffer.SetXAxis('Period' + Format(MSSalesForecast."Forecast Data"::Result),
            BusinessChartBuffer."Data Type"::String);
        end else begin
            BusinessChartBuffer.AddMeasure(InventoryForecastTxt, 1,
            BusinessChartBuffer."Data Type"::Decimal, BusinessChartBuffer."Chart Type"::Column);
            BusinessChartBuffer.SetXAxis('Period' + Format(MSSalesForecast."Forecast Data"::Result),
            BusinessChartBuffer."Data Type"::String);
        end;
    end;

    local procedure ForecastAvailable(): Boolean
    var
        MSSalesForecast: Record "MS - Sales Forecast";
    begin
        MSSalesForecast.SetRange("Forecast Data", MSSalesForecast."Forecast Data"::Result);
        MSSalesForecast.SetRange("Item No.", "No.");

        exit(not MSSalesForecast.IsEmpty());
    end;

    local procedure GetTimeSeriesPeriodType(): Text[1]
    begin
        with MSSalesForecastParameter do
            case "Time Series Period Type" of
                "Time Series Period Type"::Day:
                    exit('D');
                "Time Series Period Type"::Week:
                    exit('W');
                "Time Series Period Type"::Month:
                    exit('M');
                "Time Series Period Type"::Quarter:
                    exit('Q');
                "Time Series Period Type"::Year:
                    exit('Y');
            end;
    end;

    local procedure InitializeLabels()
    begin
        LastUpdatedText := StatusLbl;
        SetStatusText(StatusType::" ");
    end;

    local procedure IsForecastUpdated(): Boolean
    begin
        if MSSalesForecastParameter.Get("No.") then
            if LastUpdatedValue <> MSSalesForecastParameter."Last Updated" then
                exit(true);
        exit(false);
    end;

    local procedure PopulateChart(var BusinessChartBuffer: Record "Business Chart Buffer")
    var
        MSSalesForecast: Record "MS - Sales Forecast";
        ColumnNo: Integer;
    begin
        // prepare source data
        MSSalesForecast.SetRange("Item No.", "No.");
        SetDateRange();

        with BusinessChartBuffer do begin
            Initialize();
            ColumnNo := 0;

            // 1. Measures & Axis
            DefineMasuresAndAxis(BusinessChartBuffer);

            if not NeedsUpdate then
                exit;
            // 2. historic data until current period
            AddSalesHistoricData(BusinessChartBuffer, MSSalesForecast, ColumnNo);

            // 3. forecasted data
            if ForecastType = ForecastType::Sales then
                AddSalesForecastedData(BusinessChartBuffer, MSSalesForecast, ColumnNo)
            else
                AddInventoryForecastedData(BusinessChartBuffer, MSSalesForecast, ColumnNo);
        end;
    end;

    local procedure SetDateRange()
    begin
        StartingDate := WorkDate();
        EndingDate := CalcDate('<+6' + GetTimeSeriesPeriodType() + '>', WorkDate());
    end;

    local procedure UpdateChart()
    var
        BusinessChartBuffer: Record "Business Chart Buffer";
    begin
        if not IsChartAddInReady then
            exit;
        PopulateChart(BusinessChartBuffer);
        BusinessChartBuffer.Update(CurrPage.ForecastBusinessChart);
        NeedsUpdate := false;
    end;

    procedure UpdateStatus()
    var
        MSSalesForecast: Record "MS - Sales Forecast";
        ItemLedgerEntry: Record "Item Ledger Entry";
        TimeSeriesManagement: Codeunit "Time Series Management";
        SalesForecastHandler: Codeunit "Sales Forecast Handler";
        LastValidDate: Date;
        NumberOfPeriodsToPredict: Integer;
        VariancePercSetup: Decimal;
        NumberOfPeriodsWithHistory: Integer;
        NumberOfPeriodsWithHistoryLoc: Integer;
        HasMinimumHistory: Boolean;
        HasMinimumHistoryLoc: Boolean;
    begin
        NeedsUpdate := false;
        if MSSalesForecastSetup.Get() then;

        TimeSeriesManagement.SetMaximumHistoricalPeriods(MSSalesForecastSetup."Historical Periods");
        TimeSeriesManagement.SetMinimumHistoricalPeriods(5);
        SalesForecastHandler.SetItemLedgerEntryFilters(ItemLedgerEntry, "No.");

        HasMinimumHistory := TimeSeriesManagement.HasMinimumHistoricalData(
            NumberOfPeriodsToPredict,
            ItemLedgerEntry,
            ItemLedgerEntry.FieldNo("Posting Date"),
            MSSalesForecastSetup."Period Type",
            WorkDate());
        OnAfterHasMinimumSIHistData("No.", HasMinimumHistoryLoc, NumberOfPeriodsWithHistoryLoc, MSSalesForecastSetup."Period Type", WorkDate(), StatusType);
        HasMinimumHistory := (HasMinimumHistory OR HasMinimumHistoryLoc);
        if NumberOfPeriodsWithHistoryLoc > NumberOfPeriodsWithHistory then
            NumberOfPeriodsWithHistory := NumberOfPeriodsWithHistoryLoc; // Otherwise, NumberOfPeriodsWithHistory is already the bigger number
        if not HasMinimumHistory then begin
            SetStatusText(StatusType::"Not enough historical data");
            exit;
        end;
        // check if forecast exists in DB
        if not MSSalesForecastParameter.Get("No.") then
            // enough ledger entries, forecast not updated
            if not ForecastAvailable() then begin
                SetStatusText(StatusType::"No Forecast available");
                exit;
            end;

        LastUpdatedText := StrSubstNo('Updated %1', Format(DT2Date(MSSalesForecastParameter."Last Updated")));

        // forecast exists, check if forecast expired
        if MSSalesForecastParameter."Last Updated" <> 0DT then begin
            LastValidDate := CalcDate('<+' + Format(MSSalesForecastSetup."Expiration Period (Days)") + 'D>',
              DT2Date(MSSalesForecastParameter."Last Updated"));
            if LastValidDate <= WorkDate() then begin
                SetStatusText(StatusType::"Forecast expired");
                exit;
            end;
        end;

        VariancePercSetup := MSSalesForecastSetup."Variance %";
        MSSalesForecast.SetRange("Item No.", "No.");
        MSSalesForecast.SetRange("Forecast Data", MSSalesForecast."Forecast Data"::Result);
        MSSalesForecast.SetFilter("Variance %", '<=%1', VariancePercSetup);
        if MSSalesForecast.IsEmpty() then
            SetStatusText(StatusType::"No columns due to high variance");

        // forecast exists, check if Period Type has been changed in Setup
        if MSSalesForecastSetup."Period Type" <> MSSalesForecastParameter."Time Series Period Type" then begin
            SetStatusText(StatusType::"Forecast period type changed");
            exit;
        end;

        NeedsUpdate := true;
    end;

    local procedure SetStatusText(Status: Option)
    begin
        StatusType := Status;
        case Status of
            StatusType::"No columns due to high variance":
                StatusTextValue := VarianceHigherDefinedLevelFactboxMsg;
            StatusType::"Limited columns due to high variance":
                StatusTextValue := ForecastPeriodFilterFactboxMsg;
            StatusType::"Forecast expired":
                StatusTextValue := ExistingForecastExpiredFactboxMsg;
            StatusType::"Forecast period type changed":
                StatusTextValue := StrSubstNo(ForecastPeriodTypeChangedFactboxMsg, MSSalesForecastSetup.FIELDCAPTION("Period Type"));
            StatusType::"Not enough historical data":
                StatusTextValue := NotEnoughHistoricalDataFactboxMsg;
            StatusType::"Zero Forecast":
                StatusTextValue := ZeroForecastFactboxMsg;
            StatusType::"No Forecast available":
                StatusTextValue := NoForecastFactboxMsg;
            else
                StatusTextValue := UpdateSuccessfulFactboxMsg;
        end;
        if StatusType = StatusType::" " then
            IsStatusTextEnabled := false
        else
            IsStatusTextEnabled := true;
        if StatusType in [StatusType::"Not enough historical data"] then
            // Blank out the last updated text in case of an error
            LastUpdatedText := '';
    end;

    procedure TestGetStatusText(): Text
    begin
        exit(StatusTextValue);
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterHasMinimumSIHistData(ItemNo: Code[20]; VAR HasMinimumHistoryLoc: boolean; VAR NumberOfPeriodsWithHistoryLoc: Integer; PeriodType: Integer; ForecastStartDate: Date; VAR StatusType: Option " ","No columns due to high variance","Limited columns due to high variance","Forecast expired","Forecast period type changed","Not enough historical data","Zero Forecast","No Forecast available");
    begin
    end;

}

