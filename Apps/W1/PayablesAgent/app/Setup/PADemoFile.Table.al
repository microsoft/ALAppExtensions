#if not CLEANSCHEMA31
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

table 3305 "PA Demo File"
{
    Access = Internal;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
#pragma warning disable AL0432
#if not CLEAN28
    DrillDownPageId = "PA Demo Files To Download";
    LookupPageId = "PA Demo Files To Download";
#endif
#pragma warning restore AL0432
    DataClassification = CustomerContent;
    ReplicateData = false;
    ObsoleteReason = 'Use E-Doc Sample Purch. Inv File instead.';
#if not CLEAN28
    ObsoleteState = Pending;
    ObsoleteTag = '28.0';
#else
    ObsoleteState = Removed;
    ObsoleteTag = '31.0';
#endif

    fields
    {
        field(1; ID; Integer)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique identifier for the demo file.';
        }
        field(2; "File Name"; Text[250])
        {
            Caption = 'File Name';
            ToolTip = 'Specifies the name of the demo file.';
        }
        field(3; Scenario; Text[2048])
        {
            Caption = 'Scenario';
            ToolTip = 'Specifies the scenario for which the demo file is used.';
        }
        field(4; "Vendor Name"; Text[1024])
        {
            Caption = 'Vendor Name';
            ToolTip = 'Specifies the name of the vendor associated with the demo file.';
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}
#endif