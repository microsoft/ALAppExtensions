// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Document;

using Microsoft.Inventory.Item;
using Microsoft.Service.Reports;

tableextension 5034 "Serv. Decl. Serv. Line" extends "Service Line"
{
    fields
    {
        field(5010; "Service Transaction Type Code"; Code[20])
        {
            TableRelation = "Service Transaction Type";
            Caption = 'Service Transaction Type Code';

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                TestField("No.");
                if Type <> Type::Item then
                    exit;
                Item.Get("No.");
                Item.TestField(Type, Item.Type::Service);
            end;
        }
        field(5011; "Applicable For Serv. Decl."; Boolean)
        {
            Caption = 'Applicable For Service Declaration';

            trigger OnValidate()
            var
                ServiceHeader: Record "Service Header";
            begin
                ServiceHeader := Rec.GetServHeader();
                if "Applicable For Serv. Decl." then
                    ServiceHeader.TestField("Applicable For Serv. Decl.");
            end;
        }
    }
}
