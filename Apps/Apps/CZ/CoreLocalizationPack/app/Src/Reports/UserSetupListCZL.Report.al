// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.User;

using Microsoft.Finance.Dimension;

report 31201 "User Setup List CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/UserSetupList.rdl';
    Caption = 'User Setup List';

    dataset
    {
        dataitem("User Setup"; "User Setup")
        {
            RequestFilterFields = "User ID";
            column(ginPageGroup; PageGroup)
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(CheckJournalTemplates_US_Fld; Format("Check Journal Templates CZL"))
            {
            }
            column(CheckDimensionvalues_US_Fld; Format("Check Dimension Values CZL"))
            {
            }
            column(CheckBankAccounts_US_Fld; Format("Check Bank Accounts CZL"))
            {
            }
            column(CheckLocationCode_US_Fld; Format("Check Location Code CZL"))
            {
            }
            column(CheckPostDatesysDate_US_Fld; Format("Check Post.Date(sys. date) CZL"))
            {
            }
            column(CheckPostDateWorkDate_US_Fld; Format("Check Post.Date(work date) CZL"))
            {
            }
            column(CheckDocDatesysDate_US_Fld; Format("Check Doc. Date(sys. date) CZL"))
            {
            }
            column(CheckDocDateWorkDate_US_Fld; Format("Check Doc. Date(work date) CZL"))
            {
            }
            column(UserName_US_Fld; "User Name CZL")
            {
                IncludeCaption = true;
            }
            column(UserID_US_Fld; "User ID")
            {
                IncludeCaption = true;
            }
            column(NewPagePerRec_US_Var; NewPagePerRec)
            {
            }
            dataitem("User Setup Line CZL"; "User Setup Line CZL")
            {
                DataItemLink = "User ID" = field("User ID");
                DataItemTableView = sorting("User ID", Type, "Line No.");
                column(CodeName_USL_Fld; "Code / Name")
                {
                    IncludeCaption = true;
                }
                column(Type_USL_Fld; Type)
                {
                    IncludeCaption = true;
                }

                column(UserID_USL_Fld; "User ID")
                {
                }
                column(LineNo_USL_Fld; "Line No.")
                {
                }
                column(User_Setup_Line; 1)
                {
                }
            }
            dataitem("Selected Dimension"; "Selected Dimension")
            {
                DataItemLink = "User ID" = field("User ID");
                DataItemTableView = sorting("User ID", "Object Type", "Object ID", "Analysis View Code", "Dimension Code");
                column(DimensionCode_SD_Fld; "Dimension Code")
                {
                    IncludeCaption = true;
                }
                column(DimensionValueFilter_SD_Fld; "Dimension Value Filter")
                {
                    IncludeCaption = true;
                }
                column(UserID_SD_Fld; "User ID")
                {
                }
                column(ObjectType_SD_Fld; "Object Type")
                {
                }
                column(ObjectID_SD_Fld; "Object ID")
                {
                }
                column(AnalysisViewCode_SD_Fld; "Analysis View Code")
                {
                }
                column(Selected_Dimension; 1)
                {
                }

                trigger OnPreDataItem()
                begin
                    SetRange("Object Type", 1);
                    SetRange("Object ID", DATABASE::"User Setup");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if NewPagePerRec then
                    PageGroup += 1;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NewPagePerRecField; NewPagePerRec)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'User on new page';
                        ToolTip = 'Specifies if every user will appear in a new page';
                    }
                }
            }
        }
    }

    labels
    {
        PageCaptionLbl = 'Page';
        UserChecksListCaptionLbl = 'User Checks List';
        CheckJournalTemplatesCaptionLbl = 'Check Journal Templates';
        CheckDimensionValueCaptionLbl = 'Check Dimension Values';
        CheckBankAccountsCaptionLbl = 'Check Bank Accounts';
        CheckLocationCodeCaptionLbl = 'Check Location Code';
        CheckPostDatesysDateCaptionLbl = 'Check Posting Date (sys. date)';
        CheckPostDateWorkDateCaptionLbl = 'Check Posting Date (work date)';
        CheckDocDatesysDateCaptionLbl = 'Check Document Date(sys. date)';
        CheckDocDateWorkDateCaptionLbl = 'Check Document Date(work date)';
    }

    var
        NewPagePerRec: Boolean;
        PageGroup: Integer;
}
