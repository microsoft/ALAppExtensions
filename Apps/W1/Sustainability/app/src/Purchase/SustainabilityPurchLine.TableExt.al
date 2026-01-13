namespace Microsoft.Sustainability.Purchase;

using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Document;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Calculation;
using Microsoft.Sustainability.CBAM;
using Microsoft.Sustainability.Certificate;
using Microsoft.Sustainability.Energy;
using Microsoft.Sustainability.Setup;

tableextension 6211 "Sustainability Purch. Line" extends "Purchase Line"
{
    fields
    {
        field(6210; "Sust. Account No."; Code[20])
        {
            Caption = 'Sustainability Account No.';
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting), Blocked = const(false));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SustainabilityAccount: Record "Sustainability Account";
            begin
                Rec.TestStatusOpen();
                if Rec."Sust. Account No." <> xRec."Sust. Account No." then
                    ClearEmissionInformation(Rec);

                if Rec."Sust. Account No." = '' then begin
                    Rec.Validate("Sust. Account Category", '');
                    "Sust. Account Name" := '';
                end else begin
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Sust. Account No."));

                    SustainabilityAccount.Get(Rec."Sust. Account No.");
                    SustainabilityAccount.CheckAccountReadyForPosting();
                    SustainabilityAccount.TestField("Direct Posting", true);

                    Rec.Validate("Sust. Account Name", SustainabilityAccount.Name);
                    Rec.Validate("Sust. Account Category", SustainabilityAccount.Category);
                    Rec.Validate("Sust. Account Subcategory", SustainabilityAccount.Subcategory);
                    UpdateDefaultEmissionOnPurchLine(Rec);
                end;

                CreateDimFromDefaultDim(FieldNo(Rec."Sust. Account No."));
            end;
        }
        field(6211; "Sust. Account Name"; Text[100])
        {
            Caption = 'Sustainability Account Name';
            DataClassification = CustomerContent;
        }
        field(6212; "Sust. Account Category"; Code[20])
        {
            Caption = 'Sustainability Account Category';
            Editable = false;
            TableRelation = "Sustain. Account Category";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Sust. Account Category" <> '' then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Sust. Account Category"))
                else
                    Rec.Validate("Sust. Account Subcategory", '');

                if "Sust. Account Category" <> xRec."Sust. Account Category" then
                    Rec.Validate("Shortcut Dimension 1 Code", '');
            end;
        }
        field(6213; "Sust. Account Subcategory"; Code[20])
        {
            Caption = 'Sustainability Account Subcategory';
            Editable = false;
            TableRelation = "Sustain. Account Subcategory".Code where("Category Code" = field("Sust. Account Category"));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Sust. Account Subcategory" <> '' then begin
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Sust. Account Subcategory"));

                    UpdatePurchaseLineFromAccountSubcategory();
                end else begin
                    Rec.Validate("Energy Source Code", '');
                    Rec.Validate("Renewable Energy", false);
                end;
            end;
        }
        field(6214; "Emission CO2 Per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CO2 Per Unit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Emission CO2 Per Unit" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Emission CO2 Per Unit"));

                UpdateSustainabilityEmission(Rec);
            end;
        }
        field(6215; "Emission CH4 Per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CH4 Per Unit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Emission CH4 Per Unit" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Emission CH4 Per Unit"));

                UpdateSustainabilityEmission(Rec);
            end;
        }
        field(6216; "Emission N2O Per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission N2O Per Unit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Emission N2O Per Unit" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Emission N2O Per Unit"));

                UpdateSustainabilityEmission(Rec);
            end;
        }
        field(6217; "Emission CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CO2';
            CaptionClass = '102,6,1';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Emission CO2" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Emission CO2"));

                if CurrFieldNo <> Rec.FieldNo("Emission CH4 Per Unit") then
                    UpdateEmissionPerUnit(Rec);

                UpdateCarbonPricingInPurchLine(Rec);
            end;
        }
        field(6218; "Emission CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission CH4';
            CaptionClass = '102,6,2';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Emission CH4" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Emission CH4"));

                UpdateEmissionPerUnit(Rec);

                UpdateCarbonPricingInPurchLine(Rec);
            end;
        }
        field(6219; "Emission N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission N2O';
            CaptionClass = '102,6,3';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Emission N2O" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Emission N2O"));

                UpdateEmissionPerUnit(Rec);

                UpdateCarbonPricingInPurchLine(Rec);
            end;
        }
        field(6220; "Posted Emission CO2"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Posted Emission CO2';
            CaptionClass = '102,11,1';
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Posted Emission CO2" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Posted Emission CO2"));
            end;
        }
        field(6221; "Posted Emission CH4"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Posted Emission CH4';
            CaptionClass = '102,11,2';
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Posted Emission CH4" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Posted Emission CH4"));
            end;
        }
        field(6222; "Posted Emission N2O"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Posted Emission N2O';
            CaptionClass = '102,11,3';
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Posted Emission N2O" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Posted Emission N2O"));
            end;
        }
        field(6223; "Energy Source Code"; Code[20])
        {
            Caption = 'Energy Source Code';
            TableRelation = "Sustainability Energy Source";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Energy Source Code" <> '' then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Energy Source Code"));

                if Rec."Energy Source Code" <> xRec."Energy Source Code" then
                    Rec.Validate("Energy Consumption", 0);
            end;
        }
        field(6224; "Renewable Energy"; Boolean)
        {
            Caption = 'Renewable Energy';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Renewable Energy" then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Renewable Energy"));
            end;
        }
        field(6225; "Energy Consumption Per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Energy Consumption Per Unit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Energy Consumption Per Unit" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Energy Consumption Per Unit"));

                UpdateSustainabilityEmission(Rec);
            end;
        }
        field(6226; "Energy Consumption"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Energy Consumption';
            CaptionClass = '102,13,4';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Energy Consumption" <> 0 then begin
                    Rec.TestField("Energy Source Code");
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Energy Consumption"));
                end;

                UpdateEmissionPerUnit(Rec);
            end;
        }
        field(6227; "Posted Energy Consumption"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Posted Energy Consumption';
            CaptionClass = '102,14,4';
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Posted Energy Consumption" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Posted Energy Consumption"));
            end;
        }
        field(6228; "Source of Emission Data"; Enum "Sust. Source of Emission")
        {
            DataClassification = CustomerContent;
            Caption = 'Source of Emission Data';

            trigger OnValidate()
            begin
                if (Rec."Source of Emission Data" <> Rec."Source of Emission Data"::" ") then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Source of Emission Data"));
            end;
        }
        field(6229; "Emission Verified"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Emission Verified';

            trigger OnValidate()
            begin
                if Rec."Emission Verified" then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Emission Verified"));
            end;
        }
        field(6230; "CBAM Compliance"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'CBAM Compliance';

            trigger OnValidate()
            begin
                if Rec."CBAM Compliance" then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("CBAM Compliance"));
            end;
        }
        field(6231; "Emission Cost Per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Emission Cost Per Unit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Emission Cost per Unit" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Emission Cost per Unit"));

                UpdateSustainabilityEmission(Rec);
            end;
        }
        field(6232; "Total Emission Cost"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Total Emission Cost';
            CaptionClass = '102,15,5';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Total Emission Cost" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Total Emission Cost"));

                UpdateEmissionPerUnit(Rec);
            end;
        }
        field(6233; "Posted Total Emission Cost"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Posted Total Emission Cost';
            CaptionClass = '102,16,5';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Posted Total Emission Cost" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Posted Total Emission Cost"));
            end;
        }
        field(6234; "Unit for Sust. Formulas"; Code[10])
        {
            Caption = 'Unit for Sust. Formulas';
            TableRelation = "Unit of Measure";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Unit for Sust. Formulas" <> '' then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Unit for Sust. Formulas"));
            end;
        }
        field(6235; "Fuel/Electricity"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Fuel/El. Decimal Places"));
            Caption = 'Fuel/Electricity';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Fuel/Electricity" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Fuel/Electricity"));

                if (Rec."Fuel/Electricity" <> xRec."Fuel/Electricity") and (Rec."Sust. Account No." <> '') then
                    SustainabilityCalcMgt.CalculationEmissions(Rec);
            end;
        }
        field(6236; Distance; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Distance Decimal Places"));
            Caption = 'Distance';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec.Distance <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Distance"));

                if (Rec."Distance" <> xRec."Distance") and (Rec."Sust. Account No." <> '') then
                    SustainabilityCalcMgt.CalculationEmissions(Rec);
            end;
        }
        field(6237; "Custom Amount"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Custom Amt. Decimal Places"));
            Caption = 'Custom Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Custom Amount" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Custom Amount"));

                if (Rec."Custom Amount" <> xRec."Custom Amount") and (Rec."Sust. Account No." <> '') then
                    SustainabilityCalcMgt.CalculationEmissions(Rec);
            end;
        }
        field(6238; "Installation Multiplier"; Decimal)
        {
            Caption = 'Installation Multiplier';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Installation Multiplier" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Installation Multiplier"));

                if (Rec."Installation Multiplier" <> xRec."Installation Multiplier") and (Rec."Sust. Account No." <> '') then
                    SustainabilityCalcMgt.CalculationEmissions(Rec);
            end;
        }
        field(6239; "Time Factor"; Decimal)
        {
            Caption = 'Time Factor';
            MaxValue = 1;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Time Factor" <> 0 then
                    ValidateEmissionPrerequisite(Rec, xRec, Rec.FieldNo("Time Factor"));

                if (Rec."Time Factor" <> xRec."Time Factor") and (Rec."Sust. Account No." <> '') then
                    SustainabilityCalcMgt.CalculationEmissions(Rec);
            end;
        }
        #pragma warning disable PTE0002
        field(6240; "Received Sust. Cert. Type Code"; Code[50])
        {
            Caption = 'Received Sustainability Certificate Type Code';
            DataClassification = CustomerContent;
        }
        field(6241; "Received Sust. Prod. CL. Code"; Code[50])
        {
            Caption = 'Received Sustainability Product Classification Code';
            DataClassification = CustomerContent;
        }
        #pragma warning restore PTE0002
    }

    procedure UpdateSustainabilityEmission(var PurchLine: Record "Purchase Line")
    begin
        PurchLine."Emission CO2" := PurchLine."Emission CO2 Per Unit" * PurchLine."Qty. per Unit of Measure" * PurchLine.Quantity;
        PurchLine."Emission CH4" := PurchLine."Emission CH4 Per Unit" * PurchLine."Qty. per Unit of Measure" * PurchLine.Quantity;
        PurchLine."Emission N2O" := PurchLine."Emission N2O Per Unit" * PurchLine."Qty. per Unit of Measure" * PurchLine.Quantity;
        PurchLine."Energy Consumption" := PurchLine."Energy Consumption Per Unit" * PurchLine."Qty. per Unit of Measure" * PurchLine.Quantity;
        if CurrFieldNo in [0, Rec.FieldNo("Emission CO2 Per Unit"), Rec.FieldNo("Emission CH4 Per Unit"), Rec.FieldNo("Emission N2O Per Unit"), Rec.FieldNo("Sust. Account No.")] then
            PurchLine.UpdateCarbonPricingInPurchLine(PurchLine);

        PurchLine."Total Emission Cost" := PurchLine."Emission Cost per Unit" * PurchLine."Qty. per Unit of Measure" * PurchLine.Quantity;
    end;

    procedure UpdateEmissionPerUnit(var PurchLine: Record "Purchase Line")
    var
        Denominator: Decimal;
    begin
        PurchLine."Emission CO2 Per Unit" := 0;
        PurchLine."Emission CH4 Per Unit" := 0;
        PurchLine."Emission N2O Per Unit" := 0;
        PurchLine."Energy Consumption Per Unit" := 0;
        PurchLine."Emission Cost per Unit" := 0;

        if (PurchLine."Qty. per Unit of Measure" = 0) or (PurchLine.Quantity = 0) then
            exit;

        Denominator := PurchLine."Qty. per Unit of Measure" * PurchLine.Quantity;
        if PurchLine."Emission CO2" <> 0 then
            PurchLine."Emission CO2 Per Unit" := PurchLine."Emission CO2" / Denominator;

        if PurchLine."Emission CH4" <> 0 then
            PurchLine."Emission CH4 Per Unit" := PurchLine."Emission CH4" / Denominator;

        if PurchLine."Emission N2O" <> 0 then
            PurchLine."Emission N2O Per Unit" := PurchLine."Emission N2O" / Denominator;

        if PurchLine."Energy Consumption" <> 0 then
            PurchLine."Energy Consumption Per Unit" := PurchLine."Energy Consumption" / Denominator;

        if PurchLine."Total Emission Cost" <> 0 then
            PurchLine."Emission Cost Per Unit" := PurchLine."Total Emission Cost" / Denominator;

        if Rec.Type = Rec.Type::"Charge (Item)" then
            Rec.UpdateItemChargeAssgnt();
    end;

    internal procedure UpdateCarbonPricingInPurchLine(var PurchLine: Record "Purchase Line")
    var
        SustainabilityCarbonPricing: Record "Sustainability Carbon Pricing";
        ExistCarbonPrice: Boolean;
        TotalCO2e: Decimal;
        Denominator: Decimal;
    begin
        PurchLine."Emission Cost Per Unit" := 0;
        PurchLine."Total Emission Cost" := 0;
        if (Rec."Sust. Account No." = '') or (Rec.Type <> Rec.Type::Item) then
            exit;

        FindCarbonPricingFromPurchaseLine(SustainabilityCarbonPricing, PurchLine, ExistCarbonPrice, TotalCO2e);
        if not ExistCarbonPrice then
            exit;

        PurchLine."Total Emission Cost" := SustainabilityCarbonPricing."Carbon Price" * TotalCO2e;
        if (PurchLine."Qty. per Unit of Measure" = 0) or (PurchLine.Quantity = 0) then
            exit;

        Denominator := PurchLine."Qty. per Unit of Measure" * PurchLine.Quantity;
        if PurchLine."Total Emission Cost" <> 0 then
            PurchLine."Emission Cost Per Unit" := PurchLine."Total Emission Cost" / Denominator;
    end;

    internal procedure IsSustainabilityFormulaPurchaseLine(): Boolean
    begin
        exit((Rec."Sust. Account No." <> '') and
             ((Rec."Unit for Sust. Formulas" <> '') or (Rec."Fuel/Electricity" <> 0) or (Rec."Time Factor" <> 0) or
             (Rec.Distance <> 0) or (Rec."Custom Amount" <> 0) or (Rec."Installation Multiplier" <> 0)));
    end;

    local procedure UpdateDefaultEmissionOnPurchLine(var PurchaseLine: Record "Purchase Line")
    var
        Item: Record Item;
        Resource: Record Resource;
        ItemCharge: Record "Item Charge";
    begin
        case PurchaseLine.Type of
            PurchaseLine.Type::Item:
                begin
                    Item.Get(PurchaseLine."No.");

                    if Item."GHG Credit" then
                        PurchaseLine.Validate("Emission CO2 Per Unit", Item."Carbon Credit Per UOM")
                    else begin
                        PurchaseLine.Validate("Emission CO2 Per Unit", Item."Default CO2 Emission");
                        PurchaseLine.Validate("Emission CH4 Per Unit", Item."Default CH4 Emission");
                        PurchaseLine.Validate("Emission N2O Per Unit", Item."Default N2O Emission");
                    end;

                    PurchaseLine.Validate("Source of Emission Data", Item."Source of Emission Data");
                    PurchaseLine.Validate("Emission Verified", Item."Emission Verified");
                    PurchaseLine.Validate("CBAM Compliance", Item."CBAM Compliance");
                end;
            PurchaseLine.Type::Resource:
                begin
                    Resource.Get(PurchaseLine."No.");

                    PurchaseLine.Validate("Emission CO2 Per Unit", Resource."Default CO2 Emission");
                    PurchaseLine.Validate("Emission CH4 Per Unit", Resource."Default CH4 Emission");
                    PurchaseLine.Validate("Emission N2O Per Unit", Resource."Default N2O Emission");
                end;
            PurchaseLine.Type::"Charge (Item)":
                begin
                    ItemCharge.Get(PurchaseLine."No.");

                    PurchaseLine.Validate("Emission CO2 Per Unit", ItemCharge."Default CO2 Emission");
                    PurchaseLine.Validate("Emission CH4 Per Unit", ItemCharge."Default CH4 Emission");
                    PurchaseLine.Validate("Emission N2O Per Unit", ItemCharge."Default N2O Emission");
                end;
        end
    end;

    local procedure ClearEmissionInformation(var PurchLine: Record "Purchase Line")
    begin
        PurchLine.Validate("Emission CO2 Per Unit", 0);
        PurchLine.Validate("Emission CH4 Per Unit", 0);
        PurchLine.Validate("Emission N2O Per Unit", 0);
        PurchLine.Validate("Source of Emission Data", Rec."Source of Emission Data"::" ");
        PurchLine.Validate("CBAM Compliance", false);
        PurchLine.Validate("Emission Verified", false);
        PurchLine.Validate("Emission Cost Per Unit", 0);
        PurchLine.Validate("Unit for Sust. Formulas", '');
        PurchLine.Validate("Fuel/Electricity", 0);
        PurchLine.Validate(Distance, 0);
        PurchLine.Validate("Time Factor", 0);
        PurchLine.Validate("Custom Amount", 0);
        PurchLine.Validate("Installation Multiplier", 0);
    end;

    local procedure ValidateEmissionPrerequisite(PurchaseLine: Record "Purchase Line"; xPurchaseLine: Record "Purchase Line"; CurrentFieldNo: Integer)
    var
        Item: Record Item;
        SustAccountCategory: Record "Sustain. Account Category";
    begin
        case CurrentFieldNo of
            PurchaseLine.FieldNo("Emission N2O"),
            PurchaseLine.FieldNo("Emission N2O Per Unit"),
            PurchaseLine.FieldNo("Emission CH4"),
            PurchaseLine.FieldNo("Emission CH4 Per Unit"):
                begin
                    PurchaseLine.TestStatusOpen();
                    PurchaseLine.TestField("Sust. Account No.");

                    if (PurchaseLine.Type = PurchaseLine.Type::Item) and (PurchaseLine."No." <> '') then begin
                        Item.Get(PurchaseLine."No.");
                        if Item."GHG Credit" then
                            Item.TestField("GHG Credit", false);
                    end;

                    if (CurrFieldNo in [PurchaseLine.FieldNo("Emission CH4"), PurchaseLine.FieldNo("Emission CH4 Per Unit"),
                                        PurchaseLine.FieldNo("Emission N2O"), PurchaseLine.FieldNo("Emission N2O Per Unit")])
                    then
                        CheckSustainabilityFormula(PurchaseLine);
                end;
            PurchaseLine.FieldNo("Emission CO2"),
            PurchaseLine.FieldNo("Emission CO2 Per Unit"),
            PurchaseLine.FieldNo("Energy Source Code"),
            PurchaseLine.FieldNo("Renewable Energy"),
            PurchaseLine.FieldNo("Energy Consumption"),
            PurchaseLine.FieldNo("Energy Consumption Per Unit"),
            PurchaseLine.FieldNo("Emission Verified"),
            PurchaseLine.FieldNo("Source of Emission Data"),
            PurchaseLine.FieldNo("CBAM Compliance"),
            PurchaseLine.FieldNo("Emission Cost Per Unit"),
            PurchaseLine.FieldNo("Total Emission Cost"):
                begin
                    PurchaseLine.TestStatusOpen();
                    PurchaseLine.TestField("Sust. Account No.");

                    if (CurrFieldNo in [PurchaseLine.FieldNo("Emission CO2"), PurchaseLine.FieldNo("Emission CO2 Per Unit")]) then
                        CheckSustainabilityFormula(PurchaseLine);
                end;
            PurchaseLine.FieldNo("Sust. Account No."),
            PurchaseLine.FieldNo("Sust. Account Category"),
            PurchaseLine.FieldNo("Sust. Account Subcategory"),
            PurchaseLine.FieldNo("Sust. Account Name"):
                begin
                    PurchaseLine.TestField("No.");
                    if not (PurchaseLine.Type in [PurchaseLine.Type::Item, PurchaseLine.Type::"G/L Account", PurchaseLine.Type::Resource, PurchaseLine.Type::"Charge (Item)"]) then
                        Error(InvalidTypeForSustErr, PurchaseLine.Type::Item, PurchaseLine.Type::"G/L Account", PurchaseLine.Type::Resource, PurchaseLine.Type::"Charge (Item)");

                    if SustAccountCategory.Get(PurchaseLine."Sust. Account Category") then
                        if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                            Error(NotAllowedToUseSustAccountForWaterOrWasteErr, PurchaseLine."Sust. Account No.");
                end;
            PurchaseLine.FieldNo("Unit for Sust. Formulas"),
            PurchaseLine.FieldNo("Fuel/Electricity"),
            PurchaseLine.FieldNo("Custom Amount"),
            PurchaseLine.FieldNo(Distance),
            PurchaseLine.FieldNo("Installation Multiplier"),
            PurchaseLine.FieldNo("Time Factor"):
                begin
                    PurchaseLine.TestStatusOpen();
                    PurchaseLine.TestField("Sust. Account No.");

                    CheckEmissionMustBeZeroWhenFormulaIsUpdated(PurchaseLine, xPurchaseLine);
                end;
        end;
    end;

    local procedure CheckEmissionMustBeZeroWhenFormulaIsUpdated(PurchaseLine: Record "Purchase Line"; xPurchaseLine: Record "Purchase Line")
    begin
        if (xPurchaseLine."Unit for Sust. Formulas" <> '') or
           (xPurchaseLine."Fuel/Electricity" <> 0) or
           (xPurchaseLine."Custom Amount" <> 0) or
           (xPurchaseLine.Distance <> 0) or
           (xPurchaseLine."Time Factor" <> 0) or
           (xPurchaseLine."Installation Multiplier" <> 0)
        then
            exit;

        if not (CurrFieldNo in [PurchaseLine.FieldNo("Unit for Sust. Formulas"), PurchaseLine.FieldNo("Fuel/Electricity"), PurchaseLine.FieldNo("Custom Amount"),
                                PurchaseLine.FieldNo(Distance), PurchaseLine.FieldNo("Installation Multiplier"), PurchaseLine.FieldNo("Time Factor")])
        then
            exit;

        PurchaseLine.TestField("Emission CO2", 0);
        PurchaseLine.TestField("Emission CH4", 0);
        PurchaseLine.TestField("Emission N2O", 0);
    end;

    local procedure CheckSustainabilityFormula(PurchaseLine: Record "Purchase Line")
    begin
        PurchaseLine.TestField("Unit for Sust. Formulas", '');
        PurchaseLine.TestField("Fuel/Electricity", 0);
        PurchaseLine.TestField("Custom Amount", 0);
        PurchaseLine.TestField(Distance, 0);
        PurchaseLine.TestField("Time Factor", 0);
        PurchaseLine.TestField("Installation Multiplier", 0);
    end;

    local procedure UpdatePurchaseLineFromAccountSubcategory()
    var
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        SustainAccountSubcategory.Get(Rec."Sust. Account Category", Rec."Sust. Account Subcategory");

        Rec.Validate("Energy Source Code", SustainAccountSubcategory."Energy Source Code");
        Rec.Validate("Renewable Energy", SustainAccountSubcategory."Renewable Energy");
    end;

    local procedure FindCarbonPricingFromPurchaseLine(var SustainabilityCarbonPricing: Record "Sustainability Carbon Pricing"; var PurchLine: Record "Purchase Line"; var ExistCarbonPrice: Boolean; var TotalCO2e: Decimal)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseSubscriber: Codeunit "Sust. Purchase Subscriber";
    begin
        PurchaseHeader := PurchLine.GetPurchHeader();

        FilterCarbonPricing(SustainabilityCarbonPricing, PurchaseHeader, PurchLine);
        if not SustainabilityCarbonPricing.FindLast() then
            exit;

        PurchaseSubscriber.GetCO2eEmissionFromPurchLine(PurchLine, TotalCO2e);
        if (TotalCO2e > SustainabilityCarbonPricing."Threshold Quantity") then
            ExistCarbonPrice := true;
    end;

    local procedure FilterCarbonPricing(var SustainabilityCarbonPricing: Record "Sustainability Carbon Pricing"; PurchaseHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line")
    var
        Item: Record Item;
    begin
        Item.Get(PurchLine."No.");

        SustainabilityCarbonPricing.Reset();
        if Item."Country/Region of Origin Code" <> '' then
            SustainabilityCarbonPricing.SetRange("Country/Region of Origin", Item."Country/Region of Origin Code")
        else
            SustainabilityCarbonPricing.SetRange("Country/Region of Origin", PurchaseHeader."Buy-from Country/Region Code");

        SustainabilityCarbonPricing.SetFilter("Ending Date", '%1|>=%2', 0D, PurchaseHeaderStartDate(PurchaseHeader));
        SustainabilityCarbonPricing.SetRange("Starting Date", 0D, PurchaseHeaderStartDate(PurchaseHeader));
    end;

    local procedure PurchaseHeaderStartDate(PurchaseHeader: Record "Purchase Header"): Date
    begin
        if PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::Invoice, PurchaseHeader."Document Type"::"Credit Memo"] then
            exit(PurchaseHeader."Posting Date")
        else
            exit(PurchaseHeader."Order Date");
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityCalcMgt: Codeunit "Sustainability Calc. Mgt.";
        InvalidTypeForSustErr: Label 'Sustainability is only applicable for Type: %1 , %2 , %3 and %4', Comment = '%1 - Purchase Line Type Item, %2 - Purchase Line Type G/L Account, %3 - Purchase Line Type Resource , %4 - Purchase Line Type Charge (Item)';
        NotAllowedToUseSustAccountForWaterOrWasteErr: Label 'It is not allowed to use Sustainability Account %1 for water or waste in purchase document.', Comment = '%1 = Sust. Account No.';
}