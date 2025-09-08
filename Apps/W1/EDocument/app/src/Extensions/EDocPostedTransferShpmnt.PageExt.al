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
                    Caption = 'Open';
                    Image = Open;
                    ToolTip = 'Opens electronic document card.';
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
                    Caption = 'Create';
                    Image = CreateDocument;
                    ToolTip = 'Creates an E-Document from the posted document and sends it via service.';
                    Enabled = not EDocumentExists;

                    trigger OnAction()
                    var
                        EDocumentProcessing: Codeunit "E-Document Processing";
                    begin
                        if EDocumentProcessing.CreateEDocumentFromPostedDocumentPage(Rec, Enum::"E-Document Type"::"Transfer Shipment") then
                            Message(EDocumentCreatedMsg);
                    end;
                }
            }
        }
    }

    var
        EDocumentExists: Boolean;
        EDocumentCreatedMsg: Label 'The e-document has been created.';

    trigger OnAfterGetRecord()
    var
        EDocument: Record "E-Document";
    begin
        EDocument.SetRange("Document Record ID", Rec.RecordId());
        EDocumentExists := not EDocument.IsEmpty();
    end;

}