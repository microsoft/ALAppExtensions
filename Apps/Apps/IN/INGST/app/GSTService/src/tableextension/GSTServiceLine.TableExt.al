// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Document;

using Microsoft.Finance.GST.Base;
using Microsoft.Service.Setup;

tableextension 18441 "GST Service Line" extends "Service Line"
{
    fields
    {
        field(18440; "GST Place Of Supply"; Enum "GST Dependency Type")
        {
            Caption = 'GST Place Of Supply';
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Quantity Shipped", 0);
                TestField("Quantity Consumed", 0);
                TestField("Quantity Invoiced", 0);
                ServiceHeader.Get("Document Type", "Document No.");
                ServiceHeader.TestField("POS Out Of India", false);
            end;
        }
        field(18441; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            TableRelation = "GST Group";
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidateGSTGroupCode();
            end;
        }
        field(18442; "GST Group Type"; Enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18443; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(18444; "GST Jurisdiction Type"; Enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18445; "Invoice Type"; Enum "Sales Invoice Type")
        {
            Caption = 'Invoice Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18446; Exempted; Boolean)
        {
            Caption = 'Exempted';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Quantity Shipped", 0);
                TestField("Quantity Consumed", 0);
                TestField("Quantity Invoiced", 0);
                ServiceHeader.Get("Document Type", "Document No.");
                if (ServiceHeader."Applies-to Doc. No." <> '') or (ServiceHeader."Applies-to ID" <> '') then
                    Error(AppliesToDocErr);
            end;
        }
        field(18447; "GST On Assessable Value"; Boolean)
        {
            Caption = 'GST On Assessable Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                GSTGroup: Record "GST Group";
            begin
                TestField("Currency Code");
                TestField("GST Group Code");
                if GSTGroup.Get("GST Group Code") then
                    GSTGroup.TestField("GST Group Type", GSTGroup."GST Group Type"::Goods);

                "GST Assessable Value (LCY)" := 0;
            end;
        }
        field(18448; "GST Assessable Value (LCY)"; Decimal)
        {
            Caption = 'GST Assessable Value (LCY)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("GST On Assessable Value", true);
            end;
        }
        field(18449; "Non-GST Line"; Boolean)
        {
            Caption = 'Non-GST Line';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                if "Non-GST Line" then begin
                    ServiceHeader.Get("Document Type", "Document No.");
                    "GST Group Code" := '';
                    "HSN/SAC Code" := '';
                end;
            end;
        }
    }

    var
        ServiceHeader: Record "Service Header";
        GSTGroupReverseChargeErr: Label 'GST Group Code %1 with Reverse Charge cannot be selected for Service transactions.', Comment = '%1 = GST Group Code.';
        AppliesToDocErr: Label 'You must remove Applies-to Doc No. before modifying Exempted value.';

    local procedure ValidateGSTGroupCode()
    var
        GSTGroup: Record "GST Group";
        ServMgtSetup: Record "Service Mgt. Setup";
    begin
        TestStatusOpen();
        TestField("Non-GST Line", false);
        if GSTGroup.Get("GST Group Code") then begin
            if GSTGroup."Reverse Charge" then
                Error(GSTGroupReverseChargeErr, "GST Group Code");

            "GST Place Of Supply" := GSTGroup."GST Place Of Supply";
            "GST Group Type" := GSTGroup."GST Group Type";
        end;

        if "GST Place Of Supply" = "GST Place Of Supply"::" " then begin
            ServMgtSetup.Get();
            "GST Place Of Supply" := ServMgtSetup."GST Dependency Type";
        end;

        "HSN/SAC Code" := '';
        "GST On Assessable Value" := false;
        "GST Assessable Value (LCY)" := 0;
    end;
}
