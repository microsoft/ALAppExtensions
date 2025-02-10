namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Capacity;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.MachineCenter;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

tableextension 6247 "Sust. Prod. Order Routing Line" extends "Prod. Order Routing Line"
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
    }

    procedure UpdateSustainabilityEmission(var ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    begin
        ProdOrderRoutingLine."Total CO2e" := ProdOrderRoutingLine."CO2e per Unit" * GetUnitCostPerOperation(ProdOrderRoutingLine);
    end;

    local procedure GetUnitCostPerOperation(var ProdOrderRoutingLine: Record "Prod. Order Routing Line"): Decimal
    var
        ProdOrderLine: Record "Prod. Order Line";
        CalendarMgt: Codeunit "Shop Calendar Management";
    begin
        if ProdOrderRoutingLine."Unit Cost Calculation" = ProdOrderRoutingLine."Unit Cost Calculation"::Time then
            exit(
                (ProdOrderRoutingLine."Run Time" * CalendarMgt.QtyperTimeUnitofMeasure(ProdOrderRoutingLine."Work Center No.", ProdOrderRoutingLine."Run Time Unit of Meas. Code")) +
                (ProdOrderRoutingLine."Setup Time" * CalendarMgt.QtyperTimeUnitofMeasure(ProdOrderRoutingLine."Work Center No.", ProdOrderRoutingLine."Setup Time Unit of Meas. Code")) +
                (ProdOrderRoutingLine."Move Time" * CalendarMgt.QtyperTimeUnitofMeasure(ProdOrderRoutingLine."Work Center No.", ProdOrderRoutingLine."Move Time Unit of Meas. Code")) +
                (ProdOrderRoutingLine."Wait Time" * CalendarMgt.QtyperTimeUnitofMeasure(ProdOrderRoutingLine."Work Center No.", ProdOrderRoutingLine."Wait Time Unit of Meas. Code")));

        GetProdOrderLine(ProdOrderLine, ProdOrderRoutingLine);
        exit(ProdOrderLine.Quantity * ProdOrderLine."Qty. per Unit of Measure");
    end;

    procedure UpdateEmissionPerUnit(var ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    var
        Denominator: Decimal;
    begin
        ProdOrderRoutingLine."CO2e Per Unit" := 0;

        if (GetUnitCostPerOperation(ProdOrderRoutingLine) = 0) then
            exit;

        Denominator := GetUnitCostPerOperation(ProdOrderRoutingLine);
        if ProdOrderRoutingLine."Total CO2e" <> 0 then
            ProdOrderRoutingLine."CO2e per Unit" := ProdOrderRoutingLine."Total CO2e" / Denominator;
    end;

    local procedure ClearEmissionInformation(var ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    begin
        ProdOrderRoutingLine.Validate("CO2e per Unit", 0);
    end;

    local procedure ValidateEmissionPrerequisite(ProdOrderRoutingLine: Record "Prod. Order Routing Line"; CurrentFieldNo: Integer)
    var
        SustAccountCategory: Record "Sustain. Account Category";
    begin
        case CurrentFieldNo of
            ProdOrderRoutingLine.FieldNo("CO2e per Unit"),
            ProdOrderRoutingLine.FieldNo("Total CO2e"):
                ProdOrderRoutingLine.TestField("Sust. Account No.");
            ProdOrderRoutingLine.FieldNo("Sust. Account No."),
            ProdOrderRoutingLine.FieldNo("Sust. Account Category"),
            ProdOrderRoutingLine.FieldNo("Sust. Account Subcategory"),
            ProdOrderRoutingLine.FieldNo("Sust. Account Name"):
                begin
                    ProdOrderRoutingLine.TestField("No.");

                    if SustAccountCategory.Get(ProdOrderRoutingLine."Sust. Account Category") then
                        if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                            Error(NotAllowedToUseSustAccountForWaterOrWasteErr, ProdOrderRoutingLine."Sust. Account No.");
                end;
        end;
    end;

    local procedure UpdateCO2eInformation()
    var
        MachineCenter: Record "Machine Center";
        WorkCenter: Record "Work Center";
    begin
        case Rec.Type of
            Rec.Type::"Machine Center":
                begin
                    MachineCenter.Get(Rec."No.");
                    Rec.Validate("CO2e per Unit", MachineCenter."CO2e per Unit");
                end;
            Rec.Type::"Work Center":
                begin
                    WorkCenter.Get(Rec."No.");
                    Rec.Validate("CO2e per Unit", WorkCenter."CO2e per Unit");
                end;
        end;
    end;

    local procedure CopyFromSustainabilityAccount(var ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    var
        SustainabilityAccount: Record "Sustainability Account";
    begin
        SustainabilityAccount.Get(ProdOrderRoutingLine."Sust. Account No.");
        SustainabilityAccount.CheckAccountReadyForPosting();
        SustainabilityAccount.TestField("Direct Posting", true);

        ProdOrderRoutingLine.Validate("Sust. Account Name", SustainabilityAccount.Name);
        ProdOrderRoutingLine.Validate("Sust. Account Category", SustainabilityAccount.Category);
        ProdOrderRoutingLine.Validate("Sust. Account Subcategory", SustainabilityAccount.Subcategory);
    end;

    local procedure GetProdOrderLine(var ProdOrderLine: Record "Prod. Order Line"; ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    begin
        ProdOrderLine.SetRange(Status, ProdOrderRoutingLine.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProdOrderRoutingLine."Prod. Order No.");
        ProdOrderLine.SetRange("Routing No.", ProdOrderRoutingLine."Routing No.");
        ProdOrderLine.SetRange("Routing Reference No.", ProdOrderRoutingLine."Routing Reference No.");
        ProdOrderLine.FindFirst();
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        NotAllowedToUseSustAccountForWaterOrWasteErr: Label 'It is not allowed to use Sustainability Account %1 for water or waste in Production document.', Comment = '%1 = Sust. Account No.';
}