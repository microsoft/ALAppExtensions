// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Finance.GeneralLedger.Journal;
using System.Privacy;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Integration.Action;

table 6103 "E-Document Service"
{
    LookupPageId = "E-Document Services";
    DrillDownPageId = "E-Document Services";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = SystemMetadata;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(3; "Document Format"; Enum "E-Document Format")
        {
            Caption = 'Document Format';
            DataClassification = SystemMetadata;
        }
#if not CLEANSCHEMA29
        field(4; "Service Integration"; Enum "E-Document Integration")
        {
            Caption = 'Service Integration';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Use Service Integration V2 integration enum instead';
#if CLEAN26
            ObsoleteState = Removed;
            ObsoleteTag = '29.0';
#else
            ObsoleteState = Pending;
            ObsoleteTag = '26.0';

            trigger OnValidate()
            var
                CustConcentMgt: Codeunit "Customer Consent Mgt.";
            begin
                if (xRec."Service Integration" = xRec."Service Integration"::"No Integration") and (Rec."Service Integration" <> xRec."Service Integration") then
                    if not CustConcentMgt.ConfirmCustomConsent(ChooseIntegrationConsentTxt) then
                        Rec."Service Integration" := xRec."Service Integration";
            end;
#endif
        }
#endif
        field(5; "Use Batch Processing"; Boolean)
        {
            Caption = 'Use Batch Processing';
            DataClassification = SystemMetadata;
        }
        field(6; "Update Order"; Boolean)
        {
            Caption = 'Update Order';
#if not CLEAN24
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by "Receive E-Document To" on Vendor table';
            ObsoleteTag = '24.0';
#endif
        }
        field(7; "Create Journal Lines"; Boolean)
        {
            Caption = 'Create Journal Lines';
            DataClassification = SystemMetadata;
        }
        field(8; "Validate Receiving Company"; Boolean)
        {
            Caption = 'Validate Receiving Company';
            InitValue = true;
            DataClassification = SystemMetadata;
        }
        field(9; "Resolve Unit Of Measure"; Boolean)
        {
            Caption = 'Resolve Unit Of Measure';
            InitValue = true;
            DataClassification = SystemMetadata;
        }
        field(10; "Lookup Item Reference"; Boolean)
        {
            Caption = 'Lookup Item Reference';
            InitValue = true;
            DataClassification = SystemMetadata;
        }
        field(11; "Lookup Item GTIN"; Boolean)
        {
            Caption = 'Lookup Item GTIN';
            InitValue = true;
            DataClassification = SystemMetadata;
        }
        field(12; "Lookup Account Mapping"; Boolean)
        {
            Caption = 'Lookup Account Mapping';
            InitValue = true;
            DataClassification = SystemMetadata;
        }
        field(13; "Validate Line Discount"; Boolean)
        {
            Caption = 'Validate Line Discount';
            InitValue = true;
            DataClassification = SystemMetadata;
        }
        field(14; "Apply Invoice Discount"; Boolean)
        {
            Caption = 'Apply Invoice Discount';
            InitValue = true;
            DataClassification = SystemMetadata;
        }
        field(15; "Verify Totals"; Boolean)
        {
            Caption = 'Verify Totals';
            InitValue = true;
            DataClassification = SystemMetadata;
        }
        field(16; "General Journal Template Name"; Code[10])
        {
            Caption = 'General Journal Template Name';
            TableRelation = "Gen. Journal Template";

            trigger OnValidate()
            var
                GenJournalTemplate: Record "Gen. Journal Template";
                xGenJournalTemplate: Record "Gen. Journal Template";
            begin
                if "General Journal Template Name" = '' then begin
                    "General Journal Batch Name" := '';
                    exit;
                end;
                GenJournalTemplate.Get("General Journal Template Name");
                if not (GenJournalTemplate.Type in
                        [GenJournalTemplate.Type::General, GenJournalTemplate.Type::Purchases, GenJournalTemplate.Type::Payments,
                         GenJournalTemplate.Type::Sales, GenJournalTemplate.Type::"Cash Receipts"])
                then
                    Error(
                      TemplateTypeErr,
                      GenJournalTemplate.Type::General, GenJournalTemplate.Type::Purchases, GenJournalTemplate.Type::Payments,
                      GenJournalTemplate.Type::Sales, GenJournalTemplate.Type::"Cash Receipts");
                if xRec."General Journal Template Name" <> '' then
                    if xGenJournalTemplate.Get(xRec."General Journal Template Name") then;
                if GenJournalTemplate.Type <> xGenJournalTemplate.Type then
                    "General Journal Batch Name" := '';
            end;
        }
        field(17; "General Journal Batch Name"; Code[10])
        {
            Caption = 'General Journal Batch Name';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("General Journal Template Name"));
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                GenJournalBatch: Record "Gen. Journal Batch";
            begin
                if "General Journal Batch Name" <> '' then
                    TestField("General Journal Template Name");
                GenJournalBatch.Get("General Journal Template Name", "General Journal Batch Name");
                GenJournalBatch.TestField(Recurring, false);
            end;
        }
        field(18; "Auto Import"; Boolean)
        {
            Caption = 'Auto Import';
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(19; "Import Start Time"; Time)
        {
            Caption = 'Batch Start Time';
            DataClassification = SystemMetadata;
            NotBlank = true;
            InitValue = 0T;
        }
        field(20; "Import Minutes between runs"; Integer)
        {
            Caption = 'Minutes between runs';
            DataClassification = SystemMetadata;
            InitValue = 1440;
        }
        field(21; "Batch Mode"; Enum "E-Document Batch Mode")
        {
            Caption = 'Batch Mode';
            DataClassification = SystemMetadata;
        }
        field(22; "Batch Threshold"; Integer)
        {
            Caption = 'Batch Threshold';
            MinValue = 1;
            DataClassification = SystemMetadata;
        }
        field(23; "Batch Start Time"; Time)
        {
            Caption = 'Start Time';
            DataClassification = SystemMetadata;
            NotBlank = true;
            InitValue = 0T;
        }
        field(24; "Batch Minutes between runs"; Integer)
        {
            Caption = 'Minutes between runs';
            DataClassification = SystemMetadata;
            InitValue = 1440;
        }
        field(25; "Batch Recurrent Job Id"; Guid)
        {
            Caption = 'Batch Recurrent Job Id';
            DataClassification = SystemMetadata;
        }
        field(26; "Import Recurrent Job Id"; Guid)
        {
            Caption = 'Batch Recurrent Job Id';
            DataClassification = SystemMetadata;
        }
        field(27; "Service Integration V2"; Enum "Service Integration")
        {
            Caption = 'Service Integration V2';
            ToolTip = 'Specifies the integration for sending documents to the service.';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                CustConcentMgt: Codeunit "Customer Consent Mgt.";
            begin
                if (xRec."Service Integration V2" = xRec."Service Integration V2"::"No Integration") and (Rec."Service Integration V2" <> xRec."Service Integration V2") then
                    if not CustConcentMgt.ConfirmCustomConsent(ChooseIntegrationConsentTxt) then
                        Rec."Service Integration V2" := xRec."Service Integration V2";
            end;
        }
        field(28; "Sent Actions Integration"; Enum "Sent Document Actions")
        {
            Caption = 'Sent Actions For Service';
            ToolTip = 'Specifies the implementation of actions that can be performed after the document is sent to the service.';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        EDocServiceSupportedType: Record "E-Doc. Service Supported Type";
        EDocBackgroundJobs: Codeunit "E-Document Background Jobs";
    begin
        EDocServiceSupportedType.SetRange("E-Document Service Code", Rec.Code);
        EDocServiceSupportedType.DeleteAll();

        EDocBackgroundJobs.RemoveJob(Rec."Batch Recurrent Job Id");
        EDocBackgroundJobs.RemoveJob(Rec."Import Recurrent Job Id");
    end;

    internal procedure ToString(): Text
    begin
#if not CLEAN26
        exit(StrSubstNo(EDocStringLbl, SystemId, "Document Format", "Service Integration", "Use Batch Processing", "Batch Mode"));
#else
        exit(StrSubstNo(EDocStringLbl, SystemId, "Document Format", "Service Integration V2", "Use Batch Processing", "Batch Mode"));
#endif
    end;

    var
        EDocStringLbl: Label '%1,%2,%3,%4,%5', Locked = true;
        TemplateTypeErr: Label 'Only General Journal Templates of type %1, %2, %3, %4, or %5 are allowed.', Comment = '%1 - General, %2 - Purchases, %3 - Payments, %4 - Sales, %5 - Cash, %6 - Receipts';
        ChooseIntegrationConsentTxt: Label 'By choosing this option, you consent to use third party systems. These systems may have their own terms of use, license, pricing and privacy, and they may not meet the same compliance and security standards as Microsoft Dynamics 365 Business Central. Your privacy is important to us.';
}
