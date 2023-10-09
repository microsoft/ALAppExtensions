// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.eServices.EDocument;

pageextension 6128 "E-Doc. Sales Invoice" extends "Sales Invoice"
{
    actions
    {
        addafter("&Invoice")
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
                        SalesLine: Record "Sales Line";
                        EDocMapping: Codeunit "E-Doc. Mapping";
                    begin
                        SalesLine.SetRange("Document No.", Rec."No.");
                        EDocMapping.PreviewMapping(Rec, SalesLine, SalesLine.FieldNo("Line No."));
                    end;
                }
            }
        }
    }
}
