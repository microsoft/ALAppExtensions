// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Document;

using Microsoft.eServices.EDocument;

pageextension 6136 "E-Doc. Service Order" extends "Service Order"
{
    actions
    {
        addafter("P&osting")
        {
            group("E-Document")
            {
                action("PreviewEDocumentMapping")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Preview E-Document Mapping';
                    Image = ViewDetails;
                    ToolTip = 'Preview E-Document Mapping';
                    trigger OnAction()
                    var
                        ServiceLine: Record "Service Line";
                        EDocMapping: Codeunit "E-Doc. Mapping";
                    begin
                        ServiceLine.SetRange("Document No.", Rec."No.");
                        EDocMapping.PreviewMapping(Rec, ServiceLine, ServiceLine.FieldNo("Line No."));
                    end;
                }
            }
        }
    }
}
