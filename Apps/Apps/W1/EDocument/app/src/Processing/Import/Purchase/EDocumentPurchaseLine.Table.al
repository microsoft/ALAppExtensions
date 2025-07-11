// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import.Purchase;

using Microsoft.eServices.EDocument;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.Deferral;
using Microsoft.Foundation.UOM;
using Microsoft.Utilities;
using Microsoft.Purchases.Document;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Item;
using Microsoft.Finance.AllocationAccount;
using Microsoft.Projects.Resources.Resource;
using Microsoft.eServices.EDocument.Processing.Import;
using System.Reflection;
using Microsoft.Purchases.History;
using Microsoft.Inventory.Item.Catalog;

table 6101 "E-Document Purchase Line"
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;

    fields
    {

        field(1; "E-Document Entry No."; Integer)
        {
            Caption = 'E-Document Entry No.';
            TableRelation = "E-Document"."Entry No";
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        #region External data - Purchase fields [3-100]
        field(3; "Date"; Date)
        {
            Caption = 'Date';
            Editable = false;
        }
        field(4; "Product Code"; Text[100])
        {
            Caption = 'Product Code';
            Editable = false;
        }
        field(5; "Description"; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description.';
            Editable = false;
        }
        field(6; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            ToolTip = 'Specifies the quantity.';
            Editable = false;
        }
        field(7; "Unit of Measure"; Text[50])
        {
            Caption = 'Unit of Measure';
            Editable = false;
        }
        field(8; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            ToolTip = 'Specifies the direct unit cost.';
            Editable = false;
        }
        field(9; "Sub Total"; Decimal)
        {
            Caption = 'Sub Total';
        }
        field(10; "Total Discount"; Decimal)
        {
            Caption = 'Total Discount';
            ToolTip = 'Specifies the line discount.';
        }
        field(11; "VAT Rate"; Decimal)
        {
            Caption = 'VAT Rate';
            Editable = false;
        }
        field(12; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
        }
        #endregion Purchase fields

        #region Business Central Data - Validated fields [101-200]
        field(101; "[BC] Purchase Line Type"; Enum "Purchase Line Type")
        {
            Caption = 'Type';
            ToolTip = 'Specifies the type of entity that will be posted for this purchase line, such as Item, Resource, or G/L Account.';
        }
        field(102; "[BC] Purchase Type No."; Code[20])
        {
            Caption = 'No.';
            ToolTip = 'Specifies what you''re selling. The options vary, depending on what you choose in the Type field.';
            TableRelation = if ("[BC] Purchase Line Type" = const(" ")) "Standard Text"
            else
            if ("[BC] Purchase Line Type" = const("G/L Account")) "G/L Account"
            else
            if ("[BC] Purchase Line Type" = const("Fixed Asset")) "Fixed Asset"
            else
            if ("[BC] Purchase Line Type" = const("Charge (Item)")) "Item Charge"
            else
            if ("[BC] Purchase Line Type" = const(Item)) Item
            else
            if ("[BC] Purchase Line Type" = const("Allocation Account")) "Allocation Account"
            else
            if ("[BC] Purchase Line Type" = const(Resource)) Resource;

            trigger OnValidate()
            begin
                ValidateNoField();
            end;
        }
        field(103; "[BC] Unit of Measure"; Code[20])
        {
            Caption = 'Unit of Measure';
            ToolTip = 'Specifies the unit of measure code.';
            TableRelation = "Unit of Measure";
        }
        field(104; "[BC] Deferral Code"; Code[10])
        {
            Caption = 'Deferral Code';
            ToolTip = 'Specifies the deferral code.';
            TableRelation = "Deferral Template";
        }
        field(105; "[BC] Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));


        }
        field(106; "[BC] Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));
        }
        field(107; "[BC] Item Reference No."; Code[20])
        {
            Caption = 'Item Reference No.';
            ToolTip = 'Specifies the item reference number.';
            TableRelation = "Item Reference"."Reference No." where("Unit of Measure" = field("[BC] Unit of Measure"), "Variant Code" = field("[BC] Variant Code"));
        }
        field(108; "[BC] Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            ToolTip = 'Specifies the variant code.';
            TableRelation = "Item Variant".Code where("Item No." = field("[BC] Purchase Type No."));
        }
        field(109; "[BC] Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                Rec.LookupDimensions();
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("[BC] Dimension Set ID", "[BC] Shortcut Dimension 1 Code", "[BC] Shortcut Dimension 2 Code");
            end;
        }
        #endregion Validated fields

        #region Metadata fields [201-300]
        field(201; "E-Doc. Purch. Line History Id"; Integer)
        {
            Caption = 'E-Doc. Purch. Line History Id';
            ToolTip = 'Specifies the ID of the e-document purchase line history.';
            TableRelation = "E-Doc. Purchase Line History"."Entry No.";
            DataClassification = SystemMetadata;
        }
        #endregion Metadata fields
    }
    keys
    {
        key(PK; "E-Document Entry No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key1; "[BC] Purchase Type No.")
        {
        }
    }

    var
        DimMgt: Codeunit DimensionManagement;

    local procedure ValidateNoField()
    var
        Item: Record Item;
        GLAccount: Record "G/L Account";
        AllocationAccount: Record "Allocation Account";
        FixedAsset: Record "Fixed Asset";
        Resource: Record Resource;
        ItemCharge: Record "Item Charge";
    begin
        if Rec.Description <> '' then
            exit;

        case Rec."[BC] Purchase Line Type" of
            "Purchase Line Type"::Item:
                if Item.Get(Rec."[BC] Purchase Type No.") then
                    Rec.Description := Item.Description;
            "Purchase Line Type"::"G/L Account":
                if GLAccount.Get(Rec."[BC] Purchase Type No.") then
                    Rec.Description := GLAccount.Name;
            "Purchase Line Type"::"Allocation Account":
                if AllocationAccount.Get(Rec."[BC] Purchase Type No.") then
                    Rec.Description := AllocationAccount.Name;
            "Purchase Line Type"::"Fixed Asset":
                if FixedAsset.Get(Rec."[BC] Purchase Type No.") then
                    Rec.Description := FixedAsset.Description;
            "Purchase Line Type"::Resource:
                if Resource.Get(Rec."[BC] Purchase Type No.") then
                    Rec.Description := Resource.Name;
            "Purchase Line Type"::"Charge (Item)":
                if ItemCharge.Get(Rec."[BC] Purchase Type No.") then
                    Rec.Description := ItemCharge.Description;
        end;
    end;

    internal procedure GetNextLineNo(EDocumentEntryNo: Integer): Integer
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
    begin
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocumentEntryNo);
        if EDocumentPurchaseLine.FindLast() then
            exit(EDocumentPurchaseLine."Line No." + 10000);
        exit(10000);
    end;

    /// <summary>
    /// Returns any additional columns defined for this line in a human-readable format.
    /// </summary>
    /// <returns></returns>
    internal procedure AdditionalColumnsDisplayText() AdditionalColumns: Text
    var
        EDocPurchLineFieldSetup: Record "ED Purchase Line Field Setup";
        EDocPurchLineField: Record "E-Document Line - Field";
        Field: Record Field;
        AdditionalColumnValue: Text;
    begin
        if not EDocPurchLineFieldSetup.FindSet() then
            exit;
        repeat
            if Field.Get(Database::"Purch. Inv. Line", EDocPurchLineFieldSetup."Field No.") then;
            if AdditionalColumns <> '' then
                AdditionalColumns += ', ';
            AdditionalColumns += Field.FieldName;
            AdditionalColumns += ': ';
            EDocPurchLineField.Get(Rec, EDocPurchLineFieldSetup);
            AdditionalColumnValue := EDocPurchLineField.GetValueAsText();
            if AdditionalColumnValue = '' then
                AdditionalColumnValue := '-';
            AdditionalColumns += AdditionalColumnValue;
        until EDocPurchLineFieldSetup.Next() = 0;
    end;

    internal procedure LookupDimensions(): Boolean
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "[BC] Dimension Set ID";
        "[BC] Dimension Set ID" := DimMgt.EditDimensionSet(
            Rec, "[BC] Dimension Set ID", StrSubstNo('%1 %2', "E-Document Entry No.", "Line No."),
            "[BC] Shortcut Dimension 1 Code", "[BC] Shortcut Dimension 2 Code");
        DimMgt.UpdateGlobalDimFromDimSetID("[BC] Dimension Set ID", "[BC] Shortcut Dimension 1 Code", "[BC] Shortcut Dimension 2 Code");
        exit(OldDimSetID <> "[BC] Dimension Set ID");
    end;

}