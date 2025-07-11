// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

using System.IO;

Codeunit 13654 FIK_ReadFile
{
    TableNo = "Data Exch.";

    VAR
        FIKFileNotValidErr: Label 'The selected file is not a FIK file.';
        FIKPrefixValidateTxt: Label 'FI0';

    trigger OnRun();
    var
        ReadStream: InStream;
        FIKLine: Text;
        ReadLen: Integer;
    begin
        "File Content".CREATEINSTREAM(ReadStream);
        REPEAT
            ReadLen := ReadStream.READTEXT(FIKLine);
            IF ReadLen > 0 THEN
                IF STRPOS(FIKLine, FIKPrefixValidateTxt) <> 1 THEN
                    ERROR(FIKFileNotValidErr);
        UNTIL ReadLen = 0;

        CODEUNIT.RUN(CODEUNIT::"Fixed File Import", Rec);
    end;
}

