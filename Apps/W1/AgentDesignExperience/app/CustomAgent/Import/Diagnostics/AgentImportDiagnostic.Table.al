// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

table 4354 "Agent Import Diagnostic"
{
    Access = Internal;
    DataClassification = CustomerContent;
    InherentPermissions = RIMDX;
    InherentEntitlements = RIMDX;
    TableType = Temporary;

    fields
    {
        field(1; "Diagnostic ID"; Integer)
        {
            Caption = 'Diagnostic ID';
            DataClassification = SystemMetadata;
        }
        field(2; "Agent Name"; Text[50])
        {
            Caption = 'Agent Name';
        }
        field(3; "Agent Initials"; Text[4])
        {
            Caption = 'Agent Initials';
        }
        field(4; Severity; Enum "Agent Import Diag Severity")
        {
            Caption = 'Severity';
            DataClassification = SystemMetadata;
        }
        field(5; Message; Text[2048])
        {
            Caption = 'Message';
        }
    }

    keys
    {
        key(PK; "Diagnostic ID")
        {
        }
        key(Agent; "Agent Name")
        {
        }
        key(Severity; Severity)
        {
        }
    }
}