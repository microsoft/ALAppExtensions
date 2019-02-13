// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1850 "MS - Sales Forecast"
{
    ReplicateData = false;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(2; Date; Date)
        {
        }
        field(3; Quantity; Decimal)
        {
        }
        field(4; Delta; Decimal)
        {
        }
        field(5; "Forecast Data"; Option)
        {
            OptionMembers = Base,Result;
        }
        field(6; "Variance %"; Decimal)
        {
        }
    }

    keys
    {
        key(Key1; "Item No.", Date)
        {
        }
    }

    trigger OnInsert();
    begin
        UpdateVariance()
    end;

    trigger OnModify();
    begin
        UpdateVariance()
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";

    procedure PopulateForecastBase(var TempTimeSeriesBuffer: Record "Time Series Buffer" temporary)
    begin
        GeneralLedgerSetup.Get();
        if TempTimeSeriesBuffer.FindSet() then
            repeat
                NewBaseRecord(
                    CopyStr(TempTimeSeriesBuffer."Group ID", 1, MaxStrLen("Item No.")),
                    TempTimeSeriesBuffer."Period Start Date",
                    RoundAmount(TempTimeSeriesBuffer.Value));
            until TempTimeSeriesBuffer.Next() = 0;
    end;

    procedure PopulateForecastResult(var TempTimeSeriesForecast: Record "Time Series Forecast" temporary)
    begin
        GeneralLedgerSetup.Get();
        if TempTimeSeriesForecast.FindSet() then
            repeat
                NewResultRecord(
                    CopyStr(TempTimeSeriesForecast."Group ID", 1, MaxStrLen("Item No.")),
                    TempTimeSeriesForecast."Period Start Date",
                    RoundAmount(TempTimeSeriesForecast.Value),
                    RoundAmount(TempTimeSeriesForecast.Delta));
            until TempTimeSeriesForecast.Next() = 0;
    end;

    procedure NewBaseRecord(ItemNo: Code[20]; NewDate: Date; NewQuantity: Decimal)
    begin
        NewRecord(ItemNo, NewDate, NewQuantity, 0, "Forecast Data"::Base);
    end;

    procedure NewResultRecord(ItemNo: Code[20]; NewDate: Date; NewQuantity: Decimal; NewDelta: Decimal)
    begin
        NewRecord(ItemNo, NewDate, NewQuantity, NewDelta, "Forecast Data"::Result);
    end;

    local procedure NewRecord(ItemNo: Code[20]; NewDate: Date; NewQuantity: Decimal; NewDelta: Decimal; NewForecastData: Option)
    begin
        Init();
        "Item No." := ItemNo;
        Date := NewDate;
        Quantity := NewQuantity;
        Delta := NewDelta;
        "Forecast Data" := NewForecastData;
        Insert(true);
    end;

    local procedure RoundAmount(Amount: Decimal): Decimal
    begin
        exit(Round(Amount, GeneralLedgerSetup."Inv. Rounding Precision (LCY)"));
    end;

    local procedure UpdateVariance()
    begin
        if Quantity = 0 then
            "Variance %" := 0
        else
            "Variance %" := ABS(100 * Delta / Quantity);
    end;
}

