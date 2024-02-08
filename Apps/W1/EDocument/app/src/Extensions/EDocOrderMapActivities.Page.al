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

    layout
    {
        area(Content)
        {
            cuegroup("EDocument Activities")
            {
                ShowCaption = false;
                cuegroup("IncomingEDocument")
                {
                    Caption = 'Incoming E-Document';

                    field(MatchedPurchaseOrderCount; EDocumentHelper.MatchedPurchaseOrdersCount())
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Matched Purchase Orders';
                        ToolTip = 'Specifies the number of purchase orders that have matched to a received e-document.';

                        trigger OnDrillDown()
                        begin
                            EDocumentHelper.OpenMatchedPurchaseOrders();
                        end;
                    }
                    field(WaitingPurchaseOrderCount; EDocumentHelper.MatchedPurchaseEDocumentsCount())
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Waiting Purchase E-Documents';
                        ToolTip = 'Specifies the number of received purchase e-documents that needs to be reviewed.';

                        trigger OnDrillDown()
                        begin
                            EDocumentHelper.OpenMatchedPurchaseEDoc();
                        end;
                    }
                }
            }
        }
    }

    var
        EDocumentHelper: Codeunit "E-Document Processing";

}