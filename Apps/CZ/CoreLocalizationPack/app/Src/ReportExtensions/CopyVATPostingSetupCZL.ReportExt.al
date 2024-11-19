// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

reportextension 11700 "Copy - VAT Posting Setup CZL" extends "Copy - VAT Posting Setup"
{
    dataset
    {
        modify("VAT Posting Setup")
        {
            trigger OnBeforeAfterGetRecord()
            begin
                VATPostingSetup.Find();
                Description := VATPostingSetup.Description;
                if VATSetup then begin
                    "Reverse Charge Check CZL" := VATPostingSetup."Reverse Charge Check CZL";
                    "VAT Coeff. Corr. Account CZL" := VATPostingSetup."VAT Coeff. Corr. Account CZL";
                    "VAT Rate CZL" := VATPostingSetup."VAT Rate CZL";
                    "Supplies Mode Code CZL" := VATPostingSetup."Supplies Mode Code CZL";
                    "Ratio Coefficient CZL" := VATPostingSetup."Ratio Coefficient CZL";
                    "Corrections Bad Receivable CZL" := VATPostingSetup."Corrections Bad Receivable CZL";
                    "VAT LCY Corr. Rounding Acc.CZL" := VATPostingSetup."VAT LCY Corr. Rounding Acc.CZL";
                end;
                if Sales then
                    "Sales VAT Curr. Exch. Acc CZL" := VATPostingSetup."Sales VAT Curr. Exch. Acc CZL";
                if Purch then
                    "Purch. VAT Curr. Exch. Acc CZL" := VATPostingSetup."Purch. VAT Curr. Exch. Acc CZL";
                if VIESCZL then begin
                    "VIES Purchase CZL" := VATPostingSetup."VIES Purchase CZL";
                    "VIES Sales CZL" := VATPostingSetup."VIES Sales CZL";
                end;
                if VATSetup or VIESCZL then begin
                    "VAT Clause Code" := VATPostingSetup."VAT Clause Code";
                    "EU Service" := VATPostingSetup."EU Service";
                    "Intrastat Service CZL" := VATPostingSetup."Intrastat Service CZL";
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            modify(Copy)
            {
                trigger OnAfterValidate()
                begin
                    VIESCZL := Selection = Selection::"All fields";
                end;
            }
            addlast(Options)
            {
                field(VIESCZL; VIESCZL)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VIES';
                    ToolTip = 'Specifies if vies fields will be copied';

                    trigger OnValidate()
                    begin
                        Selection := Selection::"Selected fields";
                    end;
                }
            }
        }

        trigger OnOpenPage()
        begin
            VIESCZL := Selection = Selection::"All fields";
        end;
    }

    var
        VIESCZL: Boolean;
}
