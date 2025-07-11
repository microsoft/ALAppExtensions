// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using System.IO;
using Microsoft.DemoTool.Helpers;

codeunit 5309 "Create Data Exchange Type"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        DataExchDef: Record "Data Exch. Def";
        ContosoDataExchange: Codeunit "Contoso Data Exchange";
    begin
        if DataExchDef.FindSet() then
            repeat
                ContosoDataExchange.InsertDataExchangeType(DataExchDef."Code", DataExchDef.Name, DataExchDef."Code");
            until DataExchDef.Next() = 0;
    end;

}
