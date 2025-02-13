// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Service;

using Microsoft.eServices.EDocument;

page 6110 "Outbound E-Doc. Factbox"
{
    PageType = CardPart;
    ApplicationArea = Basic, Suite;
    UsageCategory = None;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "E-Document Service Status";

    layout
    {
        area(Content)
        {
            group(Details)
            {
                ShowCaption = false;

                field("E-Document Service"; EDocumentServiceStatus."E-Document Service Code")
                {
                    Caption = 'Service';
                    ToolTip = 'Specifies the service code of an E-Dcoument';
                }
                field(SingleStatus; EDocumentServiceStatus.Status)
                {
                    Caption = 'Service Status';
                    ToolTip = 'Specifies the status of an E-Dcoument';
                }
                field("Processing Status"; Format(EDocumentServiceStatus."Import Processing Status"))
                {
                    Caption = 'Processing Status';
                    ToolTip = 'Specifies the processing status of an E-Dcoument';
                    Editable = false;
                }
                field(Log; EDocumentServiceStatus.Logs())
                {
                    Caption = 'Document Logs';
                    ToolTip = 'Specifies the count of logs for an E-Dcoument';

                    trigger OnDrillDown()
                    begin
                        EDocumentServiceStatus.ShowLogs();
                    end;
                }
                field(HttpLog; EDocumentServiceStatus.IntegrationLogs())
                {
                    Caption = 'Integration Logs';
                    ToolTip = 'Specifies the count of communication logs for an E-Dcoument';

                    trigger OnDrillDown()
                    begin
                        EDocumentServiceStatus.ShowIntegrationLogs();
                    end;
                }
            }
            repeater(DocumentServices)
            {
                ShowCaption = false;

                field("E-Document Service Code"; Rec."E-Document Service Code")
                {
                    ToolTip = 'Specifies the service code of an E-Dcoument';
                }
                field(Status; Rec.Status)
                {
                    Caption = 'Service Status';
                    ToolTip = 'Specifies the status of an E-Dcoument';
                }
                field(ImportProcessingStatus; Rec."Import Processing Status")
                {
                    Caption = 'Processing Status';
                    ToolTip = 'Specifies the processing status of an E-Dcoument';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        EDocumentServiceStatus := Rec;
    end;

    var
        EDocumentServiceStatus: Record "E-Document Service Status";
}


