// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Shared.Error;

using System.Utilities;
codeunit 7901 "Execute Error Action"
{
    Access = Internal;
    TableNo = "Error Message";

    var
        IErrorMessageFixProviderGbl: Interface ErrorMessageFix;

    trigger OnRun()
    begin
        if not IErrorMessageFixProviderGbl.OnFixError(Rec) then
            Error(''); //Throw an error to make the Codeunit.OnRun fail.
    end;

    internal procedure SetErrorMessageFixImplementation(var IErrorMessageFixProvider: Interface ErrorMessageFix)
    begin
        IErrorMessageFixProviderGbl := IErrorMessageFixProvider;
    end;
}