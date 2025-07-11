namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Document;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

tableextension 6248 "Sust. Prod. Order Line" extends "Prod. Order Line"
{
    fields
    {
        field(6210; "Sust. Account No."; Code[20])
        {
            Caption = 'Sustainability Account No.';
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting), Blocked = const(false));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Sust. Account No." <> xRec."Sust. Account No." then
                    ClearEmissionInformation(Rec);

                if Rec."Sust. Account No." = '' then begin
                    Rec.Validate("Sust. Account Category", '');
                    "Sust. Account Name" := '';
                end else begin
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Sust. Account No."));
                    CopyFromSustainabilityAccount(Rec);
                    UpdateCO2eInformation();
                end;

                CreateDimFromDefaultDim();
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
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Sust. Account Category"))
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
                if Rec."Sust. Account Subcategory" <> '' then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Sust. Account Subcategory"));
            end;
        }
        field(6214; "CO2e per Unit"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'CO2e per Unit';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."CO2e per Unit" <> 0 then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("CO2e per Unit"));

                UpdateSustainabilityEmission(Rec);
            end;
        }
        field(6215; "Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Total CO2e';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Total CO2e" <> 0 then
                    ValidateEmissionPrerequisite(Rec, Rec.FieldNo("Total CO2e"));

                UpdateEmissionPerUnit(Rec);
            end;
        }
        field(6216; "Posted Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Posted Total CO2e';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6217; "Expected Operation Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            CalcFormula = sum("Prod. Order Routing Line"."Total CO2e" where(Status = field(Status),
                                                                            "Prod. Order No." = field("Prod. Order No."),
                                                                            "Routing No." = field("Routing No."),
                                                                            "Routing Reference No." = field("Routing Reference No.")));
            Caption = 'Expected Operation Total CO2e';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6218; "Expected Component Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            CalcFormula = sum("Prod. Order Component"."Total CO2e" where(Status = field(Status),
                                                                         "Prod. Order No." = field("Prod. Order No."),
                                                                         "Prod. Order Line No." = field("Line No."),
                                                                         "Due Date" = field("Date Filter")));
            Caption = 'Expected Component Total CO2e';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    procedure UpdateSustainabilityEmission(var ProdOrderLine: Record "Prod. Order Line")
    begin
        ProdOrderLine."Total CO2e" := ProdOrderLine."CO2e per Unit" * ProdOrderLine."Qty. per Unit of Measure" * ProdOrderLine.Quantity;
    end;

    procedure UpdateEmissionPerUnit(var ProdOrderLine: Record "Prod. Order Line")
    var
        Denominator: Decimal;
    begin
        ProdOrderLine."CO2e Per Unit" := 0;

        if (ProdOrderLine."Qty. per Unit of Measure" = 0) or (ProdOrderLine.Quantity = 0) then
            exit;

        Denominator := ProdOrderLine."Qty. per Unit of Measure" * ProdOrderLine.Quantity;
        if ProdOrderLine."Total CO2e" <> 0 then
            ProdOrderLine."CO2e per Unit" := ProdOrderLine."Total CO2e" / Denominator;
    end;

    local procedure ClearEmissionInformation(var ProdOrderLine: Record "Prod. Order Line")
    begin
        ProdOrderLine.Validate("CO2e per Unit", 0);
    end;

    local procedure ValidateEmissionPrerequisite(ProdOrderLine: Record "Prod. Order Line"; CurrentFieldNo: Integer)
    var
        SustAccountCategory: Record "Sustain. Account Category";
    begin
        case CurrentFieldNo of
            ProdOrderLine.FieldNo("CO2e per Unit"),
            ProdOrderLine.FieldNo("Total CO2e"):
                ProdOrderLine.TestField("Sust. Account No.");
            ProdOrderLine.FieldNo("Sust. Account No."),
            ProdOrderLine.FieldNo("Sust. Account Category"),
            ProdOrderLine.FieldNo("Sust. Account Subcategory"),
            ProdOrderLine.FieldNo("Sust. Account Name"):
                begin
                    ProdOrderLine.TestField("Item No.");

                    if SustAccountCategory.Get(ProdOrderLine."Sust. Account Category") then
                        if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                            Error(NotAllowedToUseSustAccountForWaterOrWasteErr, ProdOrderLine."Sust. Account No.");
                end;
        end;
    end;

    local procedure UpdateCO2eInformation()
    var
        Item: Record Item;
        CalcCO2ePerUnit: Decimal;
    begin
        if not Item.Get(Rec."Item No.") then
            exit;

        if (ExistSustProdOrderRoutingLine(Rec)) or (ExistSustProdOrderComponent(Rec)) then begin
            Rec.CalcFields("Expected Operation Total CO2e", "Expected Component Total CO2e");
            CalcCO2ePerUnit := (Rec."Expected Operation Total CO2e" + Rec."Expected Component Total CO2e") / Rec.Quantity;

            Rec.Validate("CO2e per Unit", CalcCO2ePerUnit);
        end else
            Rec.Validate("CO2e per Unit", Item."CO2e per Unit");
    end;

    local procedure CopyFromSustainabilityAccount(var ProdOrderLine: Record "Prod. Order Line")
    var
        SustainabilityAccount: Record "Sustainability Account";
    begin
        SustainabilityAccount.Get(ProdOrderLine."Sust. Account No.");
        SustainabilityAccount.CheckAccountReadyForPosting();
        SustainabilityAccount.TestField("Direct Posting", true);

        ProdOrderLine.Validate("Sust. Account Name", SustainabilityAccount.Name);
        ProdOrderLine.Validate("Sust. Account Category", SustainabilityAccount.Category);
        ProdOrderLine.Validate("Sust. Account Subcategory", SustainabilityAccount.Subcategory);
    end;

    local procedure ExistSustProdOrderRoutingLine(ProdOrderLine: Record "Prod. Order Line"): Boolean
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        ProdOrderRoutingLine.SetLoadFields(Status, "Prod. Order No.", "Routing No.", "Routing Reference No.", "Sust. Account No.");
        ProdOrderRoutingLine.SetRange(Status, ProdOrderLine.Status);
        ProdOrderRoutingLine.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
        ProdOrderRoutingLine.SetRange("Routing No.", ProdOrderLine."Routing No.");
        ProdOrderRoutingLine.SetRange("Routing Reference No.", ProdOrderLine."Line No.");
        ProdOrderRoutingLine.SetFilter("Sust. Account No.", '<>%1', '');

        exit(not ProdOrderRoutingLine.IsEmpty());
    end;

    local procedure ExistSustProdOrderComponent(ProdOrderLine: Record "Prod. Order Line"): Boolean
    var
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        ProdOrderComponent.SetLoadFields(Status, "Prod. Order No.", "Prod. Order Line No.", "Sust. Account No.");
        ProdOrderComponent.SetRange(Status, ProdOrderLine.Status);
        ProdOrderComponent.SetRange("Prod. Order No.", ProdOrderLine."Prod. Order No.");
        ProdOrderComponent.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
        ProdOrderComponent.SetFilter("Sust. Account No.", '<>%1', '');

        exit(not ProdOrderComponent.IsEmpty());
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        NotAllowedToUseSustAccountForWaterOrWasteErr: Label 'It is not allowed to use Sustainability Account %1 for water or waste in Production document.', Comment = '%1 = Sust. Account No.';
}