// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.FinanceCharge;

using Microsoft.eServices.EDocument;

pageextension 6140 "E-Doc. Fin. Charge Memo" extends "Finance Charge Memo"
{
    actions
    {
        addafter("&Issuing")
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
                        FinChargeMemoLine: Record "Finance Charge Memo Line";
                        EDocMapping: Codeunit "E-Doc. Mapping";
                    begin
                        FinChargeMemoLine.SetRange("Document No.", Rec."No.");
                        EDocMapping.PreviewMapping(Rec, FinChargeMemoLine, FinChargeMemoLine.FieldNo("Line No."));
                    end;
                }
            }
        }
    }
}
