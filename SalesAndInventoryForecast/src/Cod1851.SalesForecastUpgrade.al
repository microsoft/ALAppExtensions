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
            if ModuleInfo.DataVersion().Major() = 1 then begin
                // we are upgrading from version 1.?.?.? to version 2.?.?.?
                NavApp.RestoreArchiveData(Database::"MS - Sales Forecast");
                NavApp.RestoreArchiveData(Database::"MS - Sales Forecast Parameter");
                NavApp.RestoreArchiveData(Database::"MS - Sales Forecast Setup");
                // The "Has Sales Forecast" field on the item table is populated through triggers on request and does never persist any data.
                NavApp.DeleteArchiveData(Database::Item);
            end;
    end;
}

