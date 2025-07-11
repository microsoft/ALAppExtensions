// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.RoleCenters;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Payments;
using Microsoft.Finance.GST.Reconcilation;
using Microsoft.Finance.GST.ReturnSettlement;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

pageextension 18254 "Purchase Agent Role Center GST" extends "Purchasing Agent Role Center"
{
    Actions
    {
        addafter("Common Setup")
        {
            group("Goods and Services Tax")
            {
                group("Auto Configuration GST")
                {
                    Caption = 'Auto Configuration';
                    action("GST Group")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'GST Group';
                        Promoted = false;
                        Image = EditList;
                        RunObject = page "GST Group";
                        ToolTip = 'Specifies an unique identifier for the GST group code used to calculate and post GST';
                    }
                    action("HSN/SAC")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'HSN/SAC';
                        Promoted = false;
                        Image = EditList;
                        RunObject = page "HSN/SAC";
                        ToolTip = 'Specifies an unique identifier for the type of HSN or SAC that is used to calculate and post GST.';
                    }
                }
                group("User Configuration GST")
                {
                    Caption = 'User Configuration';
                    action("GST Registration Nos.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'GST Registration Nos.';
                        Promoted = false;
                        Image = EditList;
                        RunObject = page "GST Registration Nos.";
                        ToolTip = 'Specifies the goods and services tax registration number of the location.';
                    }
                    action("GST Posting Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'GST Posting Setup';
                        Promoted = false;
                        Image = EditList;
                        RunObject = page "GST Posting Setup";
                        ToolTip = 'Specifies the general ledger accounts in combination of state code and GST component code, which will be used for the posting of calculated GST.';
                    }
                    action("GST Rates")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'GST Rates';
                        Promoted = false;
                        Image = EditList;
                        RunObject = page "Tax Rates";
                        RunPageLink = "Tax Type" = const('GST');
                        RunPageMode = Edit;
                        ToolTip = 'Specifies the rates for the defined components, which will be used to calculate GST.';
                    }
                }
                group("Periodic Activities")
                {
                    action("GST Credit Adjustment")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'GST Credit Adjustment';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "GST Credit Adjustment";
                        ToolTip = 'GST credit adjustment is a type of journal to keep track of all the credit adjustments made.';
                    }
                    action("GST Reconciliation")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'GST Reconciliation';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "GST Reconcilation List";
                        ToolTip = 'GST Reconciliation is a process to keep track of all the GST reconciliation.';
                    }
                    action("GST Settlement")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'GST Settlement';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "GST Settlement";
                        ToolTip = 'GST Settlement is a process to keep track of all the GST settlement made.';
                    }
                    action("GST Liability Adjustment")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'GST Liability Adjustment';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "GST Liability Adjustment";
                        ToolTip = 'GST liability adjustment is a type of journal to keep track of all the liability adjustments made in GST.';
                    }
                    action("GST Adjustment Journal")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'GST Adjustment Journal';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "GST Adjustment Journal";
                        ToolTip = 'GST adjustment journal is a type of journal to keep track of all the GST adjustments made.';
                    }
                    action("Update GST TDS Certificate")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Update GST TDS Certificate';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "Update GST TDS Certificate Dtl";
                        ToolTip = 'Update GST TDS certificate is a register maintained to keep track of all the GST TDS certificates with relevant details.';
                    }
                }
            }
        }
        addlast("User Configuration")
        {
            action("Bank Charge Deemed Value Setup")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bank Charge Deemed Value Setup';
                Promoted = false;
                Image = EditList;
                RunObject = page "Bank Charge Deemed Value Setup";
            }
        }
    }
}
