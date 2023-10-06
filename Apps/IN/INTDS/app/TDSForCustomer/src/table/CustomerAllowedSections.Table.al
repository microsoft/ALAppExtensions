// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSForCustomer;

using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Sales.Customer;

table 18661 "Customer Allowed Sections"
{
    Caption = 'Customer Allowed Sections';
    LookupPageId = "Allowed Sections";
    DrillDownPageId = "Allowed Sections";
    DataCaptionFields = "Customer No", "TDS Section";
    fields
    {
        field(1; "Customer No"; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;
        }
        field(2; "TDS Section"; Code[10])
        {
            Caption = 'TDS Section';
            TableRelation = "TDS Section";
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if "TDS Section" <> '' then begin
                    "Threshold Overlook" := true;
                    "Surcharge Overlook" := true;
                end else begin
                    "Threshold Overlook" := false;
                    "Surcharge Overlook" := false;
                end;
            end;
        }
        field(3; "Threshold Overlook"; Boolean)
        {
            Caption = 'Threshold Overlook';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Surcharge Overlook"; Boolean)
        {
            Caption = 'Surcharge Overlook';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "TDS Section Description"; Text[100])
        {
            Caption = 'TDS Section Description';
            FieldClass = FlowField;
            CalcFormula = lookup("TDS Section".Description where(Code = field("TDS Section")));
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Customer No", "TDS Section")
        {
            Clustered = true;
        }
    }
}
