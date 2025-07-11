// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.eServices.EDocument;

pageextension 6129 "E-Doc. Purchase Invoice" extends "Purchase Invoice"
{
    actions
    {
        addafter("&Invoice")
        {
            group("E-Document")
            {
                action(OpenEDocumentDraft)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Open E-Document Draft';
                    Image = Open;
                    ToolTip = 'Opens the E-Document draft.';
                    Visible = HasEDocumentLinked;

                    trigger OnAction()
                    var
                        EDocument: Record "E-Document";
                        EDocumentHelper: Codeunit "E-Document Helper";
                    begin
                        if not EDocument.GetBySystemId(Rec."E-Document Link") then
                            exit;
                        EDocumentHelper.OpenDraftPage(EDocument);
                    end;
                }
                action(ViewDocumentSource)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'View E-Document Source';
                    Image = View;
                    ToolTip = 'Opens a view of the document source, like a PDF or XML file.';
                    Visible = HasEDocumentLinked;

                    trigger OnAction()
                    var
                        EDocument: Record "E-Document";
                    begin
                        if not EDocument.GetBySystemId(Rec."E-Document Link") then
                            exit;
                        EDocument.ViewSourceFile();
                    end;
                }
                action("PreviewEDocumentMapping")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Preview E-Document Mapping';
                    Image = ViewDetails;
                    ToolTip = 'Preview E-Document Mapping';
                    trigger OnAction()
                    var
                        PurchaseLine: Record "Purchase Line";
                        EDocMapping: Codeunit "E-Doc. Mapping";
                    begin
                        PurchaseLine.SetRange("Document No.", Rec."No.");
                        EDocMapping.PreviewMapping(Rec, PurchaseLine, PurchaseLine.FieldNo("Line No."));
                    end;
                }
            }
        }
        addlast(Promoted)
        {
            group("E-Document Promoted")
            {
                Caption = 'E-Document';
                actionref(OpenEDocumentDraft_Promoted; OpenEDocumentDraft)
                {
                }
                actionref(ViewDocumentSource_Promoted; ViewDocumentSource)
                {
                }
            }
        }
    }

    var
        HasEDocumentLinked: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        HasEDocumentLinked := not IsNullGuid(Rec."E-Document Link");
    end;
}
