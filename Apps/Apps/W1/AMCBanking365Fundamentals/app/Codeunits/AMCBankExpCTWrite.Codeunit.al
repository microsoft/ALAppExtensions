// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using System.IO;

codeunit 20120 "AMC Bank Exp. CT Write"
{
    Permissions = TableData "Payment Export Data" = rimd;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        DataExchDef: Record "Data Exch. Def";
        PaymentExportData: Record "Payment Export Data";
        OutStream: OutStream;
    begin
        DataExchDef.Get("Data Exch. Def Code");
        DataExchDef.TestField("Reading/Writing XMLport");

        "File Content".CreateOutStream(OutStream);
        PaymentExportData.SetRange("Data Exch Entry No.", "Entry No.");
        XMLPORT.Export(DataExchDef."Reading/Writing XMLport", OutStream, PaymentExportData);

    end;
}

