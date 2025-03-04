// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

page 6108 "Inbound E-Doc. Factbox"
{
    PageType = CardPart;
    UsageCategory = None;
    ApplicationArea = Basic, Suite;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "E-Document Service Status";

    layout
    {
        area(Content)
        {
            field("E-Document Service"; Rec."E-Document Service Code")
            {
                Caption = 'Service';
                ToolTip = 'Specifies the service code of an E-Document';
            }
            field("Status"; Rec.Status)
            {
                Caption = 'Service Status';
                ToolTip = 'Specifies the status of an E-Document';
            }
            field("Processing Status"; Format(Rec."Import Processing Status"))
            {
                Caption = 'Processing Status';
                ToolTip = 'Specifies the processing status of an E-Document';
                Editable = false;
                Visible = ImportProcessingStatusVisible;
            }
            field(Logs; Rec.Logs())
            {
                Caption = 'Document Logs';
                ToolTip = 'Specifies the count of logs for an E-Document';

                trigger OnDrillDown()
                begin
                    Rec.ShowLogs();
                end;
            }
            field(HttpLogs; Rec.IntegrationLogs())
            {
                Caption = 'Integration Logs';
                ToolTip = 'Specifies the count of communication logs for an E-Document';

                trigger OnDrillDown()
                begin
                    Rec.ShowIntegrationLogs();
                end;
            }
        }
    }

    var
        ImportProcessingStatusVisible: Boolean;

    trigger OnOpenPage()
    var
        EDocumentsSetup: Record "E-Documents Setup";
    begin
        ImportProcessingStatusVisible := EDocumentsSetup.IsNewEDocumentExperienceActive();
    end;

}


