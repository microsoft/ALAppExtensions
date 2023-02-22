// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 144740 "BCPT Test Library"
{
    SingleInstance = true;
    Access = Internal;

    procedure AddBCPTSuite(var BCPTHeader: Record "BCPT Header")
    begin
        Clear(BCPTHeader);
        BCPTHeader.Code := CopyStr(CreateGuid(), 1, MaxStrLen(BCPTHeader.Code));
        BCPTHeader.Description := CopyStr(CreateGuid(), 1, MaxStrLen(BCPTHeader.Description));
        BCPTHeader.Insert(true);
        Commit();
    end;

    procedure AddBCPTLineToSuite(var BCPTLine: Record "BCPT Line"; BCPTHeaderCode: Code[10]; CodeunitIDToRun: Integer)
    begin
        Clear(BCPTLine);
        BCPTLine."BCPT Code" := BCPTHeaderCode;
        BCPTLine."Codeunit ID" := CodeunitIDToRun;
        BCPTLine."Run in Foreground" := true;
        BCPTLine."Delay Type" := BCPTLine."Delay Type"::Fixed;
        BCPTLine.Insert(true);
        Commit();
    end;

}