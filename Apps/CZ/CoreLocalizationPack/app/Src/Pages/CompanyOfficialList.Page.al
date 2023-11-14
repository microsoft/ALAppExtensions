// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;

page 11765 "Company Official List CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Company Officials';
    CardPageId = "Company Official Card CZL";
    Editable = false;
    PageType = List;
    SourceTable = "Company Official CZL";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of company official.';
                }
                field(FullName; Rec.FullName())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Full Name';
                    ToolTip = 'Specifies the company official''s full name.';
                    Visible = false;
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s first name.';
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s middle name.';
                    Visible = false;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s last name.';
                }
                field(Initials; Rec.Initials)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s initials.';
                    Visible = false;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s job title.';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s post code.';
                    Visible = false;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s country and region.';
                    Visible = false;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s phone number.';
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s mobile phone number.';
                    Visible = false;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the e-mail address for the company official.';
                    Visible = false;
                }
                field("Privacy Blocked"; Rec."Privacy Blocked")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether to limit access to data for the data subject during daily operations. This is useful, for example, when protecting data from changes while it is under privacy review.';
                    Visible = false;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the employee number for the company official.';
                }
                field("Search Name"; Rec."Search Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company official''s search name.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
}
