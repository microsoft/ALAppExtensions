// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.FinanceCharge;

using Microsoft.eServices.EDocument;

pageextension 6149 "E-Doc. Issued Fin. Charge Memo" extends "Issued Finance Charge Memo"
{
    layout
    {
        addlast(General)
        {
            field("Your Reference"; Rec."Your Reference")
            {
                ApplicationArea = All;
                Caption = 'Your Reference';
                ToolTip = 'Specifies the customer''s reference.';
            }
        }
    }

    actions
    {
        addafter("&Memo")
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
                action(CreateAndSendEDocument)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Create and Send E-Document';
                    Image = CreateDocument;
                    ToolTip = 'Creates an electronic document from the issued finance charge memo and sends it via service.';
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
