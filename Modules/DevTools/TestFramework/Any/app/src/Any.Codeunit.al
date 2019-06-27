// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
///
/// </summary>
codeunit 130500 "Any"
{

    SingleInstance = true;

    // <summary>.
    // Generates a random integer between [1, Max]. 0 Returns 1 and negative numbers are treated as positive.
    // </summary>
    // <param name="Max">Max range of the number.</param>
    // <return>Generated int value</return>
    [Scope('OnPrem')]
    procedure RandInt("Max": Integer): Integer
    begin
        EXIT(RANDOM(Max));
    end;
}

