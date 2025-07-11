// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using Microsoft.Sales.Customer;

table 18807 "Allowed NOC"
{
    Caption = 'Allowed NOC';
    DrillDownPageId = "Allowed NOC";
    LookupPageId = "Allowed NOC";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Customer No."; code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(2; "TCS Nature of Collection"; code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "TCS Nature Of Collection";
        }
        field(3; "Default NOC"; Boolean)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckDefault();
            end;
        }
        field(4; "Threshold Overlook"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Surcharge Overlook"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(6; Description; Text[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("TCS Nature Of Collection".Description where(Code = field("TCS Nature of Collection")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Customer No.", "TCS Nature of Collection")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "TCS Nature of Collection", Description)
        {

        }
    }

    local procedure CheckDefault()
    var
        AllowedNOC: Record "Allowed NOC";
        DefaultErr: Label 'Default Noc is already selected for Noc Type %1.', Comment = '%1=Noc Type.';
    begin
        if rec."Default Noc" then begin
            AllowedNOC.Reset();
            AllowedNOC.SetRange("Customer No.", "Customer No.");
            AllowedNOC.SetRange("Default Noc", true);
            if not AllowedNOC.IsEmpty() then
                Error(DefaultErr, AllowedNOC."TCS Nature of Collection");
        end;
    end;
}
