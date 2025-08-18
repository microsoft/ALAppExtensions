// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.OrderMatch;

pageextension 6137 "E-Doc. Purchase Order List" extends "Purchase Order List"
{
    actions
    {
        addafter("P&osting")
        {
            group("E-Document")
            {
                action(MatchToOrder)
                {
                    Caption = 'Map E-Document Lines';
                    ToolTip = 'Map received E-Document to the Purchase Order';
                    ApplicationArea = All;
                    Image = Reconcile;
                    Visible = ShowMapToEDocument;

                    trigger OnAction()
                    var
                        EDocument: Record "E-Document";
                        EDocOrderMatch: Codeunit "E-Doc. Line Matching";
                    begin
                        EDocument.GetBySystemId(Rec."E-Document Link");
                        EDocOrderMatch.RunMatching(EDocument);
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
        addlast(Prompting)
        {
            action(MatchToOrderCopilotEnabled)
            {
                Caption = 'Map E-Document Lines';
                ToolTip = 'Map received E-Document to the Purchase Order';
                ApplicationArea = All;
                Image = SparkleFilled;
                Visible = ShowMapToEDocument;

                trigger OnAction()
                var
                    EDocument: Record "E-Document";
                    EDocOrderMatch: Codeunit "E-Doc. Line Matching";
                begin
                    EDocument.GetBySystemId(Rec."E-Document Link");
                    EDocOrderMatch.RunMatching(EDocument, true);
                end;
            }

        }
        addlast(Category_Process)
        {
            actionref(MapEDocumentCE_Promoted; MatchToOrderCopilotEnabled)
            {
            }
            actionref(MapEDocument_Promoted; MatchToOrder)
            {
            }
        }

    }


    var
        ShowMapToEDocument: Boolean;

    trigger OnAfterGetCurrRecord()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        ShowMapToEDocument := false;
        if not IsNullGuid(Rec."E-Document Link") then begin
            EDocument.GetBySystemId(Rec."E-Document Link");
            EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
            EDocumentServiceStatus.FindFirst();
            ShowMapToEDocument := EDocumentServiceStatus.Status = Enum::"E-Document Service Status"::"Order Linked";
        end;
    end;

}
