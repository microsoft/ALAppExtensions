// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Finance.RoleCenters;

pageextension 6103 "E-Doc. A/P Admin Activities" extends "A/P Admin Activities"
{
    layout
    {
        addafter(OngoingPurchase)
        {
            cuegroup("IncomingEDocument")
            {
                Caption = 'Incoming E-Document';

                field(IncomingEDocumentProcessedCount; this.IncomingEDocumentProcessedCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Processed';
                    ToolTip = 'Specifies the number of processed e-document';

                    trigger OnDrillDown()
                    begin
                        EDocumentHelper.OpenEDocuments(Enum::"E-Document Status"::Processed, Enum::"E-Document Direction"::Incoming);
                    end;
                }
                field(IncomingEDocumentInProgressCount; this.IncomingEDocumentInProgressCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'In Progress';
                    ToolTip = 'Specifies the number of in progress e-document';

                    trigger OnDrillDown()
                    begin
                        EDocumentHelper.OpenEDocuments(Enum::"E-Document Status"::"In Progress", Enum::"E-Document Direction"::Incoming);
                    end;
                }
                field(IncomingEDocumentErrorCount; this.IncomingEDocumentErrorCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Error';
                    ToolTip = 'Specifies the number of e-document with errors';

                    trigger OnDrillDown()
                    begin
                        EDocumentHelper.OpenEDocuments(Enum::"E-Document Status"::Error, Enum::"E-Document Direction"::Incoming);
                    end;
                }
                field(MatchedPurchaseOrderCount; this.MatchedPurchaseOrderCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Linked Purchase Orders';
                    ToolTip = 'Specifies the number of e-documents that are linked to a purchase order and needs to be processed.';

                    trigger OnDrillDown()
                    begin
                        EDocumentHelper.OpenMatchedPurchaseOrders();
                    end;
                }
                field(WaitingPurchaseOrderCount; this.WaitingPurchaseEDocCount)
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
        IncomingEDocumentInProgressCount, IncomingEDocumentProcessedCount, IncomingEDocumentErrorCount : Integer;
        MatchedPurchaseOrderCount, WaitingPurchaseEDocCount : Integer;

    trigger OnOpenPage()
    begin
        this.IncomingEDocumentInProgressCount := EDocumentHelper.GetEDocumentCount(Enum::"E-Document Status"::"In Progress", Enum::"E-Document Direction"::Incoming);
        this.IncomingEDocumentProcessedCount := EDocumentHelper.GetEDocumentCount(Enum::"E-Document Status"::Processed, Enum::"E-Document Direction"::Incoming);
        this.IncomingEDocumentErrorCount := EDocumentHelper.GetEDocumentCount(Enum::"E-Document Status"::Error, Enum::"E-Document Direction"::Incoming);
        this.MatchedPurchaseOrderCount := EDocumentHelper.MatchedPurchaseOrdersCount();
        this.WaitingPurchaseEDocCount := EDocumentHelper.WaitingPurchaseEDocCount();
    end;
}