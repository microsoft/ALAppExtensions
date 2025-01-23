// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.eServices.EDocument;
pageextension 6144 "E-Doc. Posted Sales Inv." extends "Posted Sales Invoice"
{
    actions
    {
        addafter("&Invoice")
        {
            group("E-Document")
            {
                action("OpenEDocument")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Open E-Document';
                    Image = CopyDocument;
                    ToolTip = 'Opens the electronic document card.';
                    Enabled = EDocumentExists;

                    trigger OnAction()
                    var
                        EDocument: Record "E-Document";
                    begin
                        EDocument.OpenEDocument(Rec.RecordId);
                    end;
                }
                action(CreateEDocument)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Create and send E-Document';
                    Image = CreateDocument;
                    ToolTip = 'Creates an electronic document from the posted sales invoice.';
                    Enabled = not EDocumentExists;

                    trigger OnAction()
                    var
                        EDocExport: Codeunit "E-Doc. Export";
                        SalesInvoiceRecordRef: RecordRef;
                    begin
                        SalesInvoiceRecordRef.GetTable(Rec);
                        EDocExport.CreateEDocumentForPostedDocument(SalesInvoiceRecordRef);
                        Message(EDocumentCreatedMsg);
                    end;
                }

            }
        }
        addlast(Category_Category6)
        {
            actionref("CreateEDocument_Promoted"; "CreateEDocument") { }
        }
    }

    var
        EDocumentCreatedMsg: Label 'The electronic document has been created.';
        EDocumentExists: Boolean;

    trigger OnAfterGetRecord()
    var
        EDocument: Record "E-Document";
    begin
        EDocument.SetRange("Document Record ID", Rec.RecordId);
        EDocumentExists := not EDocument.IsEmpty();
    end;
}
