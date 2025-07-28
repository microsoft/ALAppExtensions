// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

codeunit 30338 "Shpfy Mtfld Type Boolean" implements "Shpfy IMetafield Type"
{
    procedure HasAssistEdit(): Boolean
    begin
        exit(false);
    end;

    procedure IsValidValue(Value: Text): Boolean
    var
        DummyBoolean: Boolean;
    begin
        exit(Evaluate(DummyBoolean, Value, 9));
    end;

    procedure AssistEdit(var Value: Text[2048]): Boolean
    begin
        Value := Value;
        exit(false);
    end;

    procedure GetExampleValue(): Text
    begin
        exit('true');
    end;
}