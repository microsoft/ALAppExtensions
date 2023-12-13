// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using System.Reflection;
using Microsoft.Finance.GeneralLedger.IRS;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Sales.Setup;

codeunit 14611 "Enable IS Core App"
{
    Access = Internal;

    procedure TransferData()
    var
        DepreciationBook: Record "Depreciation Book";
        GLAccount: Record "G/L Account";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        // Transfer records - IRSGroup, IRSNumbers, IRSTypes
        TransferRecords(10901, Database::"IS IRS Groups"); // 10901 = Database::"IRS Groups"
        TransferRecords(10900, Database::"IS IRS Numbers"); // 10900 = Database::"IRS Numbers"
        TransferRecords(10902, Database::"IS IRS Types"); // 10902 = Database::"IRS Types"

        // Copy certain fields within records
        UpdateRecords(Database::"Depreciation Book", 10900, DepreciationBook.FieldNo("Revalue in Year Prch.")); // 10900 = DepreciationBook.FieldNo("Revalue in Year Purch.")
        UpdateRecords(Database::"Depreciation Book", 10901, DepreciationBook.FieldNo("Residual Val. %")); // 10901 = DepreciationBook.FieldNo("Residual Value %")

        UpdateRecords(Database::"G/L Account", 10900, GLAccount.FieldNo("IRS No.")); // 10900 = GLAccount.FieldNo("IRS Number")
        UpdateRecords(Database::"Sales & Receivables Setup", 10901, SalesReceivablesSetup.FieldNo("Electronic Invoicing Reminder")); // 10901 = SalesReceivablesSetup.FieldNo("Electronic Invoicing")
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

    procedure UpdateRecords(SourceTableId: Integer; SourceFieldId: Integer; TargetFieldId: Integer)
    var
        SourceRecRef: RecordRef;
        TargetFieldRef: FieldRef;
        SourceFieldRef: FieldRef;
    begin
        SourceRecRef.Open(SourceTableId, false);
        if SourceRecRef.FieldExist(SourceFieldId) then begin
            SourceRecRef.SetLoadFields(SourceFieldId, TargetFieldId);
            SourceFieldRef := SourceRecRef.Field(SourceFieldId);
            if SourceRecRef.FindSet() then
                repeat
                    SourceFieldRef := SourceRecRef.Field(SourceFieldId);
                    TargetFieldRef := SourceRecRef.Field(TargetFieldId);

                    TargetFieldRef.Value := SourceFieldRef.Value;
                    SourceRecRef.Modify();
                until SourceRecRef.Next() = 0;
        end;
        SourceRecRef.Close();
    end;

    procedure GetISCoreAppUpdateTag(): Code[250]
    begin
        exit('MS-460511-ISCoreApp-20231118');
    end;
}