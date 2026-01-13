namespace Microsoft.Sustainability.Certificate;

using Microsoft.Inventory.Item;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.EPR;
using Microsoft.Sustainability.Setup;
using Microsoft.Sustainability.Codes;

tableextension 6220 "Sust. Item" extends Item
{
    fields
    {
        field(6210; "Sust. Cert. No."; Code[50])
        {
            DataClassification = CustomerContent;
            TableRelation = "Sustainability Certificate"."No." where(Type = const(Item));
            Caption = 'Sustainability Certificate No.';

            trigger OnValidate()
            begin
                UpdateCertificateInformation();
            end;
        }
        field(6211; "Sust. Cert. Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Sustainability Certificate Name';
            Editable = false;

            trigger OnValidate()
            begin
                if Rec."Sust. Cert. Name" <> '' then
                    Rec.TestField("Sust. Cert. No.");
            end;
        }
        field(6212; "GHG Credit"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'GHG Credit';

            trigger OnValidate()
            begin
                if not Rec."GHG Credit" then
                    Rec.TestField("Carbon Credit Per UOM", 0);
            end;
        }
        field(6213; "Carbon Credit Per UOM"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Carbon Credit Per UOM';

            trigger OnValidate()
            begin
                Rec.TestField("GHG Credit");
            end;
        }
        field(6214; "Default Sust. Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting), Blocked = const(false));
            Caption = 'Default Sust. Account';

            trigger OnValidate()
            var
                SustainabilityAccount: Record "Sustainability Account";
            begin
                if Rec."Default Sust. Account" = '' then
                    ClearDefaultEmissionInformation(Rec)
                else begin
                    SustainabilityAccount.Get(Rec."Default Sust. Account");

                    SustainabilityAccount.CheckAccountReadyForPosting();
                    SustainabilityAccount.TestField("Direct Posting", true);
                end;
            end;
        }
        field(6215; "Default CO2 Emission"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Default CO2 Emission';
            CaptionClass = '102,10,1';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Default CO2 Emission" <> 0 then
                    Rec.TestField("Default Sust. Account");

                if Rec."Item of Concern" then
                    ValidateEmissionsForItemOfConcern();
            end;
        }
        field(6216; "Default CH4 Emission"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Default CH4 Emission';
            CaptionClass = '102,10,2';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Default CH4 Emission" <> 0 then
                    Rec.TestField("Default Sust. Account");

                if Rec."Item of Concern" then
                    ValidateEmissionsForItemOfConcern();
            end;
        }
        field(6217; "Default N2O Emission"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Default N2O Emission';
            CaptionClass = '102,10,3';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Default N2O Emission" <> 0 then
                    Rec.TestField("Default Sust. Account");

                if Rec."Item of Concern" then
                    ValidateEmissionsForItemOfConcern();
            end;
        }
        field(6218; "CO2e per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'CO2e per Unit';
            MinValue = 0;
            DataClassification = CustomerContent;
        }
        field(6219; "CO2e Last Date Modified"; Date)
        {
            Caption = 'CO2e Last Date Modified';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6220; "Source of Emission Data"; Enum "Sust. Source of Emission")
        {
            DataClassification = CustomerContent;
            Caption = 'Source of Emission Data';
        }
        field(6221; "Emission Verified"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Emission Verified';
        }
        field(6222; "CBAM Compliance"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'CBAM Compliance';
        }
        field(6223; "EPR Category"; Enum "Sust. EPR Category")
        {
            DataClassification = CustomerContent;
            Caption = 'EPR Category';
        }
        field(6224; "Material Composition No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Sust. Item Mat. Comp. Header"."No.";
            Caption = 'Material Composition No.';

            trigger OnValidate()
            var
                ItemMaterialCompositionHeader: Record "Sust. Item Mat. Comp. Header";
                ItemUnitOfMeasure: Record "Item Unit of Measure";
            begin
                if ("Material Composition No." <> '') and ("Material Composition No." <> xRec."Material Composition No.") then begin
                    ItemMaterialCompositionHeader.Get("Material Composition No.");
                    ItemUnitOfMeasure.Get("No.", ItemMaterialCompositionHeader."Unit of Measure Code");
                end;

                UpdateEPRFeeRateInItem();
            end;
        }
        field(6225; "Total EPR Weight"; Decimal)
        {
            AutoFormatType = 11;
            Editable = false;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Total EPR Weight';
            FieldClass = FlowField;
            CalcFormula = sum("Sust. Item Mat. Comp. Line".Weight where("Item Material Composition No." = field("Material Composition No.")));
        }
        field(6226; "EPR Fees Per Unit"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 11;
            Editable = false;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'EPR Fees Per Unit';
        }
        field(6227; "End-of-Life Disposal Req."; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'End-of-Life Disposal Requirements';
        }
        field(6230; "Item of Concern"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Item of Concern';

            trigger OnValidate()
            begin
                if Rec."Item of Concern" then
                    ValidateEmissionsForItemOfConcern();
            end;
        }
        field(6231; "Recyclability Percentage"; Decimal)
        {
            Caption = 'Recyclability Percentage';
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            DataClassification = CustomerContent;
            ToolTip = 'Specifies % of recyclable content.';
            MinValue = 0;
            MaxValue = 100;
        }
        field(6232; "Energy Efficiency Rating"; Code[10])
        {
            Caption = 'Energy Efficiency Rating';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies energy efficiency information, e.g. product category, or label (A-G rating).';
        }
        field(6233; "End-of-Life Information"; Text[50])
        {
            Caption = 'End-of-Life Information';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies instructions about disposal methods, recycling facilities, return schemes, or environmental impact.';
        }
#pragma warning disable PTE0002
        field(6234; "Product Classification Enabled"; Boolean)
        {
            Caption = 'Product Classification Enabled';
            ToolTip = 'Specifies whether external product classification codes are enabled for this item.';
            DataClassification = SystemMetadata;
        }
        field(6235; "Product Classification Type"; Enum "Product Classification Type")
        {
            Caption = 'Product Classification Type';
            ToolTip = 'Specifies the classification system, such as HS, CPV, or UNSPSC.';
            DataClassification = SystemMetadata;
        }
        field(6236; "Product Classification Code"; Code[50])
        {
            Caption = 'Product Classification Code';
            ToolTip = 'Specifies the external classification code for this item.';
            DataClassification = CustomerContent;
            TableRelation = "Product Classification Code".Code where(Type = field("Product Classification Type"));
        }
        field(6237; "Product Classification Name"; Text[250])
        {
            Caption = 'Product Classification Name';
            ToolTip = 'Specifies the descriptive name of the classification code.';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup("Product Classification Code".Name where("Code" = field("Product Classification Code"),
                                                                          "Type" = field("Product Classification Type")));
        }
#pragma warning restore PTE0002
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
        AtLeastOneNonZeroEmissionValueErr: Label '%1, %2, %3 cannot all be zero. Please provide at least one non-zero value.', Comment = '%1, %2 , %3 = Field Caption';

    local procedure UpdateCertificateInformation()
    var
        SustCertificate: Record "Sustainability Certificate";
    begin
        Rec.TestField(Type, Rec.Type::Inventory);
        Rec."Sust. Cert. Name" := '';

        if SustCertificate.Get(SustCertificate.Type::Item, Rec."Sust. Cert. No.") then
            Rec.Validate("Sust. Cert. Name", SustCertificate.Name);
    end;

    local procedure ValidateEmissionsForItemOfConcern()
    begin
        if (Rec."Default CO2 Emission" = 0) and (Rec."Default CH4 Emission" = 0) and (Rec."Default N2O Emission" = 0) then
            Error(
                AtLeastOneNonZeroEmissionValueErr,
                Rec.FieldCaption("Default CO2 Emission"),
                Rec.FieldCaption("Default CH4 Emission"),
                Rec.FieldCaption("Default N2O Emission"));
    end;

    local procedure UpdateEPRFeeRateInItem()
    var
        ItemMaterialCompLine: Record "Sust. Item Mat. Comp. Line";
    begin
        ItemMaterialCompLine.SetRange("Item Material Composition No.", Rec."Material Composition No.");
        ItemMaterialCompLine.CalcSums("EPR Fee Rate");

        Rec.Validate("EPR Fees Per Unit", ItemMaterialCompLine."EPR Fee Rate");
    end;

    procedure ClearDefaultEmissionInformation(var Item: Record Item)
    begin
        Item.Validate("Default N2O Emission", 0);
        Item.Validate("Default CH4 Emission", 0);
        Item.Validate("Default CO2 Emission", 0);
    end;
}