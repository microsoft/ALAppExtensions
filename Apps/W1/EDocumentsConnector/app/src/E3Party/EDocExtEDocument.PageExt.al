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
        addafter(UpdateOrder)
        {
            action(Approve)
            {
                Caption = 'Approve';
                ToolTip = 'Approve related document.';
                Image = Approve;
                ApplicationArea = All;
                Visible = Rec.Direction = Rec.Direction::Incoming;

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
                Visible = Rec.Direction = Rec.Direction::Incoming;

                trigger OnAction()
                var
                    PageroProcessing: Codeunit "Pagero Processing";
                begin
                    PageroProcessing.RejectEDocument(Rec);
                end;
            }
        }
        addafter(UpdateOrder_Promoted)
        {
            actionref(Approve_Promoted; Approve) { }
            actionref(Reject_Promoted; Reject) { }
        }
    }
}