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
                field("Location Basic Logistics"; Rec."Location Basic Logistics")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Code of the Location for the Basic Location scenarios.';
                }
                field("Location Simple"; Rec."Location Simple")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Code of the Location for the Basic Logistics scenarios.';
                }
                field("Location Directed"; Rec."Location Directed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Code of the Location for the Advanced Logistics scenarios.';
                }
            }

            group(MasterData)
            {

                field("S. Customer No."; Rec."S. Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Customer No. to use for the Basic Location and Basic Logistics scenarios.';
                }
                field("L. Customer No."; Rec."L. Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Customer No. to use for the Advanced Logistics scenarios.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Vendor No. to use for the scenarios.';
                }
                field("Main Item No."; Rec."Main Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Item No. to use for the Basic Location and Basic Logistics scenarios.';
                }
                field("Complex Item No."; Rec."Complex Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Item No. to use for some of the Advanced Logistics scenarios.';
                }
            }
            group("Posting Setup")
            {
                Caption = 'Posting Setup';
                field("S. Cust. Posting Group"; Rec."S. Cust. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Cust. Posting Group for the Customer for the Basic Location and Basic Logistics scenarios.';
                }
                field("SCust. Gen. Bus. Posting Group"; Rec."SCust. Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Gen. Bus. Posting Group for the Customer for the Basic Location and Basic Logistics scenarios.';
                }
                field("L. Cust. Posting Group"; Rec."L. Cust. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Cust. Posting Group for the Customer for the Advanced Logistics scenarios.';
                }
                field("LCust. Gen. Bus. Posting Group"; Rec."LCust. Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Gen. Bus. Posting Group for the Customer for the Advanced Logistics scenarios.';
                }
                field("Vendor Posting Group"; Rec."Vendor Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Vendor Posting Group for the Vendor for all scenarios.';
                }
                field("Vend. Gen. Bus. Posting Group"; Rec."Vend. Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Gen. Bus. Posting Group for the Vendor for all scenarios.';
                }
                field("Base VAT Code"; Rec."Base VAT Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Base VAT Code field.';
                }
                field("Domestic Code"; Rec."Domestic Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Domestic - Gen. Bus. Posting Group field.';
                }
                field("Finished Code"; Rec."Finished Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Finished Code field.';
                }
                field("Retail Code"; Rec."Retail Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Retail - Gen. Prod. Posting Group field.';
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