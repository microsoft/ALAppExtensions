// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

using Microsoft.eServices.EDocument;

pageextension 6106 "E-Doc. Posted Transfer Shpmnt." extends "Posted Transfer Shipment"
{
    actions
    {
        addafter("&Shipment")
        {
            group("E-Document")
            {
                Caption = 'E-Document';

                action(OpenEDocument)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Open E-Document';
                    Enabled = HasEDocument;
                    Image = CopyDocument;
                    ToolTip = 'Opens electronic document card.';

                    trigger OnAction()
                    var
                        EDocument: Record "E-Document";
                    begin
                        EDocument.OpenEDocument(Rec.RecordId);
                    end;
                }
            }
        }
    }

    var
        HasEDocument: Boolean;

    trigger OnAfterGetRecord()
    begin
        HasEDocument := EDocumentExists(Rec.RecordId);
    end;

    local procedure EDocumentExists(DocumentRecordId: RecordId): Boolean
    var
        EDocument: Record "E-Document";
    begin
        EDocument.SetRange("Document Record ID", DocumentRecordId);
        exit(not EDocument.IsEmpty());
    end;
}