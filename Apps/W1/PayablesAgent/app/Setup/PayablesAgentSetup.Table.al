// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;
using Microsoft.eServices.EDocument;
using System.Agents;

table 3303 "Payables Agent Setup"
{
    Access = Internal;
    Extensible = false;
    ReplicateData = false;
    InherentEntitlements = RIMDX;
    InherentPermissions = rimdX;
    Permissions = tabledata "Payables Agent Setup" = ri;

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "E-Document Service Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "E-Document Service".Code;
        }
        field(3; "Monitor Outlook"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
#if not CLEANSCHEMA28
#pragma warning disable AS0072
        field(4; "Agent User Security Id"; Guid)
        {
            DataClassification = SystemMetadata;
            ObsoleteReason = 'No longer used, replaced by "User Security Id" field';
#if not CLEAN28
            ObsoleteState = Pending;
            ObsoleteTag = '28.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '31.0';
#endif
        }
#pragma warning restore AS0072
#endif
        field(5; "Review Incoming Invoice"; Boolean)
        {
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(7; Exists; Boolean)
        {
            Caption = 'Exists';
            FieldClass = FlowField;
            CalcFormula = exist(Agent where("User Security ID" = field("User Security Id")));
        }
        field(9; "Last Activated"; DateTime)
        {
            Caption = 'Last Activated';
            DataClassification = SystemMetadata;
        }
        field(10; "User Security Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(11; "Use MLLM Processing"; Boolean)
        {
            Caption = 'Use MLLM Processing';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    internal procedure GetSetup()
    begin
        if Rec.FindFirst() then
            exit;

        Clear(Rec);
        Rec.Insert();
    end;
}