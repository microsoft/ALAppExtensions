// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSForCustomer;

using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Sales.Customer;
using Microsoft.Finance.TaxBase;

table 18662 "TDS Customer Concessional Code"
{
    Caption = 'TDS Customer Concessional Code';
    DrillDownPageId = "TDS Concessional Codes";
    LookupPageId = "TDS Concessional Codes";
    DataCaptionFields = "Customer No.", "TDS Section Code";
    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;
        }
        field(2; "TDS Section Code"; Code[10])
        {
            Caption = 'TDS Section Code';
            TableRelation = "TDS Section";
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                CheckAllowedSection();
            end;
        }
        field(3; "Concessional Code"; Code[10])
        {
            Caption = 'Concessional Code';
            TableRelation = "Concessional Code";
            DataClassification = CustomerContent;
        }
        field(4; "Certificate No."; Code[20])
        {
            Caption = 'Certificate No.';
            DataClassification = CustomerContent;
        }
        field(5; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
        }
        field(6; "End Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                ShorterEndDateErr: Label 'End Date should not be greater than the Start Date';
            begin
                if "End Date" < "Start Date" then
                    Error(ShorterEndDateErr);
            end;
        }
    }
    keys
    {
        key(PK; "Customer No.", "TDS Section Code", "Concessional Code", "Certificate No.", "Start Date", "End Date")
        {
            Clustered = true;
        }
    }
    local procedure CheckAllowedSection()
    var
        AllowedSections: Record "Customer Allowed Sections";
        AllowedSectionsErr: Label 'TDS Section Code %1 is not attached with Customer No. %2', Comment = '%1 and %2 = TDS Section Code and Customer No.';
    begin
        AllowedSections.Reset();
        AllowedSections.SetRange("Customer No", "Customer No.");
        AllowedSections.SetRange("TDS Section", "TDS Section Code");
        if AllowedSections.IsEmpty then
            Error(AllowedSectionsErr, Rec."TDS Section Code", Rec."Customer No.");
    end;
}
