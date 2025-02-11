// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.eServices.EDocument;

pageextension 6145 "E-Doc. Posted Sales Cr. Memo" extends "Posted Sales Credit Memo"
{
    actions
    {
        addafter("&Cr. Memo")
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
                        EDocument.OpenEdocument(Rec.RecordId);
                    end;
                }
                action(CreateAndSendEDocument)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Create and Send E-Document';
                    Image = CreateDocument;
                    ToolTip = 'Creates an electronic document from the posted sales credit memo and sends it via service.';
                    Enabled = not EDocumentExists;

                    trigger OnAction()
                    begin
                        Rec.CreateEDocument();
                        Message(EDocumentCreatedMsg);
                    end;
                }
                action(CreateAndEmailEDocument)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Create and E-mail E-Document';
                    Image = CreateDocument;
                    ToolTip = 'Creates an electronic document, sends it via service and attaches created e-document file to email.';
                    Enabled = not EDocumentExists;

                    trigger OnAction()
                    begin
                        Rec.CreateAndEmailEDocument();
                    end;
                }
            }
        }
        addlast(Category_Category7)
        {
            actionref(CreateAndEmailEDocument_Promoted; CreateAndEmailEDocument) { }
        }
    }

    var
        EDocumentCreatedMsg: Label 'The electronic document has been created.';
        EDocumentExists: Boolean;

    trigger OnAfterGetRecord()
    var
        EDocument: Record "E-Document";
    begin
        EDocument.SetRange("Document Record ID", Rec.RecordId());
        EDocumentExists := not EDocument.IsEmpty();
    end;
}
