page 149006 "BCPT Suite API"
{
    PageType = API;

    APIPublisher = 'microsoft';
    APIGroup = 'performancToolkit';
    APIVersion = 'v1.0';
    Caption = 'BCPT Suite API';

    EntityCaption = 'bcptSuite';
    EntitySetCaption = 'bcptSuite';
    EntityName = 'bcptSuite';
    EntitySetName = 'bcptSuites';

    SourceTable = "BCPT Header";
    ODataKeyFields = SystemId;

    Extensible = false;
    DelayedInsert = true;


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field("durationInMinutes"; Rec."Duration (minutes)")
                {
                    Caption = 'Duration (minutes)';
                }
                field("defaultMinimumUserDelayInMilliSeconds"; Rec."Default Min. User Delay (ms)")
                {
                    Caption = 'Default Min. User Delay (ms)';
                }
                field("defaultMaximumUserDelayInMilliSeconds"; Rec."Default Max. User Delay (ms)")
                {
                    Caption = 'Default Max. User Delay (ms)';
                }
                field("workDateStartsAt"; Rec."Work date starts at")
                {
                    Caption = 'Work date starts at';
                }
                field("oneDayCorrespondsToInMinutes"; Rec."1 Day Corresponds to (minutes)")
                {
                    Caption = '1 Work Day Corresponds to (minutes)';
                }
                field(tag; Rec.Tag)
                {
                    Caption = 'Tag';
                }
                part("testSuitesLines"; "BCPT Suite Line API")
                {
                    Caption = 'BCPT Suite Line';
                    EntityName = 'bcptSuiteLine';
                    EntitySetName = 'bcptSuiteLines';
                    SubPageLink = "BCPT Code" = Field("Code");
                }
            }
        }
    }
}