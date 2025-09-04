// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.EPR;

using Microsoft.Foundation.UOM;
using Microsoft.Sustainability.Setup;

table 6237 "Sust. Item Mat. Comp. Line"
{
    Caption = 'Item Material Composition Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item Material Composition No."; Code[20])
        {
            Caption = 'Item Material Composition No.';
            NotBlank = true;
            TableRelation = "Sust. Item Mat. Comp. Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; "Material Type No."; Code[20])
        {
            Caption = 'Material Type No.';
            TableRelation = "Sustainability EPR Material"."No.";

            trigger OnValidate()
            var
                EPRMaterial: Record "Sustainability EPR Material";
            begin
                if EPRMaterial.Get("Material Type No.") then begin
                    Description := EPRMaterial.Description;
                    "Unit of Measure Code" := EPRMaterial."Unit of Measure Code";
                    "EPR Fee Rate" := EPRMaterial."EPR Fee Rate";
                end else
                    ClearEPRMaterialInformation();
            end;
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(12; Weight; Decimal)
        {
            Caption = 'Weight';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));

            trigger OnValidate()
            begin
                if Rec.Weight <> 0 then
                    TestField("Material Type No.");
            end;
        }
        field(13; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Unit of Measure".Code;

            trigger OnValidate()
            begin
                if Rec."Unit of Measure Code" <> '' then
                    TestField("Material Type No.");
            end;
        }
        field(14; "EPR Fee Rate"; Decimal)
        {
            Caption = 'EPR Fee Rate';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));

            trigger OnValidate()
            begin
                if Rec."EPR Fee Rate" <> 0 then
                    TestField("Material Type No.");
            end;
        }
        field(15; "Collection Fee"; Decimal)
        {
            Caption = 'Collection Fee';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));

            trigger OnValidate()
            begin
                if Rec."Collection Fee" <> 0 then
                    TestField("Material Type No.");
            end;
        }
        field(16; "Sorting Fee"; Decimal)
        {
            Caption = 'Sorting Fee';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));

            trigger OnValidate()
            begin
                if Rec."Sorting Fee" <> 0 then
                    TestField("Material Type No.");
            end;
        }
        field(17; "Admin Fee"; Decimal)
        {
            Caption = 'Admin Fee';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));

            trigger OnValidate()
            begin
                if Rec."Admin Fee" <> 0 then
                    TestField("Material Type No.");
            end;
        }
        field(18; "Environ. Fee"; Decimal)
        {
            Caption = 'Environ. Fee';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));

            trigger OnValidate()
            begin
                if Rec."Environ. Fee" <> 0 then
                    TestField("Material Type No.");
            end;
        }
    }
    keys
    {
        key(Key1; "Item Material Composition No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        TestStatus();
    end;

    trigger OnInsert()
    begin
        TestStatus();
    end;

    trigger OnModify()
    begin
        TestStatus();
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        ItemMaterialCompositionHeader: Record "Sust. Item Mat. Comp. Header";

    procedure TestStatus()
    begin
        if IsTemporary then
            exit;

        ItemMaterialCompositionHeader.Get("Item Material Composition No.");
        if ItemMaterialCompositionHeader.Status = ItemMaterialCompositionHeader.Status::Certified then
            ItemMaterialCompositionHeader.FieldError(Status);
    end;

    local procedure ClearEPRMaterialInformation()
    begin
        Rec.Description := '';
        Rec."EPR Fee Rate" := 0;
        Rec.Weight := 0;
        Rec."Unit of Measure Code" := '';
        Rec."Collection Fee" := 0;
        Rec."Sorting Fee" := 0;
        Rec."Admin Fee" := 0;
        Rec."Environ. Fee" := 0;
    end;
}