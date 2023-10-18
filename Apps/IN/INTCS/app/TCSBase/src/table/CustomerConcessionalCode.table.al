// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using Microsoft.Sales.Customer;
using Microsoft.Finance.TaxBase;

table 18808 "Customer Concessional Code"
{
    Caption = 'Customer Concessional Code';
    DataCaptionFields = "Customer No.", "TCS Nature of Collection";
    DrillDownPageId = "Customer Concessional Codes";
    LookupPageId = "Customer Concessional Codes";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            NotBlank = true;
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(2; "TCS Nature of Collection"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Allowed NOC"."TCS Nature of Collection" where("Customer No." = field("Customer No."));
        }
        field(3; "Concessional Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Concessional Code";
        }
        field(4; "Concessional Form No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Start Date"; date)
        {
            DataClassification = CustomerContent;
        }
        field(6; "End Date"; date)
        {
            DataClassification = CustomerContent;
        }
        field(7; Description; Text[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("TCS Nature Of Collection".Description where(Code = field("TCS Nature of Collection")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Customer No.", "TCS Nature of Collection", "Concessional Code", "Concessional Form No.", "Start Date", "End Date")
        {
            Clustered = true;
        }
    }
}
