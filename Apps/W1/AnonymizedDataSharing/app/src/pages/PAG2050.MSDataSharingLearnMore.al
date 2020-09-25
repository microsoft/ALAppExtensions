page 2050 "MS - Data Sharing Learn More"
{
    Caption = 'Anonymized Data Sharing';
    Editable = False;
    PageType = NavigatePage;

    layout
    {
        area(content)
        {
            group(Heading)
            {
                Caption = 'Help us continue to improve our service';
                InstructionalText = 'If you enable data sharing, we''ll make your data anonymous and use it to improve our service. For example, to make our data analysis and machine learning features even smarter. We will not share your data outside Microsoft, or mine it for advertising. You can stop sharing at any time, and take your data when you go.';
            }

            group(LearnMore)
            {
                Caption = 'Learn more';
                InstructionalText = 'Before you enable data sharing, read our Privacy Statement.';

                field(PrivacyStatementLink; PrivacyStatementLbl)
                {
                    ApplicationArea = Invoicing, Basic, Suite;
                    ToolTip = 'Read our Privacy Statement';
                    ShowCaption = false;

                    trigger OnDrillDown()
                    begin
                        DataSharingManagement.ShowPrivacyStatement();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionEnable)
            {
                ApplicationArea = Invoicing, Basic, Suite;
                Caption = 'Enable';
                Image = Approve;
                InFooterBar = True;
                ToolTip = 'Enable data sharing';

                trigger OnAction()
                begin
                    DataSharingManagement.EnableDataSharing();
                    CurrPage.Close();
                end;
            }

            action(ActionDoNotEnable)
            {
                ApplicationArea = Invoicing, Basic, Suite;
                Caption = 'Do not enable';
                Image = Reject;
                InFooterBar = True;
                ToolTip = 'Do not enable data sharing';

                trigger OnAction()
                begin
                    DataSharingManagement.DisableDataSharing();
                    CurrPage.Close();
                end;
            }
        }
    }
    var
        DataSharingManagement: Codeunit "MS - Data Sharing Mgt.";
        PrivacyStatementLbl: Label 'Privacy Statement';
}