#if CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.Foundation.Company;
using System.Upgrade;

codeunit 10587 "Upgrade GovTalk"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagGovTalk: Codeunit "Upg. Tag GovTalk";

    trigger OnUpgradePerCompany()
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        if CurrentModuleInfo.AppVersion().Major() < 30 then
            exit;

        UpgradeGovTalk();
    end;

    local procedure UpgradeGovTalk()
    var
        GovTalkHelperProcedures: Codeunit "GovTalk Helper Procedures";
        GovTalkMessageTableId: Integer;
        GovTalkMessagePartsTableId: Integer;
        GovTalkSetupTableId: Integer;
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagGovTalk.GetGovTalkUpgradeTag()) then
            exit;

        GovTalkHelperProcedures.TransferFields(Database::"Company Information", 10507, 10509); // 10507 - the existing field "Branch Number", 10509 - the new field "Branch Number GB"; 
        GovTalkHelperProcedures.TransferFields(Database::"ECSL VAT Report Line", 10500, 10502); // 10500 - the existing field "Line Status", 10502 - the new field "Line Status GB"; 
        GovTalkHelperProcedures.TransferFields(Database::"ECSL VAT Report Line", 10501, 10503); // 10501 - the existing field "XML Part Id", 10503 - the new field "XML Part Id GB"; 
        GovTalkHelperProcedures.TransferFields(Database::"VAT Reports Configuration", 10500, 10501); // 10500 - the existing field "Content Max Lines", 10501 - the new field "Content Max Lines GB"; 
        GovTalkMessageTableId := 10520;
        GovTalkMessagePartsTableId := 10524;
        GovTalkSetupTableId := 10523;
        GovTalkHelperProcedures.TransferRecords(GovTalkMessageTableId, Database::"GovTalk Message");
        GovTalkHelperProcedures.TransferRecords(GovTalkMessagePartsTableId, Database::"GovTalk Msg. Parts");
        GovTalkHelperProcedures.TransferRecords(GovTalkSetupTableId, Database::"Gov Talk Setup");
        GovTalkHelperProcedures.UpgradeVATReportHeaderStatus();
        GovTalkHelperProcedures.SetDefaultReportLayouts();

        UpgradeTag.SetUpgradeTag(UpgTagGovTalk.GetGovTalkUpgradeTag());
    end;
}
#endif