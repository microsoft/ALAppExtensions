// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Foundation.Address;
#if not CLEAN22
using Microsoft.Foundation.Company;
#endif
using Microsoft.Inventory.Intrastat;
#if not CLEAN22
using System.Environment.Configuration;
#endif

tableextension 11754 "Purchase Line CZL" extends "Purchase Line"
{
    fields
    {
        field(11769; "Negative CZL"; Boolean)
        {
            Caption = 'Negative';
            DataClassification = CustomerContent;
        }
        field(11773; "Ext. Amount CZL"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Ext. Amount';
            Editable = false;
#if not CLEAN24
            ObsoleteState = Pending;
            ObsoleteTag = '24.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '27.0';
#endif
            ObsoleteReason = 'The field is not used anymore.';
        }
        field(11774; "Ext. Amount Incl. VAT CZL"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Ext. Amount Including VAT';
            Editable = false;
#if not CLEAN24
            ObsoleteState = Pending;
            ObsoleteTag = '24.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '27.0';
#endif
            ObsoleteReason = 'The field is not used anymore.';
        }
        field(31064; "Physical Transfer CZL"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
#if not CLEAN22

            trigger OnValidate()
            begin
                if "Physical Transfer CZL" then begin
                    TestField(Type, Type::Item);
                    if not ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]) then
                        FieldError("Document Type");
                end;
            end;
#endif
        }
        field(31065; "Tariff No. CZL"; Code[20])
        {
            Caption = 'Tariff No.';
            TableRelation = "Tariff Number";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TariffNumber: Record "Tariff Number";
            begin
                if (Type = Type::"G/L Account") and ("Tariff No. CZL" <> xRec."Tariff No. CZL") then begin
                    if not TariffNumber.Get("Tariff No. CZL") then
                        TariffNumber.Init();
                    if TariffNumber."VAT Stat. UoM Code CZL" <> '' then
                        Validate("Unit of Measure Code", TariffNumber."VAT Stat. UoM Code CZL");
                end;
#if not CLEAN22
#pragma warning disable AL0432
                if "Tariff No. CZL" <> xRec."Tariff No. CZL" then
                    "Statistic Indication CZL" := '';
#pragma warning restore AL0432
#endif
            end;
        }
        field(31066; "Statistic Indication CZL"; Code[10])
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
        field(31067; "Country/Reg. of Orig. Code CZL"; Code[10])
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
    }
#if not CLEAN22
    [Obsolete('Intrastat related functionalities are moved to Intrastat extensions.', '22.0')]
    procedure CheckIntrastatMandatoryFieldsCZL(PurchaseHeader: Record "Purchase Header")
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        FeatureMgtFacade: Codeunit "Feature Management Facade";
        IntrastatFeatureKeyIdTok: Label 'ReplaceIntrastat', Locked = true;
    begin
        if FeatureMgtFacade.IsEnabled(IntrastatFeatureKeyIdTok) then
            exit;
        if Type <> Type::Item then
            exit;
        if ("Qty. to Receive" = 0) and ("Return Qty. to Ship" = 0) then
            exit;
        if not (PurchaseHeader.Ship or PurchaseHeader.Receive) then
            exit;
        if not PurchaseHeader.IsIntrastatTransactionCZL() then
            exit;
        StatutoryReportingSetupCZL.Get();
        if StatutoryReportingSetupCZL."Tariff No. Mandatory" then
            TestField("Tariff No. CZL");
        if StatutoryReportingSetupCZL."Net Weight Mandatory" and IsInventoriableItem() then
            TestField("Net Weight");
        if StatutoryReportingSetupCZL."Country/Region of Origin Mand." then
            TestField("Country/Reg. of Orig. Code CZL");
    end;
#endif
}
