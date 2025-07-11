// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Purchase;
using Microsoft.Foundation.Address;

tableextension 18094 "GST Party" extends Party
{
    fields
    {
        field(18080; "P.A.N. No."; Code[20])
        {
            Caption = 'P.A.N. No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "GST Registration No." <> '' then
                    CheckGSTRegBlankInRef();
            end;
        }
        field(18081; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(18082; State; Code[10])
        {
            Caption = 'State';
            TableRelation = State;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("GST Registration No.", '');
            end;
        }
        field(18083; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = CustomerContent;
            TableRelation = "Post Code";
        }
        field(18084; "P.A.N. Reference No."; Code[20])
        {
            Caption = 'P.A.N. Reference No.';
            DataClassification = CustomerContent;
        }
        field(18085; "P.A.N. Status"; Enum "PAN Status")
        {
            Caption = 'P.A.N. Status';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "P.A.N. No." := Format("P.A.N. Status");
            end;
        }
        field(18086; "GST Party Type"; enum "GST Party Type")
        {
            Caption = 'GST Party Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                case "GST Party Type" of
                    "GST Party Type"::" ":
                        begin
                            TestField("GST Vendor Type", "GST Vendor Type"::" ");
                            TestField("GST Customer Type", "GST Customer Type"::" ");
                            TestField("Associated Enterprises", false);
                        end;
                    "GST Party Type"::Customer:
                        begin
                            TestField("GST Vendor Type", "GST Vendor Type"::" ");
                            TestField("Associated Enterprises", false);
                        end;
                    "GST Party Type"::Vendor:
                        begin
                            TestField("GST Customer Type", "GST Customer Type"::" ");
                            TestField("GST Registration Type", "GST Registration Type"::GSTIN);
                        end;
                end;
            end;
        }
        field(18087; "GST Registration No."; Code[20])
        {
            Caption = 'GST Registration No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "GST Registration No." <> '' then begin
                    TestField(State);
                    if "P.A.N. No." <> '' then
                        GSTBaseValidation.CheckGSTRegistrationNo(State, "GST Registration No.", "P.A.N. No.")
                    else
                        if "GST Registration No." <> '' then
                            Error(PANErr);

                    TestField("GST Party Type");
                    case "GST Party Type" of
                        "GST Party Type"::Vendor:
                            if "GST Vendor Type" = "GST Vendor Type"::" " then
                                "GST Vendor Type" := "GST Vendor Type"::Registered
                            else
                                if not ("GST Vendor Type" in [
                                    "GST Vendor Type"::Registered,
                                    "GST Vendor Type"::Composite,
                                    "GST Vendor Type"::Exempted,
                                    "GST Vendor Type"::SEZ])
                                then
                                    "GST Vendor Type" := "GST Vendor Type"::Registered;
                        "GST Party Type"::Customer:
                            if "GST Registration Type" = "GST Registration Type"::GSTIN then begin
                                if "P.A.N. No." <> '' then
                                    GSTBaseValidation.CheckGSTRegistrationNo(
                                        State,
                                        "GST Registration No.",
                                        "P.A.N. No.")
                                else
                                    if "GST Registration No." <> '' then
                                        Error(PANErr);
                                if "GST Customer Type" = "GST Customer Type"::" " then
                                    "GST Customer Type" := "GST Customer Type"::Registered
                                else
                                    if not ("GST Customer Type" in [
                                        "GST Customer Type"::Registered,
                                        "GST Customer Type"::Exempted,
                                        "GST Customer Type"::"SEZ Development",
                                        "GST Customer Type"::"SEZ Unit",
                                        "GST Customer Type"::"Deemed Export"])
                                    then
                                        "GST Customer Type" := "GST Customer Type"::Registered;
                            end else begin
                                "GST Customer Type" := "GST Customer Type"::Registered;
                                if not ("GST Registration Type" = "GST Registration Type"::GSTIN) then
                                    if ("P.A.N. No." <> '') and ("P.A.N. Status" = "P.A.N. Status"::" ") then
                                        GSTBaseValidation.CheckGSTRegistrationNo(
                                            State,
                                            "GST Registration No.",
                                            "P.A.N. No.");
                            end;
                    end;
                end else
                    if "ARN No." = '' then begin
                        "GST Customer Type" := "GST Customer Type"::" ";
                        "GST Vendor Type" := "GST Vendor Type"::" ";
                    end;
            end;
        }
        field(18088; "GST Vendor Type"; enum "GST Vendor Type")
        {
            Caption = 'GST Vendor Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("GST Party Type", "GST Party Type"::Vendor);
                if "GST Vendor Type" = "GST Vendor Type"::" " then begin
                    "GST Registration No." := '';
                    exit;
                end;

                if "GST Vendor Type" in [
                    "GST Vendor Type"::Registered,
                    "GST Vendor Type"::Composite,
                    "GST Vendor Type"::SEZ,
                    "GST Vendor Type"::Exempted]
                then begin
                    if "GST Registration No." = '' then
                        if "ARN No." = '' then
                            Error(GSTARNErr)
                end else begin
                    if "GST Vendor Type" <> "GST Vendor Type"::Exempted then
                        "GST Registration No." := '';
                    if "GST Vendor Type" = "GST Vendor Type"::Import then
                        TestField(State, '')
                    else
                        if "GST Vendor Type" = "GST Vendor Type"::Unregistered then
                            TestField(State);
                    if "GST Vendor Type" <> "GST Vendor Type"::Import then
                        "Associated Enterprises" := false;
                end;

                if "GST Registration No." <> '' then begin
                    TestField(State);
                    if "P.A.N. No." <> '' then
                        GSTBaseValidation.CheckGSTRegistrationNo(State, "GST Registration No.", "P.A.N. No.")
                    else
                        if "GST Registration No." <> '' then
                            Error(PANErr);
                end;
            end;
        }
        field(18089; "Associated Enterprises"; Boolean)
        {
            Caption = 'Associated Enterprises';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Associated Enterprises" then
                    TestField("GST Vendor Type", "GST Vendor Type"::Import);
            end;
        }
        field(18090; "GST Registration Type"; Enum "Registration Type")
        {
            Caption = 'GST Registration Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                case "GST Party Type" of
                    "GST Party Type"::Vendor:
                        TestField("GST Registration Type", "GST Registration Type"::GSTIN);
                    "GST Party Type"::Customer:
                        begin
                            if not ("GST Customer Type" in [
                                "GST Customer Type"::Registered,
                                "GST Customer Type"::" "]) and
                                not ("GST Registration Type" = "GST Registration Type"::GSTIN)
                            then
                                Error(GSTCustRegErr);
                            if ("P.A.N. No." <> '') and ("P.A.N. Status" = "P.A.N. Status"::" ") then
                                GSTBaseValidation.CheckGSTRegistrationNo(
                                    State,
                                    "GST Registration No.",
                                    "P.A.N. No.")
                            else
                                if "GST Registration No." <> '' then
                                    Error(PANErr);
                        end;
                end;
            end;
        }
        field(18091; "GST Customer Type"; Enum "GST Customer Type")
        {
            Caption = 'GST Customer Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("GST Party Type", "GST Party Type"::Customer);

                if "GST Customer Type" = "GST Customer Type"::" " then begin
                    "GST Registration No." := '';
                    exit;
                end;

                TestField(Address);
                if not ("GST Customer Type" in ["GST Customer Type"::Registered]) and not
                   ("GST Registration Type" = "GST Registration Type"::GSTIN)
                then
                    Error(GSTCustRegErr);
                if ("GST Customer Type" in [
                    "GST Customer Type"::Registered,
                    "GST Customer Type"::"Deemed Export",
                    "GST Customer Type"::Exempted,
                    "GST Customer Type"::"SEZ Development",
                    "GST Customer Type"::"SEZ Unit"])
                then
                    if "GST Registration No." = '' then
                        if "ARN No." = '' then
                            Error(GSTARNErr);
                if ("GST Customer Type" in [
                    "GST Customer Type"::Registered,
                    "GST Customer Type"::Unregistered,
                    "GST Customer Type"::Exempted,
                    "GST Customer Type"::"SEZ Development",
                    "GST Customer Type"::"SEZ Unit"])
                then
                    TestField(State)
                else
                    if "GST Customer Type" <> "GST Customer Type"::"Deemed Export" then
                        TestField(State, '');
                if not ("GST Customer Type" in [
                    "GST Customer Type"::Registered,
                    "GST Customer Type"::Exempted,
                    "GST Customer Type"::"Deemed Export",
                    "GST Customer Type"::"SEZ Development",
                    "GST Customer Type"::"SEZ Unit"])
                then
                    "GST Registration No." := '';
                if "GST Registration No." <> '' then begin
                    TestField(State);
                    if "P.A.N. No." <> '' then
                        GSTBaseValidation.CheckGSTRegistrationNo(
                            State,
                            "GST Registration No.",
                            "P.A.N. No.")
                    else
                        if "GST Registration No." <> '' then
                            Error(PANErr);
                end;
            end;
        }
        field(18092; "ARN No."; Code[20])
        {
            Caption = 'ARN No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("ARN No." = '') and ("GST Registration No." = '') and
                    ("GST Party Type" = "GST Party Type"::Customer)
                then
                    if not ("GST Customer Type" in [
                        "GST Customer Type"::Export,
                        "GST Customer Type"::Unregistered])
                    then
                        "GST Customer Type" := "GST Customer Type"::" ";

                if ("ARN No." = '') and
                    ("GST Registration No." = '') and
                    ("GST Party Type" = "GST Party Type"::Vendor)
                then
                    if not ("GST Vendor Type" in [
                        "GST Vendor Type"::Import,
                        "GST Vendor Type"::Unregistered])
                    then
                        "GST Vendor Type" := "GST Vendor Type"::" ";

                if "GST Vendor Type" in [
                    "GST Vendor Type"::Import,
                    "GST Vendor Type"::Unregistered]
                then
                    TestField("ARN No.", '');

                if "GST Customer Type" in [
                    "GST Customer Type"::Export,
                    "GST Customer Type"::Unregistered]
                then
                    TestField("ARN No.", '');
            end;
        }
    }

    var
        GSTBaseValidation: Codeunit "GST Base Validation";
        GSTARNErr: Label 'Either GST Registration No. or ARN No. must have a value.';
        PANErr: Label 'PAN No. must be entered.';
        SamePANErr: Label 'From postion 3 to 12 it must be same as it is in PAN No. so delete the GST Registration No. and then update it.';
        GSTCustRegErr: Label 'GST Customer type ''Blank'' & ''Registered'' is allowed to select when GST Registration Type is UID or GID.';

    local procedure CheckGSTRegBlankInRef()
    begin
        if "P.A.N. No." <> CopyStr("GST Registration No.", 3, 10) then
            Error(SamePANErr);
    end;
}
