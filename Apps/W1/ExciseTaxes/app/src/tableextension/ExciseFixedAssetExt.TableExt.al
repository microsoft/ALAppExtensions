// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.UOM;

tableextension 7418 "Excise Fixed Asset Ext" extends "Fixed Asset"
{
    fields
    {
        field(7412; "Excise Tax Type"; Code[20])
        {
            Caption = 'Excise Tax Type';
            TableRelation = "Excise Tax Type".Code where(Enabled = const(true));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ExciseTaxType: Record "Excise Tax Type";
            begin
                if "Excise Tax Type" <> '' then begin
                    ExciseTaxType.Get("Excise Tax Type");
                    if not ExciseTaxType.Enabled then
                        Error(ExciseTaxTypeNotEnabledErr, "Excise Tax Type");

                    if Rec."Excise Tax Type" <> xRec."Excise Tax Type" then begin
                        Rec.TestField("Quantity for Excise Tax", 0);
                        Rec.TestField("Excise Unit of Measure Code", '');
                    end;

                end else begin
                    "Quantity for Excise Tax" := 0;
                    "Excise Unit of Measure Code" := '';
                end;
            end;
        }

        field(7413; "Quantity for Excise Tax"; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Quantity for Excise Tax';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Quantity for Excise Tax" <> 0) and ("Excise Tax Type" = '') then
                    Error(MustSpecifyExciseTaxTypeForQuantityErr);
            end;
        }

        field(7414; "Excise Unit of Measure Code"; Code[10])
        {
            Caption = 'Excise Tax Unit of Measure';
            TableRelation = "Unit of Measure".Code;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Excise Unit of Measure Code" <> '') and ("Excise Tax Type" = '') then
                    Error(MustSpecifyExciseTaxTypeForUOMErr);
            end;
        }
    }

    var
        ExciseTaxTypeNotEnabledErr: Label 'Excise tax type %1 is not enabled.', Comment = '%1 = Excise Tax Type Code';
        MustSpecifyExciseTaxTypeForQuantityErr: Label 'You must specify an Excise Tax Type before entering a quantity.';
        MustSpecifyExciseTaxTypeForUOMErr: Label 'You must specify an Excise Tax Type before entering a UOM.';

}