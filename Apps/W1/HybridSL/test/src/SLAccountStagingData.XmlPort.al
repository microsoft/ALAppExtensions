// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 147622 "SL Account Staging Data"
{
    Caption = 'SL Account Staging data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL Account Staging"; "SL Account Staging")
            {
                AutoSave = false;
                XmlName = 'SLAccountStaging';

                textelement("AccountNumber")
                {
                }
                textelement("Name")
                {
                }
                textelement("SearchName")
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
                textelement("Active")
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
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    SLAccountStaging.AcctNum := AccountNumber;
                    SLAccountStaging.Name := Name;
                    SLAccountStaging.SearchName := SearchName;
                    Evaluate(SLAccountStaging.AccountCategory, AccountCategory);
                    Evaluate(SLAccountStaging.IncomeBalance, IncomeBalance);
                    Evaluate(SLAccountStaging.DebitCredit, DebitCredit);
                    Evaluate(SLAccountStaging.Active, Active);
                    SLAccountStaging.Insert(false);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        CaptionRow := true;
    end;

    var
        CaptionRow: Boolean;
        SLAccountStaging: Record "SL Account Staging";
}