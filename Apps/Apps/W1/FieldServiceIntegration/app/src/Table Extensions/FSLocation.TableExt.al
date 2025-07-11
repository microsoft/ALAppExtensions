// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Inventory.Location;
using Microsoft.Integration.Dataverse;

tableextension 6614 "FS Location" extends Location
{
    fields
    {
        field(12000; "Coupled to FS"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Coupled to Field Service';
            Editable = false;
            CalcFormula = exist("CRM Integration Record" where("Integration ID" = field(SystemId), "Table ID" = const(Database::Location)));
        }
    }
}