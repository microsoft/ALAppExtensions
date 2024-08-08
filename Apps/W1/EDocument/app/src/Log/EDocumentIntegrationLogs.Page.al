// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

page 6128 "E-Document Integration Logs"
{
    ApplicationArea = Basic, Suite;
    Caption = 'E-Document Communication Logs';
    SourceTable = "E-Document Integration Log";
    PageType = List;
    Editable = false;
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(Content)
        {
            group("Logs")
            {
                ShowCaption = false;
                repeater(IntegrationLogs)
                {
                    ShowCaption = false;
                    field("Entry No."; Rec."Entry No.")
                    {
                        ToolTip = 'Specifies the log entry no.';
                    }
                    field("Service Code"; Rec."Service Code")
                    {
                        ToolTip = 'Specifies the service code for the document.';
                    }
                    field(URL; Rec."Request URL")
                    {
                        ToolTip = 'Specifies the integration url used to send the document.';
                    }
                    field(Method; Rec.Method)
                    {
                        ToolTip = 'Specifies the http method used to send the document.';
                    }
                    field("Response Status"; Rec."Response Status")
                    {
                        ToolTip = 'Specifies the response status of sending the document.';
                    }
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ExportRequestMsg)
            {
                Caption = 'Export Request Message';
                ToolTip = 'Exports request message.';
                Image = ExportAttachment;

                trigger OnAction()
                begin
                    Rec.ExportRequestMessage();
                end;
            }
            action(ExportResponseMsg)
            {
                Caption = 'Export Response Message';
                ToolTip = 'Exports resonse message.';
                Image = ExportAttachment;

                trigger OnAction()
                begin
                    Rec.ExportResponseMessage();
                end;
            }
        }
    }
}
