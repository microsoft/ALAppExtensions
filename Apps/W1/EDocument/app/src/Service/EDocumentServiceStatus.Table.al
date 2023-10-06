// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

table 6138 "E-Document Service Status"
{
    fields
    {
        field(1; "E-Document Entry No"; Integer)
        {
            DataClassification = SystemMetadata;
            TableRelation = "E-Document";
            Caption = 'E-Document Entry No';
        }
        field(2; "E-Document Service Code"; Code[20])
        {
            TableRelation = "E-Document Service";
            DataClassification = SystemMetadata;
            Caption = 'E-Document Service Code';
        }
        field(3; "Status"; Enum "E-Document Service Status")
        {
            DataClassification = SystemMetadata;
            Caption = 'E-Document Status';
        }
    }

    keys
    {
        key(Key1; "E-Document Entry No", "E-Document Service Code")
        {
            Clustered = true;
        }
        key(Key2; Status, "E-Document Service Code")
        {
        }
    }

    internal procedure Logs(): Text
    var
        EDocumentLog: Record "E-Document Log";
    begin
        EDocumentLog.SetRange("Service Code", Rec."E-Document Service Code");
        EDocumentLog.SetRange("E-Doc. Entry No", Rec."E-Document Entry No");
        exit(Format(EDocumentLog.Count));
    end;

    internal procedure ShowLogs()
    var
        EDocumentLog: Record "E-Document Log";
    begin
        EDocumentLog.SetRange("Service Code", Rec."E-Document Service Code");
        EDocumentLog.SetRange("E-Doc. Entry No", Rec."E-Document Entry No");
        Page.RunModal(Page::"E-Document Logs", EDocumentLog);
    end;

    internal procedure IntegrationLogs(): Text
    var
        EDocumentIntegrationLog: Record "E-Document Integration Log";
    begin
        EDocumentIntegrationLog.SetRange("Service Code", Rec."E-Document Service Code");
        EDocumentIntegrationLog.SetRange("E-Doc. Entry No", "E-Document Entry No");
        exit(Format(EDocumentIntegrationLog.Count()));
    end;

    internal procedure ShowIntegrationLogs()
    var
        EDocumentIntegrationLog: Record "E-Document Integration Log";
    begin
        EDocumentIntegrationLog.SetRange("Service Code", Rec."E-Document Service Code");
        EDocumentIntegrationLog.SetRange("E-Doc. Entry No", Rec."E-Document Entry No");
        Page.RunModal(Page::"E-Document Integration Logs", EDocumentIntegrationLog);
    end;

    internal procedure ToString(): Text
    begin
        exit(StrSubstNo(EDocStringLbl, SystemId, Status));
    end;

    var
        EDocStringLbl: Label '%1,%2', Locked = true;
}
