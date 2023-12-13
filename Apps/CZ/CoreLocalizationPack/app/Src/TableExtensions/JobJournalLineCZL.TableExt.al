// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Projects.Project.Journal;

using Microsoft.Foundation.Address;
#if not CLEAN22
using Microsoft.Foundation.Company;
#endif
using Microsoft.Inventory.Intrastat;
using Microsoft.Inventory.Journal;
#if not CLEAN22
using System.Environment.Configuration;
#endif

tableextension 11710 "Job Journal Line CZL" extends "Job Journal Line"
{
    fields
    {
        field(31050; "Tariff No. CZL"; Code[20])
        {
            Caption = 'Tariff No.';
            TableRelation = "Tariff Number";
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
#if not CLEAN22
#pragma warning disable AL0432
            trigger OnValidate()
            begin
                if "Tariff No. CZL" <> xRec."Tariff No. CZL" then
                    "Statistic Indication CZL" := '';
            end;
#pragma warning restore AL0432
#endif
        }
        field(31054; "Net Weight CZL"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
        }
        field(31057; "Country/Reg. of Orig. Code CZL"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
        }
        field(31058; "Statistic Indication CZL"; Code[10])
        {
            Caption = 'Statistic Indication';
            DataClassification = CustomerContent;
#if not CLEAN22
            TableRelation = "Statistic Indication CZL".Code where("Tariff No." = field("Tariff No. CZL"));
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31059; "Intrastat Transaction CZL"; Boolean)
        {
            Caption = 'Intrastat Transaction';
            Editable = false;
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
        }
        field(31079; "Invt. Movement Template CZL"; Code[10])
        {
            Caption = 'Inventory Movement Template';
            TableRelation = "Invt. Movement Template CZL";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                InvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
            begin
                if InvtMovementTemplateCZL.Get("Invt. Movement Template CZL") then begin
                    InvtMovementTemplateCZL.TestField("Entry Type", InvtMovementTemplateCZL."Entry Type"::"Negative Adjmt.");
                    Validate("Gen. Bus. Posting Group", InvtMovementTemplateCZL."Gen. Bus. Posting Group");
                end;
            end;
        }
        field(11764; "Correction CZL"; Boolean)
        {
            Caption = 'Correction';
            DataClassification = CustomerContent;
        }
    }
#if not CLEAN22

    [Obsolete('Intrastat related functionalities are moved to Intrastat extensions.', '22.0')]
    procedure CheckIntrastatCZL()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        FeatureMgtFacade: Codeunit "Feature Management Facade";
        MandatoryFieldErr: Label '%1 is required for Item %2.', Comment = '%1 = fieldcaption, %2 = No. of inventoriable item';
        IntrastatFeatureKeyIdTok: Label 'ReplaceIntrastat', Locked = true;
    begin
        if FeatureMgtFacade.IsEnabled(IntrastatFeatureKeyIdTok) then
            exit;
        if "Intrastat Transaction CZL" and (IsInventoriableItem()) then begin
            StatutoryReportingSetupCZL.Get();
            if StatutoryReportingSetupCZL."Transaction Type Mandatory" and ("Transaction Type" = '') then
                Error(MandatoryFieldErr, FieldCaption("Transaction Type"), "No.");
            if StatutoryReportingSetupCZL."Transaction Spec. Mandatory" and ("Transaction Specification" = '') then
                Error(MandatoryFieldErr, FieldCaption("Transaction Specification"), "No.");
            if StatutoryReportingSetupCZL."Transport Method Mandatory" and ("Transport Method" = '') then
                Error(MandatoryFieldErr, FieldCaption("Transport Method"), "No.");
            if StatutoryReportingSetupCZL."Shipment Method Mandatory" and ("Shpt. Method Code" = '') then
                Error(MandatoryFieldErr, FieldCaption("Shpt. Method Code"), "No.");
            if StatutoryReportingSetupCZL."Tariff No. Mandatory" and ("Tariff No. CZL" = '') then
                Error(MandatoryFieldErr, FieldCaption("Tariff No. CZL"), "No.");
            if StatutoryReportingSetupCZL."Net Weight Mandatory" and ("Net Weight CZL" = 0) then
                Error(MandatoryFieldErr, FieldCaption("Net Weight CZL"), "No.");
            if StatutoryReportingSetupCZL."Country/Region of Origin Mand." and ("Country/Reg. of Orig. Code CZL" = '') then
                Error(MandatoryFieldErr, FieldCaption("Country/Reg. of Orig. Code CZL"), "No.");
        end;
    end;

    [Obsolete('Intrastat related functionalities are moved to Intrastat extensions.', '22.0')]
    procedure IsIntrastatTransactionCZL() IsIntrastat: Boolean
    var
        CountryRegion: Record "Country/Region";
    begin
        exit(CountryRegion.IsIntrastatCZL("Country/Region Code", false));
    end;
#endif
}
