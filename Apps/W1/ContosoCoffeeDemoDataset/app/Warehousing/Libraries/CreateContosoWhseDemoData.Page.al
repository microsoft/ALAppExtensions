page 4761 "Create Contoso Whse Demo Data"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Contoso Coffee Whse Demo Data';
    SourceTable = "Whse Demo Data Setup";
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
            group(Locations)
            {
                field("Location Basic"; Rec."Location Basic")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the location for the Basic Location scenarios.';
                }
                field("Location Simple Logistics"; Rec."Location Simple Logistics")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the location for the Simple Logistics scenarios.';
                }
                field("Location Advanced Logistics"; Rec."Location Advanced Logistics")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the location for the Advanced Logistics scenarios.';
                }
            }

            group("Master Data")
            {
                field("S. Customer No."; Rec."S. Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number to use for the Basic Location and Simple Logistics scenarios.';
                }
                field("L. Customer No."; Rec."L. Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number to use for the Advanced Logistics scenarios.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies vendor number to use for the scenarios.';
                }
                field("Main Item No."; Rec."Main Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item number to use for the Basic Location and Simple Logistics scenarios.';
                }
                field("Complex Item No."; Rec."Complex Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item number to use for some of the Advanced Logistics scenarios.';
                }
                field("CrossDock Item No."; Rec."CrossDock Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item number to use for the Cross-Dock Advanced Logistics scenario.';
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
                field("Vendor Posting Group"; Rec."Vendor Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor posting group for the vendor for all scenarios.';
                }
                field("Vend. Gen. Bus. Posting Group"; Rec."Vend. Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the general business posting group for the vendor for all scenarios.';
                }
                field("Domestic Code"; Rec."Domestic Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT business posting group field used by customers and vendors for all scenarios.';
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
                    //TODO: Telemetry tag
                    Telemetry.LogMessage('0000H72', StrSubstNo(ContosoCoffeeDemoDatasetInitilizationTok, ContosoCoffeeDemoDatasetFeatureNameTok),
                        Verbosity::Normal, DataClassification::SystemMetadata);

                    CreateWarehousingDemoData.Create();
                    IsDemoDataPopulated := true;
                    Message(DemoDataInsertedMsg)
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        //TODO: Telemetry tag
        FeatureTelemetry.LogUptake('0000GYT', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::Discovered);

        CreateWarehousingDemoData.InitWarehousingDemoDataSetup();
        IsDemoDataPopulated := CreateWarehousingDemoData.IsDemoDataPopulated();
    end;

    var
        CreateWarehousingDemoData: Codeunit "Create Warehousing Demo Data";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Telemetry: Codeunit Telemetry;
        IsDemoDataPopulated: Boolean;
        DemoDataInsertedMsg: Label 'The Contoso Coffee demo data is now available in the current company.';
        ContosoCoffeeDemoDatasetFeatureNameTok: Label 'ContosoCoffeeDemoDataset', Locked = true;
        ContosoCoffeeDemoDatasetInitilizationTok: Label '%1: installation initialized from page', Locked = true;
}