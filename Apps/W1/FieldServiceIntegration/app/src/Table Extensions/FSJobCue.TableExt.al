// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Integration.Dataverse;
using Microsoft.Projects.RoleCenters;
using Microsoft.Integration.SyncEngine;

tableextension 6613 "FS Job Cue" extends "Job Cue"
{
    fields
    {
        field(12000; "Coupled Data Sync Errors"; Integer)
        {
            CalcFormula = count("CRM Integration Record" where(Skipped = const(true)));
            Caption = 'Coupled Data Synch Errors';
            FieldClass = FlowField;
        }
        field(12001; "FS Int. Errors"; Integer)
        {
            CalcFormula = count("Integration Synch. Job Errors");
            Caption = 'Field Service Integration Errors';
            FieldClass = FlowField;
        }
    }
}