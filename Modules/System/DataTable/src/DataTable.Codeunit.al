// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to use expressions to calculate decimal, boolean etc.  
/// </summary>
codeunit 50000 DataTable
{
    Access = Public;

    var
        DataTableImpl: Codeunit "DataTable Impl.";

    /// <summary>
    /// Calculates the value of a text expression.
    /// In case of an error condition a value of 0 is returned.
    /// </summary>
    /// <param name="Expression">The text expression to evaluate.</param>
    /// <returns>The calcultated value as a variant. The variant can contain a boolean, byte, integer, biginteger or decimal.</returns>
    procedure Calculate(Expression: Text) Result: Variant
    begin
        Result := DataTableImpl.Calculate(Expression);
    end;

    /// <summary>
    /// Calculates the value of a text expression
    /// In case of an error condition a value of 0 is returned.
    /// </summary>
    /// <param name="Expression">The text expression to evaluate.</param>
    /// <param name="Result">The calcultated value as a variant. The variant can contain a boolean, byte, integer, biginteger or decimal.</param>
    /// <returns>A boolean indicating a succesful operation.</returns>
    [TryFunction]
    procedure Calculate(Expression: Text; var Result: Variant)
    begin
        DataTableImpl.Calculate(Expression, Result);
    end;
}
