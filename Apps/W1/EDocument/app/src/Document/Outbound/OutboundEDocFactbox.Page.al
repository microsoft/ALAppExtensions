// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Service;

using Microsoft.eServices.EDocument;
using System.Security.AccessControl;

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
                field("Created date"; EDocSystemCreatedAt)
                {
                    Caption = 'Created Date';
                    ToolTip = 'Specifies the date when the E-Document was created';
                }
                field("Created by"; EDocSystemCreatedBy)
                {
                    Caption = 'Created By';
                    ToolTip = 'Specifies the user who created the E-Document';
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
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        EDocumentServiceStatus := Rec;
    end;

    trigger OnAfterGetCurrRecord()
    var
        EDocument: Record "E-Document";
    begin
        if EDocument.Get(Rec."E-Document Entry No") then
            UpdateStatus(EDocument);
    end;

    local procedure UpdateStatus(EDocument: Record "E-Document")
    var
        User: Record User;
    begin
        if EDocument."Entry No" = 0 then
            exit;

        EDocSystemCreatedAt := EDocument.SystemCreatedAt;
        if User.Get(EDocument.SystemCreatedBy) then
            EDocSystemCreatedBy := User."Full Name"
        else
            EDocSystemCreatedBy := 'System';
    end;

    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocSystemCreatedAt: DateTime;
        EDocSystemCreatedBy: Text;
}
