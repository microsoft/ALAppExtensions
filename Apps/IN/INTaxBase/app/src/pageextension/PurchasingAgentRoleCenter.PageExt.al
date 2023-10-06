// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.RoleCenters;

using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

pageextension 18565 "Purchasing Agent Role Center" extends "Purchasing Agent Role Center"
{
    actions
    {
        addlast(sections)
        {
            group("India Taxation")
            {
                group("Common Setup")
                {
                    group("Auto Configuration")
                    {
                        action("Tax Types")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Tax Types';
                            Image = EditList;
                            RunObject = Page "Tax Types";
                            ToolTip = 'Specifies the type of Tax to be calculated.';
                        }
                        action("States")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'States';
                            Image = EditList;
                            RunObject = Page States;
                            RunPageMode = Edit;
                            ToolTip = 'Specifies the state of the specified address.';
                        }
                        action("Tax Accounting Periods")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Tax Accounting Periods';
                            Image = EditList;
                            RunObject = Page "Tax Accounting Periods";
                            ToolTip = 'Specifies the  accounting periods which are required to file tax returns.';
                        }
                    }
                    group("User Configuration")
                    {
                        action("Assessee Codes")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Assessee Codes';
                            Promoted = false;
                            Image = EditList;
                            RunObject = Page "Assessee Codes";
                            ToolTip = 'Specifies a person by whom any tax or any other sum of money is payable under Income Tax Act.';
                        }
                        action("Concessional Codes")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Concessional Codes';
                            Promoted = false;
                            Image = EditList;
                            RunObject = Page "Concessional Codes";
                            RunPageMode = Edit;
                            ToolTip = 'Specifies the concessional code for cases authorized for concessional rates exclusively by the government.';
                        }
                        action("Deductor Categories")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Deductor Categories';
                            Promoted = false;
                            Image = EditList;
                            RunObject = Page "Deductor Categories";
                            RunPageMode = Edit;
                            ToolTip = 'Specifies the code of type of deductor /employer.';
                        }
                        action("Ministry")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Ministries';
                            Promoted = false;
                            Image = EditList;
                            RunObject = Page Ministries;
                            RunPageMode = Edit;
                            ToolTip = 'Specifies the Ministry name which is mandatory for deductor type Central - Govt (A), Statutory body - Central Govt. (D) & Autonomous body - Central Govt. (G).';
                        }
                    }
                }
            }
        }
    }
}
