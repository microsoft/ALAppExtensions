// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Bank.BankAccount;

xmlport 147636 "SL BC Bank Account Data"
{
    Caption = 'Bank Account data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("Bank Account"; "Bank Account")
            {
                AutoSave = false;
                XmlName = 'BankAccount';
                UseTemporary = true;

                textelement("No.")
                {
                }
                textelement("Name")
                {
                }
                textelement("SearchName")
                {
                }
                textelement("Name2")
                {
                }
                textelement("Address")
                {
                }
                textelement("Address2")
                {
                }
                textelement("City")
                {
                }
                textelement("Contact")
                {
                }
                textelement("PhoneNo.")
                {
                }
                textelement("BankAccountNo.")
                {
                }
                textelement("TransitNo.")
                {
                }
                textelement("BankAccPostingGroup")
                {
                }
                textelement("CountryRegionCode")
                {
                }
                textelement("Amount")
                {
                }
                textelement("Blocked")
                {
                }
                textelement("FaxNo.")
                {
                }
                textelement("ZIPCode")
                {
                }
                textelement("State")
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

                    TempBankAccount."No." := "No.";
                    TempBankAccount.Name := "Name";
                    TempBankAccount."Search Name" := "SearchName";
                    TempBankAccount."Name 2" := "Name2";
                    TempBankAccount.Address := "Address";
                    TempBankAccount."Address 2" := "Address2";
                    TempBankAccount.City := "City";
                    TempBankAccount.Contact := "Contact";
                    TempBankAccount."Phone No." := "PhoneNo.";
                    TempBankAccount."Bank Account No." := "BankAccountNo.";
                    TempBankAccount."Transit No." := "TransitNo.";
                    TempBankAccount."Bank Acc. Posting Group" := "BankAccPostingGroup";
                    TempBankAccount."Country/Region Code" := "CountryRegionCode";
                    Evaluate(TempBankAccount.Amount, "Amount");
                    Evaluate(TempBankAccount.Blocked, "Blocked");
                    TempBankAccount."Fax No." := "FaxNo.";
                    TempBankAccount."Post Code" := "ZIPCode";
                    TempBankAccount.County := "State";
                    TempBankAccount.Insert(false);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        CaptionRow := true;
    end;

    procedure GetExpectedBankAccounts(var NewTempBankAccount: Record "Bank Account" temporary)
    begin
        if TempBankAccount.FindSet() then begin
            repeat
                NewTempBankAccount.Copy(TempBankAccount);
                NewTempBankAccount.Insert();
            until TempBankAccount.Next() = 0;
        end;
    end;

    var
        CaptionRow: Boolean;
        TempBankAccount: Record "Bank Account" temporary;
}