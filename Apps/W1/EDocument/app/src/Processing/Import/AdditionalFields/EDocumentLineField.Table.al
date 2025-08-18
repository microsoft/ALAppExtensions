// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.Purchases.History;
using System.Reflection;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.eServices.EDocument;

table 6110 "E-Document Line - Field"
{
    Caption = 'E-Document Line Field';
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    Access = Internal;
    ReplicateData = false;

    fields
    {
        field(1; "E-Document Entry No."; Integer)
        {
            Caption = 'E-Document Entry No.';
            ToolTip = 'Specifies the entry number of the e-document.';
            TableRelation = "E-Document"."Entry No";
            DataClassification = SystemMetadata;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            ToolTip = 'Specifies the line number.';
            DataClassification = SystemMetadata;
        }
        field(3; "Field No."; Integer)
        {
            Caption = 'Field No.';
            ToolTip = 'Specifies the field number.';
            DataClassification = SystemMetadata;
        }
        field(4; "Text Value"; Text[2048])
        {
            Caption = 'Custom Text Value';
            ToolTip = 'Specifies the custom text value.';
            DataClassification = CustomerContent;
        }
        field(5; "Decimal Value"; Decimal)
        {
            Caption = 'Custom Decimal Value';
            ToolTip = 'Specifies the custom decimal value.';
            DataClassification = CustomerContent;
        }
        field(6; "Date Value"; Date)
        {
            Caption = 'Custom Date Value';
            ToolTip = 'Specifies the custom date value.';
            DataClassification = CustomerContent;
        }
        field(7; "Boolean Value"; Boolean)
        {
            Caption = 'Custom Boolean Value';
            ToolTip = 'Specifies the custom boolean value.';
            DataClassification = CustomerContent;
        }
        field(8; "Code Value"; Code[2048])
        {
            Caption = 'Custom Code Value';
            ToolTip = 'Specifies the custom code value.';
            DataClassification = CustomerContent;
        }
        field(9; "Integer Value"; Integer)
        {
            Caption = 'Custom Integer Value';
            ToolTip = 'Specifies the custom integer value.';
            DataClassification = CustomerContent;
        }
        field(10; "E-Document Service"; Code[20])
        {
            Caption = 'E-Document Service';
            ToolTip = 'Specifies the E-Document Service that this field setup belongs to.';
            FieldClass = FlowField;
            CalcFormula = lookup("E-Document".Service where("Entry No" = field("E-Document Entry No.")));
        }
    }
    keys
    {
        key(PK; "E-Document Entry No.", "Line No.", "Field No.")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Sets the current record to have the values corresponding to the line for a given purchase invoice line field
    /// if there is no existing customization of the historic values (a physical record of this table) it loads the appropriate values from history.
    /// The history is loaded according to the EDocumentLineMapping's "Line History Id" field.
    ///
    /// This procedure should not fail, default or blank values should be provided instead.
    /// </summary>
    /// <param name="EDocumentLineMapping">The draft line that will get its' value loaded</param>
    /// <param name="PurchaseLineFieldSetup:">The Purchase Invoice Line field that we want to load</param>
    /// <returns>The source that was used to load the values, Customized, Historic or Default</returns>
    procedure Get(EDocumentPurchaseLine: Record "E-Document Purchase Line"; PurchaseLineFieldSetup: Record "ED Purchase Line Field Setup") Source: Option Customized,Historic,Default
    var
        EDocPurchaseLineHistory: Record "E-Doc. Purchase Line History";
        PurchaseInvoiceLineRecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        // We start from a clean record
        Clear(Rec);
        // If a physical record exists, we load it and exit with source Customized
        if Rec.Get(EDocumentPurchaseLine."E-Document Entry No.", EDocumentPurchaseLine."Line No.", PurchaseLineFieldSetup."Field No.") then
            exit(Source::Customized);
        // If there is no physical record, we prepare the record fields that correspond to the arguments and the default configuration of the fields
        Rec."E-Document Entry No." := EDocumentPurchaseLine."E-Document Entry No.";
        Rec."Line No." := EDocumentPurchaseLine."Line No.";
        Rec."Field No." := PurchaseLineFieldSetup."Field No.";
        // We check if there are any values to load from history, if not we exit with source Default
        if not EDocPurchaseLineHistory.Get(EDocumentPurchaseLine."E-Doc. Purch. Line History Id") then
            exit(Source::Default);
        PurchaseInvoiceLineRecordRef.Open(Database::"Purch. Inv. Line");
        if not PurchaseInvoiceLineRecordRef.GetBySystemId(EDocPurchaseLineHistory."Purch. Inv. Line SystemId") then
            exit(Source::Default);
        // We load the values from history and exit with source Historic
        FieldRef := PurchaseInvoiceLineRecordRef.Field(PurchaseLineFieldSetup."Field No.");
        case FieldRef.Type of
            FieldRef.Type::Text:
                Rec."Text Value" := FieldRef.Value();
            FieldRef.Type::Decimal:
                Rec."Decimal Value" := FieldRef.Value();
            FieldRef.Type::Date:
                Rec."Date Value" := FieldRef.Value();
            FieldRef.Type::Boolean:
                Rec."Boolean Value" := FieldRef.Value();
            FieldRef.Type::Code:
                Rec."Code Value" := FieldRef.Value();
        end;
        exit(Source::Historic);
    end;

    procedure GetValue() Result: Variant
    var
        Field: Record Field;
    begin
        if not Field.Get(Database::"Purch. Inv. Line", Rec."Field No.") then
            exit;
        case Field.Type of
            Field.Type::Text:
                exit(Rec."Text Value");
            Field.Type::Decimal:
                exit(Rec."Decimal Value");
            Field.Type::Date:
                exit(Rec."Date Value");
            Field.Type::Boolean:
                exit(Rec."Boolean Value");
            Field.Type::Code:
                exit(Rec."Code Value");
            Field.Type::Integer:
                exit(Rec."Integer Value");
            Field.Type::Option:
                exit(Rec."Integer Value");
        end;
    end;

    procedure InsertOrModify()
    var
        EDocument: Record "E-Document";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        Field: Record Field;
    begin
        if not EDocument.Get(Rec."E-Document Entry No.") then
            exit;
        if not EDocumentPurchaseLine.Get(Rec."E-Document Entry No.", Rec."Line No.") then
            exit;
        if not Field.Get(Database::"Purch. Inv. Line", Rec."Field No.") then
            exit;
        if IsNullGuid(Rec.SystemId) then
            Rec.Insert()
        else
            Rec.Modify();
    end;

    procedure GetValueAsText(): Text
    var
        Field: Record Field;
        RecordRef: RecordRef;
        EnumValue: Integer;
    begin
        if not Field.Get(Database::"Purch. Inv. Line", Rec."Field No.") then
            exit('');
        if Field.Type <> Field.Type::Option then
            exit(Format(GetValue()));
        EnumValue := GetValue();
        RecordRef.Open(Database::"Purch. Inv. Line");
        exit(RecordRef.Field(Rec."Field No.").GetEnumValueCaptionFromOrdinalValue(EnumValue));
    end;

    procedure HasCustomizedRecords(EDocumentPurchaseLine: Record "E-Document Purchase Line"): Boolean
    begin
        Clear(Rec);
        FilterForEDocumentLineMapping(EDocumentPurchaseLine);
        exit(not Rec.IsEmpty());
    end;

    procedure DeleteCustomizedRecords(EDocumentPurchaseLine: Record "E-Document Purchase Line")
    begin
        Clear(Rec);
        FilterForEDocumentLineMapping(EDocumentPurchaseLine);
        Rec.DeleteAll();
    end;

    local procedure FilterForEDocumentLineMapping(EDocumentPurchaseLine: Record "E-Document Purchase Line")
    begin
        Rec.SetRange("E-Document Entry No.", EDocumentPurchaseLine."E-Document Entry No.");
        Rec.SetRange("Line No.", EDocumentPurchaseLine."Line No.");
    end;

}