﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

pageextension 11756 "VAT Posting Setup CZL" extends "VAT Posting Setup"
{
    layout
    {
        addafter("EU Service")
        {
            field("Intrastat Service CZL"; Rec."Intrastat Service CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies if this combination of VAT business posting group and VAT product posting group is used to the intrastat journal.';
            }
        }
        addlast(Control1)
        {
            field("Sales VAT Curr. Exch. Acc CZL"; Rec."Sales VAT Curr. Exch. Acc CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the G/L account for clearing sales VAT due to the different exchange rate for VAT';
                Visible = false;
            }
            field("Purch. VAT Curr. Exch. Acc CZL"; Rec."Purch. VAT Curr. Exch. Acc CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the G/L account for clearing purchase VAT due to the different exchange rate for VAT';
                Visible = false;
            }
            field("VIES Purchase CZL"; Rec."VIES Purchase CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the option to include this posting setup in the purchase VIES declarations.';
                Visible = false;
            }
            field("VAT LCY Corr. Rounding Acc.CZL"; Rec."VAT LCY Corr. Rounding Acc.CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the account to which the VAT correction in LCY will be posted on documents in foreign currency, eg use an account for document rounding';
                Visible = false;
            }
            field("VIES Sales CZL"; Rec."VIES Sales CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the option to include this posting setup in sales VIES declarations.';
                Visible = false;
            }
            field("VAT Rate CZL"; Rec."VAT Rate CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies typ of VAT rate - base, reduced or reduced 2.';
            }
            field("Ratio Coefficient CZL"; Rec."Ratio Coefficient CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies ratio coefficient.';
            }
            field("Corrections Bad Receivable CZL"; Rec."Corrections Bad Receivable CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the designation of the receivable for the purposes of VAT Control Report.';
                Visible = false;
            }
            field("Supplies Mode Code CZL"; Rec."Supplies Mode Code CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies supplies mode code from VAT layer. The setting is used in the VAT Control Report.';
                Visible = false;
            }
            field("Reverse Charge Check CZL"; Rec."Reverse Charge Check CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if and how reverse charge will be checked depending on Commodity Limit Amount';
                Visible = false;
            }
        }
    }
}
