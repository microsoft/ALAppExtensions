// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

table 7412 "Excise Tax Type"
{
    Caption = 'Excise Tax Type';
    DataClassification = CustomerContent;
    LookupPageId = "Excise Tax Types";
    DrillDownPageId = "Excise Tax Types";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Tax Basis"; Enum "Excise Tax Basis")
        {
            Caption = 'Tax Basis';
        }
        field(4; Enabled; Boolean)
        {
            Caption = 'Enabled';
        }
        field(5; "Report Caption"; Text[50])
        {
            Caption = 'Report Caption';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        ExciseTaxEntryPermission: Record "Excise Tax Entry Permission";
        ExciseTaxItemFARate: Record "Excise Tax Item/FA Rate";
    begin
        ExciseTaxEntryPermission.SetRange("Excise Tax Type Code", Code);
        if not ExciseTaxEntryPermission.IsEmpty() then
            Error(CannotDeleteTaxTypeWithRateConfigurationsErr, Code, ExciseTaxEntryPermission.TableCaption());

        ExciseTaxItemFARate.SetRange("Excise Tax Type Code", Code);
        if not ExciseTaxItemFARate.IsEmpty() then
            Error(CannotDeleteTaxTypeWithRateConfigurationsErr, Code, ExciseTaxItemFARate.TableCaption());
    end;

    var
        CannotDeleteTaxTypeWithRateConfigurationsErr: Label 'Cannot delete tax type %1 because it has rate %2 entries.', Comment = '%1 = Excise Tax Type Code, %2 = Table Caption';
}