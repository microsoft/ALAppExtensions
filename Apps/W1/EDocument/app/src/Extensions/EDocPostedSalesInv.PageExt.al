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

                    trigger OnAction()
                    var
                        EDocument: Record "E-Document";
                    begin
                        EDocument.OpenEdocument(Rec.RecordId);
                    end;
                }
                action(CreateEDocument)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Create E-Document';
                    Image = CreateDocument;
                    ToolTip = 'Creates an electronic document from the posted sales invoice.';

                    trigger OnAction()
                    var
                        EDocExport: Codeunit "E-Doc. Export";
                        DocRecRef: RecordRef;
                    begin
                        DocRecRef.GetTable(Rec);
                        EDocExport.CheckEDocument(DocRecRef, "E-Document Processing Phase"::Create);
                        EDocExport.CreateEDocument(DocRecRef);
                        Message(EDocumentCreatedMsg);
                    end;
                }

            }
        }
    }

    var
        EDocumentCreatedMsg: Label 'The electronic document has been created.';
}
