// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

using Microsoft.Purchases.Vendor;

table 18687 "Allowed Sections"
{
    Caption = 'Allowed Sections';
    LookupPageId = "Allowed Sections";
    DrillDownPageId = "Allowed Sections";
    DataCaptionFields = "Vendor No", "TDS Section";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Vendor No"; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
            DataClassification = CustomerContent;
        }
        field(2; "TDS Section"; Code[10])
        {
            Caption = 'TDS Section';
            TableRelation = "TDS Section";
            DataClassification = CustomerContent;
        }
        field(3; "Default Section"; Boolean)
        {
            Caption = 'Default Section';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckDefault();
            end;
        }
        field(4; "Threshold Overlook"; Boolean)
        {
            Caption = 'Threshold Overlook';
            DataClassification = CustomerContent;
        }
        field(5; "Surcharge Overlook"; Boolean)
        {
            Caption = 'Surcharge Overlook';
            DataClassification = CustomerContent;
        }
        field(6; "TDS Section Description"; Text[100])
        {
            Caption = 'TDS Section Description';
            FieldClass = FlowField;
            CalcFormula = lookup("TDS Section".Description where(Code = field("TDS Section")));
            Editable = false;
        }
        field(7; "Non Resident Payments"; Boolean)
        {
            Caption = 'Non Resident Payments';
            DataClassification = CustomerContent;
        }
        field(8; "Nature of Remittance"; Code[10])
        {
            Caption = 'Nature of Remittance';
            TableRelation = "TDS Nature of Remittance";
            DataClassification = CustomerContent;
        }
        field(9; "Act Applicable"; Code[10])
        {
            Caption = 'Act Applicable';
            TableRelation = "Act Applicable";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Vendor No", "TDS Section")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "TDS Section", "TDS Section Description")
        {

        }
    }

    local procedure CheckDefault()
    var
        AllowedSections: Record "Allowed Sections";
        DefaultErr: Label 'Default Section is already selected for TDS Section %1.', Comment = '%1 = Section';
    begin
        if rec."Default Section" then begin
            AllowedSections.Reset();
            AllowedSections.SetRange("Vendor No", "Vendor No");
            AllowedSections.SetRange("Default Section", true);
            if AllowedSections.FindFirst() then
                Error(DefaultErr, AllowedSections."TDS Section");
        end;
    end;
}
