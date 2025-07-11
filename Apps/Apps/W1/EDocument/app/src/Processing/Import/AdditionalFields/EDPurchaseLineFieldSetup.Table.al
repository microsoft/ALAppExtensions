// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.Purchases.History;
using System.Reflection;
using Microsoft.Purchases.Document;
using Microsoft.eServices.EDocument;

table 6112 "ED Purchase Line Field Setup"
{
    Access = Internal;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    ReplicateData = false;

    fields
    {
        field(1; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "E-Document Service"; Code[20])
        {
            Caption = 'E-Document Service';
            ToolTip = 'Specifies the E-Document Service that this field setup belongs to.';
            DataClassification = SystemMetadata;
            TableRelation = "E-Document Service";
        }
    }
    keys
    {
        key(PK; "Field No.", "E-Document Service")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        EDocPurchLineField: Record "E-Document Line - Field";
    begin
        if Rec."Field No." = 0 then
            exit;
        EDocPurchLineField.SetRange("Field No.", Rec."Field No.");
        EDocPurchLineField.SetAutoCalcFields("E-Document Service");
        EDocPurchLineField.SetRange("E-Document Service", Rec."E-Document Service");
        EDocPurchLineField.DeleteAll();
    end;

    /// <summary>
    /// Populates the contents of the temporary table "ED Purchase Line Field Setup" with the fields from the "Purch. Inv. Line" table that can be configured for e-document history.
    /// The fields are loaded with the default configuration if the user has not set up any specific configuration.
    /// </summary>
    /// <param name="EDocPurchLineFieldSetup"></param>
    procedure AllPurchaseLineFields(EDocumentService: Record "E-Document Service"; var EDocPurchLineFieldSetup: Record "ED Purchase Line Field Setup" temporary)
    var
        PersistedEDocPurchLineFieldSetup: Record "ED Purchase Line Field Setup";
        PurchaseInvoiceLineField: Record Field;
        PurchaseLineField: Record Field;
    begin
        EDocPurchLineFieldSetup.DeleteAll();
        PurchaseInvoiceLineField.SetRange(TableNo, Database::"Purch. Inv. Line");
        PurchaseInvoiceLineField.SetFilter(ObsoleteState, '<> %1', PurchaseInvoiceLineField.ObsoleteState::Removed);
        PurchaseInvoiceLineField.SetRange(Class, PurchaseInvoiceLineField.Class::Normal);
        PurchaseInvoiceLineField.SetFilter("No.", '<%1', 2000000000);
        PurchaseInvoiceLineField.SetFilter(Type, '%1|%2|%3|%4|%5|%6|%7|%8',
            // Supported types
            PurchaseInvoiceLineField.Type::Boolean,
            PurchaseInvoiceLineField.Type::Code,
            PurchaseInvoiceLineField.Type::Date,
            PurchaseInvoiceLineField.Type::DateTime,
            PurchaseInvoiceLineField.Type::Decimal,
            PurchaseInvoiceLineField.Type::Integer,
            PurchaseInvoiceLineField.Type::Option,
            PurchaseInvoiceLineField.Type::Text);
        if not PurchaseInvoiceLineField.FindSet() then
            exit;
        repeat
            // The fields to be copied are read from the "Purch. Inv. Line" table, and inserted into a record of the "Purchase Line" table.
            // For this reason, we will only consider valid fields to configure those that match field number and type as a heuristic of both fields being the same.
            if PurchaseLineField.Get(Database::"Purchase Line", PurchaseInvoiceLineField."No.") then
                if (PurchaseLineField.Type = PurchaseInvoiceLineField.Type) and (PurchaseLineField.Len = PurchaseInvoiceLineField.Len) then begin
                    if FieldsToOmit().Contains(PurchaseInvoiceLineField."No.") then
                        continue;
                    // If there is a persisted setup for this field, it means the user has configured it, so we will copy it.
                    if PersistedEDocPurchLineFieldSetup.Get(PurchaseInvoiceLineField."No.", EDocumentService.Code) then
                        EDocPurchLineFieldSetup.Copy(PersistedEDocPurchLineFieldSetup)
                    // If not, we provide the default configuration.
                    else begin
                        EDocPurchLineFieldSetup."Field No." := PurchaseInvoiceLineField."No.";
                        EDocPurchLineFieldSetup."E-Document Service" := EDocumentService.Code;
                    end;
                    EDocPurchLineFieldSetup.Insert();
                end;
        until PurchaseInvoiceLineField.Next() = 0;
    end;

    /// <summary>
    /// Persist the changes in the parameter to the configuration
    /// </summary>
    /// <param name="ConsiderField"></param>
    /// <param name="EDocPurchLineFieldSetup"></param>
    procedure ApplySetup(ConsiderField: Boolean; EDocPurchLineFieldSetup: Record "ED Purchase Line Field Setup")
    var
        PersistedEDocPurchLineFieldSetup: Record "ED Purchase Line Field Setup";
        RecordPreviouslyConfigured: Boolean;
    begin
        RecordPreviouslyConfigured := PersistedEDocPurchLineFieldSetup.Get(EDocPurchLineFieldSetup."Field No.", EDocPurchLineFieldSetup."E-Document Service");
        if not ConsiderField then begin
            if RecordPreviouslyConfigured then
                PersistedEDocPurchLineFieldSetup.Delete(true);
            exit;
        end;
        // If the user wants to copy this field, and the record didn't exist, we will create it.
        if not RecordPreviouslyConfigured then begin
            PersistedEDocPurchLineFieldSetup."Field No." := EDocPurchLineFieldSetup."Field No.";
            PersistedEDocPurchLineFieldSetup."E-Document Service" := EDocPurchLineFieldSetup."E-Document Service";
            PersistedEDocPurchLineFieldSetup.Insert();
        end;
        PersistedEDocPurchLineFieldSetup.Modify();
    end;

    internal procedure DeleteOmittedFieldsIfConfigured()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            if FieldsToOmit().Contains(Rec."Field No.") then
                Rec.Mark(true);
        until Rec.Next() = 0;
        Rec.MarkedOnly(true);
        Rec.DeleteAll();
        Clear(Rec);
    end;

    internal procedure IsOmitted(): Boolean
    begin
        exit(FieldsToOmit().Contains(Rec."Field No."));
    end;

    local procedure FieldsToOmit() OmittedFields: List of [Integer]
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        // Primary key fields, they shouldn't be copied
        OmittedFields.Add(PurchInvLine.FieldNo("Document No."));
        OmittedFields.Add(PurchInvLine.FieldNo("Line No."));
        // Fields that are already in the draft tables
        OmittedFields.Add(PurchInvLine.FieldNo("Buy-from Vendor No."));
        OmittedFields.Add(PurchInvLine.FieldNo("Deferral Code"));
        OmittedFields.Add(PurchInvLine.FieldNo(Type));
        OmittedFields.Add(PurchInvLine.FieldNo("No."));
        OmittedFields.Add(PurchInvLine.FieldNo("Unit of Measure"));
        OmittedFields.Add(PurchInvLine.FieldNo(Quantity));
        OmittedFields.Add(PurchInvLine.FieldNo("Direct Unit Cost"));
        OmittedFields.Add(PurchInvLine.FieldNo("Unit Cost"));
        OmittedFields.Add(PurchInvLine.FieldNo("Unit Cost (LCY)"));
        OmittedFields.Add(PurchInvLine.FieldNo("Unit Price (LCY)"));
        OmittedFields.Add(PurchInvLine.FieldNo("Line Discount Amount"));
        OmittedFields.Add(PurchInvLine.FieldNo(Amount));
        OmittedFields.Add(PurchInvLine.FieldNo(Description));
        OmittedFields.Add(PurchInvLine.FieldNo("Shortcut Dimension 1 Code"));
        OmittedFields.Add(PurchInvLine.FieldNo("Shortcut Dimension 2 Code"));
        // Fields that are document/line specific and should not be copied
        OmittedFields.Add(PurchInvLine.FieldNo("Amount Including VAT"));
        OmittedFields.Add(PurchInvLine.FieldNo("Blanket Order No."));
        OmittedFields.Add(PurchInvLine.FieldNo("Blanket Order Line No."));
        OmittedFields.Add(PurchInvLine.FieldNo("Attached to Line No."));
    end;

}