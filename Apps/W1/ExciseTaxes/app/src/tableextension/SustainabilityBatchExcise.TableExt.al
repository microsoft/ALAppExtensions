// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

using Microsoft.Sustainability.ExciseTax;

tableextension 7412 "Sustainability Batch Excise" extends "Sust. Excise Journal Batch"
{
    fields
    {
        field(7412; "Excise Tax Type Filter"; Code[20])
        {
            Caption = 'Excise Tax Type Filter';
            TableRelation = "Excise Tax Type".Code where(Enabled = const(true));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ExciseTaxType: Record "Excise Tax Type";
            begin
                if "Excise Tax Type Filter" <> '' then begin
                    ExciseTaxType.Get("Excise Tax Type Filter");
                    Description := CopyStr(StrSubstNo(TaxBatchDescLbl, ExciseTaxType.Description), 1, MaxStrLen(Description));
                end;
            end;
        }
    }

    var
        TaxTypeMismatchBatchFilterErr: Label 'Tax type %1 does not match batch filter %2', Comment = '%1 = Excise Tax Type Code, %2 = Excise Tax Type Filter Code';
        TaxBatchDescLbl: Label '%1 Tax Batch', Comment = '%1 = Excise Tax Type Description';

    procedure ValidateTaxTypeForBatch(ExciseTaxType: Code[20])
    begin
        if ("Excise Tax Type Filter" <> '') and (ExciseTaxType <> '') and (ExciseTaxType <> "Excise Tax Type Filter") then
            Error(TaxTypeMismatchBatchFilterErr, ExciseTaxType, "Excise Tax Type Filter");
    end;
}