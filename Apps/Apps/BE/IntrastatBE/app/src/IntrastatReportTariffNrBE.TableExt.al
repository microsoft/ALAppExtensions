// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

tableextension 11348 "Intrastat Report Tariff Nr. BE" extends "Tariff Number"
{
    fields
    {
        modify("Suppl. Conversion Factor")
        {
            trigger OnBeforeValidate()
            begin
                SetSkipValidationLogic(true);
            end;
        }
        modify("Suppl. Unit of Measure")
        {
            trigger OnBeforeValidate()
            begin
                SetSkipValidationLogic(true);
            end;
        }
    }
}