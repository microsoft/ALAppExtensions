// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
xmlport 149000 "BCPT Log Entries"
{
    Caption = 'Export Item Data';
    DefaultFieldsValidation = false;
    Direction = Export;
    FieldDelimiter = '<~>';
    FieldSeparator = '<;>';
    Format = VariableText;
    TextEncoding = UTF16;
    UseRequestPage = false;

    schema
    {
        textelement(root)
        {
            XmlName = 'Root';
            tableelement(logentry; "BCPT Log Entry")
            {
                AutoSave = false;
                AutoUpdate = false;
                RequestFilterFields = "BCPT Code";
                XmlName = 'BCPTLogEntry';
                fieldelement(Entry_No; logentry."Entry No.") { }
                fieldelement(BCPT_Code; logentry."BCPT Code") { }
                fieldelement(BCPT_Line_No; logentry."BCPT Line No.") { }
                fieldelement(Start_Time; logentry."Start Time") { }
                fieldelement(End_Time; logentry."End Time") { }
                fieldelement(Message; logentry."Message") { }
                fieldelement(Codeunit_ID; logentry."Codeunit ID") { }
                fieldelement(Codeunit_Name; logentry."Codeunit Name") { }
                fieldelement(Duration_ms; logentry."Duration (ms)") { }
                fieldelement(Status; logentry."Status") { }
                fieldelement(Tage; logentry.Tag) { }
                fieldelement(No_Of_Sql_Statements; logentry."No. of SQL Statements") { }
                fieldelement(Version; logentry.Version) { }
            }
        }
    }
}