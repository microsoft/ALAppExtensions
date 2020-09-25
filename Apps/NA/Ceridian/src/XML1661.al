xmlport 1661 "Import Ceridian Payroll"
{
    Direction = Import;
    FieldDelimiter = '<None>';
    Format = VariableText;
    FormatEvaluate = Legacy;
    TextEncoding = WINDOWS;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement("Import G/L Transaction"; 1661)
            {
                XmlName = 'PayrollBuffer';
                UseTemporary = true;
                textelement(Account)
                {

                    trigger OnAfterAssignVariable();
                    begin
                        "Import G/L Transaction".VALIDATE("External Account", Account);
                    end;
                }
                textelement(transactiondate)
                {
                    XmlName = 'TransactionDate';

                    trigger OnAfterAssignVariable();
                    var
                        Day: Integer;
                        Month: Integer;
                        Year: Integer;
                    begin
                        EVALUATE(Day, COPYSTR(TransactionDate, 3, 2));
                        EVALUATE(Month, COPYSTR(TransactionDate, 1, 2));
                        EVALUATE(Year, COPYSTR(TransactionDate, 5, 4));
                        "Import G/L Transaction"."Transaction Date" := DMY2DATE(Day, Month, Year);
                    end;
                }
                textelement(amountvar)
                {
                    XmlName = 'Amount';

                    trigger OnAfterAssignVariable();
                    begin
                        // Ceridian formats the decimals in US format with no thousands seperator. <Integer>.<Decimals>
                        // We can read that in any language as XML formatted. 
                        EVALUATE("Import G/L Transaction".Amount, AmountVar, 9);
                    end;
                }
                fieldelement(Description; "Import G/L Transaction".Description)
                {
                }

                trigger OnAfterInitRecord();
                var
                    MSCeridianPayrollSetup: Record 1665;
                begin
                    I += 1;
                    "Import G/L Transaction"."Entry No." := I;
                    "Import G/L Transaction"."App ID" := MSCeridianPayrollSetup.GetAppID();
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

    trigger OnInitXmlPort();
    begin
        I := 0;
    end;

    var
        I: Integer;

    procedure GetTemporaryRecords(var TempImportGLTransaction: Record 1661 temporary);
    begin
        IF "Import G/L Transaction".FINDSET() THEN
            REPEAT
                TempImportGLTransaction := "Import G/L Transaction";
                TempImportGLTransaction.VALIDATE("External Account");
                TempImportGLTransaction.INSERT();
            UNTIL "Import G/L Transaction".NEXT() = 0;
    end;
}

