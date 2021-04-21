page 2051 "MS - Data Sharing Setup"
{
    Caption = 'Anonymized Data Sharing Setup';
    PageType = Card;
    DeleteAllowed = false;
    InsertAllowed = false;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(GroupName)
            {
                Caption = '';

                field(EnabledStateField; EnabledState)
                {
                    Caption = 'Enabled';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Anonymized Data Sharing is enabled';

                    trigger OnValidate();
                    var
                        MSDataSharingLearnMore: Page "MS - Data Sharing Learn More";
                    begin
                        // run the wizard so it is clearer what this is about,
                        // for users that discover the feature from the search or from the Service Connections page
                        MSDataSharingLearnMore.RunModal();

                        GetEnabledState();
                        CurrPage.Update();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            Action(LearnMorePrivacy)
            {
                ApplicationArea = Invoicing, Basic, Suite;
                Caption = 'Learn more (Privacy)';
                Image = LinkWeb;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Look at our privacy disclaimer.';

                trigger OnAction();
                begin
                    DataSharingMgt.ShowPrivacyStatement();
                end;
            }
        }
    }

    trigger OnOpenPage();
    begin
        GetEnabledState();
    end;

    local procedure GetEnabledState();
    var
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
    begin
        if MSDataSharingSetup.Get(DataSharingMgt.GetCurrentCompanyId()) then
            EnabledState := MSDataSharingSetup.Enabled;
    end;

    var
        DataSharingMgt: Codeunit "MS - Data Sharing Mgt.";
        EnabledState: Boolean;

}