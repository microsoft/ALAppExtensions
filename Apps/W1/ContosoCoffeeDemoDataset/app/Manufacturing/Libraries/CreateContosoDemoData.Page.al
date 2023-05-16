page 4760 "Create Contoso Demo Data"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Contoso Coffee Demo Data';
    SourceTable = "Manufacturing Demo Data Setup";
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
                field("Manufacturing Location"; Rec."Manufacturing Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a new or an existing location that you want to use for production operations.';
                }
                field("Company Type"; Rec."Company Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the company type.';
                }
            }

            group("Posting Setup")
            {
                Caption = 'Posting Setup';
                field("Domestic Code"; Rec."Domestic Code")
                {
                    Caption = 'Domestic - General Business Posting Group';
                    ApplicationArea = All;
                    ToolTip = 'Specifies existing business posting groups and, if relevant, VAT posting groups that will be applied to the vendors that will be added. The Domestic group is a great choice.';
                }
                field("Manufact Code"; Rec."Manufact Code")
                {
                    Caption = 'Capacity - General Product Posting Group';
                    ApplicationArea = All;
                    ToolTip = 'Specifies a new product group that will be used to map capacity transactions.';
                }
                field("Retail Code"; Rec."Retail Code")
                {
                    Caption = 'Retail - General Product Posting Group';
                    ApplicationArea = All;
                    ToolTip = 'Specifies an existing product posting group that will be used for finished items. The Retail group is a great choice.';
                }

                field("Raw Mat Code"; Rec."Raw Mat Code")
                {
                    Caption = 'Raw - General Product Posting Group';
                    ApplicationArea = All;
                    ToolTip = 'Specifies new product and inventory posting groups that will be used for raw materials items.';
                }
                field("Base VAT Code"; Rec."Base VAT Code")
                {
                    Caption = 'Base VAT Code';
                    ApplicationArea = All;
                    ToolTip = 'Specifies an existing VAT product group that will be used for items.';
                }

                field("Finished Code"; Rec."Finished Code")
                {
                    Caption = 'Finished Code';
                    ApplicationArea = All;
                    ToolTip = 'Specifies a new inventory posting group that will be used for finished items.';
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
                ToolTip = 'Adds new demonstration data for the Manufacturing capabilities in Business Central.';
                Enabled = not IsDemoDataPopulated;
                Image = Apply;

                trigger OnAction()
                begin
                    Telemetry.LogMessage('0000H72', StrSubstNo(ContosoCoffeeDemoDatasetInitilizationTok, ContosoCoffeeDemoDatasetFeatureNameTok),
                        Verbosity::Normal, DataClassification::SystemMetadata);

                    CreateManufacturingDemoData.Create();
                    IsDemoDataPopulated := true;
                    Message(DemoDataInsertedMsg)
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        FeatureTelemetry.LogUptake('0000GYT', ContosoCoffeeDemoDatasetFeatureNameTok, Enum::"Feature Uptake Status"::Discovered);

        CreateManufacturingDemoData.InitManufacturingDemoDataSetup();
        IsDemoDataPopulated := CreateManufacturingDemoData.IsDemoDataPopulated();
    end;

    var
        CreateManufacturingDemoData: Codeunit "Create Manufacturing DemoData";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Telemetry: Codeunit Telemetry;
        IsDemoDataPopulated: Boolean;
        DemoDataInsertedMsg: Label 'The Contoso Coffee demo data is now available in the current company.';
        ContosoCoffeeDemoDatasetFeatureNameTok: Label 'ContosoCoffeeDemoDataset', Locked = true;
        ContosoCoffeeDemoDatasetInitilizationTok: Label '%1: installation initialized from page', Locked = true;
}