// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Finance.TCS.TCSReturnAndSettlement;

pageextension 18814 "Accountant Role Center TCS" extends "Accountant Role Center"
{
    actions
    {
        addlast("India Taxation")
        {
            group("Tax Collected at Source")
            {
                group("Auto Configuration TCS")
                {
                    Caption = 'Auto Configuration';

                    action("TCS Nature of Collection")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'TCS Nature of Collection';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "TCS Nature of Collections";
                        ToolTip = 'Specifies the TCS Nature of Collection under which tax has been collected.';
                    }
                }
                group("User Configuration TCS")
                {
                    Caption = 'User Configuration';

                    action("TCS Posting Setup")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'TCS Posting Setup';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "TCS Posting Setup";
                        ToolTip = 'Specifies the TCS nature of collection on which TCS is liable to be collected.';
                    }
                    action("T.C.A.N. Nos.")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'T.C.A.N. Nos.';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "T.C.A.N. Nos.";
                        RunPageMode = Edit;
                        ToolTip = 'T.C.A.N. number is allotted by Income Tax Department to the collector.';
                    }
                    action("TCS Rates")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'TCS Rates';
                        Promoted = false;
                        Image = EditList;
                        RunObject = page "Tax Rates";
                        RunPageLink = "Tax Type" = const('TCS');
                        RunPageMode = Edit;
                        ToolTip = 'Specifies the TCS rates for each NOC and assessee type in the TCS rates window.';
                    }
                }
                group("Periodic Activities")
                {
                    action("Update TCS Register")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Update TCS Register';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "Update TCS Register";
                        ToolTip = 'TCS Update is a register maintained to keep track of all the TCS payments made to the government with relevant challan details.';
                    }
                    action("TCS Challan Register")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'TCS Challan Register';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "TCS Challan Register";
                        ToolTip = 'TCS Challan Register is a register maintained to keep track of Interest and Penalties paid to the Income Tax Department with TCS amount through challan.';
                    }
                    action("TCS Adjustment Journal")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'TCS Adjustment Journal';
                        Promoted = false;
                        Image = EditList;
                        RunObject = Page "TCS Adjustment Journal";
                        ToolTip = 'TCS Adjustment Journals are used for correction of the TCS amount/TCS Base amount already deducted but not paid to the government.';
                    }
                }
            }
        }
    }
}
