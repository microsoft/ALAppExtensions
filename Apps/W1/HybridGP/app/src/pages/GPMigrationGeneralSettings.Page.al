page 4102 "GP Migration General Settings"
{
    Caption = 'GP Migration General Settings';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            label(DescriptionHeader)
            {
                ApplicationArea = All;
                Caption = 'Description';
                Style = Strong;
            }
            label(Intro)
            {
                ApplicationArea = All;
                Caption = 'Use this page to configure general settings for the migration.';
            }

            group(OverallSettings)
            {
                Caption = 'Overall Settings';

                field("TwoStepProcess"; UseTwoStepProcess)
                {
                    Caption = 'Enable two step process';
                    ToolTip = 'Specify if you would like to run the replication step separately from the upgrade step.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        GPConfiguration: Record "GP Configuration";
                    begin
                        GPConfiguration.GetSingleInstance();
                        GPConfiguration.Validate("Use Two Step Process", UseTwoStepProcess);
                        GPConfiguration.Modify();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        GPConfiguration: Record "GP Configuration";
    begin
        GPConfiguration.GetSingleInstance();
        UseTwoStepProcess := GPConfiguration.ShouldUseTwoStepProcess();
    end;

    var
        UseTwoStepProcess: Boolean;
}