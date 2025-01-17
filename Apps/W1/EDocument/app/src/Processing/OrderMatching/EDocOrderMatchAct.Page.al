// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

page 6162 "E-Doc. Order Match Act."
{
    PageType = CardPart;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            field(MatchedPurchaseOrderCount; MatchedPurchaseOrderCount)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Matched Purchase Orders';
                ToolTip = 'Specifies the number of purchase orders that have matched to a received e-document.';

                trigger OnDrillDown()
                begin

                end;
            }
            field(WaitingPurchaseOrderCount; WaitingPurchaseOrderCount)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Waiting Purchase E-Documents';
                ToolTip = 'Specifies the number of received purchase e-documents that needs to be reviewed.';

                trigger OnDrillDown()
                begin

                end;
            }
        }
    }

    var
        MatchedPurchaseOrderCount, WaitingPurchaseOrderCount : Integer;

}
