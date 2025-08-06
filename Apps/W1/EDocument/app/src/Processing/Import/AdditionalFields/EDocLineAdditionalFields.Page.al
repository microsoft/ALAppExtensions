// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Processing.Import;
using Microsoft.Purchases.History;
using Microsoft.eServices.EDocument;
using System.Reflection;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;

page 6104 "E-Doc. Line Additional Fields"
{
    Caption = 'Additional fields';
    PageType = ListPart;
#pragma warning disable AS0035 // extensible = false, released in 26.2, changed for 26.3, this is breaking if someone uses Page.run(6104, Rec)
    SourceTable = "ED Purchase Line Field Setup";
#pragma warning restore AS0035
    InsertAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Fields)
            {
                field(FieldName; this.FieldName)
                {
                    ApplicationArea = All;
                    Caption = 'Field Name';
                    Editable = false;
                    ToolTip = 'Specifies the field name.';
                }
                field(FieldValue; FieldValue)
                {
                    ApplicationArea = All;
                    Caption = 'Field Value';
                    ToolTip = 'Specifies the value for this field.';
                    Editable = false;
                    trigger OnAssistEdit()
                    var
                        EDocFieldValueEdit: Page "E-Doc. Field Value Edit";
                    begin
                        EDocFieldValueEdit.LookupMode(true);
                        EDocFieldValueEdit.SetValueToEdit(EDocPurchLineField);
                        if EDocFieldValueEdit.RunModal() = Action::OK then;
                        CurrPage.Update();
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(RevertChanges)
            {
                ApplicationArea = All;
                Caption = 'Revert Changes';
                ToolTip = 'Revert changes back to it''s original values.';
                Image = Undo;
                Visible = HasCustomizations;
                trigger OnAction()
                var
                    LocalEDocPurchaseLineField: Record "E-Document Line - Field";
                begin
                    LocalEDocPurchaseLineField.DeleteCustomizedRecords(CurrentEDocumentPurchaseLine);
                    CurrPage.Update();
                end;
            }
        }
    }

    var
        CurrentEDocumentPurchaseLine: Record "E-Document Purchase Line";
        CurrentPurchaseInvoiceLine: Record "Purch. Inv. Line";
        EDocPurchLineField: Record "E-Document Line - Field";
        FieldName, FieldValue : Text;
        HasCustomizations: Boolean;

    trigger OnOpenPage()
    var
        EDocument: Record "E-Document";
    begin
        Rec.DeleteOmittedFieldsIfConfigured();
        EDocument.Get(CurrentEDocumentPurchaseLine."E-Document Entry No.");
        Rec.SetRange("E-Document Service", EDocument.GetEDocumentService().Code);
    end;

    trigger OnAfterGetRecord()
    var
        Field: Record Field;
    begin
        EDocPurchLineField.Get(CurrentEDocumentPurchaseLine, Rec);
        FieldValue := EDocPurchLineField.GetValueAsText();
        if Field.Get(Database::"Purch. Inv. Line", Rec."Field No.") then
            this.FieldName := Field.FieldName;
    end;

    trigger OnAfterGetCurrRecord()
    var
        LocalEDocPurchaseLineField: Record "E-Document Line - Field";
    begin
        HasCustomizations := LocalEDocPurchaseLineField.HasCustomizedRecords(CurrentEDocumentPurchaseLine);
    end;

    internal procedure SetEDocumentLine(EDocumentPurchaseLine: Record "E-Document Purchase Line"; PurchaseInvoiceLine: Record "Purch. Inv. Line")
    begin
        CurrentEDocumentPurchaseLine := EDocumentPurchaseLine;
        CurrentPurchaseInvoiceLine := PurchaseInvoiceLine;
    end;

}