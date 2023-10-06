// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;

pageextension 18543 "CompanyInformation" extends "Company Information"
{
    layout
    {
        addlast(General)
        {
            field("Company Status"; Rec."Company Status")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Company Status';
                ToolTip = 'Specifies the status of the company as Public Limited/Private Limited/Government or Others.';
            }
        }
        addafter(Shipping)
        {
            group("E-Filling")
            {
                field("P.A.N. Status"; Rec."P.A.N. Status")
                {
                    Caption = 'P.A.N. Status';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the PAN status of the company, whether the PAN number is available or not.';
                }
                field("P.A.N. No."; Rec."P.A.N. No.")
                {
                    Caption = 'P.A.N. No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the P.A.N. number of the company.';
                }
                field("Deductor Category"; Rec."Deductor Category")
                {
                    Caption = 'Deductor Category';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the deductor category of the company for TDS deduction.';
                }
                field("PAO Code"; Rec."PAO Code")
                {
                    Caption = 'PAO Code';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies pay and accounts officer code for eTDS return purpose.';
                }
                field("PAO Registration No."; Rec."PAO Registration No.")
                {
                    Caption = 'PAO Registration No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies PAO registration number of the company for eTDS return purpose.';
                }
                field("DDO Code"; Rec."DDO Code")
                {
                    Caption = 'DDO Code';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the DDO of the District Nodal Office. ';
                }
                field("DDO Registration No."; Rec."DDO Registration No.")
                {
                    Caption = 'DDO Registration No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the DDO registration number.';
                }
                field("Ministry Type"; Rec."Ministry Type")
                {
                    Caption = 'Ministry Type';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ministry type as Regular or Other.';
                }
                field("Ministry Code"; Rec."Ministry Code")
                {
                    Caption = 'Ministry Code';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Ministry code.';
                }
            }
        }
        addafter("E-Filling")
        {
            group("Tax Information")
            {
                field("T.A.N. No."; Rec."T.A.N. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the T.A.N No of Company';
                }
                field("State Code"; Rec."State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the State Code of Company';
                }
            }
        }
    }
}
