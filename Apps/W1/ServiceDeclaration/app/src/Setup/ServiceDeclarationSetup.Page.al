// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

page 5010 "Service Declaration Setup"
{
    DataCaptionExpression = '';
    PageType = Card;
    SourceTable = "Service Declaration Setup";
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Declaration No. Series"; Rec."Declaration No. Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the no. series for the service declarations.';
                }
                field("Report Item Charges"; Rec."Report Item Charges")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the item charges have to be reported in the service declaration. If enabled, system checks the service transaction code for item charges and include them into service declarations.';
                }
                field("Sell-To/Bill-To Customer No."; Rec."Sell-To/Bill-To Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies which customer must be taken to compare his country code with the country code from the Company Information page. Only documents where these two codes are different will be considered for the service declaration. Bill-To.: The country code will be taken from the Bill-to Customer. Sell-To. : The country code will be taken from the Sell-to Customer.';
                }
                field("Buy-From/Pay-To Vendor No."; Rec."Buy-From/Pay-To Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies which vendor must be taken to compare his country code with the country code from the Company Information page. Only documents where these two codes are different will be considered for the service declaration. Buy-From.: The country code will be taken from the Buy-From Vendor. Pay-To. : The country code will be taken from the Pay-To Vendor.';
                }
                field("Data Exch. Def. Code"; Rec."Data Exch. Def. Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the data exchange definition code used to generate the exported file for the service declaration.';
                }
                field("Enable VAT Registration No."; Rec."Enable VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the VAT Registration No. is enabled for the service declaration.';
                }
                field("Vend. VAT Reg. No. Type"; Rec."Vend. VAT Reg. No. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how a vendor''s VAT registration number exports to the file. 0 is the value of the VAT Reg. No. field, 1 adds the country code as a prefix, and 2 removes the country code.';
                }
                field("Cust. VAT Reg. No. Type"; Rec."Cust. VAT Reg. No. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how a customer''s VAT registration number exports to the file. 0 is the value of the VAT Reg. No. field, 1 adds the country code as a prefix, and 2 removes the country code.';
                }
                field("Def. Customer/Vendor VAT No."; Rec."Def. Customer/Vendor VAT No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT registration number that will be used if customer or vendor company does not have its own VAT registration number.';
                    Visible = false;
                }
                field("Def. Private Person VAT No."; Rec."Def. Private Person VAT No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT registration number that will be used if customer or vendor private person does not have its own VAT registration number.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ImportDefaultDataExchangeDef)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Create Default Data Exch. Def.';
                Image = Create;
                ToolTip = 'Create/Restore Default Data Exchange Definition(-s)';
                trigger OnAction()
                var
                    ServDeclMgt: Codeunit "Service Declaration Mgt.";
                begin
                    ServDeclMgt.CreateDefaultDataExchangeDef();
                end;
            }
        }
    }
}
