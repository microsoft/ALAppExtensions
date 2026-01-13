// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using System.Telemetry;

table 6294 "Sust. Formula Buffer"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    TableType = Temporary;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Expression Name"; Text[1024])
        {
            DataClassification = CustomerContent;
            Caption = 'Expression Name';
            ToolTip = 'Specifies the name of the expression';
        }
        field(2; "Expression Formula"; Text[1024])
        {
            Caption = 'Expression Formula';
            ToolTip = 'Specifies the formula of the expression';
        }
        field(3; "Expression Value"; Decimal)
        {
            Caption = 'Expression Value';
            ToolTip = 'Specifies the value of the expression';
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
        field(4; Order; Integer)
        {
            Caption = 'Order';
            ToolTip = 'Specifies the sequence of the expression';
        }
    }

    keys
    {
        key(PK; "Expression Name")
        {
            Clustered = true;
        }
        key(Order; Order)
        {

        }
    }

    var
        IncorrectLengthErr: Label 'The %1 exceeds the maximum length of %2', Comment = '%1 = Field Caption, %2 = Max Length';

    procedure InsertExpression(ExpressionName: Text; ExpressionFormula: Text; ExpressionValue: Decimal; ExpressionOrder: Integer)
    begin
        CheckLength(ExpressionName, 'Expression Name', MaxStrLen(Rec."Expression Name"));
        CheckLength(ExpressionFormula, 'Expression Formula', MaxStrLen(Rec."Expression Formula"));
        Rec."Expression Name" := CopyStr(ExpressionName, 1, MaxStrLen(Rec."Expression Name"));
        Rec."Expression Formula" := CopyStr(ExpressionFormula, 1, MaxStrLen(Rec."Expression Formula"));
        Rec."Expression Value" := ExpressionValue;
        Rec."Order" := ExpressionOrder;
        Insert(true);
    end;

    local procedure CheckLength(Text: Text; FieldCaption: Text; MaxLength: Integer)
    var
        Telemetry: Codeunit Telemetry;
    begin
        if StrLen(Text) > MaxLength then begin
            Telemetry.LogMessage('0000PYG', StrSubstNo(IncorrectLengthErr, FieldCaption, MaxLength), Verbosity::Error, DataClassification::SystemMetadata);
            Error(IncorrectLengthErr, FieldCaption, MaxLength);
        end;
    end;
}