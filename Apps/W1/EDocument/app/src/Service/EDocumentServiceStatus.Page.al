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
                    ToolTip = 'Specifies the service code of an E-Document';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the status of an E-Document';
                    StyleExpr = StyleTxt;
                }
                field(Logs; Rec.Logs())
                {
                    Caption = 'Logs';
                    ToolTip = 'Specifies the count of logs for an E-Document';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowLogs();
                    end;
                }
                field(HttpLogs; Rec.IntegrationLogs())
                {
                    ToolTip = 'Specifies the count of communication logs for an E-Document';
                    Caption = 'Communication Logs';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowIntegrationLogs();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::"Sending Error",
            Rec.Status::"Export Error",
            Rec.Status::"Cancel Error",
            Rec.Status::"Imported Document Processing Error":
                StyleTxt := 'Unfavorable';

            Rec.Status::Sent,
            Rec.Status::"Imported Document Created",
            Rec.Status::Approved,
            Rec.Status::"Order Linked",
            Rec.Status::"Order Updated":
                StyleTxt := 'Favorable';
            else
                StyleTxt := 'None';
        end;
    end;

    var
        StyleTxt: Text;
}


