// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Shipping;
using System.IO;

codeunit 31303 "Intrastat Transformation CZ"
{

    trigger OnRun()
    begin
    end;

    var
        IntrastatArrivalDispatchDescTxt: Label 'Transforming intrastat "Receipt" type to letter ''A'' and "Shipment" type to letter ''D''.';
        IntrastatArrivalDispatchTxt: Label 'INT_ARRIVALDISPATCH', Locked = true;
        IntrastatDeliveryGroupDescTxt: Label 'Lookup intrastat delivery group code from shipment method.';
        IntrastatDeliveryGroupTxt: Label 'INT_DELIV_GROUP', Locked = true;
        IntrastatRoundToIntDescTxt: Label 'Round to integer and take into account the rounding direction setting in intrastat report setup.';
        IntrastatRoundToIntTxt: Label 'INT_ROUNDTOINT', Locked = true;
        IntrastatRoundToIntGreaterThanOneDescTxt: Label 'Round to integer when the decimal is greater than 1.';
        IntrastatRoundToIntGreaterThanOneTxt: Label 'INT_ROUNDTOINTGTONE', Locked = true;
        IntrastatStatisticsMonthDescTxt: Label 'Transforming intrastat Statistics Period to month.';
        IntrastatStatisticsMonthTxt: Label 'INT_STAT_MONTH', Locked = true;
        IntrastatStatisticsYearDescTxt: Label 'Transforming intrastat Statistics Period to year.';
        IntrastatStatisticsYearTxt: Label 'INT_STAT_YEAR', Locked = true;
        ArrivalTok: Label 'A', MaxLength = 1, Locked = true;
        DispatchTok: Label 'D', MaxLength = 1, Locked = true;

    [EventSubscriber(ObjectType::Table, Database::"Transformation Rule", 'OnTransformation', '', false, false)]
    local procedure TransformIntrastatOnTransformation(TransformationCode: Code[20]; InputText: Text; var OutputText: Text)
    begin
        case TransformationCode of
            GetIntrastatStatisticsYearCode():
                OutputText := Format(TransformStatisticsPeriod(InputText));
            GetIntrastatArrivalDispatchCode():
                OutputText := TransformIntrastatReportLineType(InputText);
            GetIntrastatRoundToIntCode():
                OutputText := Format(RoundToInt(InputText), 0, 9);
            GetIntrastatRoundToIntGreaterThanOneCode():
                OutputText := Format(RoundToIntWhenGreaterThanOne(InputText), 0, '<Precision,3:3><Standard Format,9>');
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transformation Rule", 'OnCreateTransformationRules', '', false, false)]
    local procedure InsertIntrastatTransformationRulesOnCreateTransformationRules()
    var
        ShipmentMethod: Record "Shipment Method";
        TransformationRule: Record "Transformation Rule";
    begin
        TransformationRule.InsertRec(GetIntrastatStatisticsMonthCode(), IntrastatStatisticsMonthDescTxt, TransformationRule."Transformation Type"::Substring.AsInteger(), 3, 2, '', '');
        TransformationRule.InsertRec(GetIntrastatStatisticsYearCode(), IntrastatStatisticsYearDescTxt, TransformationRule."Transformation Type"::Custom.AsInteger(), 0, 0, '', '');
        TransformationRule.InsertRec(GetIntrastatArrivalDispatchCode(), IntrastatArrivalDispatchDescTxt, TransformationRule."Transformation Type"::Custom.AsInteger(), 0, 0, '', '');
        TransformationRule.InsertRec(GetIntrastatRoundToIntCode(), IntrastatRoundToIntDescTxt, TransformationRule."Transformation Type"::Custom.AsInteger(), 0, 0, '', '');
        TransformationRule.InsertRec(GetIntrastatRoundToIntGreaterThanOneCode(),
            IntrastatRoundToIntGreaterThanOneDescTxt, TransformationRule."Transformation Type"::Custom.AsInteger(), 0, 0, '', '');

        if not TransformationRule.Get(GetIntrastatDeliveryGroupCode()) then begin
            TransformationRule.Init();
            TransformationRule.Validate(Code, GetIntrastatDeliveryGroupCode());
            TransformationRule.Validate(Description, IntrastatDeliveryGroupDescTxt);
            TransformationRule.Validate("Transformation Type", Enum::"Transformation Rule Type"::"Field Lookup");
            TransformationRule.Validate("Table ID", Database::"Shipment Method");
            TransformationRule.Validate("Source Field ID", ShipmentMethod.FieldNo(Code));
            TransformationRule.Validate("Target Field ID", ShipmentMethod.FieldNo("Intrastat Deliv. Grp. Code CZ"));
            TransformationRule.Insert();
        end;
    end;

    local procedure TransformStatisticsPeriod(InputText: Text): Integer
    var
        Century: Integer;
        Year: Integer;
    begin
        Century := Date2DMY(WorkDate(), 3) div 100;
        Evaluate(Year, CopyStr(InputText, 1, 2));
        exit(Year + Century * 100);
    end;

    local procedure TransformIntrastatReportLineType(InputText: Text): Text[1]
    var
        IntrastatReportLineType: Enum "Intrastat Report Line Type";
    begin
        Evaluate(IntrastatReportLineType, InputText);
        case IntrastatReportLineType of
            IntrastatReportLineType::Receipt:
                exit(ArrivalTok);
            IntrastatReportLineType::Shipment:
                exit(DispatchTok);
        end;
    end;

    local procedure RoundToIntWhenGreaterThanOne(InputText: Text): Decimal
    var
        DecVar: Decimal;
    begin
        Evaluate(DecVar, InputText);
        if DecVar > 1 then
            DecVar := Round(DecVar, 1, GetRoundingDirection());
        exit(DecVar);
    end;

    local procedure RoundToInt(InputText: Text): Decimal
    var
        DecVar: Decimal;
    begin
        Evaluate(DecVar, InputText);
        exit(Round(DecVar, 1, GetRoundingDirection()));
    end;

    local procedure GetRoundingDirection(): Text[1]
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        exit(IntrastatReportSetup.GetRoundingDirectionCZ());
    end;

    procedure GetIntrastatArrivalDispatchCode(): Code[20]
    begin
        exit(IntrastatArrivalDispatchTxt);
    end;

    procedure GetIntrastatDeliveryGroupCode(): Code[20]
    begin
        exit(IntrastatDeliveryGroupTxt);
    end;

    procedure GetIntrastatRoundToIntCode(): Code[20]
    begin
        exit(IntrastatRoundToIntTxt);
    end;

    procedure GetIntrastatRoundToIntGreaterThanOneCode(): Code[20]
    begin
        exit(IntrastatRoundToIntGreaterThanOneTxt);
    end;

    procedure GetIntrastatStatisticsMonthCode(): Code[20]
    begin
        exit(IntrastatStatisticsMonthTxt);
    end;

    procedure GetIntrastatStatisticsYearCode(): Code[20]
    begin
        exit(IntrastatStatisticsYearTxt);
    end;
}

