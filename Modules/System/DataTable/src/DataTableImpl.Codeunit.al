// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 50001 "DataTable Impl."
{
    Access = Internal;

    var
        DotNetDataTable: DotNet DataTable;

    procedure Calculate(Expression: Text) Result: Variant
    begin
        if not Compute(Expression, Result) then
            Result := 0;
    end;

    procedure Calculate(Expression: Text; var Result: Variant)
    begin
        Compute(Expression, Result);
    end;

    [TryFunction]
    local procedure Compute(Expression: Text; var Result: Variant)
    var
        DotNetObject: DotNet Object;
    begin
        if IsNull(DotNetDataTable) then
            DotNetDataTable := DotNetDataTable.DataTable();

        DotNetObject := DotNetDataTable.Compute(Expression, '');

        Result := ConvertResult(DotNetObject);
    end;

    local procedure ConvertResult(DotNetResult: DotNet Object) Result: Variant
    var
        DotNetSByte: DotNet SByte;
        DotNetByte: DotNet Byte;
        DotNetShort: DotNet Int16;
        DotNetInt: DotNet Int32;
        DotNetLong: DotNet Int64;
        DotNetFloat: DotNet Float;
        DotNetDouble: DotNet Double;
        DotNetDecimal: DotNet Decimal;
        DotNetBoolean: DotNet Boolean;
        DotNetType: DotNet Type;
        DotNetConvert: DotNet Convert;
        Integer: Integer;
        BigInteger: BigInteger;
        Decimal: Decimal;
        Boolean: Boolean;
    begin
        DotNetType := DotNetResult.GetType();
        case true of
            DotNetType.Equals(GetDotNetType(DotNetByte)),
            DotNetType.Equals(GetDotNetType(DotNetSByte)),
            DotNetType.Equals(GetDotNetType(DotNetShort)),
            DotNetType.Equals(GetDotNetType(DotNetInt)):
                begin
                    Integer := DotNetResult;
                    Result := Integer;
                end;
            DotNetType.Equals(GetDotNetType(DotNetLong)):
                begin
                    BigInteger := DotNetResult;
                    Result := BigInteger;
                end;
            DotNetType.Equals(GetDotNetType(DotNetFloat)),
            DotNetType.Equals(GetDotNetType(DotNetDecimal.Decimal(0))):
                begin
                    Decimal := DotNetResult;
                    Result := Decimal;
                end;
            DotNetType.Equals(GetDotNetType(DotNetDouble)):
                begin
                    if DotNetDouble.IsInfinity(DotNetResult) then
                        Error('Attempted to divide by zero.');
                    DotNetDouble := DotNetResult;
                    Decimal := DotNetConvert.ToDecimal(DotNetDouble);
                    Result := Decimal;
                end;
            DotNetType.Equals(GetDotNetType(DotNetBoolean)):
                begin
                    Boolean := DotNetResult;
                    Result := Boolean;
                end;
        end;
    end;
}