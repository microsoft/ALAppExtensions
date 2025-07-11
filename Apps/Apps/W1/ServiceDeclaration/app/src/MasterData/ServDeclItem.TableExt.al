// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;

using Microsoft.Service.Reports;

tableextension 5012 "Serv. Decl. Item" extends Item
{
    fields
    {
        field(5010; "Service Transaction Type Code"; Code[20])
        {
            Caption = 'Service Transaction Type Code';
            TableRelation = "Service Transaction Type";

            trigger OnValidate()
            begin
                if "Service Transaction Type Code" <> '' then
                    TestField(Type, Type::Service);
            end;
        }
        field(5011; "Exclude From Service Decl."; Boolean)
        {
            Caption = 'Exclude From Service Declaration';
        }
    }
}
