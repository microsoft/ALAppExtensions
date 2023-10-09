// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

page 6127 "E-Document Activities"
{
    PageType = CardPart;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            cuegroup("EDocument Activities")
            {
                ShowCaption = false;
                cuegroup("OutgoingEDocument")
                {
                    Caption = 'Outgoing E-Document';

                    field(OutgoingEDocumentProcessedCount; OutgoingEDocumentProcessedCount)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Processed';
                        ToolTip = 'Specifies the number of processed e-document';

                        trigger OnDrillDown()
                        begin
                            EDocumentHelper.OpenEDocuments(Enum::"E-Document Status"::Processed, Enum::"E-Document Direction"::Outgoing);
                        end;
                    }
                    field(OutgoingEDocumentInProgressCount; OutgoingEDocumentInProgressCount)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'In Progress';
                        ToolTip = 'Specifies the number of in progress e-document';

                        trigger OnDrillDown()
                        begin
                            EDocumentHelper.OpenEDocuments(Enum::"E-Document Status"::"In Progress", Enum::"E-Document Direction"::Outgoing);
                        end;
                    }
                    field(OutgoingEDocumentErrorCount; OutgoingEDocumentErrorCount)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Error';
                        ToolTip = 'Specifies the number of e-document with errors';

                        trigger OnDrillDown()
                        begin
                            EDocumentHelper.OpenEDocuments(Enum::"E-Document Status"::Error, Enum::"E-Document Direction"::Outgoing);
                        end;
                    }
                }
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
    }

    var
        EDocumentHelper: Codeunit "E-Document Processing";
        OutgoingEDocumentInProgressCount, OutgoingEDocumentProcessedCount, OutgoingEDocumentErrorCount : Integer;
        IncomingEDocumentInProgressCount, IncomingEDocumentProcessedCount, IncomingEDocumentErrorCount : Integer;

    trigger OnOpenPage()
    begin
        OutgoingEDocumentInProgressCount := EDocumentHelper.GetEDocumentCount(Enum::"E-Document Status"::"In Progress", Enum::"E-Document Direction"::Outgoing);
        OutgoingEDocumentProcessedCount := EDocumentHelper.GetEDocumentCount(Enum::"E-Document Status"::Processed, Enum::"E-Document Direction"::Outgoing);
        OutgoingEDocumentErrorCount := EDocumentHelper.GetEDocumentCount(Enum::"E-Document Status"::Error, Enum::"E-Document Direction"::Outgoing);

        IncomingEDocumentInProgressCount := EDocumentHelper.GetEDocumentCount(Enum::"E-Document Status"::"In Progress", Enum::"E-Document Direction"::Incoming);
        IncomingEDocumentProcessedCount := EDocumentHelper.GetEDocumentCount(Enum::"E-Document Status"::Processed, Enum::"E-Document Direction"::Incoming);
        IncomingEDocumentErrorCount := EDocumentHelper.GetEDocumentCount(Enum::"E-Document Status"::Error, Enum::"E-Document Direction"::Incoming);
    end;
}
