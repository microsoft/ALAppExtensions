// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Factbox part page that enables a user to learn more about upcoming changes
/// </summary>
page 2611 "Upcoming Changes Factbox"
{
    PageType = CardPart;
    Caption = 'Managing change';
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(Header)
            {
                ShowCaption = false;
                group(DescLine1)
                {
                    ShowCaption = false;
                    InstructionalText = 'Some new features are turned off when Dynamics 365 Business Central is updated to a newer version. These features are optional for a period of time until they are automatically enabled for all users in a later software update.';
                }
                group(DescLine2)
                {
                    ShowCaption = false;
                    InstructionalText = 'You can prepare in advance by enabling these features for all users on the right environment at the right time that suits your schedule.';
                }
                group(Links)
                {
                    ShowCaption = false;
                    InstructionalText = ' ';
                    field(LearnMoreNewFeatures; LearnMoreNewFeaturesLbl)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Learn more about managing features.';
                        ShowCaption = false;
                        ToolTip = 'Learn more about feature management.';

                        trigger OnDrillDown()
                        begin
                            Hyperlink(LearnMoreAboutPreviewProcessUrlTxt);
                        end;
                    }

                    field(ReleasePlan; ReleasePlanLbl)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        Caption = 'See the Release Plan';
                        ToolTip = 'See the Release Plan.';

                        trigger OnDrillDown()
                        begin
                            Hyperlink(ReleasePlanUrlTxt);
                        end;
                    }
                }
            }
        }
    }

    var
        LearnMoreNewFeaturesLbl: Label 'Learn more about feature management.';
        ReleasePlanLbl: Label 'See the Release Plan';
        LearnMoreAboutPreviewProcessUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2112707', Locked = true;
        ReleasePlanUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2047422', Locked = true;
}