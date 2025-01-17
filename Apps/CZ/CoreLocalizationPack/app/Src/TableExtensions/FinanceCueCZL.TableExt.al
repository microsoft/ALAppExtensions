// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

using Microsoft.Finance.VAT.Reporting;

tableextension 31065 "Finance Cue CZL" extends "Finance Cue"
{
    fields
    {
        field(11700; "Opened VAT Reports"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("VAT Report Header" where(Status = const(Open)));
            Caption = 'Opened VAT Reports';
            Editable = false;
        }
    }
}