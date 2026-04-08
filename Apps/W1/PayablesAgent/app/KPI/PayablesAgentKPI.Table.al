// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

/// <summary>
/// A table with the KPI data for the Payables Agent.
/// </summary>
table 3304 "Payables Agent KPI"
{
    Access = Internal;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    ReplicateData = false;

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Is Aggregate"; Boolean)
        {
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies whether the values in this record are aggregate values.';
        }
        field(3; "KPI Scenario"; Enum "PA KPI Scenario")
        {
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the KPI scenario that this record is related to.';
        }
        field(4; Count; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Specifies the count associated to this KPI entry.';
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
}