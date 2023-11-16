// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Reporting;

tableextension 11738 "VAT Posting Setup CZL" extends "VAT Posting Setup"
{
    fields
    {
        field(11770; "Reverse Charge Check CZL"; Enum "Reverse Charge Check CZL")
        {
            Caption = 'Reverse Charge Check';
            DataClassification = CustomerContent;
        }
        field(11774; "Purch. VAT Curr. Exch. Acc CZL"; Code[20])
        {
            Caption = 'Purchase VAT Currency Exchange Rate Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Purch. VAT Curr. Exch. Acc CZL");
            end;
        }
        field(11775; "Sales VAT Curr. Exch. Acc CZL"; Code[20])
        {
            Caption = 'Sales VAT Currency Exchange Rate Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Sales VAT Curr. Exch. Acc CZL");
            end;
        }
        field(31050; "VIES Purchase CZL"; Boolean)
        {
            Caption = 'VIES Purchase';
            DataClassification = CustomerContent;
        }
        field(31051; "VIES Sales CZL"; Boolean)
        {
            Caption = 'VIES Sales';
            DataClassification = CustomerContent;
        }
        field(31071; "Intrastat Service CZL"; Boolean)
        {
            Caption = 'Intrastat Service';
            DataClassification = CustomerContent;
        }
        field(31110; "VAT Rate CZL"; Enum "VAT Rate CZL")
        {
            Caption = 'VAT Rate';
            DataClassification = CustomerContent;
        }
        field(31111; "Supplies Mode Code CZL"; Enum "VAT Ctrl. Report Mode CZL")
        {
            Caption = 'Supplies Mode Code';
            DataClassification = CustomerContent;
        }
        field(31112; "Ratio Coefficient CZL"; Boolean)
        {
            Caption = 'Ratio Coefficient';
            DataClassification = CustomerContent;
        }
        field(31113; "Corrections Bad Receivable CZL"; Enum "VAT Ctrl. Report Corect. CZL")
        {
            Caption = 'Corrections for Bad Receivable';
            DataClassification = CustomerContent;
        }
        field(31115; "VAT LCY Corr. Rounding Acc.CZL"; Code[20])
        {
            Caption = 'VAT LCY Correction Rounding Account';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting));
            DataClassification = CustomerContent;
        }
    }

    procedure GetLCYCorrRoundingAccCZL(): Code[20]
    var
        PostingSetupManagement: Codeunit PostingSetupManagement;
        VATLCYCorrRoundingAccNo: Code[20];
        IsHandled: Boolean;
    begin
        OnBeforeGetLCYCorrRoundingAccCZL(Rec, VATLCYCorrRoundingAccNo, IsHandled);
        if IsHandled then
            exit(VATLCYCorrRoundingAccNo);

        if "VAT LCY Corr. Rounding Acc.CZL" = '' then
            PostingSetupManagement.SendVATPostingSetupNotification(Rec, FieldCaption("VAT LCY Corr. Rounding Acc.CZL"));
        TestField("VAT LCY Corr. Rounding Acc.CZL");
        exit("VAT LCY Corr. Rounding Acc.CZL");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetLCYCorrRoundingAccCZL(var VATPostingSetup: Record "VAT Posting Setup"; var VATLCYCorrRoundingAccNo: Code[20]; var IsHandled: Boolean)
    begin
    end;
}
