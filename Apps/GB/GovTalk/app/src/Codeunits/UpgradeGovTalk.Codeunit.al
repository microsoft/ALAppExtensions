#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using System.Upgrade;
using Microsoft.Foundation.Company;
using Microsoft.Finance.VAT.Reporting;
using System.Reflection;

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
        FeatureGovTalk: Codeunit "Feature - GovTalk";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagGovTalk.GetGovTalkUpgradeTag()) then
            exit;

        TransferFields(Database::"Company Information", 10509, 10507); // 10509 - the new field "Branch Number GB", 10507;  the existing field "Branch Number"; 
        TransferFields(Database::"ECSL VAT Report Line", 10502, 10500); // 10502 - the new field "Line Status GB", 10500;  the existing field "Line Status"; 
        TransferFields(Database::"ECSL VAT Report Line", 10503, 10501); // 10503 - the new field "XML Part Id GB", 10501;  the existing field "XML Part Id"; 
        TransferFields(Database::"VAT Reports Configuration", 10501, 10500); // 10501 - the new field "Content Max Lines GB", 10500;  the existing field "Content Max Lines"; 
#pragma warning disable AL0797
        TransferRecords(Database::"GovTalkMessage", Database::"GovTalk Message");
#pragma warning restore AL0797
        TransferRecords(Database::"GovTalk Message Parts", Database::"GovTalk Msg. Parts");
#pragma warning disable AL0797
        TransferRecords(Database::"GovTalk Setup", Database::"Gov Talk Setup");
#pragma warning restore AL0797
        UpgradeVATReportHeaderStatus();
        FeatureGovTalk.SetDefaultReportLayouts();

        UpgradeTag.SetUpgradeTag(UpgTagGovTalk.GetGovTalkUpgradeTag());
    end;

    local procedure TransferRecords(SourceTableId: Integer; TargetTableId: Integer)
    var
        SourceField: Record Field;
        SourceRecRef: RecordRef;
        TargetRecRef: RecordRef;
        TargetFieldRef: FieldRef;
        SourceFieldRef: FieldRef;
        SourceFieldRefNo: Integer;
    begin
        SourceRecRef.Open(SourceTableId, false);
        TargetRecRef.Open(TargetTableId, false);

        if SourceRecRef.IsEmpty() then
            exit;

        SourceRecRef.FindSet();

        repeat
            Clear(SourceField);
            SourceField.SetRange(TableNo, SourceTableId);
            SourceField.SetRange(Class, SourceField.Class::Normal);
            SourceField.SetRange(Enabled, true);
            if SourceField.Findset() then
                repeat
                    SourceFieldRefNo := SourceField."No.";
                    SourceFieldRef := SourceRecRef.Field(SourceFieldRefNo);
                    TargetFieldRef := TargetRecRef.Field(SourceFieldRefNo);
                    TargetFieldRef.VALUE := SourceFieldRef.VALUE;
                until SourceField.Next() = 0;
            TargetRecRef.Insert();
        until SourceRecRef.Next() = 0;
        SourceRecRef.Close();
        TargetRecRef.Close();
    end;

    local procedure UpgradeVATReportHeaderStatus()
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        if VATReportHeader.FindSet() then
            repeat
                if VATReportHeader.Status.AsInteger() = 7 then
                    VATReportHeader.Status := VATReportHeader.Status::"Part. Accepted";
                VATReportHeader.Modify();
            until VATReportHeader.Next() = 0;
    end;

    local procedure TransferFields(TableId: Integer; SourceFieldNo: Integer; TargetFieldNo: Integer)
    var
        RecRef: RecordRef;
        TargetFieldRef: FieldRef;
        SourceFieldRef: FieldRef;
    begin
        RecRef.Open(TableId, false);
        SourceFieldRef := RecRef.Field(SourceFieldNo);
        SourceFieldRef.SetFilter('<>%1', '');

        if RecRef.FindSet() then
            repeat
                TargetFieldRef := RecRef.Field(TargetFieldNo);
                TargetFieldRef.VALUE := SourceFieldRef.VALUE;
                RecRef.Modify(false);
            until RecRef.Next() = 0;
    end;
}
#endif