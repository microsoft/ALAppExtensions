// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

xmlport 47200 "SL Import Customer Data"
{
    Caption = 'SL Import Customer Data';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement("SL Customer"; "SL Customer")
            {
                AutoSave = false;
                XmlName = 'SLCustomer';

                fieldelement(CustID; "SL Customer".CustId)
                {
                }
                fieldelement(Addr1; "SL Customer".Addr1)
                {
                }
                fieldelement(Addr2; "SL Customer".Addr2)
                {
                }
                fieldelement(Attn; "SL Customer".Attn)
                {
                }
                fieldelement(BillName; "SL Customer".BillName)
                {
                }
                fieldelement(City; "SL Customer".City)
                {
                }
                fieldelement(Country; "SL Customer".Country)
                {
                }
                fieldelement(CrLmt; "SL Customer".CrLmt)
                {
                }
                fieldelement(DfltShipToId; "SL Customer".DfltShipToId)
                {
                }
                fieldelement(Fax; "SL Customer".Fax)
                {
                }
                fieldelement(Name; "SL Customer".Name)
                {
                }
                fieldelement(Phone; "SL Customer".Phone)
                {
                }
                fieldelement(SlsperId; "SL Customer".SlsperId)
                {
                }
                fieldelement(State; "SL Customer".State)
                {
                }
                fieldelement(Status; "SL Customer".Status)
                {
                }
                fieldelement(TaxID00; "SL Customer".TaxID00)
                {
                }
                fieldelement(Terms; "SL Customer".Terms)
                {
                }
                fieldelement(Territory; "SL Customer".Territory)
                {
                }
                fieldelement(Zip; "SL Customer".Zip)
                {
                }

                trigger OnBeforeInsertRecord()
                var
                    SLCustomer: Record "SL Customer";
                begin
                    SLCustomer.Init();
                    SLCustomer.CustId := "SL Customer".CustId;
                    SLCustomer.Addr1 := "SL Customer".Addr1;
                    SLCustomer.Addr2 := "SL Customer".Addr2;
                    SLCustomer.Attn := "SL Customer".Attn;
                    SLCustomer.BillName := "SL Customer".BillName;
                    SLCustomer.City := "SL Customer".City;
                    SLCustomer.Country := "SL Customer".Country;
                    SLCustomer.CrLmt := "SL Customer".CrLmt;
                    SLCustomer.DfltShipToId := "SL Customer".DfltShipToId;
                    SLCustomer.Fax := "SL Customer".Fax;
                    SLCustomer.Name := "SL Customer".Name;
                    SLCustomer.Phone := "SL Customer".Phone;
                    SLCustomer.SlsperId := "SL Customer".SlsperId;
                    SLCustomer.State := "SL Customer".State;
                    SLCustomer.Status := "SL Customer".Status;
                    SLCustomer.TaxID00 := "SL Customer".TaxID00;
                    SLCustomer.Terms := "SL Customer".Terms;
                    SLCustomer.Territory := "SL Customer".Territory;
                    SLCustomer.Zip := "SL Customer".Zip;

                    SLCustomer.Insert();
                end;
            }
        }
    }

    trigger OnPostXmlPort()
    begin
        Message(SuccessMsg);
    end;

    trigger OnPreXmlPort()
    begin
        SLCustomer.DeleteAll();
    end;

    var
        SLCustomer: Record "SL Customer";
        SuccessMsg: Label 'File has been imported successfully.';
}