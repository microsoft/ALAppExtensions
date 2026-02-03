// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

using Microsoft.Finance.TaxBase;
using Microsoft.Purchases.Vendor;

table 18688 "TDS Concessional Code"
{
    Caption = 'TDS Concessional Code';
    DrillDownPageId = "TDS Concessional Codes";
    LookupPageId = "TDS Concessional Codes";
    DataCaptionFields = "Vendor No.", "Section";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
            DataClassification = CustomerContent;
        }
        field(2; Section; Code[10])
        {
            Caption = 'Section';
            TableRelation = "Allowed Sections"."TDS Section" where("Vendor No" = field("Vendor No."));
            DataClassification = CustomerContent;
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
        field(7; "Certificate Value"; Decimal)
        {
            Caption = 'Certificate Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Remaining Certificate Value" = 0) or ("Certificate Value" <> xRec."Certificate Value") then
                    "Remaining Certificate Value" := "Certificate Value";
            end;
        }
        field(8; "Remaining Certificate Value"; Decimal)
        {
            Caption = 'Remaining Certificate Value';
            DataClassification = CustomerContent;
        }
        field(9; "Used Certificate Value"; Decimal)
        {
            Caption = 'Used Certificate Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Vendor No.", Section, "Concessional Code", "Certificate No.", "Start Date", "End Date")
        {
            Clustered = true;
        }
    }
}
