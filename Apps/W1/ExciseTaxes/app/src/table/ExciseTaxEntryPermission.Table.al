// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

table 7414 "Excise Tax Entry Permission"
{
    Caption = 'Excise Tax Entry Permission';
    DataClassification = CustomerContent;
    LookupPageId = "Excise Tax Entry Permissions";
    DrillDownPageId = "Excise Tax Entry Permissions";

    fields
    {
        field(1; "Excise Tax Type Code"; Code[20])
        {
            Caption = 'Excise Tax Type Code';
            TableRelation = "Excise Tax Type".Code;
            NotBlank = true;
        }
        field(2; "Excise Entry Type"; Enum "Excise Entry Type")
        {
            Caption = 'Excise Entry Type';
            NotBlank = true;
        }
        field(3; Allowed; Boolean)
        {
            Caption = 'Allowed';
        }
    }

    keys
    {
        key(Key1; "Excise Tax Type Code", "Excise Entry Type")
        {
            Clustered = true;
        }
        key(Key2; "Excise Tax Type Code")
        {
        }
        key(Key3; "Excise Entry Type")
        {
        }
    }

    procedure IsEntryTypeAllowed(TaxTypeCode: Code[20]; EntryType: Enum "Excise Entry Type"): Boolean
    var
        ExciseTaxEntryPermission: Record "Excise Tax Entry Permission";
    begin
        ExciseTaxEntryPermission.SetRange("Excise Tax Type Code", TaxTypeCode);
        ExciseTaxEntryPermission.SetRange("Excise Entry Type", EntryType);
        ExciseTaxEntryPermission.SetRange(Allowed, true);
        exit(not ExciseTaxEntryPermission.IsEmpty());
    end;

    procedure GetAllowedEntryTypes(TaxTypeCode: Code[20]; var TempExciseEntryType: Record "Excise Tax Entry Permission" temporary)
    var
        ExciseTaxEntryPermission: Record "Excise Tax Entry Permission";
    begin
        TempExciseEntryType.Reset();
        TempExciseEntryType.DeleteAll();

        ExciseTaxEntryPermission.SetRange("Excise Tax Type Code", TaxTypeCode);
        ExciseTaxEntryPermission.SetRange(Allowed, true);
        if ExciseTaxEntryPermission.FindSet() then
            repeat
                TempExciseEntryType := ExciseTaxEntryPermission;
                TempExciseEntryType.Insert();
            until ExciseTaxEntryPermission.Next() = 0;
    end;

    procedure SetDefaultPermissions(TaxTypeCode: Code[20])
    begin
        CreatePermissionRecord(TaxTypeCode, "Excise Entry Type"::Purchase);
        CreatePermissionRecord(TaxTypeCode, "Excise Entry Type"::Sale);
        CreatePermissionRecord(TaxTypeCode, "Excise Entry Type"::"Positive Adjmt.");
        CreatePermissionRecord(TaxTypeCode, "Excise Entry Type"::"Negative Adjmt.");
        CreatePermissionRecord(TaxTypeCode, "Excise Entry Type"::Output);
        CreatePermissionRecord(TaxTypeCode, "Excise Entry Type"::"Assembly Output");
    end;

    local procedure CreatePermissionRecord(TaxTypeCode: Code[20]; EntryType: Enum "Excise Entry Type")
    begin
        if Rec.Get(TaxTypeCode, EntryType) then
            exit;

        Rec.Init();
        Rec."Excise Tax Type Code" := TaxTypeCode;
        Rec."Excise Entry Type" := EntryType;
        Rec.Insert(true);
    end;
}