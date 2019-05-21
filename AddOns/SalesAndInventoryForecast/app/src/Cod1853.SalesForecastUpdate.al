// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1853 "Sales Forecast Update"
{

    trigger OnRun()
    var
        MSSalesForecastSetup: Record "MS - Sales Forecast Setup";
        Item: Record Item;
        LogInManagement: Codeunit LogInManagement;
        SalesForecastHandler: Codeunit "Sales Forecast Handler";
        SalesForecastScheduler: Codeunit "Sales Forecast Scheduler";
        TimeSeriesManagement: Codeunit "Time Series Management";
        OriginalWorkDate: Date;
    begin
        SalesForecastScheduler.RemoveScheduledTaskIfUserInactive();

        MSSalesForecastSetup.GetSingleInstance();
        if MSSalesForecastSetup.URIOrKeyEmpty() then
            exit;

        OriginalWorkDate := WorkDate();
        WorkDate := LogInManagement.GetDefaultWorkDate();

        if Item.FindSet() then
            repeat
                if SalesForecastHandler.CalculateForecast(Item, TimeSeriesManagement) then;
            until Item.Next() = 0;

        WorkDate := OriginalWorkDate;

        UpdateLastRunCompleted();
    end;

    local procedure UpdateLastRunCompleted()
    var
        MSSalesForecastSetup: Record "MS - Sales Forecast Setup";
    begin
        // Retrieving record again, since it was modified by CaluculateForecast call
        MSSalesForecastSetup.GetSingleInstance();
        MSSalesForecastSetup."Last Run Completed" := CurrentDateTime();
        MSSalesForecastSetup.Modify();
    end;
}

