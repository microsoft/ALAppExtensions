// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

page 6159 "E-Doc. Order Map. Activities"
{
    PageType = CardPart;
    RefreshOnActivate = true;
    Caption = 'E-Document Activities';
    ShowFilter = false;

    layout
    {
        area(Content)
        {
            cuegroup("IncomingEDocument")
            {
                Caption = 'Incoming E-Document';

                field(MatchedPurchaseOrderCount; EDocumentHelper.MatchedPurchaseOrdersCount())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Linked Purchase Orders';
                    ToolTip = 'Specifies the number of e-documents that are linked to a purchase order and needs to be processed.';

                    trigger OnDrillDown()
                    begin
                        EDocumentHelper.OpenMatchedPurchaseOrders();
                    end;
                }
                field(WaitingPurchaseOrderCount; EDocumentHelper.WaitingPurchaseEDocCount())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Waiting Purchase E-Invoices';
                    ToolTip = 'Specifies the number of received purchase e-documents that needs to be reviewed.';

                    trigger OnDrillDown()
                    begin
                        EDocumentHelper.OpenWaitingPurchaseEDoc();
                    end;
                }
            }
        }
    }

    var
        EDocumentHelper: Codeunit "E-Document Processing";

}