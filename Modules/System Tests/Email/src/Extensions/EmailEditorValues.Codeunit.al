// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Email;

codeunit 134683 "Email Editor Values"
{
    Access = Internal;
    SingleInstance = true;

    var
        ExitOption: Integer;

    procedure GetDefaultExitOption(): Integer
    begin
        // Default value 1 if the value has not been set
        if ExitOption = 0 then
            exit(1);

        exit(ExitOption);
    end;

    procedure SetDefaultExitOption(NewExitOption: Integer)
    begin
        ExitOption := NewExitOption;
    end;
}