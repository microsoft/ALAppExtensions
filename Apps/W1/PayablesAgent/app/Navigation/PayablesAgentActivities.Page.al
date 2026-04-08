// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Agent.PayablesAgent;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import;

page 3310 "Payables Agent Activities"
{
    PageType = CardPart;
    RefreshOnActivate = true;
    InherentEntitlements = X;
    InherentPermissions = X;
    Caption = 'Payables Agent', Locked = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            cuegroup(PurchaseDocuments)
            {
                Caption = 'Purchase documents';

                field(PendingProcessing; PendingProcessing)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pending processing';
                    ToolTip = 'Specifies the number of vendor invoices that are pending processing.';

                    trigger OnDrillDown()
                    begin
                        DrillDownInboundEDocumentsInStatus(Enum::"Import E-Doc. Proc. Status"::Readable);
                    end;
                }
                field(NeedAttention; NeedAttention)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Need attention';
                    ToolTip = 'Specifies the number of vendor invoices that need attention from the user.';

                    trigger OnDrillDown()
                    begin
                        DrillDownInboundEDocumentsInStatus(Enum::"Import E-Doc. Proc. Status"::"Draft Ready");
                    end;
                }
                field(ReadyForReview; ReadyForReview)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ready for review';
                    ToolTip = 'Specifies the number of vendor invoices that are ready for review.';

                    trigger OnDrillDown()
                    begin
                        DrillDownInboundEDocumentsInStatus(Enum::"Import E-Doc. Proc. Status"::"Ready for draft");
                    end;
                }
                field(ProcessedThisMonth; ProcessedThisMonth)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Processed this month';
                    ToolTip = 'Specifies the number of vendor invoices that have been processed this month.';

                    trigger OnDrillDown()
                    begin
                        DrillDownInboundEDocumentsInStatus(Enum::"Import E-Doc. Proc. Status"::Processed);
                    end;
                }
            }

        }
    }

    var
        PendingProcessing, NeedAttention, ReadyForReview, ProcessedThisMonth : Integer;

    trigger OnOpenPage()
    begin
        PendingProcessing := CalcInboundEDocsInStatus(Enum::"Import E-Doc. Proc. Status"::Readable);
        NeedAttention := CalcInboundEDocsInStatus(Enum::"Import E-Doc. Proc. Status"::"Draft Ready");
        ReadyForReview := CalcInboundEDocsInStatus(Enum::"Import E-Doc. Proc. Status"::"Ready for draft");
        ProcessedThisMonth := CalcInboundEDocsInStatus(Enum::"Import E-Doc. Proc. Status"::Processed);
    end;

    local procedure CalcInboundEDocsInStatus(ImportEDocProcStatus: Enum "Import E-Doc. Proc. Status"): Integer
    var
        EDocument: Record "E-Document";
    begin
        EDocument.SetRange("Import Processing Status", ImportEDocProcStatus);
        exit(EDocument.Count());
    end;

    local procedure DrillDownInboundEDocumentsInStatus(ImportEDocProcStatus: Enum "Import E-Doc. Proc. Status")
    var
        EDocument: Record "E-Document";
        InboundEDocuments: Page "Inbound E-Documents";
    begin
        EDocument.SetRange("Import Processing Status", ImportEDocProcStatus);
        InboundEDocuments.SetTableView(EDocument);
        InboundEDocuments.Run();
    end;
}