// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Shared.Error;

using System.Utilities;
codeunit 7902 "Default Impl. Error Message" implements ErrorMessageFix
{
    procedure OnSetErrorMessageProps(var ErrorMessage: Record "Error Message" temporary);
    begin
    end;

    procedure OnFixError(ErrorMessage: Record "Error Message" temporary): Boolean;
    begin
    end;

    procedure OnSuccessMessage(): Text;
    begin
    end;
}