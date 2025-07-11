namespace Microsoft.Inventory.InventoryForecast;

using System.Upgrade;
using System.Threading;

// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1851 "Sales Forecast Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        ModuleInfo: ModuleInfo;
    begin
        if NavApp.GetCurrentModuleInfo(ModuleInfo) then
            SetConsentIfForecastAlreadyScheduled();
    end;

    local procedure SetConsentIfForecastAlreadyScheduled()
    var
        SalesForecastSetup: Record "MS - Sales Forecast Setup";
        JobQueueEntry: Record "Job Queue Entry";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetForecastCustomerConsentTag(), '') then
            exit;

        if UpgradeTag.HasUpgradeTag(GetForecastCustomerConsentTag()) then
            exit;

        if SalesForecastSetup.Get() then
            if not SalesForecastSetup.Enabled then begin
                JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
                JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Sales Forecast Update");
                if not JobQueueEntry.IsEmpty() then begin
                    SalesForecastSetup.Enabled := true;
                    SalesForecastSetup.Modify();
                end;
            end;

        UpgradeTag.SetUpgradeTag(GetForecastCustomerConsentTag());
    end;

    internal procedure GetForecastCustomerConsentTag(): Code[250]
    begin
        exit('MS-474737-SalesForecastCustomerConsent-20230607');
    end;

}

