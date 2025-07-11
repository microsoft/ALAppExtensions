// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.IO;

codeunit 11778 "Transformation Rule Mgt. CZL"
{
    var
        CZDATEFORMATTxt: Label 'CZ_DATE_FORMAT', Comment = 'Assigned to Transformation.Code field for getting date formatting rule from Czech dates';
        CZDATEFORMATDescTxt: Label 'Czech Date Format';
        CZDATETIMEFORMATTxt: Label 'CZ_DATETIME_FORMAT', Comment = 'Assigned to Transformation.Code field for getting datetime formatting rule from Czech date/time';
        CZDATETIMEFORMATDescTxt: Label 'Czech Date/Time Format';
        CZNUMBERFORMATTxt: Label 'CZ_DECIMAL_FORMAT', Comment = 'Assigned to Transformation.Code field for getting decimal formatting rule for Czech numbers';
        CZNUMBERFORMATDescTxt: Label 'Czech Decimal Format';

    [EventSubscriber(ObjectType::Table, Database::"Transformation Rule", 'OnCreateTransformationRules', '', false, false)]
    local procedure CreateDefaultTransformationsOnCreateTransformationRules()
    var
        TransformationRule: Record "Transformation Rule";
    begin
        TransformationRule.InsertRec(CZDATEFORMATTxt, CZDATEFORMATDescTxt, TransformationRule."Transformation Type"::"Date Formatting".AsInteger(), 0, 0, '', 'cs-CZ');
        TransformationRule.InsertRec(CZDATETIMEFORMATTxt, CZDATETIMEFORMATDescTxt, TransformationRule."Transformation Type"::"Date and Time Formatting".AsInteger(), 0, 0, '', 'cs-CZ');
        TransformationRule.InsertRec(CZNUMBERFORMATTxt, CZNUMBERFORMATDescTxt, TransformationRule."Transformation Type"::"Decimal Formatting".AsInteger(), 0, 0, '', 'cs-CZ');
    end;

    procedure GetCZDateFormatCode(): Code[20]
    begin
        exit(CZDATEFORMATTxt);
    end;

    procedure GetCZDateTimeFormatCode(): Code[20]
    begin
        exit(CZDATETIMEFORMATTxt);
    end;

    procedure GetCzechDecimalFormatCode(): Code[20]
    begin
        exit(CZNUMBERFORMATTxt);
    end;
}
