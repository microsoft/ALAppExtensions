// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.EServices.EDocument;

pageextension 6360 "E-Doc. Ext. EDocument" extends "E-Document"
{
    actions
    {
        addlast(Incoming)
        {
            action(Approve)
            {
                Caption = 'Approve';
                ToolTip = 'Approve related document.';
                Image = Approve;
                ApplicationArea = All;
                Visible = ApprovalActionVisible;

                trigger OnAction()
                var
                    PageroProcessing: Codeunit "Pagero Processing";
                begin
                    PageroProcessing.ApproveEDocument(Rec);
                end;
            }
            action(Reject)
            {
                Caption = 'Reject';
                ToolTip = 'Reject related document.';
                Image = Reject;
                ApplicationArea = All;
                Visible = ApprovalActionVisible;

                trigger OnAction()
                var
                    PageroProcessing: Codeunit "Pagero Processing";
                begin
                    PageroProcessing.RejectEDocument(Rec);
                end;
            }
        }
        addlast(Category_Process)
        {
            actionref(Approve_Promoted; Approve) { }
            actionref(Reject_Promoted; Reject) { }
        }
    }

    trigger OnAfterGetRecord()
    var
        EDocumentService: Record "E-Document Service";
        EDocumentHelper: Codeunit "E-Document Helper";
    begin
        EDocumentHelper.GetEdocumentService(Rec, EdocumentService);
        ApprovalActionVisible :=
            (EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::Pagero) and (Rec.Direction = Rec.Direction::Incoming);
    end;

    var
        ApprovalActionVisible: Boolean;
}