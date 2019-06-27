page 130450 "AL Test Suites"
{
    PageType = List;
    SaveValues = true;
    SourceTable = "AL Test Suite";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name;Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the test suite.';
                }
                field(Description;Description)
                {
                    ApplicationArea = All;
                }
                field("Tests to Execute";"Tests to Execute")
                {
                    ApplicationArea = All;
                }
                field(Failures;Failures)
                {
                    ApplicationArea = All;
                }
                field("Tests not Executed";"Tests not Executed")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

