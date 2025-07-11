#if not CLEAN25
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using System.Environment;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Account;
using System.Upgrade;
using System.Reflection;

codeunit 4854 "Upgrade Auto. Acc. Codes"
{
    ObsoleteReason = 'Automatic Acc.functionality is moved to a new app.';
    ObsoleteState = Pending;
#pragma warning disable AS0072
    ObsoleteTag = '25.0';
#pragma warning restore AS0072
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDefAutoAccCodes: Codeunit "Upg. Tag Def. Auto. Acc. Codes";
        Localization: Text;
    begin
        Localization := EnvironmentInformation.GetApplicationFamily();
        if (Localization <> 'SE') and (Localization <> 'FI') then begin
            UpgradeTag.SetUpgradeTag(UpgTagDefAutoAccCodes.GetAutoAccCodesUpgradeTag());
            exit;
        end;

        if UpgradeTag.HasUpgradeTag(UpgTagDefAutoAccCodes.GetAutoAccCodesUpgradeTag()) then
            exit;
        UpgradeAutomaticAccountCodes();
        UpgradeTag.SetUpgradeTag(UpgTagDefAutoAccCodes.GetAutoAccCodesUpgradeTag());
    end;

    local procedure UpgradeAutomaticAccountCodes()
    var
        AutoAccPageSetup: Record "Auto. Acc. Page Setup";
        AutomaticAccHeaderTableId: Integer;
        AutomaticAccLineTableId: Integer;
    begin
        // if there is record in the AutoAccPageSetuptable then the feature is already enabled
        if not AutoAccPageSetup.IsEmpty() then
            exit;

        AutomaticAccHeaderTableId := 11203; // Database::"Automatic Acc. Header";
        AutomaticAccLineTableId := 11204; // Database::"Automatic Acc. Line";
        TransferRecords(AutomaticAccHeaderTableId, Database::"Automatic Account Header");
        TransferRecords(AutomaticAccLineTableId, Database::"Automatic Account Line");
        TransferFields(Database::"G/L Account", 11200, 4850); // 4850 - the new field "Automatic Account Group", 11200;  the existing field  "Auto. Acc. Group"; 
        TransferFields(Database::"Gen. Journal Line", 11201, 4852);// 4852 - the new field "Automatic Account Group", 11201;  the existing field  "Auto. Acc. Group"; 
        TransferFields(Database::"Sales Line", 11200, 4850);   // 4850 - the new field "Automatic Account Group", 11200;  the existing field  "Auto. Acc. Group"; 
        TransferFields(Database::"Purchase Line", 11200, 4850);// 4850 - the new field "Automatic Account Group", 11200;  the existing field  "Auto. Acc. Group"; 

        RemoveAutomaticAccountCodes(AutomaticAccHeaderTableId);
        RemoveAutomaticAccountCodes(AutomaticAccLineTableId);
    end;

    local procedure RemoveAutomaticAccountCodes(TableId: Integer)
    var
        RecordRef: RecordRef;
    begin
        if TableId = 0 then
            exit;
        RecordRef.Open(TableId, false);
        RecordRef.DeleteAll();
        RecordRef.Close();
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