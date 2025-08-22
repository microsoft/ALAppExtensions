// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.EPR;

using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Sustainability.Setup;

table 6236 "Sust. Item Mat. Comp. Header"
{
    Caption = 'Item Material Composition Header';
    DataCaptionFields = "No.", Description;
    DrillDownPageID = "Sust. Item Mat. Comp. List";
    LookupPageID = "Sust. Item Mat. Comp. List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(21; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            var
                Item: Record Item;
                ItemUnitOfMeasure: Record "Item Unit of Measure";
            begin
                if Status = Status::Certified then
                    FieldError(Status);

                Item.SetCurrentKey("Material Composition No.");
                Item.SetRange("Material Composition No.", "No.");
                if Item.FindSet() then
                    repeat
                        ItemUnitOfMeasure.Get(Item."No.", "Unit of Measure Code");
                    until Item.Next() = 0;
            end;
        }
        field(40; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            Editable = false;
        }
        field(43; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(45; Status; Enum "Sust. Item Mat. Comp. Status")
        {
            Caption = 'Status';
        }
        field(51; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, Status)
        {
        }
    }

    trigger OnDelete()
    var
        Item: Record Item;
    begin
        Item.SetRange("Material Composition No.", "No.");
        if not Item.IsEmpty() then
            Error(ItemMaterialCompositionIsAlreadyBeingUsedOnItemsErr);

        ItemMaterialCompositionLine.SetRange("Item Material Composition No.", "No.");
        ItemMaterialCompositionLine.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        SustainabilitySetup.Get();
        if "No." = '' then begin
            SustainabilitySetup.TestField("Item Material Composition Nos.");
            if NoSeries.AreRelated(SustainabilitySetup."Item Material Composition Nos.", xRec."No. Series") then
                "No. Series" := xRec."No. Series"
            else
                "No. Series" := SustainabilitySetup."Item Material Composition Nos.";
            "No." := NoSeries.GetNextNo("No. Series");
        end;

        "Creation Date" := Today;
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;
    end;

    trigger OnRename()
    begin
        if Status = Status::Certified then
            Error(CannotRenameItemMaterialCompErr, TableCaption(), FieldCaption(Status), Format(Status));
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        ItemMaterialCompositionHeader: Record "Sust. Item Mat. Comp. Header";
        ItemMaterialCompositionLine: Record "Sust. Item Mat. Comp. Line";
        ItemMaterialCompositionIsAlreadyBeingUsedOnItemsErr: Label 'This Item Material Composition is being used on Items.';
        CannotRenameItemMaterialCompErr: Label 'You cannot rename the %1 when %2 is %3.', Comment = '%1 = Table Caption , %2 = Field Caption , %3 = Status';

    procedure AssistEdit(OldItemMatCompHeader: Record "Sust. Item Mat. Comp. Header"): Boolean
    var
        NoSeries: Codeunit "No. Series";
    begin
        ItemMaterialCompositionHeader := Rec;
        SustainabilitySetup.Get();
        SustainabilitySetup.TestField("Item Material Composition Nos.");
        if NoSeries.LookupRelatedNoSeries(SustainabilitySetup."Item Material Composition Nos.", OldItemMatCompHeader."No. Series", ItemMaterialCompositionHeader."No. Series") then begin
            ItemMaterialCompositionHeader."No." := NoSeries.GetNextNo(ItemMaterialCompositionHeader."No. Series");
            Rec := ItemMaterialCompositionHeader;
            exit(true);
        end;
    end;

    procedure ItemMaterialCompositionExist(): Boolean
    var
        ItemMatCompLine: Record "Sust. Item Mat. Comp. Line";
    begin
        ItemMatCompLine.SetRange("Item Material Composition No.", Rec."No.");
        exit(not ItemMatCompLine.IsEmpty());
    end;
}