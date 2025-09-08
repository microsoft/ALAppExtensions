// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Test.Shared.Error;

using Microsoft.Shared.Error;
using System.Utilities;

codeunit 139623 FailToFixErrorMessageTest implements ErrorMessageFix
{
    Access = Internal;

    procedure OnSetErrorMessageProps(var ErrorMessage: Record "Error Message" temporary);
    begin
        ErrorMessage.Title := '';
        ErrorMessage."Recommended Action Caption" := '';
    end;

    procedure OnFixError(ErrorMessage: Record "Error Message" temporary): Boolean;
    begin
        Error('Test error');
    end;

    procedure OnSuccessMessage(): Text;
    begin
        // Do nothing
    end;
}