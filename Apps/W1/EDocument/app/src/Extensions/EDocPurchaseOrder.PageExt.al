// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.eServices.EDocument;

pageextension 6132 "E-Doc. Purchase Order" extends "Purchase Order"
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
                        PurchaseLine: Record "Purchase Line";
                        EDocMapping: Codeunit "E-Doc. Mapping";
                    begin
                        PurchaseLine.SetRange("Document No.", Rec."No.");
                        EDocMapping.PreviewMapping(Rec, PurchaseLine, PurchaseLine.FieldNo("Line No."));
                    end;
                }
            }
        }
    }
}
