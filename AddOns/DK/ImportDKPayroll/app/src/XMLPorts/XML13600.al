// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

xmlport 13600 "Data Exch. Imp.- Proløn"
{
    Direction = Import;
    FieldSeparator = ';';
    Format = VariableText;
    Permissions = TableData 1221 = rimd;
    TextEncoding = WINDOWS;
    UseRequestPage = false;

    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            tableelement(DataExchDocument; "Data Exch.")
            {
                AutoSave = false;
                XmlName = 'DataExchDocument';
                textelement(col1)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'col1';

                    trigger OnAfterAssignVariable();
                    begin
                        InsertColumn(1, col1);
                    end;
                }
                textelement(col2)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'col2';

                    trigger OnAfterAssignVariable();
                    begin
                        InsertColumn(2, col2);
                    end;
                }
                textelement(col3)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'col3';

                    trigger OnAfterAssignVariable();
                    begin
                        InsertColumn(3, col3);
                    end;
                }
                textelement(col4)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'col4';

                    trigger OnAfterAssignVariable();
                    begin
                        InsertColumn(4, col4);
                    end;
                }
                textelement(col5)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'col5';

                    trigger OnAfterAssignVariable();
                    begin
                        AmountTxt := col5;
                    end;
                }
                textelement(col6)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'col6';

                    trigger OnAfterAssignVariable();
                    begin
                        CASE col6 OF
                            'K':
                                InsertColumn(5, '-' + AmountTxt);
                            'D':
                                InsertColumn(5, AmountTxt);
                            ELSE
                                IF NOT SkipLine THEN
                                    ERROR(WrongFileErr);
                        END;
                    end;
                }
                textelement(col7)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'col7';

                    trigger OnAfterAssignVariable();
                    begin
                        InsertColumn(7, col7);
                    end;
                }
                textelement(col8)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'col8';

                    trigger OnAfterAssignVariable();
                    begin
                        InsertColumn(8, col8);
                    end;
                }
                textelement(col9)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'col9';

                    trigger OnAfterAssignVariable();
                    begin
                        InsertColumn(9, col9);
                    end;
                }
                textelement(col10)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'col10';

                    trigger OnAfterAssignVariable();
                    begin
                        InsertColumn(10, col10);
                    end;
                }

                trigger OnAfterInitRecord();
                begin
                    LineNo += 1;
                    SkipLine := LineNo <= 1;
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPreXmlPort();
    var
        DataExch: Record 1220;
        DataExchDef: Record 1222;
    begin
        DataExchEntryNo := DataExchDocument.GETRANGEMIN("Entry No.");
        DataExch.GET(DataExchEntryNo);
        DataExchLineDefCode := DataExch."Data Exch. Line Def Code";
        DataExchDef.GET(DataExch."Data Exch. Def Code");
        LineNo := 0;
    end;

    var
        DataExchEntryNo: Integer;
        LineNo: Integer;
        SkipLine: Boolean;
        AmountTxt: Text;
        WrongFileErr: Label 'The imported file does not match the expected format.';
        DataExchLineDefCode: Code[20];

    local procedure InsertColumn(columnNumber: Integer; columnValue: Text);
    var
        DataExchField: Record 1221;
    begin
        IF SkipLine THEN
            EXIT;
        IF columnValue <> '' THEN BEGIN
            DataExchField.INIT();
            DataExchField.VALIDATE("Data Exch. No.", DataExchEntryNo);
            DataExchField.VALIDATE("Line No.", LineNo - 1);
            DataExchField.VALIDATE("Column No.", columnNumber);
            DataExchField.VALIDATE(Value, COPYSTR(columnValue, 1, MAXSTRLEN(DataExchField.Value)));
            DataExchField.VALIDATE("Data Exch. Line Def Code", DataExchLineDefCode);
            DataExchField.INSERT(TRUE);
        END;
    end;
}
