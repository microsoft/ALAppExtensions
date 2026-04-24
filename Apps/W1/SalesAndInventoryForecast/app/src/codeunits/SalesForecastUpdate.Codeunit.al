// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.InventoryForecast;

using Microsoft.Inventory.Item;
using System.AI;
using System.Environment;

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
        MSSalesForecastSetup.CheckEnabled();
        if MSSalesForecastSetup.URIOrKeyEmpty() then
            exit;

        OriginalWorkDate := WorkDate();
        WorkDate := LogInManagement.GetDefaultWorkDate();

        if Item.FindSet() then
            repeat
                if not TryCalculateForecast(SalesForecastHandler, Item, TimeSeriesManagement) then
                    Session.LogMessage('0000TBO', ForecastFailedLbl, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', 'Sales & Inventory Forecast');
            until Item.Next() = 0;

        WorkDate := OriginalWorkDate;

        UpdateLastRunCompleted();
    end;

    [TryFunction]
    local procedure TryCalculateForecast(var SalesForecastHandler: Codeunit "Sales Forecast Handler"; var Item: Record Item; var TimeSeriesManagement: Codeunit "Time Series Management")
    begin
        if SalesForecastHandler.CalculateForecast(Item, TimeSeriesManagement) then;
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

    var
        ForecastFailedLbl: Label 'Sales forecast calculation failed.', Locked = true;
}

