// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Document;

using Microsoft.Manufacturing.Setup;

codeunit 31258 "Production Order Handler CZA"
{
    [EventSubscriber(ObjectType::Table, Database::"Production Order", 'OnAfterInitRecord', '', false, false)]
    local procedure DefaultGenBusPostingGroupOnAfterInitRecord(var ProductionOrder: Record "Production Order")
    var
        ManufacturingSetup: Record "Manufacturing Setup";
    begin
        ManufacturingSetup.Get();
        ProductionOrder.Validate("Gen. Bus. Posting Group", ManufacturingSetup."Default Gen.Bus.Post. Grp. CZA");
    end;
}
