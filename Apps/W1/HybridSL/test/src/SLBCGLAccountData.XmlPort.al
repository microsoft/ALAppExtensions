// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Finance.GeneralLedger.Account;

xmlport 147602 "SL BC GL Account Data"
{
    Caption = 'G/L Account data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("G/L Account"; "G/L Account")
            {
                AutoSave = false;
                XmlName = 'GLAccount';

                textelement("No.")
                {
                }
                textelement("Name")
                {
                }
                textelement("SearchName")
                {
                }
                textelement("AccountType")
                {
                }
                textelement("AccountCategory")
                {
                }
                textelement("IncomeBalance")
                {
                }
                textelement("DebitCredit")
                {
                }
                textelement("DirectPosting")
                {
                }

                trigger OnPreXmlItem()
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;
                end;

                trigger OnBeforeInsertRecord()
                var
                    GLAccount: Record "G/L Account";
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    GLAccount."No." := "No.";
                    GLAccount.Name := Name;
                    GLAccount."Search Name" := "SearchName";
                    Evaluate(GLAccount."Account Type", "AccountType");
                    Evaluate(GLAccount."Account Category", "AccountCategory");
                    Evaluate(GLAccount."Income/Balance", "IncomeBalance");
                    Evaluate(GLAccount."Debit/Credit", "DebitCredit");
                    Evaluate(GLAccount."Direct Posting", "DirectPosting");
                    GLAccount.Insert(true);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        GLAccount.DeleteAll();
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        GLAccount: Record "G/L Account";
}
