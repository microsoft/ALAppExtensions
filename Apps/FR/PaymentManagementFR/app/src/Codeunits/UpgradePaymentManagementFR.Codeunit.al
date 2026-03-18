#if CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.Reflection;
using System.Upgrade;

codeunit 10840 "Upgrade Payment Management FR"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagPayment: Codeunit "Upg. Tag Payment Management FR";

    trigger OnUpgradePerCompany()
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        if CurrentModuleInfo.AppVersion().Major() < 31 then
            exit;

        UpgradePayment();
    end;

    local procedure UpgradePayment()
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagPayment.GetPaymentUpgradeTag()) then
            exit;

        TransferFields(Database::"Bank Account", 10805, 10851); //  10805 - the existing field "Agency Code", 10851 - the new field "Agency Code FR"; 
        TransferFields(Database::"Bank Account", 10806, 10852); // 10806 - the existing field "RIB Key", 10852 - the new field "RIB Key FR"; 
        TransferFields(Database::"Bank Account", 10807, 10853); // 10807 - the existing field "RIB Checked", 10853 - the new field "RIB Checked FR",; 
        TransferFields(Database::"Customer Bank Account", 10805, 10851); // 10805 - the existing field "Agency Code", 10851 - the new field "Agency Code FR",; 
        TransferFields(Database::"Customer Bank Account", 10806, 10852); //, 10806 - the existing field "RIB Key", 10852 - the new field "RIB Key FR"; 
        TransferFields(Database::"Customer Bank Account", 10807, 10853); // 10807 - the existing field "RIB Checked", 10853 - the new field "RIB Checked FR";
        TransferFields(Database::"Vendor Bank Account", 10805, 10851); // 10805 - the existing field "Agency Code", 10851 - the new field "Agency Code FR"; 
        TransferFields(Database::"Vendor Bank Account", 10806, 10852); // 10806 - the existing field "RIB Key", 10852 - the new field "RIB Key FR"; 
        TransferFields(Database::"Vendor Bank Account", 10807, 10853); // 10807 - the existing field "RIB Checked", 10853 - the new field "RIB Checked FR";
        TransferRecords(Database::"Bank Account Buffer", Database::"Bank Account Buffer FR");
        TransferRecords(Database::"Payment Class", Database::"Payment Class FR");
        TransferRecords(Database::"Payment Header", Database::"Payment Header FR");
        TransferRecords(Database::"Payment Header Archive", Database::"Payment Header Archive FR");
        TransferRecords(Database::"Payment Line", Database::"Payment Line FR");
        TransferRecords(Database::"Payment Line Archive", Database::"Payment Line Archive FR");
        TransferRecords(Database::"Payment Post. Buffer", Database::"Payment Post. Buffer FR");
        TransferRecords(Database::"Payment Status", Database::"Payment Status FR");
        TransferRecords(Database::"Payment Step", Database::"Payment Step FR");
        TransferRecords(Database::"Payment Step Ledger", Database::"Payment Step Ledger FR");
        TransferRecords(Database::"Payment Address", Database::"Payment Address FR");

        UpgradeTag.SetUpgradeTag(UpgTagPayment.GetPaymentUpgradeTag());
    end;

    procedure TransferRecords(SourceTableId: Integer; TargetTableId: Integer)
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

    procedure TransferFields(TableId: Integer; SourceFieldNo: Integer; TargetFieldNo: Integer)
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