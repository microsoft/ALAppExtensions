page 4763 "Create Contoso Svc Demo Data"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Contoso Coffee Svc Demo Data';
    SourceTable = "Svc Demo Data Setup";
    DeleteAllowed = false;
    InsertAllowed = false;
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Starting Year"; Rec."Starting Year")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the first year that you you want to use for the Contoso demonstration data.';
                }
                field("Company Type"; Rec."Company Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the company type.';
                }
            }

            group("Master Data")
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number to use for the scenarios.';
                }
                field("Item 1 No."; Rec."Item 1 No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the main number to use for the scenarios.';
                }
                field("Item 2 No."; Rec."Item 2 No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies extra item number to use for the scenarios.';
                }
                field("Resource L1 No."; Rec."Resource L1 No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the local resource number to use for the small unit scenarios.';
                }
                field("Resource L2 No."; Rec."Resource L2 No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the local resource number to use for the large unit scenarios.';
                }
                field("Resource R1 No."; Rec."Resource R1 No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the remote resource number to use for the small unit scenarios.';
                }
                field("Resource R2 No."; Rec."Resource R2 No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the remote resource number to use for the large unit scenarios.';
                }
            }
            group("Posting Setup")
            {
                Caption = 'Posting Setup';
                field("Cust. Posting Group"; Rec."Cust. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer posting group for the customer for the all scenarios.';
                }
                field("Cust. Gen. Bus. Posting Group"; Rec."Cust. Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the general business posting group for the customer for all scenarios.';
                }
                field("Svc. Gen. Prod. Posting Group"; Rec."Svc. Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the general product posting group for the service G/L Account fees for all scenarios.';
                }
                field("Domestic Code"; Rec."Domestic Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT business posting group field used by new customers and new vendors for all scenarios.';
                }
                field("Resale Code"; Rec."Resale Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the inventory posting group used for items for all scenarios.';
                }
                field("Retail Code"; Rec."Retail Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the general product posting group for items for all scenarios.';
                }
                field("VAT Prod. Posting Group Code"; Rec."VAT Prod. Posting Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT product posting group code used on items if VAT is used.';
                }
            }

            group("Pricing")
            {
                Caption = 'Price/cost factor and rounding';
                field("Price Factor"; Rec."Price Factor")
                {
                    Caption = 'Price Factor';
                    ApplicationArea = All;
                    ToolTip = 'Specifies a factor to convert a price from USD/EUR to your local currency. 1 means that the price is 149 in any currency. A higher number will be used to get the price in your local currency.';
                }
                field("Rounding Precision"; Rec."Rounding Precision")
                {
                    Caption = 'Rounding Precision';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rounding precision for prices on items.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Create Demo Data")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Adds new demonstration data for the Warehousing capabilities in Business Central.';
                Enabled = not IsDemoDataPopulated;
                Image = Apply;

                trigger OnAction()
                begin
                    //TODO
                    // Telemetry.LogMessage('0000JJL', StrSubstNo(ContosoCoffeeDemoDatasetInitilizationTok, ContosoCoffeeDemoDatasetFeatureNameTok),
                    // Verbosity::Normal, DataClassification::SystemMetadata);

                    CreateServiceDemoData.Create();
                    IsDemoDataPopulated := true;
                    Message(DemoDataInsertedMsg)
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        //TODO
        // FeatureTelemetry.LogUptake('0000JJK', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::Discovered);

        CreateServiceDemoData.InitServiceDemoDataSetup();
        IsDemoDataPopulated := CreateServiceDemoData.IsDemoDataPopulated();
    end;

    var
        CreateServiceDemoData: Codeunit "Create Service Demo Data";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Telemetry: Codeunit Telemetry;
        IsDemoDataPopulated: Boolean;
        DemoDataInsertedMsg: Label 'The Contoso Coffee demo data is now available in the current company.';
        ContosoCoffeeDemoDatasetFeatureNameTok: Label 'ContosoCoffeeDemoDataset', Locked = true;
        ContosoCoffeeDemoDatasetInitilizationTok: Label '%1: installation initialized from page', Locked = true;
}