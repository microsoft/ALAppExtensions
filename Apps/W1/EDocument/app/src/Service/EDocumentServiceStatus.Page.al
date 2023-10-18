// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

page 6135 "E-Document Service Status"
{
    PageType = ListPart;
    ApplicationArea = Basic, Suite;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "E-Document Service Status";

    layout
    {
        area(Content)
        {

            repeater(DocumentServices)
            {
                field("E-Document Service Code"; Rec."E-Document Service Code")
                {
                    ToolTip = 'Specifies the service code of an E-Dcoument';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the status of an E-Dcoument';
                }
                field(Logs; Rec.Logs())
                {
                    Caption = 'Logs';
                    ToolTip = 'Specifies the count of logs for an E-Dcoument';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowLogs();
                    end;
                }
                field(HttpLogs; Rec.IntegrationLogs())
                {
                    ToolTip = 'Specifies the count of communication logs for an E-Dcoument';
                    Caption = 'Communication Logs';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowIntegrationLogs();
                    end;
                }
            }
        }
    }
}
