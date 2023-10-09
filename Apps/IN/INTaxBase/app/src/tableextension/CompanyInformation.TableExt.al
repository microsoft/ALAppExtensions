// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;

using Microsoft.Finance.TaxBase;

tableextension 18543 "CompanyInformation" extends "Company Information"
{
    fields
    {
        field(18543; "State Code"; Code[10])
        {
            TableRelation = "State";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18544; "T.A.N. No."; Code[10])
        {
            TableRelation = "TAN Nos.";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18545; "P.A.N. Status"; enum "Company P.A.N.Status")
        {
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            var
                PANNotReqLbl: Label 'PANNOTREQD';
            begin
                if "P.A.N. Status" = "P.A.N. Status"::"Not available" then
                    "P.A.N. No." := PANNotReqLbl
                else
                    "P.A.N. No." := '';
            end;
        }
        field(18546; "PAO Code"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18547; "PAO Registration No."; Code[7])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18548; "DDO Code"; Code[7])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18549; "DDO Registration No."; Code[7])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18550; "Ministry Type"; Enum "Ministry Type")
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18551; "P.A.N. No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18552; "Ministry Code"; Code[3])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = if ("Ministry Type" = const(Others)) "Ministry" where("Other Ministry" = filter('Yes'))
            else
            if ("Ministry Type" = const(Regular)) Ministry where("Other Ministry" = filter('No'));
        }
        field(18553; "Deductor Category"; Code[1])
        {
            TableRelation = "Deductor Category";
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            var
                DeductorCategory: Record "Deductor Category";
            begin
                DeductorCategory.Get("Deductor Category");
                if not DeductorCategory."DDO Code Mandatory" then begin
                    "DDO Code" := '';
                    "DDO Registration No." := '';
                end;
                if not DeductorCategory."PAO Code Mandatory" then begin
                    "PAO Code" := '';
                    "PAO Registration No." := '';
                end;
                if not DeductorCategory."Ministry Details Mandatory" then
                    "Ministry Code" := '';
            end;
        }
        field(18554; "Company Status"; Enum "Company Status")
        {
            DataClassification = CustomerContent;
        }
    }
}
