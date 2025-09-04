// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Finance.RoleCenters;

pageextension 6107 "E-Doc. A/P Admin Activities" extends "Acc. Payable Activities"
{
    layout
    {
        addafter(OngoingPurchase)
        {
            cuegroup("IncomingEDocument")
            {
                Caption = 'Incoming E-Document';

                field(IncomingEDocumentProcessedCount; IncomingEDocumentProcessedCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Processed';
                    ToolTip = 'Specifies the number of processed e-document';

                    trigger OnDrillDown()
                    begin
                        EDocumentHelper.OpenEDocuments(Enum::"E-Document Status"::Processed, Enum::"E-Document Direction"::Incoming);
                    end;
                }
                field(IncomingEDocumentInProgressCount; IncomingEDocumentInProgressCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'In Progress';
                    ToolTip = 'Specifies the number of in progress e-document';

                    trigger OnDrillDown()
                    begin
                        EDocumentHelper.OpenEDocuments(Enum::"E-Document Status"::"In Progress", Enum::"E-Document Direction"::Incoming);
                    end;
                }
                field(IncomingEDocumentErrorCount; IncomingEDocumentErrorCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Error';
                    ToolTip = 'Specifies the number of e-document with errors';

                    trigger OnDrillDown()
                    begin
                        EDocumentHelper.OpenEDocuments(Enum::"E-Document Status"::Error, Enum::"E-Document Direction"::Incoming);
                    end;
                }
            }
        }
    }

    var
        EDocumentHelper: Codeunit "E-Document Processing";
        IncomingEDocumentInProgressCount, IncomingEDocumentProcessedCount, IncomingEDocumentErrorCount : Integer;

    trigger OnOpenPage()
    begin
        IncomingEDocumentInProgressCount := EDocumentHelper.GetEDocumentCount(Enum::"E-Document Status"::"In Progress", Enum::"E-Document Direction"::Incoming);
        IncomingEDocumentProcessedCount := EDocumentHelper.GetEDocumentCount(Enum::"E-Document Status"::Processed, Enum::"E-Document Direction"::Incoming);
        IncomingEDocumentErrorCount := EDocumentHelper.GetEDocumentCount(Enum::"E-Document Status"::Error, Enum::"E-Document Direction"::Incoming);
    end;
}