// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Finance.TDS.TDSForCustomer;
using Microsoft.Finance.TDS.TDSReturnAndSettlement;

pageextension 18753 "Accountant Role Center TDS" extends "Accountant Role Center"
{
    actions
    {
        addlast("India Taxation")
        {
            group("Tax Deducted at Source")
            {
                group("Auto Configuration TDS")
                {
                    Caption = 'Auto Configuration';

                    action("Section")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'TDS Section';
                        Promoted = false;
                        Image = EditList;
                        ToolTip = 'Specify the section codes as per the Income Tax Act of 1961 for eTDS Returns.';
                        RunObject = Page "TDS Sections";
                    }
                }
                group("User Configuration TDS")
                {
                    Caption = 'User Configuration';

                    action("TDS Posting Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'TDS Posting Setup';
                        Promoted = false;
                        Image = EditList;
                        ToolTip = 'Open record TDS Posting Setup ';
                        RunObject = Page "TDS Posting Setup";
                        RunPageMode = Edit;
                    }
                    action("TDS Rates")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'TDS Rates';
                        Promoted = false;
                        Image = EditList;
                        ToolTip = 'Open record TDS Rates';
                        RunObject = Page "Tax Rates";
                        RunPageLink = "Tax Type" = const('TDS');
                        RunPageMode = Edit;
                    }
                    action("T.A.N. Nos.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'T.A.N. Nos.';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "T.A.N. Nos.";
                        ToolTip = 'Specifies the T.A.N. number of the location.';
                    }
                    action("Nature Of Remittances")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Nature Of Remittances';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "TDS Nature Of Remittances";
                        ToolTip = 'Specify the type of Remittance deductee deals with.';
                    }
                    action("Act Applicable")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Act Applicable';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "Act Applicable";
                        ToolTip = 'Specify the tax rates prescribed under the IT Act or DTAA.';
                    }
                }
                group("Periodic Activities")
                {
                    action("Update TDS Register")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Update TDS Register';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "Update TDS Register";
                        ToolTip = 'TDS Update is a register maintained to keep track of all the TDS payments made to the government with relevant challan details.';
                    }
                    action("TDS Challan Register")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'TDS Challan Register';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "TDS Challan Register";
                        ToolTip = 'TDS Challan Register is a register maintained to keep track of Interest and Penalties paid to the Income Tax Department with TDS amount through challan.';
                    }
                    action("TDS Adjustment Journal")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'TDS Adjustment Journal';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "TDS Adjustment Journal";
                        ToolTip = 'TDS Adjustment Journals are used for correction of the TDS amount/TDS Base amount already deducted but not paid to the government.';
                    }
                }
                group("TDS for Customer")
                {
                    action("Update TDS Certificate Details")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Update TDS Certificate Details';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "Update TDS Certificate Details";
                        ToolTip = 'Update TDS Certificate Details page allows to Assign TDS cert. details, Update TDS Certificate Details and RectifyTDS Certificate Details.';
                    }
                }
            }
        }
    }
}
