#if CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using Microsoft.Foundation.Company;
using System.Upgrade;

codeunit 10548 "UK Postcode Upgrade"
{
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagUKPostcode: Codeunit "UK Postcode Upg Tag";

    trigger OnUpgradePerCompany()
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        if CurrentModuleInfo.AppVersion().Major() < 31 then
            exit;

        CompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    var
        PostcodeNotificationMemory: Record "Postcode Notification Memory";
        PostcodeNotifMemory: Record "Postcode Notif. Memory";
        PostcodeNotifMemoryDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagUKPostcode.GetUKPostcodeUpgradeTag()) then
            exit;

        PostcodeNotifMemoryDataTransfer.SetTables(Database::"Postcode Notification Memory", Database::"Postcode Notif. Memory");
        PostcodeNotifMemoryDataTransfer.AddFieldValue(PostcodeNotificationMemory.FieldNo(UserId), PostcodeNotifMemory.FieldNo(UserId));
        PostcodeNotifMemoryDataTransfer.CopyRows();

        UpgradeTag.SetUpgradeTag(UpgTagUKPostcode.GetUKPostcodeUpgradeTag());
    end;
}
#endif