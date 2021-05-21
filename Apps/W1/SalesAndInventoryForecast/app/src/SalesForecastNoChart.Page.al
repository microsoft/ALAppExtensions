// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 1851 "Sales Forecast No Chart"
{
    Caption = 'Forecast';
    PageType = CardPart;
    SourceTable = Item;
    ContextSensitiveHelpPage = 'ui-extensions-sales-forecast';

    layout
    {
        area(content)
        {
            field(StatusText; StatusTextValue)
            {
                ApplicationArea = Basic, Suite;
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
                        StatusType::"Forecast expired":
                            Message(ExistingForecastExpiredMsg);
                        StatusType::"Forecast period type changed":
                            Message(ForecastPeriodTypeChangedMsg);
                        StatusType::"Not enough historical data":
                            Message(NotEnoughHistoricalDataMsg);
                    end;
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
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
        }
    }

    trigger OnAfterGetRecord()
    begin
        if ("No." = '') or (xRec."No." <> "No.") or NeedsUpdate or IsForecastUpdated() then begin
            if MSSalesForecastSetup.Get() then;
            UpdateStatus();
            LastUpdatedValue := MSSalesForecastParameter."Last Updated";
        end;
    end;

    trigger OnInit()
    begin
        StatusTextValue := NoForecastLbl;
    end;

    var
        MSSalesForecastSetup: Record "MS - Sales Forecast Setup";
        MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
        NoForecastLbl: Label 'Sales forecast not available for this item.';
        NeedsUpdate: Boolean;
        StatusType: Option " ","No columns due to high variance","Limited columns due to high variance","Forecast expired","Forecast period type changed","Not enough historical data","Zero Forecast";
        StatusTextValue: Text;
        NotEnoughHistoricalDataFactboxMsg: Label 'Not enough historical data';
        VarianceHigherDefinedLevelFactboxMsg: Label 'Variance too high';
        ExistingForecastExpiredFactboxMsg: Label 'Forecast expired';
        ForecastPeriodTypeChangedFactboxMsg: Label 'The %1 has been changed', Comment = '%1=Forecast Period Type';
        NotEnoughHistoricalDataMsg: Label 'There is not enough historical data to predict future sales.\You must have at least 5 periods of historical sales in order to predict future sales.';
        VarianceTooHighMsg: Label 'The calculated forecast shows a degree of variance that is higher than the setup allows.';
        ExistingForecastExpiredMsg: Label 'The forecast has passed the expiration date and is no longer valid.';
        ForecastPeriodTypeChangedMsg: Label 'The forecast is not valid. Someone has changed the forecast period type in the setup on the Sales and Inventory Forecast Setup page. Recalculate the forecast to see the latest figures.';
        LastUpdatedValue: DateTime;
        IsStatusTextEnabled: Boolean;

    procedure UpdateStatus()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        MSSalesForecast: Record "MS - Sales Forecast";
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

        // check if forecast exists in DB
        if not MSSalesForecastParameter.Get("No.") then begin
            SetStatusText(StatusType::" ");
            exit;
        end;

        // check if forecast expired
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

        // check if Period Type has been changed in Setup
        if MSSalesForecastSetup."Period Type" <> MSSalesForecastParameter."Time Series Period Type" then begin
            SetStatusText(StatusType::"Forecast period type changed");
            exit;
        end;

        // check if there is enough historical data
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

        NeedsUpdate := true;
    end;

    local procedure SetStatusText(Status: Option)
    begin
        StatusType := Status;
        case Status of
            StatusType::"No columns due to high variance":
                StatusTextValue := VarianceHigherDefinedLevelFactboxMsg;
            StatusType::"Forecast expired":
                StatusTextValue := ExistingForecastExpiredFactboxMsg;
            StatusType::"Forecast period type changed":
                StatusTextValue := StrSubstNo(ForecastPeriodTypeChangedFactboxMsg, MSSalesForecastSetup.FIELDCAPTION("Period Type"));
            StatusType::"Not enough historical data":
                StatusTextValue := NotEnoughHistoricalDataFactboxMsg
            else
                StatusTextValue := NoForecastLbl;
        end;
        if StatusType = StatusType::" " then
            IsStatusTextEnabled := false
        else
            IsStatusTextEnabled := true;
    end;

    local procedure IsForecastUpdated(): Boolean
    begin
        if MSSalesForecastParameter.Get("No.") then
            if LastUpdatedValue <> MSSalesForecastParameter."Last Updated" then
                exit(true);
        exit(false);
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterHasMinimumSIHistData(ItemNo: Code[20]; VAR HasMinimumHistoryLoc: boolean; VAR NumberOfPeriodsWithHistoryLoc: Integer; PeriodType: Integer; ForecastStartDate: Date; VAR StatusType: Option " ","No columns due to high variance","Limited columns due to high variance","Forecast expired","Forecast period type changed","Not enough historical data","Zero Forecast","No Forecast available");
    begin
    end;

}

