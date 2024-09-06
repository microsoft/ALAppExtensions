// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Service.Setup;
using Microsoft.Integration.Dataverse;

tableextension 6618 "FS Service Order Type" extends "Service Order Type"
{
    fields
    {
        field(12000; "Coupled to FS"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Coupled to Field Service';
            Editable = false;
            CalcFormula = exist("CRM Integration Record" where("Integration ID" = field(SystemId), "Table ID" = const(Database::"Service Order Type")));
        }
    }
}
